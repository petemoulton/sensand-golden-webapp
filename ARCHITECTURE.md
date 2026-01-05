# Non-Negotiable Architecture Rules

## Rule 0: Golden Path Only

**All new projects MUST start from this template.**

```bash
git clone ~/Repos/sensand-golden-webapp ~/Repos/new-project
cd ~/Repos/new-project
rm -rf .git && git init
pnpm install
pnpm doctor
```

**No exceptions. Snowflake repos are forbidden.**

---

## Domain Rules

1. `src/domain/**` is pure TypeScript. **No React imports**.
2. `src/shared/**` never imports `src/features/**`.
3. API calls and shape mapping live in `src/adapters/**`.
4. UI features live in `src/features/<feature>/**` only.

## State Rules

5. **Server state** lives in React Query only.
6. **UI state** lives in Zustand (sidebar, theme, etc.). No server data.

## Quality Rules

7. **No circular dependencies**. CI blocks them.
8. No API calls inside components. Use domain queries/hooks.
9. All Radix components wrapped once in `src/shared/components/**`.
10. Refactors require `refactor:approved` label on PR.

---

## CI Gates (All Must Pass)

```bash
pnpm check:types    # TypeScript validation
pnpm check:lint     # ESLint (boundaries)
pnpm check:circular # Madge (0 cycles)
pnpm check:budget   # Max 20 files, 500 LOC
pnpm test           # Vitest
pnpm test:e2e       # Playwright smoke
```

---

## Folder Contract

```
domain/ (pure TS, no React)
  ↓
adapters/ (API normalization)
  ↓
features/ (React components)
  ↓
shared/ (reusable UI, no feature imports)
```

**One-way dependency flow. Never import upwards.**

---

## Explicit Non-Goals (Phase 1)

This system is **NOT** trying to:
- Enforce perfect architecture across legacy code
- Eliminate all technical debt
- Maximize test coverage
- Support multiple frontend stacks
- Auto-refactor existing code

Those are Phase 2+ concerns.

**Phase 1 exists to create a safe, repeatable golden path for new work only.**

---

## Change Budget

**Max 20 files, 500 lines changed per PR.**

Exceeding budget requires `refactor:approved` label.

This prevents accidental full-repo rewrites and makes debt visible.

---

## Getting Started

```bash
pnpm doctor    # Always start here
pnpm help      # Show START_HERE guide
```

See `docs/START_HERE.md` for onboarding.
