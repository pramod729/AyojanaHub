// Helpers to drive the Flutter (CanvasKit + ensureSemantics) web app with
// Playwright via the accessibility DOM. Text is entered with pressSequentially
// into the field's real <input> (the only thing that drives Flutter's text
// controller on canvas); buttons are found by aria-label/text and clicked.
import * as pw from 'playwright';

export async function boot({ url, record, headed } = {}) {
  // Flutter web renders with CanvasKit, which needs WebGL. Headless Chromium has
  // no GPU, so force software WebGL (SwiftShader) — without this the canvas never
  // paints and the accessibility tree stays empty.
  const browser = await pw.chromium.launch({
    headless: !headed,
    slowMo: headed ? 140 : 60,
    args: [
      '--use-gl=angle',
      '--use-angle=swiftshader',
      '--enable-unsafe-swiftshader',
      '--ignore-gpu-blocklist',
      '--enable-webgl',
    ],
  });
  const ctx = await browser.newContext({
    viewport: { width: 1280, height: 900 },
    recordVideo: record ? { dir: 'videos', size: { width: 1280, height: 900 } } : undefined,
  });
  const page = await ctx.newPage();
  page.on('pageerror', (e) => console.log('PAGEERROR', e.message));
  await page.goto(url, { waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(6000);
  // wait until Flutter has booted AND the accessibility tree is populated
  for (let i = 0; i < 25; i++) {
    const ready = await page.evaluate(() =>
      document.querySelectorAll('input[type="email"]').length > 0 ||
      document.querySelectorAll('[aria-label]').length > 2);
    if (ready) break;
    await page.waitForTimeout(1000);
  }
  // The semantic tree builds incrementally — inputs first, buttons/text a beat
  // later (slower under software WebGL). Wait until it's fully built so callers
  // don't tap a half-built screen.
  for (let i = 0; i < 25; i++) {
    const rich = await page.evaluate(() => document.querySelectorAll('flt-semantics').length > 8);
    if (rich) break;
    await page.waitForTimeout(700);
  }
  await page.waitForTimeout(1500);
  return { browser, ctx, page };
}

export const labels = (page) => page.evaluate(() =>
  Array.from(document.querySelectorAll('[aria-label]'))
    .map((e) => e.getAttribute('aria-label')).filter((s) => s && s.trim()));

// center {x,y} of the element best matching `text`. Flutter emits duplicate and
// 0x0 "ghost" semantic nodes for the same label, and giant container nodes whose
// textContent contains the label — so we score every candidate (exact aria/text
// beats a substring match) and, among non-zero-area matches, take the smallest
// (the real leaf widget, never a ghost or a full-screen container).
export const center = (page, text) => page.evaluate((t) => {
  const all = Array.from(document.querySelectorAll('[aria-label],flt-semantics,[role],input,textarea,button'));
  const score = (e) => {
    const aria = ((e.getAttribute && e.getAttribute('aria-label')) || '').trim();
    const txt = (e.textContent || '').trim();
    if (aria === t || txt === t) return 2;
    if (aria.includes(t) || txt.includes(t)) return 1;
    return 0;
  };
  let best = null, bestScore = 0, bestArea = Infinity;
  for (const e of all) {
    const s = score(e);
    if (!s) continue;
    const r = e.getBoundingClientRect();
    const area = r.width * r.height;
    if (area <= 0) continue;
    if (s > bestScore || (s === bestScore && area < bestArea)) {
      best = r; bestScore = s; bestArea = area;
    }
  }
  if (!best) return null;
  return { x: best.x + best.width / 2, y: best.y + best.height / 2 };
}, text);

export const texts = (page) => page.evaluate(() =>
  [...new Set(Array.from(document.querySelectorAll('flt-semantics'))
    .map((e) => (e.textContent || '').trim()).filter((s) => s && s.length < 40))]);

export async function waitFor(page, text, timeout = 15000) {
  const t0 = Date.now();
  while (Date.now() - t0 < timeout) {
    if (await center(page, text)) return true;
    await page.waitForTimeout(300);
  }
  // Report the real semantic text nodes (input aria-labels clear on focus, so
  // labels() alone is misleading).
  throw new Error(`not found: "${text}" — have: ${JSON.stringify((await texts(page)).slice(0, 60))}`);
}

export async function tap(page, text) {
  await waitFor(page, text);
  let c = await center(page, text);
  // If the target sits outside the viewport (common for submit buttons below a
  // long form), scroll it into view first — a click at y>viewport does nothing.
  const vh = (page.viewportSize() && page.viewportSize().height) || 900;
  if (c && (c.y > vh - 60 || c.y < 60)) {
    await page.mouse.move(640, Math.floor(vh / 2));
    await page.mouse.wheel(0, c.y - Math.floor(vh / 2));
    await page.waitForTimeout(700);
    const c2 = await center(page, text);
    if (c2) c = c2;
  }
  await page.mouse.click(c.x, c.y);
  await page.waitForTimeout(900);
}

// Tap a bottom-navigation item. The same label can appear several times (e.g. a
// stats card "Events" AND the nav tab "Events"); the nav bar is the bottom-most
// on-screen match, so pick the largest-y candidate.
export async function tapNav(page, label) {
  await waitFor(page, label);
  const c = await page.evaluate((t) => {
    const els = Array.from(document.querySelectorAll('flt-semantics,[role]'));
    const hits = els
      .map((e) => ({ e, txt: (e.textContent || '').trim() }))
      .filter((o) => o.txt === t)
      .map((o) => { const r = o.e.getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2, area: r.width * r.height }; })
      .filter((o) => o.area > 0);
    if (!hits.length) return null;
    hits.sort((a, b) => b.y - a.y);
    return { x: hits[0].x, y: hits[0].y };
  }, label);
  if (!c) throw new Error(`nav not found: ${label}`);
  await page.mouse.click(c.x, c.y);
  await page.waitForTimeout(1200);
}

// Like tapUntil, but taps the bottom-nav item (tapNav) and verifies the landing.
export async function navUntil(page, navLabel, expectText, tries = 4) {
  for (let i = 0; i < tries; i++) {
    try { await tapNav(page, navLabel); } catch (_) { await page.waitForTimeout(1000); continue; }
    try { await waitFor(page, expectText, 6000); return true; }
    catch (_) { await page.waitForTimeout(1000); }
  }
  await tapNav(page, navLabel);
  await waitFor(page, expectText, 10000);
  return true;
}

// Tap `tapText`, then confirm we landed on the next screen by waiting for
// `expectText`; retry the tap if the click was swallowed by a route animation
// (the common Flutter-web flake). Throws with diagnostics if it never lands.
export async function tapUntil(page, tapText, expectText, tries = 4) {
  for (let i = 0; i < tries; i++) {
    try { await tap(page, tapText); } catch (_) { await page.waitForTimeout(1000); continue; }
    try { await waitFor(page, expectText, 6000); return true; }
    catch (_) { await page.waitForTimeout(1200); }
  }
  await tap(page, tapText);
  await waitFor(page, expectText, 12000); // final attempt surfaces a real error
  return true;
}

// Robust text entry: focus the field, then pressSequentially; verify and
// repair a dropped first keystroke (a known Flutter-web focus race).
async function enter(page, locator, text) {
  await locator.click({ force: true });
  await page.waitForTimeout(450);
  await locator.pressSequentially(text, { delay: 35 });
  await page.waitForTimeout(250);
  let v = null;
  try { v = await locator.inputValue(); } catch (_) { v = null; }
  if (v !== null && v !== text) {
    try { await locator.fill(''); } catch (_) {}
    await locator.click({ force: true });
    await page.waitForTimeout(350);
    await page.keyboard.type(text, { delay: 45 });
    await page.waitForTimeout(200);
  }
}

// Fill a Flutter text field by clicking its semantic node (the label) to focus
// it, then typing via the keyboard. Flutter's proxy <input> elements are not
// "actionable" to Playwright's strict locator API (pressSequentially hangs), but
// they receive real keystrokes once the field is focused by a click.
export async function typeInto(page, label, text) {
  await waitFor(page, label);
  const c = await center(page, label);
  await page.mouse.click(c.x, c.y);
  await page.waitForTimeout(400);
  // clear anything pre-filled, then type
  await page.keyboard.press('Control+A').catch(() => {});
  await page.keyboard.type(text, { delay: 30 });
  await page.waitForTimeout(200);
}

export async function login(page, email, pass) {
  await enter(page, page.locator('input[type="email"]').first(), email);
  await page.waitForTimeout(250);
  await enter(page, page.locator('input[type="password"]').first(), pass);
  await page.waitForTimeout(600);
  await tap(page, 'Sign In');
  await page.waitForTimeout(8000);
}

// Switch user reliably: clear Firebase auth persistence + reload.
export async function logout(page) {
  try { await tap(page, 'Profile'); await page.waitForTimeout(1200); } catch (_) {}
  try { await tap(page, 'Logout'); await page.waitForTimeout(1500); await tap(page, 'Logout'); } catch (_) {}
  await page.waitForTimeout(2000);
  // hard fallback if still logged in
  if (!(await center(page, 'Sign In'))) {
    await page.evaluate(() => { try { indexedDB.deleteDatabase('firebaseLocalStorageDb'); } catch (e) {} });
    await page.reload({ waitUntil: 'load' });
    await page.waitForTimeout(9000);
  }
}

export const shot = (page, name) => page.screenshot({ path: `screenshots/${name}.png` });
