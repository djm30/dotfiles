import assert from 'node:assert/strict';

const origin = process.env.UI_COMPARE_ORIGIN ?? 'http://127.0.0.1:4180';
export default {
  beforeUrl: origin + '/?version=before',
  afterUrl: origin + '/?version=after',

  async run({ step, both }) {
    await step('Enter the same valid name', async () => {
      await both(page => page.getByLabel('Name', { exact: true }).fill('Ada Lovelace'));
      await both(async page => {
        assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), 'Ada Lovelace');
        assert(await page.getByLabel('Name', { exact: true }).evaluate(el => document.hasFocus() && document.activeElement === el));
      });
    });

    await step('Save on both sides', async () => {
      // Check readiness on BOTH sides before dispatching the actual clicks.
      await both(page => page.getByRole('button', { name: 'Save', exact: true }).click({ trial: true }));
      await both(page => page.getByRole('button', { name: 'Save', exact: true }).click());
      await both(page => page.getByRole('status').filter({ hasText: /^Saved$/ }).waitFor());
      await both(async page => assert.equal(await page.getByTestId('saved-count').innerText(), '1'));
    });

    await step('Verify the saved result and reset fields', async () => {
      await both(async page => {
        assert.equal(await page.getByRole('list', { name: 'Saved names' }).innerText(), 'Ada Lovelace');
        assert.equal(await page.getByLabel('Name', { exact: true }).inputValue(), '');
      });
    });
  },
};
