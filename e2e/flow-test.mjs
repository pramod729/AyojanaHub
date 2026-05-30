// Data-layer end-to-end test that drives the EXACT Firestore collections,
// fields, queries and security rules the app uses — as the seeded users.
// Proves the reworked flow works, including the original bug (a proposal
// request must reach the vendor's dashboard query).
//
// Usage: node flow-test.mjs

const API = 'AIzaSyD9lRHEEwRgFxYpRd3UXtDQQqwwkyyXhCg';
const PROJECT = 'ayojana-hub';
const IDP = 'https://identitytoolkit.googleapis.com/v1/accounts';
const FS = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

let pass = 0, fail = 0;
const ok = (c, m) => { if (c) { pass++; console.log('  PASS ✓ ' + m); } else { fail++; console.log('  FAIL ✗ ' + m); } };

// ---- value codec -----------------------------------------------------------
const enc = (v) => v === null ? { nullValue: null }
  : typeof v === 'string' ? { stringValue: v }
  : typeof v === 'boolean' ? { booleanValue: v }
  : typeof v === 'number' ? (Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v })
  : v instanceof Date ? { timestampValue: v.toISOString() }
  : Array.isArray(v) ? { arrayValue: { values: v.map(enc) } }
  : { mapValue: { fields: encF(v) } };
const encF = (o) => Object.fromEntries(Object.entries(o).map(([k, x]) => [k, enc(x)]));
const dec = (val) => {
  if (!val) return null;
  if ('stringValue' in val) return val.stringValue;
  if ('integerValue' in val) return Number(val.integerValue);
  if ('doubleValue' in val) return val.doubleValue;
  if ('booleanValue' in val) return val.booleanValue;
  if ('timestampValue' in val) return val.timestampValue;
  if ('arrayValue' in val) return (val.arrayValue.values || []).map(dec);
  if ('mapValue' in val) return decF(val.mapValue.fields || {});
  if ('nullValue' in val) return null;
  return null;
};
const decF = (f) => Object.fromEntries(Object.entries(f || {}).map(([k, v]) => [k, dec(v)]));

const signIn = async (email) => {
  const j = await (await fetch(`${IDP}:signInWithPassword?key=${API}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'Test@1234', returnSecureToken: true }),
  })).json();
  if (!j.idToken) throw new Error('signIn ' + email + ': ' + JSON.stringify(j.error));
  return { uid: j.localId, tok: j.idToken };
};
const add = async (coll, tok, fields) => {
  const r = await fetch(`${FS}/${coll}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + tok },
    body: JSON.stringify({ fields: encF(fields) }),
  });
  const j = await r.json();
  if (!r.ok) throw new Error(`add ${coll}: ${r.status} ${JSON.stringify(j)}`);
  return j.name.split('/').pop();
};
const patch = async (path, tok, fields) => {
  // updateMask => partial update (preserve other fields), matching SDK .update()
  const mask = Object.keys(fields).map((k) => 'updateMask.fieldPaths=' + encodeURIComponent(k)).join('&');
  const r = await fetch(`${FS}/${path}?${mask}`, {
    method: 'PATCH', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + tok },
    body: JSON.stringify({ fields: encF(fields) }),
  });
  if (!r.ok) throw new Error(`patch ${path}: ${r.status} ${await r.text()}`);
};
const query = async (tok, coll, filters) => {
  const where = filters.length === 1 ? filters[0] : { compositeFilter: { op: 'AND', filters } };
  const r = await fetch(`${FS}:runQuery`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + tok },
    body: JSON.stringify({ structuredQuery: { from: [{ collectionId: coll }], where } }),
  });
  const j = await r.json();
  if (!r.ok) throw new Error(`query ${coll}: ${r.status} ${JSON.stringify(j)}`);
  return (j || []).filter((x) => x.document).map((x) => ({ id: x.document.name.split('/').pop(), ...decF(x.document.fields) }));
};
const eq = (field, value) => ({ fieldFilter: { field: { fieldPath: field }, op: 'EQUAL', value: enc(value) } });

// ---------------------------------------------------------------------------
console.log('AyojanaHub end-to-end data-flow test\n');

const customer = await signIn('customer@ayojanahub.test');
const vendorCat = await signIn('catering@ayojanahub.test');   // Catering vendor
const vendorPhoto = await signIn('photo@ayojanahub.test');    // Photography vendor

console.log('1) Customer creates an event (status awaiting_proposals, needs Catering)');
const eventId = await add('events', customer.tok, {
  userId: customer.uid, userName: 'Sita Customer', eventType: 'Wedding',
  eventName: 'Sita & Ram Wedding', eventDate: new Date(Date.now() + 30 * 864e5),
  location: 'Kathmandu', description: 'Grand wedding, ~300 guests.',
  guestCount: 300, budget: 800000, status: 'awaiting_proposals',
  createdAt: new Date(), proposalCount: 0,
  requiredServices: ['Catering', 'Photography', 'Decoration', 'DJ & Music', 'Venue'],
});
ok(!!eventId, `event created (${eventId})`);

console.log('2) Vendor opportunity discovery (events where status==awaiting_proposals)');
const opps = await query(vendorCat.tok, 'events', [eq('status', 'awaiting_proposals')]);
ok(opps.some((e) => e.id === eventId), 'catering vendor sees the new event as an opportunity');
const catNeeded = opps.find((e) => e.id === eventId)?.requiredServices?.includes('Catering');
ok(catNeeded === true, 'event lists Catering in requiredServices (category match)');

console.log('3) DIRECT request: customer requests a proposal from the Catering vendor');
console.log('   (vendorId stored = vendor AUTH UID — the original bug fix)');
const reqId = await add('proposals', customer.tok, {
  eventId, eventName: 'Sita & Ram Wedding', eventType: 'Wedding',
  userId: customer.uid, vendorId: vendorCat.uid, vendorName: 'Everest Catering Co.',
  vendorCategory: 'Catering', proposedPrice: 0, description: 'Please quote for 300 pax.',
  servicesIncluded: ['Catering'], deliveryTime: 'Event day', status: 'requested',
  createdAt: new Date(), userMessage: 'Please quote for 300 pax.',
});
ok(!!reqId, `proposal request created (${reqId})`);

console.log('4) BUG CHECK: vendor dashboard query (proposals where vendorId == my uid)');
const vendorInbox = await query(vendorCat.tok, 'proposals', [eq('vendorId', vendorCat.uid)]);
ok(vendorInbox.some((p) => p.id === reqId), 'the proposal REACHES the vendor (was the reported bug)');

console.log('5) Isolation: a DIFFERENT vendor must NOT see that request');
const otherInbox = await query(vendorPhoto.tok, 'proposals', [eq('vendorId', vendorPhoto.uid)]);
ok(!otherInbox.some((p) => p.id === reqId), 'photography vendor does NOT see catering vendor\'s request');

console.log('6) Vendor replies with a quote (status -> quoted, price set)');
await patch(`proposals/${reqId}`, vendorCat.tok, { status: 'quoted', proposedPrice: 650000, vendorReply: 'We can do 300 pax premium menu.', respondedAt: new Date() });
// Customer views proposals on their event — rule-safe query is by userId
// (every proposal on the event carries the owner's userId), filtered by event.
const mine = (await query(customer.tok, 'proposals', [eq('userId', customer.uid)])).filter((p) => p.eventId === eventId);
const q = mine.find((p) => p.id === reqId);
ok(q?.status === 'quoted' && q?.proposedPrice === 650000, 'customer sees the quoted price (negotiation)');

console.log('7) Customer accepts -> booking created, proposal accepted');
await patch(`proposals/${reqId}`, customer.tok, { status: 'accepted', respondedAt: new Date() });
const bookingId = await add('bookings', customer.tok, {
  eventId, eventName: 'Sita & Ram Wedding', customerId: customer.uid, customerName: 'Sita Customer',
  vendorId: vendorCat.uid, vendorName: 'Everest Catering Co.', proposalId: reqId,
  vendorCategory: 'Catering', price: 650000, bookingDate: new Date(),
  eventDate: new Date(Date.now() + 30 * 864e5), status: 'confirmed',
  notes: 'Booking created from accepted proposal', createdAt: new Date(),
});
ok(!!bookingId, `booking created (${bookingId})`);

console.log('8) Vendor sees the confirmed booking (bookings where vendorId == my uid)');
const vendorBookings = await query(vendorCat.tok, 'bookings', [eq('vendorId', vendorCat.uid)]);
ok(vendorBookings.some((b) => b.id === bookingId && b.status === 'confirmed'), 'vendor sees confirmed booking');

console.log('9) Customer sees the booking (bookings where customerId == my uid)');
const custBookings = await query(customer.tok, 'bookings', [eq('customerId', customer.uid)]);
ok(custBookings.some((b) => b.id === bookingId), 'customer sees their booking');

// A fresh direct customer->vendor request to exercise vendor actions on.
const freshRequest = () => add('proposals', customer.tok, {
  eventId, eventName: 'Sita & Ram Wedding', eventType: 'Wedding',
  userId: customer.uid, vendorId: vendorCat.uid, vendorName: 'Everest Catering Co.',
  vendorCategory: 'Catering', proposedPrice: 0, description: 'Please quote for 300 pax.',
  servicesIncluded: ['Catering'], deliveryTime: 'Event day', status: 'requested',
  createdAt: new Date(), userMessage: 'Please quote for 300 pax.',
});
const custNotifIds = async () => (await query(customer.tok, 'notifications', [eq('userId', customer.uid)])).map((n) => n.id);

console.log('\n10) Vendor REQUESTS MORE INFO -> customer is notified + status visible');
const reqInfo = await freshRequest();
await patch(`proposals/${reqInfo}`, vendorCat.tok, { status: 'info_requested', vendorReply: 'How many guests need catering, and any dietary needs?', respondedAt: new Date() });
const infoNotif = await add('notifications', vendorCat.tok, {
  userId: customer.uid, type: 'vendor_info_requested', title: 'Vendor needs more info',
  message: 'Everest Catering Co. asked for more details about Sita & Ram Wedding',
  eventId, proposalId: reqInfo, isRead: false, createdAt: new Date(),
});
ok((await custNotifIds()).includes(infoNotif), 'customer receives the "needs more info" notification');
const infoSeen = (await query(customer.tok, 'proposals', [eq('userId', customer.uid)])).find((p) => p.id === reqInfo);
ok(infoSeen?.status === 'info_requested', 'customer sees proposal status: info_requested (with the question)');

console.log('\n11) Vendor REJECTS the offer -> customer is notified');
const reqRej = await freshRequest();
await patch(`proposals/${reqRej}`, vendorCat.tok, { status: 'vendor_rejected', vendorReply: 'Sorry, fully booked that date.', respondedAt: new Date() });
const rejNotif = await add('notifications', vendorCat.tok, {
  userId: customer.uid, type: 'vendor_rejected_offer', title: 'Offer Update',
  message: 'Everest Catering Co. has declined your offer for Sita & Ram Wedding',
  eventId, proposalId: reqRej, isRead: false, createdAt: new Date(),
});
ok((await custNotifIds()).includes(rejNotif), 'customer receives the rejection notification');

console.log('\n12) Vendor ACCEPTS the offer -> customer is notified');
const reqAcc = await freshRequest();
await patch(`proposals/${reqAcc}`, vendorCat.tok, { status: 'vendor_accepted', respondedAt: new Date() });
const accNotif = await add('notifications', vendorCat.tok, {
  userId: customer.uid, type: 'vendor_accepted_offer', title: 'Offer Accepted!',
  message: 'Everest Catering Co. has accepted your offer for Sita & Ram Wedding',
  eventId, proposalId: reqAcc, isRead: false, createdAt: new Date(),
});
ok((await custNotifIds()).includes(accNotif), 'customer receives the acceptance notification');

console.log(`\n=== RESULT: ${pass} passed, ${fail} failed ===`);
process.exit(fail === 0 ? 0 : 1);
