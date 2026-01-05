# Common Tasks Playbook

## Starting a New Project

```bash
# Clone template
git clone ~/Repos/sensand-golden-webapp ~/Repos/new-project
cd ~/Repos/new-project

# Remove template git history
rm -rf .git && git init

# Update project name in package.json
# Change "name" field from "sensand-golden-webapp" to "new-project"

# Install dependencies
pnpm install

# Validate setup
pnpm doctor

# Start developing
pnpm dev
```

---

## How to Add a New Feature

### 1. Generate Scaffold

```bash
pnpm gen:feature feature-name
```

This creates:
- `src/features/feature-name/components/` - React components
- `src/features/feature-name/hooks/` - Feature-specific hooks
- `src/features/feature-name/routes/` - Route definitions

### 2. Add Domain Logic (if needed)

```bash
pnpm gen:domain feature-name
```

This creates:
- `src/domain/feature-name/feature-name.types.ts` - TypeScript types
- `src/domain/feature-name/feature-name.rules.ts` - Business rules
- `src/domain/feature-name/feature-name.queries.ts` - React Query hooks
- `src/adapters/feature-name-adapter.ts` - API normalization

### 3. Implement

**Add Types** (`src/domain/feature-name/feature-name.types.ts`):
```typescript
export interface FeatureName {
  id: string;
  // Add fields
}
```

**Add Business Rules** (`src/domain/feature-name/feature-name.rules.ts`):
```typescript
export function validateFeatureName(data: unknown): FeatureName {
  // Validation logic
}
```

**Add API Adapter** (`src/adapters/feature-name-adapter.ts`):
```typescript
export class FeatureNameAdapter {
  static toFrontend(backend: any): FeatureName {
    return {
      id: backend.id,
      // Map fields
    };
  }

  static async fetchAll(): Promise<FeatureName[]> {
    const { body } = await apiClient.featureName.getAll();
    return body.map(this.toFrontend);
  }
}
```

**Add React Query Hook** (`src/domain/feature-name/feature-name.queries.ts`):
```typescript
import { useQuery } from '@tanstack/react-query';
import { FeatureNameAdapter } from '@adapters/feature-name-adapter';

export function useFeatureNames() {
  return useQuery({
    queryKey: ['feature-names'],
    queryFn: () => FeatureNameAdapter.fetchAll(),
  });
}
```

**Add Component** (`src/features/feature-name/components/FeatureNameList.tsx`):
```typescript
import { useFeatureNames } from '@domain/feature-name/feature-name.queries';

export function FeatureNameList() {
  const { data, isLoading } = useFeatureNames();

  if (isLoading) return <div>Loading...</div>;

  return (
    <div>
      {data?.map((item) => (
        <div key={item.id}>{item.id}</div>
      ))}
    </div>
  );
}
```

### 4. Test

```bash
pnpm check:all
```

---

## How to Add an API Endpoint

### 1. Update API Contract

**Edit `src/data/client.ts`**:
```typescript
import { initContract } from '@ts-rest/core';

const c = initContract();

export const contract = c.router({
  entities: {
    getAll: {
      method: 'GET',
      path: '/entities',
      responses: {
        200: EntitySchema,
      },
    },
  },
});
```

### 2. Create Adapter

**Create `src/adapters/entity-adapter.ts`**:
```typescript
import { Entity } from '@domain/entities/entities.types';
import { apiClient } from '@/data/client';

export class EntityAdapter {
  static toFrontend(backend: any): Entity {
    return {
      id: backend.id,
      name: backend.name,
    };
  }

  static async fetchAll(): Promise<Entity[]> {
    const { body } = await apiClient.entities.getAll();
    return body.map(this.toFrontend);
  }
}
```

### 3. Add React Query Hook

**Create `src/domain/entities/entities.queries.ts`**:
```typescript
import { useQuery } from '@tanstack/react-query';
import { EntityAdapter } from '@adapters/entity-adapter';

export function useEntities() {
  return useQuery({
    queryKey: ['entities'],
    queryFn: () => EntityAdapter.fetchAll(),
  });
}
```

### 4. Use in Component

```typescript
import { useEntities } from '@domain/entities/entities.queries';

export function EntitiesList() {
  const { data } = useEntities();
  // Use data
}
```

---

## How to Add a Smoke Test

### 1. Create Test File

**Create `e2e/<flow-name>.spec.ts`**:
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Flow', () => {
  test('should complete happy path', async ({ page }) => {
    // Navigate
    await page.goto('/feature');

    // Action
    await page.click('[data-testid="action-button"]');
    await page.fill('[name="field"]', 'value');
    await page.click('[data-testid="submit"]');

    // Assert
    await expect(page.locator('text=Success')).toBeVisible();
  });
});
```

### 2. Use Stable Selectors

Always use `data-testid` for test selectors:
```tsx
<button data-testid="submit-button">Submit</button>
```

### 3. Test Happy Path Only

Smoke tests verify critical flows work. Don't test edge cases in E2E.

### 4. Run Tests

```bash
pnpm test:e2e
```

---

## How to Add a Shared Component

### 1. Wrap Radix Component Once

**Create `src/shared/components/Button.tsx`**:
```typescript
import { Button as RadixButton } from '@radix-ui/themes';
import { ComponentProps } from 'react';

export function Button(props: ComponentProps<typeof RadixButton>) {
  return <RadixButton {...props} />;
}
```

### 2. Use in Features

```typescript
import { Button } from '@shared/components/Button';

export function MyFeature() {
  return <Button>Click me</Button>;
}
```

---

## How to Add UI State (Zustand)

### 1. Create Store

**Create `src/shared/stores/sidebar-store.ts`**:
```typescript
import { create } from 'zustand';

interface SidebarStore {
  isOpen: boolean;
  toggle: () => void;
}

export const useSidebarStore = create<SidebarStore>((set) => ({
  isOpen: false,
  toggle: () => set((state) => ({ isOpen: !state.isOpen })),
}));
```

### 2. Use in Component

```typescript
import { useSidebarStore } from '@shared/stores/sidebar-store';

export function Sidebar() {
  const { isOpen, toggle } = useSidebarStore();

  return (
    <aside className={isOpen ? 'open' : 'closed'}>
      <button onClick={toggle}>Toggle</button>
    </aside>
  );
}
```

**IMPORTANT**: Zustand is for UI state ONLY. Never put server data in Zustand.

---

## How to Run Quality Gates

### Before Every Commit

```bash
pnpm check:all
```

This runs:
- TypeScript validation
- ESLint (including boundaries)
- Madge (circular dependency detection)

### Individual Checks

```bash
pnpm check:types     # TypeScript only
pnpm check:lint      # ESLint only
pnpm check:circular  # Circular deps only
pnpm check:budget    # Change budget (CI only)
```

---

## How to Debug a Failing CI Build

### 1. Run Doctor

```bash
pnpm doctor
```

This validates:
- Node/pnpm installed
- Dependencies installed
- TypeScript valid
- No circular dependencies
- Linting passes

### 2. Run Check All Locally

```bash
pnpm check:all
```

Fix any errors shown.

### 3. Check Change Budget

If you changed >20 files or >500 lines:
- Split into multiple PRs
- OR add `refactor:approved` label (requires approval)

### 4. Re-push

```bash
git push
```

---

## Troubleshooting

### "Cannot find module '@domain/...'"

Path aliases not working. Check:
1. `tsconfig.json` has `paths` configured
2. `vite.config.ts` has `resolve.alias` configured
3. Restart dev server: `pnpm dev`

### "Circular dependency detected"

Run `pnpm check:circular` to see the cycle. Fix by:
1. Extracting shared logic to `src/shared/`
2. Lifting types to parent module
3. Inverting dependency via dependency injection

### "Domain layer cannot import React"

ESLint boundary violation. Domain must be pure TypeScript.

Move React-specific code to:
- `src/features/` for UI components
- `src/domain/*/queries.ts` for React Query hooks (allowed exception)

### "Features cannot import other features"

Extract shared logic to `src/shared/components/` or `src/shared/hooks/`.

---

## Reference

### Folder Contract

```
domain/        → Pure TS, no React
  ↓
adapters/      → API normalization
  ↓
features/      → React components
  ↓
shared/        → Reusable UI (no feature imports)
```

### Change Budget

- Max 20 files per PR
- Max 500 lines per PR
- Exceeding requires `refactor:approved` label

### Quality Gates (All Must Pass)

1. `pnpm check:types` - TypeScript
2. `pnpm check:lint` - ESLint boundaries
3. `pnpm check:circular` - Madge (0 cycles)
4. `pnpm check:budget` - Change budget
5. `pnpm test` - Vitest
6. `pnpm test:e2e` - Playwright smoke
