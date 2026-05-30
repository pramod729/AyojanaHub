// Role-by-role UI walkthrough, driven like a human and recorded to one video.
// Logs in as every seeded role and tours each role's major screens, taking a
// screenshot of each. Best-effort per screen: a flaky transition is logged and
// skipped so the recording always completes and documents real coverage.
//
//   python3 -m http.server 8080 --directory ../build/web
//   URL=http://localhost:8080 node walkthrough.mjs
import { boot, login, logout, tap, tapUntil, navUntil, waitFor, texts, shot } from './lib.mjs';

const url = process.env.URL || 'http://localhost:8080';
const headed = !!process.env.HEADED;
const { browser, ctx, page } = await boot({ url, record: true, headed });

const log = (m) => console.log(m);
const settle = (ms = 1600) => page.waitForTimeout(ms);
let n = 0;
const snap = async (name) => { n++; await shot(page, `w${String(n).padStart(2, '0')}-${name}`); };

// Visit a screen: tap `navLabel`, confirm `expect` appeared, screenshot, then go
// back. Never throws — logs and returns false on failure.
async function visit(navLabel, expect, name, { back = true, nav = false } = {}) {
  try {
    if (nav) await navUntil(page, navLabel, expect);
    else if (expect) await tapUntil(page, navLabel, expect);
    else { await tap(page, navLabel); }
    await settle();
    await snap(name);
    log(`  ✓ ${name}`);
    if (back) { try { await tap(page, 'Back'); await settle(900); } catch (_) {} }
    return true;
  } catch (e) {
    log(`  ✗ ${name}: ${e.message.split('—')[0].trim()}`);
    try { await tap(page, 'Back'); await settle(700); } catch (_) {}
    return false;
  }
}

try {
  // ============ CUSTOMER ============
  log('\n=== CUSTOMER ===');
  await login(page, 'customer@ayojanahub.test', 'Test@1234');
  await waitFor(page, 'Create Event');
  await settle();
  await snap('customer-home');
  await visit('Create Event', 'Event Name', 'customer-create-event');
  await visit('Find Vendors', 'Vendors', 'customer-vendors');
  await visit('Messages', 'Messages', 'customer-messages');
  await visit('Ask Ayojana AI', 'Ayojana', 'customer-ai-assistant');
  await visit('Events', 'My Events', 'customer-my-events', { back: false, nav: true });
  await visit('Bookings', 'My Bookings', 'customer-bookings', { back: false, nav: true });
  await visit('Profile', 'Profile', 'customer-profile', { back: false, nav: true });
  await visit('Notifications', 'Notifications', 'customer-notifications');
  await logout(page);

  // ============ VENDOR (catering) ============
  log('\n=== VENDOR: Catering ===');
  await login(page, 'catering@ayojanahub.test', 'Test@1234');
  await settle(2200);
  await snap('vendor-dashboard');
  await visit('Event Opportunities', 'Opportunities', 'vendor-opportunities');
  await visit('My Proposals', 'Proposals', 'vendor-proposals');
  await visit('View Bookings', 'Bookings', 'vendor-bookings');
  await visit('Reviews & Ratings', 'Reviews', 'vendor-reviews');
  await visit('Edit Business Profile', 'Profile', 'vendor-edit-profile');
  await logout(page);

  // ============ VENDOR (photography) ============
  log('\n=== VENDOR: Photography ===');
  await login(page, 'photo@ayojanahub.test', 'Test@1234');
  await settle(2200);
  await snap('vendor2-dashboard');
  await visit('Event Opportunities', 'Opportunities', 'vendor2-opportunities');
  await visit('My Proposals', 'Proposals', 'vendor2-proposals');
  await logout(page);

  // ============ ADMIN ============
  log('\n=== ADMIN ===');
  await login(page, 'admin@ayojanahub.test', 'Test@1234');
  await settle(2200);
  await snap('admin-home');
  // admin analytics may be reachable from home or profile
  await visit('Analytics', 'Analytics', 'admin-analytics');
  await visit('Profile', 'Profile', 'admin-profile', { back: false, nav: true });
  await logout(page);

  log('\nWALKTHROUGH_OK');
} catch (e) {
  log('\nWALKTHROUGH_ERROR: ' + e.message);
  await snap('zz-error');
} finally {
  await page.waitForTimeout(1500);
  await ctx.close();
  await browser.close();
}
