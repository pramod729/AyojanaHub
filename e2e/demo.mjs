// Full end-to-end demo of AyojanaHub, driven like a human and recorded to video.
// Story: a customer creates an event and requests proposals -> a catering vendor
// sees the opportunity and submits a priced proposal -> the customer reviews and
// accepts it -> a confirmed booking appears for both sides.
//
//   python3 -m http.server 8080 --directory ../build/web   # serve the web build
//   URL=http://localhost:8080 node demo.mjs                # run + record (headless)
//   HEADED=1 URL=http://localhost:8080 node demo.mjs       # watch it live
import { boot, login, logout, typeInto, tap, tapUntil, navUntil, waitFor, center, texts, shot } from './lib.mjs';

const url = process.env.URL || 'http://localhost:8080';
const headed = !!process.env.HEADED;
// Unique per run so the vendor's proposal and the customer's accept always
// target the SAME event (no collision with events left by earlier runs).
const EVENT = `Aarav & Priya Wedding ${Date.now().toString().slice(-5)}`;
const { browser, ctx, page } = await boot({ url, record: true, headed });
const step = (m) => console.log('\n=== ' + m + ' ===');
const dump = async (t) => console.log(t + ' :: ' + JSON.stringify((await texts(page)).slice(0, 30)));
const settle = (ms = 1800) => page.waitForTimeout(ms);
// run a phase but never abort the recording on a single flaky transition
const phase = async (name, fn) => { try { await fn(); } catch (e) { console.log(`PHASE_WARN [${name}]: ${e.message}`); await shot(page, 'warn-' + name); } };

try {
  // ---------------- CUSTOMER: create an event ----------------
  await phase('customer-login', async () => {
    step('CUSTOMER LOGIN');
    await login(page, 'customer@ayojanahub.test', 'Test@1234');
    await waitFor(page, 'Create Event');
    await settle();
    await shot(page, 'd01-customer-home');
  });

  await phase('create-event', async () => {
    step('CREATE EVENT');
    await tapUntil(page, 'Create Event', 'Event Name');
    await settle();
    await shot(page, 'd02-create-form');
    await tap(page, 'Wedding');                 // event type
    await typeInto(page, 'Event Name', EVENT);
    await typeInto(page, 'Location', 'Kathmandu');
    await typeInto(page, 'Expected Guests', '250');
    await typeInto(page, 'Budget (NPR)', '700000');
    await typeInto(page, 'Description', 'Need catering, photography and decoration for a 250-guest wedding.');
    // required services -> ensures matching vendors get the opportunity
    for (const s of ['Catering', 'Photography', 'Decoration']) { try { await tap(page, s); } catch (_) {} }
    await shot(page, 'd03-event-form-filled');
    await tap(page, 'Create Event & Get Proposals');
    await page.waitForTimeout(5000);
    await shot(page, 'd04-event-created');
  });

  await phase('customer-logout', async () => {
    step('CUSTOMER LOGOUT');
    await logout(page);
    await shot(page, 'd05-logged-out');
  });

  // ---------------- VENDOR: respond with a proposal ----------------
  await phase('vendor-login', async () => {
    step('VENDOR LOGIN (catering)');
    await login(page, 'catering@ayojanahub.test', 'Test@1234');
    await settle(2500);
    await dump('VENDOR HOME');
    await shot(page, 'd06-vendor-dashboard');
  });

  await phase('vendor-opportunities', async () => {
    step('OPEN EVENT OPPORTUNITIES');
    await tapUntil(page, 'Event Opportunities', 'Submit Proposal');
    await settle(2500);
    await dump('OPPORTUNITIES');
    await shot(page, 'd07-opportunities');
  });

  await phase('vendor-proposal', async () => {
    step('SUBMIT A PROPOSAL');
    await tapUntil(page, 'Submit Proposal', 'Proposed Price (NPR)');
    await settle();
    await shot(page, 'd08-proposal-form');
    await typeInto(page, 'Proposed Price (NPR)', '650000');
    await typeInto(page, 'Delivery/Service Time', 'Wedding day, full service');
    await typeInto(page, 'Proposal Description', 'Premium 250-pax wedding catering with live counters and desserts.');
    try { await typeInto(page, 'e.g., Professional photography', 'Full catering team, live counters'); } catch (_) {}
    await shot(page, 'd09-proposal-filled');
    await tap(page, 'Submit Proposal');         // submit button
    await page.waitForTimeout(4000);
    await shot(page, 'd10-proposal-submitted');
  });

  await phase('vendor-my-proposals', async () => {
    step('VIEW MY PROPOSALS (vendor)');
    // after submitting we're back on Opportunities; return to the dashboard first
    for (let i = 0; i < 3; i++) {
      if (await center(page, 'My Proposals')) break;
      try { await tap(page, 'Back'); await settle(900); } catch (_) {}
    }
    await tapUntil(page, 'My Proposals', 'Proposals');
    await settle(2500);
    await shot(page, 'd11-vendor-proposals');
  });

  await phase('vendor-logout', async () => {
    step('VENDOR LOGOUT');
    await logout(page);
  });

  // ---------------- CUSTOMER: accept the proposal ----------------
  await phase('customer-login-2', async () => {
    step('CUSTOMER LOGIN (again)');
    await login(page, 'customer@ayojanahub.test', 'Test@1234');
    await waitFor(page, 'Create Event');
    await settle();
  });

  await phase('open-my-events', async () => {
    step('OPEN MY EVENTS');
    await tapUntil(page, 'View My Events', EVENT);
    await settle(2000);
    await dump('MY EVENTS');
    await shot(page, 'd12-my-events');
  });

  await phase('open-proposals', async () => {
    step('OPEN THE EVENT + ITS PROPOSALS');
    await tap(page, EVENT);
    await settle(2200);
    await dump('EVENT DETAIL');
    await shot(page, 'd13-event-detail');
    await tapUntil(page, 'View Proposals', 'Accept Proposal');
    await settle(1500);
    await dump('PROPOSALS');
    await shot(page, 'd14-proposals');
  });

  await phase('accept-proposal', async () => {
    step('ACCEPT THE PROPOSAL');
    await tap(page, 'Accept Proposal');
    await settle(1500);
    try { await tap(page, 'Accept'); } catch (_) {}   // confirm dialog
    await page.waitForTimeout(4000);
    await shot(page, 'd15-accepted');
  });

  await phase('view-bookings', async () => {
    step('VIEW MY BOOKINGS');
    // Pushed proposal screens have no bottom nav; reload returns to home (the
    // customer stays signed in via Firebase persistence), then open Bookings.
    await page.reload({ waitUntil: 'load' });
    await page.waitForTimeout(9000);
    await waitFor(page, 'Create Event');
    await navUntil(page, 'Bookings', 'My Bookings');
    await settle(2000);
    await dump('BOOKINGS');
    await shot(page, 'd16-bookings');
  });

  console.log('\nDEMO_OK');
} catch (e) {
  console.log('\nDEMO_ERROR: ' + e.message);
  await shot(page, 'dZZ-error');
} finally {
  await page.waitForTimeout(1500);
  await ctx.close(); // finalize the recorded video
  await browser.close();
}
