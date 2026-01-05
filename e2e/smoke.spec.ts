import { test, expect } from '@playwright/test';

/**
 * Basic smoke test to verify app loads
 * This is an example - add your own tests for critical user flows
 */
test.describe('Smoke Tests', () => {
  test('should load homepage', async ({ page }) => {
    await page.goto('/');

    // Verify app loads
    await expect(page.locator('text=Sensand Golden Path')).toBeVisible();
  });
});
