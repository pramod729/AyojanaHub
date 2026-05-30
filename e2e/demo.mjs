// Full end-to-end demo of AyojanaHub, driven like a human and recorded.
// Customer creates an event -> vendor sees the opportunity and submits a
// proposal with a price -> customer reviews and accepts -> booking is created.
// Run headed so it is visible:  HEADED=1 node demo.mjs
import { boot, login, logout, typeInto, tap, waitFor, labels, shot } from './lib.mjs';

const url = process.env.URL || 'http://localhost:8080';
const headed = !!process.env.HEADED;
const EVENT = 'Aarav & Priya Wedding';
const { browser, ctx, page } = await boot({ url, record: true, headed });
const step = (m) => console.log('\n=== ' + m + ' ===');
const dump = async (t) => console.log(t + ' :: ' + JSON.stringify(await labels(page)).slice(0, 600));

try {
  // ---------------- CUSTOMER: create an event ----------------
  step('CUSTOMER LOGIN');
  await login(page, 'customer@ayojanahub.test', 'Test@1234');
  await waitFor(page, 'Create Event');
  await shot(page, 'd01-customer-home');

  step('CREATE EVENT');
  await tap(page, 'Create Event');
  await waitFor(page, 'Event Name');
  await tap(page, 'Wedding');
  await typeInto(page, 'Event Name', EVENT);
  await typeInto(page, 'Location', 'Kathmandu');
  await typeInto(page, 'Expected Guests', '250');
  await typeInto(page, 'Budget (NPR)', '700000');
  await typeInto(page, 'Description', 'Need catering, photography and decoration for a 250-guest wedding.');
  await shot(page, 'd02-event-form');
  await tap(page, 'Create Event & Get Proposals');
  await page.waitForTimeout(5000);
  await shot(page, 'd03-event-created');

  step('CUSTOMER LOGOUT');
  await logout(page);
  await shot(page, 'd04-logged-out');

  // ---------------- VENDOR: respond with a proposal ----------------
  step('VENDOR LOGIN (catering)');
  await login(page, 'catering@ayojanahub.test', 'Test@1234');
  await page.waitForTimeout(2000);
  await shot(page, 'd05-vendor-dashboard');

  step('OPEN EVENT OPPORTUNITIES');
  await tap(page, 'Event Opportunities');
  await page.waitForTimeout(2500);
  await dump('OPPORTUNITIES');
  await shot(page, 'd06-opportunities');

  step('SUBMIT PROPOSAL FOR THE EVENT');
  await tap(page, 'Submit Proposal'); // on the opportunity card
  await page.waitForTimeout(2500);
  await dump('PROPOSAL FORM');
  await shot(page, 'd07-proposal-form');
  await typeInto(page, 'Proposed Price (NPR)', '650000');
  await typeInto(page, 'Delivery/Service Time', 'Wedding day, full service');
  await typeInto(page, 'Proposal Description', 'Premium 250-pax wedding catering with live counters and desserts.');
  // first "services included" field
  await typeInto(page, 'e.g., Professional photography', 'Full catering team');
  await shot(page, 'd08-proposal-filled');
  await tap(page, 'Submit Proposal'); // submit button
  await page.waitForTimeout(4000);
  await shot(page, 'd09-proposal-submitted');

  step('VIEW MY PROPOSALS (vendor)');
  try { await tap(page, 'My Proposals'); await page.waitForTimeout(2500); await shot(page, 'd10-vendor-proposals'); } catch (_) {}

  step('VENDOR LOGOUT');
  await logout(page);

  // ---------------- CUSTOMER: accept the proposal ----------------
  step('CUSTOMER LOGIN (again)');
  await login(page, 'customer@ayojanahub.test', 'Test@1234');
  await waitFor(page, 'Create Event');

  step('OPEN MY EVENTS');
  await tap(page, 'Events');
  await page.waitForTimeout(2500);
  await dump('MY EVENTS');
  await shot(page, 'd11-my-events');

  step('OPEN THE EVENT + ITS PROPOSALS');
  await tap(page, EVENT);
  await page.waitForTimeout(2500);
  await dump('EVENT DETAIL');
  await shot(page, 'd12-event-detail');
  // some builds route via a "View Proposals" button
  try { await tap(page, 'View Proposals'); await page.waitForTimeout(2000); } catch (_) {}
  await dump('PROPOSALS');
  await shot(page, 'd13-proposals');

  step('ACCEPT THE PROPOSAL');
  await tap(page, 'Accept Proposal');
  await page.waitForTimeout(1500);
  try { await tap(page, 'Accept'); } catch (_) {} // confirm dialog
  await page.waitForTimeout(4000);
  await shot(page, 'd14-accepted');

  step('VIEW MY BOOKINGS');
  try { await tap(page, 'Bookings'); await page.waitForTimeout(2500); await shot(page, 'd15-bookings'); } catch (_) {}

  console.log('\nDEMO_OK');
} catch (e) {
  console.log('\nDEMO_ERROR: ' + e.message);
  await shot(page, 'dZZ-error');
} finally {
  await page.waitForTimeout(1500);
  await ctx.close(); // finalize video
  await browser.close();
}
