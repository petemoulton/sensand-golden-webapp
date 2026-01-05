# Claude Code Usage Contract

## Purpose
This file defines how Claude Code should interact with this repository. It enforces architectural rules while providing escape hatches for legitimate exceptions.

---

## Core Rules

### 1. Always Run Doctor First

Before making ANY changes, run:
```bash
pnpm doctor
```

If doctor fails, fix the issues before proceeding.

### 2. Follow the Folder Contract

**One-way dependency flow**:
```
domain/ (pure TS, no React)
  ↓
adapters/ (API normalization)
  ↓
features/ (React components)
  ↓
shared/ (reusable UI, no feature imports)
```

**Never import upwards.**

### 3. No Direct Refactors

Claude should NOT:
- Refactor code that isn't directly related to the task
- "Improve" architecture without user request
- Touch `src/shared/` unless task requires it
- Rename variables/functions in unrelated files
- Add "helpful" abstractions for one-time use

**Exception**: Refactors are allowed ONLY when:
1. User explicitly requests refactor
2. Task is labeled `refactor:approved`
3. Fixing a circular dependency that blocks the current task

### 4. Respect Change Budget

**Maximum per PR**:
- 20 files changed
- 500 lines changed

If budget exceeded, STOP and:
1. Ask user to split into multiple PRs
2. Suggest which changes to defer
3. Wait for `refactor:approved` label

### 5. Use Generators First

Before creating files manually:
```bash
pnpm gen:feature <name>   # For new features
pnpm gen:domain <name>    # For domain logic
```

Generators ensure correct folder structure and imports.

### 6. Validate Before Claiming Success

After making changes, ALWAYS run:
```bash
pnpm check:all
```

If any check fails, fix it before marking task complete.

---

## Escape Hatch Protocol

Sometimes architectural rules need to be bent for legitimate reasons.

### When to Use Escape Hatch

- **Blocker**: Architectural rule prevents completing critical task
- **Migration**: Moving to new pattern requires temporary violation
- **Emergency**: Production bug requires quick fix outside normal flow
- **Experiment**: Prototyping new approach before formalizing

### How to Use Escape Hatch

**1. Ask User for Approval**:
```
I need to [action that violates rule] because [reason].

This violates [specific rule from ARCHITECTURE.md].

Options:
A. Proceed with violation (requires refactor:approved label)
B. Find alternative approach (may take longer)
C. Defer this task

What would you like to do?
```

**2. If Approved, Document**:

Create `docs/ESCAPE_HATCHES.md` (if doesn't exist):
```markdown
# Escape Hatches

## [Date] - [Rule Violated]

**Task**: [What you were trying to accomplish]

**Rule Violated**: [Specific rule from ARCHITECTURE.md]

**Reason**: [Why normal approach didn't work]

**Approval**: [User name/date]

**Remediation Plan**: [How to fix this later]

**Files Affected**:
- file1.ts
- file2.ts
```

**3. Add PR Label**:
- Label PR with `escape-hatch`
- Link to `docs/ESCAPE_HATCHES.md` in PR description

**4. Schedule Remediation**:
- Create follow-up issue to fix the violation
- Add to technical debt backlog

---

## Common Scenarios

### Scenario: "I need to add a feature but can't use generators"

**Ask**: Why can't you use generators?
- If generator is broken → Fix generator first
- If feature doesn't fit pattern → Ask user if pattern should expand
- If prototyping → Create in separate branch, don't merge

### Scenario: "Fixing circular dependency requires refactoring 30 files"

**Options**:
1. Find surgical fix (extract ONE shared module)
2. Ask user for `refactor:approved` label
3. Split into multiple PRs (fix cycle partially each PR)

**Never**: Silently refactor 30 files without asking.

### Scenario: "Domain logic needs React hooks"

**Solution**: React Query hooks are allowed in `src/domain/*/queries.ts`

**Rationale**: React Query is the domain's interface to server state.

**Not Allowed**: React components in domain, useEffect, useState, etc.

### Scenario: "User asked me to improve code quality across the repo"

**Response**:
```
I can improve code quality, but need to follow change budget (20 files, 500 LOC per PR).

I'll create a plan with multiple PRs:
1. PR 1: Improve module X (15 files, 400 LOC)
2. PR 2: Improve module Y (12 files, 350 LOC)
3. PR 3: Improve module Z (18 files, 480 LOC)

Each PR will be labeled refactor:approved.

Approve this approach?
```

---

## What Claude Should Do Proactively

### ✅ Always Do

1. **Run `pnpm doctor` at start of session**
2. **Run `pnpm check:all` before marking task complete**
3. **Use generators** (`gen:feature`, `gen:domain`) when creating code
4. **Ask for approval** when change budget will be exceeded
5. **Document escape hatches** when rules are violated
6. **Suggest smaller scope** when task is too large

### ❌ Never Do

1. **Refactor unrelated code** without explicit request
2. **Silently exceed change budget**
3. **Import upwards** in folder hierarchy
4. **Add React imports to domain layer**
5. **Create circular dependencies**
6. **Skip quality gates** to "save time"

---

## Quality Gate Checklist

Before completing any task, verify:

- [ ] `pnpm doctor` passes
- [ ] `pnpm check:types` passes
- [ ] `pnpm check:lint` passes
- [ ] `pnpm check:circular` passes
- [ ] Change budget not exceeded (≤20 files, ≤500 LOC)
- [ ] No React imports in `src/domain/` (except `queries.ts`)
- [ ] No feature imports in `src/shared/`
- [ ] API calls only in `src/adapters/`
- [ ] Server state only in React Query
- [ ] UI state only in Zustand

---

## Examples

### ✅ Good: Following the Rules

```
User: "Add a user profile feature"

Claude:
1. Runs pnpm doctor → passes
2. Runs pnpm gen:feature user-profile
3. Runs pnpm gen:domain user-profile
4. Implements domain logic in src/domain/user-profile/
5. Implements adapter in src/adapters/user-profile-adapter.ts
6. Implements UI in src/features/user-profile/
7. Runs pnpm check:all → passes
8. Task complete (8 files changed, 320 LOC)
```

### ❌ Bad: Ignoring the Rules

```
User: "Add a user profile feature"

Claude:
1. Skips pnpm doctor
2. Creates files manually (no generators)
3. Puts business logic directly in React components
4. Makes API calls from components (skips adapters)
5. Stores user data in Zustand (should be React Query)
6. Imports user-profile feature from another feature
7. Skips pnpm check:all
8. 35 files changed, 1200 LOC (no approval for refactor)
```

### ✅ Good: Using Escape Hatch

```
User: "Fix this production bug urgently"

Claude:
The fix requires changing 25 files (exceeds 20 file budget).

Options:
A. Quick fix with escape hatch (needs approval)
B. Proper fix split into 2 PRs (takes longer)

User: "Do the quick fix, this is urgent"

Claude:
1. Implements fix (25 files)
2. Creates docs/ESCAPE_HATCHES.md documenting violation
3. Runs pnpm check:all → passes
4. Adds 'escape-hatch' label to PR
5. Creates follow-up issue to refactor properly
```

---

## Emergency Override

In true emergency situations (production down, data loss, security breach):

**User can say**: "Emergency override - ignore all rules"

**Claude will**:
1. Acknowledge override
2. Proceed with fastest solution
3. Document what rules were violated
4. Create remediation plan
5. Schedule follow-up cleanup

**After emergency**:
- Review what was changed
- Create issues to restore architectural compliance
- Update runbooks to prevent similar emergencies

---

## Summary

**Default mode**: Follow ARCHITECTURE.md rules strictly

**When blocked**: Ask user for approval via escape hatch protocol

**When unsure**: Run `pnpm doctor`, check `.ai/PLAYBOOK.md`, ask user

**Always**: Validate with `pnpm check:all` before claiming success

---

This contract exists to prevent architecture drift while staying flexible for real-world constraints. When in doubt, ask the user.
