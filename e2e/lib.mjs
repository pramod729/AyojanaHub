// Helpers to drive the Flutter (CanvasKit + ensureSemantics) web app with
// Playwright via the accessibility DOM. Text is entered with pressSequentially
// into the field's real <input> (the only thing that drives Flutter's text
// controller on canvas); buttons are found by aria-label/text and clicked.
import * as pw from 'playwright';

export async function boot({ url, record, headed } = {}) {
  const browser = await pw.chromium.launch({ headless: !headed, slowMo: headed ? 140 : 0 });
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
  await page.waitForTimeout(1500);
  return { browser, ctx, page };
}

export const labels = (page) => page.evaluate(() =>
  Array.from(document.querySelectorAll('[aria-label]'))
    .map((e) => e.getAttribute('aria-label')).filter((s) => s && s.trim()));

// center {x,y} of first element whose aria-label/text equals or contains `text`
export const center = (page, text) => page.evaluate((t) => {
  const all = Array.from(document.querySelectorAll('[aria-label],flt-semantics,[role],input,textarea,button'));
  const pick = all.find((e) => ((e.getAttribute && e.getAttribute('aria-label')) || '').trim() === t)
    || all.find((e) => (e.textContent || '').trim() === t)
    || all.find((e) => ((e.getAttribute && e.getAttribute('aria-label')) || '').includes(t))
    || all.find((e) => (e.textContent || '').includes(t));
  if (!pick) return null;
  const r = pick.getBoundingClientRect();
  if (r.width === 0 && r.height === 0) return null;
  return { x: r.x + r.width / 2, y: r.y + r.height / 2 };
});

export async function waitFor(page, text, timeout = 15000) {
  const t0 = Date.now();
  while (Date.now() - t0 < timeout) {
    if (await center(page, text)) return true;
    await page.waitForTimeout(300);
  }
  throw new Error(`not found: "${text}" — have: ${JSON.stringify((await labels(page)).slice(0, 60))}`);
}

export async function tap(page, text) {
  await waitFor(page, text);
  const c = await center(page, text);
  await page.mouse.click(c.x, c.y);
  await page.waitForTimeout(900);
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

export async function typeInto(page, label, text) {
  const inp = page.locator(`input[aria-label="${label}"], textarea[aria-label="${label}"]`).first();
  if (await inp.count()) { await enter(page, inp, text); return; }
  // fallback: focus the semantic node, then type
  await waitFor(page, label);
  const c = await center(page, label);
  await page.mouse.click(c.x, c.y); await page.waitForTimeout(350);
  await page.keyboard.type(text, { delay: 40 });
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
