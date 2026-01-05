# Sensand Golden Path - Quick Start

## The One Command You Need

```bash
pnpm doctor              # Validates setup, prints what's wrong
```

**If `pnpm doctor` passes, you're ready to develop.**
**If it fails, it tells you exactly what to fix.**

---

## 5 Essential Commands

```bash
# 1. Health check (run this first, always)
pnpm doctor

# 2. Development
pnpm dev

# 3. Generate code
pnpm gen:feature user-profile   # Creates feature scaffold
pnpm gen:domain tasks            # Creates domain module

# 4. Quality gates (run before commit)
pnpm check:all

# 5. Get help
pnpm help                # Shows this file
```

---

## Project Structure

- `src/domain/` - Pure business logic (no React)
- `src/adapters/` - API normalization layer
- `src/features/` - UI feature slices
- `src/shared/` - Reusable components
- `.ai/` - For universal indexer (INDEX, DECISIONS, PLAYBOOK, CLAUDE)

---

## Common Tasks

### Adding a New Feature

```bash
pnpm gen:feature my-feature
# Generates: src/features/my-feature/{components,hooks,routes}
```

### Adding Domain Logic

```bash
pnpm gen:domain entities
# Generates: src/domain/entities/{types,rules,queries}
# Plus: src/adapters/entities-adapter.ts
```

### Running Tests

```bash
pnpm test           # Unit tests (watch)
pnpm test:e2e       # Playwright smoke tests
```

---

## Architecture Rules

See `ARCHITECTURE.md` for the 10 non-negotiable rules.

**Key principles:**
- Domain is pure TypeScript (no React)
- Server state in React Query only
- No circular dependencies
- Change budget: max 20 files, 500 LOC per PR

---

## Troubleshooting

**CI failing?**
1. Run `pnpm doctor`
2. Run `pnpm check:all` locally
3. Fix errors shown
4. Re-push

**Forgot how something works?**
1. Run `pnpm doctor` (always start here)
2. Check `.ai/PLAYBOOK.md`
3. Read `ARCHITECTURE.md`
4. Check `.ai/CLAUDE.md` (if using Claude)

**Need to bypass a rule?**
See `.ai/CLAUDE.md` for the escape hatch protocol.

---

## First-Time Setup

```bash
# Clone template for new project
git clone ~/Repos/sensand-golden-webapp ~/Repos/my-project
cd ~/Repos/my-project
rm -rf .git && git init

# Update project name
# Edit package.json: change "name" field

# Install and validate
pnpm install
pnpm doctor

# Start developing
pnpm dev
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `pnpm doctor` | Health check (run first!) |
| `pnpm dev` | Start dev server |
| `pnpm gen:feature <name>` | Generate feature |
| `pnpm gen:domain <name>` | Generate domain module |
| `pnpm check:all` | Run all quality gates |
| `pnpm help` | Show this file |

**Always start with `pnpm doctor`.**
