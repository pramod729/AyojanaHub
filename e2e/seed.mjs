// Seeds Firebase Auth users + Firestore profile docs for AyojanaHub test data.
// Uses the public Web API key for Auth sign-up and each user's own ID token to
// write their Firestore docs (so it respects the production security rules).
// Re-runnable: existing emails are signed in instead of re-created.
//
// Usage: node seed.mjs

const API_KEY = 'AIzaSyD9lRHEEwRgFxYpRd3UXtDQQqwwkyyXhCg';
const PROJECT = 'ayojana-hub';
const PASSWORD = 'Test@1234';

const IDENTITY = 'https://identitytoolkit.googleapis.com/v1/accounts';
const FS = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

const nowIso = new Date().toISOString();

// ---- Firestore REST value encoding -----------------------------------------
function enc(v) {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') return Number.isInteger(v)
    ? { integerValue: String(v) }
    : { doubleValue: v };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(enc) } };
  if (typeof v === 'object') return { mapValue: { fields: encFields(v) } };
  return { stringValue: String(v) };
}
function encFields(obj) {
  const f = {};
  for (const [k, val] of Object.entries(obj)) f[k] = enc(val);
  return f;
}

async function signUpOrIn(email) {
  let r = await fetch(`${IDENTITY}:signUp?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: PASSWORD, returnSecureToken: true }),
  });
  let j = await r.json();
  if (j.error && j.error.message && j.error.message.includes('EMAIL_EXISTS')) {
    r = await fetch(`${IDENTITY}:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password: PASSWORD, returnSecureToken: true }),
    });
    j = await r.json();
  }
  if (!j.idToken) throw new Error('auth failed for ' + email + ': ' + JSON.stringify(j));
  return { uid: j.localId, idToken: j.idToken };
}

async function writeDoc(path, idToken, fields) {
  const r = await fetch(`${FS}/${path}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + idToken },
    body: JSON.stringify({ fields: encFields(fields) }),
  });
  if (!r.ok) {
    const t = await r.text();
    throw new Error(`write ${path} failed: ${r.status} ${t}`);
  }
  return r.json();
}

const accounts = [
  { key: 'admin', email: 'admin@ayojanahub.test', name: 'Ayojana Admin', phone: '9800000000', role: 'admin' },
  { key: 'customer', email: 'customer@ayojanahub.test', name: 'Sita Customer', phone: '9811111111', role: 'customer' },
  {
    key: 'vendorCatering', email: 'catering@ayojanahub.test', name: 'Everest Catering', phone: '9822222222',
    role: 'vendor', businessName: 'Everest Catering Co.', category: 'Catering',
    description: 'Authentic Nepali and continental catering for weddings and corporate events.',
    location: 'Kathmandu', services: ['Traditional Nepali', 'Continental', 'Desserts', 'Beverages'],
  },
  {
    key: 'vendorPhoto', email: 'photo@ayojanahub.test', name: 'Himalaya Photography', phone: '9833333333',
    role: 'vendor', businessName: 'Himalaya Photography', category: 'Photography',
    description: 'Cinematic wedding and event photography with drone coverage.',
    location: 'Lalitpur', services: ['Wedding Photography', 'Candid Photography', 'Drone Photography'],
  },
  {
    key: 'vendorDecor', email: 'decor@ayojanahub.test', name: 'Kathmandu Decorators', phone: '9844444444',
    role: 'vendor', businessName: 'Kathmandu Decor Studio', category: 'Decoration',
    description: 'Elegant stage, floral and thematic decoration for every occasion.',
    location: 'Bhaktapur', services: ['Stage Decoration', 'Flower Arrangements', 'Thematic Decor'],
  },
];

const results = {};
for (const a of accounts) {
  const { uid, idToken } = await signUpOrIn(a.email);
  results[a.key] = { uid, email: a.email, password: PASSWORD, role: a.role };

  const userDoc = {
    uid, name: a.name, email: a.email, phone: a.phone,
    displayName: a.name, photoURL: '', role: a.role,
    createdAt: new Date(), updatedAt: new Date(),
  };
  if (a.role === 'vendor') {
    userDoc.businessName = a.businessName;
    userDoc.vendorCategory = a.category;
    userDoc.vendorDescription = a.description;
    userDoc.vendorLocation = a.location;
    userDoc.vendorServices = a.services;
  }
  await writeDoc(`users/${uid}`, idToken, userDoc);

  if (a.role === 'vendor') {
    await writeDoc(`vendors/${uid}`, idToken, {
      userId: uid, name: a.businessName, category: a.category,
      description: a.description, phone: a.phone, email: a.email,
      location: a.location, services: a.services,
      rating: 5.0, reviewCount: 0, profileImage: null, portfolioImages: [],
      createdAt: new Date(), updatedAt: new Date(),
    });
  }
  console.log(`seeded ${a.role.padEnd(8)} ${a.email}  uid=${uid}`);
}

console.log('\n=== SEED COMPLETE ===');
console.log(JSON.stringify(results, null, 2));
