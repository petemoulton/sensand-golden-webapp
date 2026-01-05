# Architectural Decisions

## Decision 1: Hexagonal Architecture (2025-01-05)

**Context**: Need to rebuild UI without touching domain logic. Previous architecture had tight coupling between UI and business logic.

**Decision**: Adopt hexagonal architecture with clear layer boundaries:
- Domain → Adapters → Features → Shared (one-way dependency flow)
- ESLint boundaries prevent imports upwards

**Consequences**:
- Domain layer is pure TypeScript (no React)
- Backend changes isolated to adapters
- UI can be rewritten without touching business logic
- Easier to test business logic in isolation

---

## Decision 2: React Query for Server State (2025-01-05)

**Context**: Server data was previously mixed in Zustand stores, causing cache invalidation issues and state synchronization problems.

**Decision**:
- React Query handles ALL server state (API data, caching, invalidation)
- Zustand ONLY for UI state (sidebar open, theme, etc.)

**Consequences**:
- No server data in Zustand stores
- Automatic caching/invalidation via React Query
- Simpler state management
- Clear separation of concerns

---

## Decision 3: ts-rest for API Client (2025-01-05)

**Context**: Need type-safe API calls without code generation. Want contract-first development.

**Decision**: Use ts-rest for type-safe API client with shared contract between frontend and backend.

**Consequences**:
- Type safety across API boundary
- Auto-complete for API calls
- Contract defined once, used in both FE and BE
- No code generation step needed

---

## Decision 4: Change Budget Enforcement (2025-01-05)

**Context**: Accidental full-repo rewrites happening frequently. Need mechanism to prevent mass refactors.

**Decision**: CI gate blocks PRs exceeding:
- 20 files changed
- 500 lines changed

**Consequences**:
- Large refactors require `refactor:approved` label
- Forces small, incremental changes
- Makes technical debt visible
- Prevents surprise architecture changes

---

## Decision 5: No Circular Dependencies (2025-01-05)

**Context**: 51 circular dependencies in previous codebase prevented modular rebuilds.

**Decision**: CI blocks any circular dependencies detected by Madge.

**Consequences**:
- Modules can be rebuilt independently
- Clearer dependency graph
- Forces proper architecture
- May require extracting shared logic

---

## Decision 6: Radix UI Wrapping (2025-01-05)

**Context**: Direct usage of Radix components across codebase makes upgrades painful.

**Decision**: All Radix components wrapped once in `src/shared/components/`.

**Consequences**:
- Upgrades happen in one place
- Consistent styling/behavior
- Can swap component library later
- One extra layer of indirection

---

## Decision 7: Golden Path Only (Rule 0) (2025-01-05)

**Context**: Snowflake repos with different stacks cause context switching and knowledge silos.

**Decision**: ALL new projects MUST clone from this template. No exceptions.

**Consequences**:
- Consistent tech stack across all projects
- Shared knowledge and patterns
- Easier onboarding for new developers
- Templates can be improved centrally

---

## Deprecation Policy

When deprecating patterns, architecture decisions, or technologies:

### 1. Announce Deprecation
- Add `[DEPRECATED]` to decision title
- Add deprecation date and reason
- Link to replacement decision

### 2. Migration Window
- **Minimum 2 sprints** before removal
- Provide migration guide
- Update generators to use new pattern

### 3. Example
```markdown
## [DEPRECATED] Decision X: Old Pattern (2024-01-01, deprecated 2024-06-01)

**Deprecation Reason**: Replaced by Decision Y (better performance)

**Migration Guide**: See `.ai/PLAYBOOK.md` section "Migrating from X to Y"

**Removal Date**: 2024-08-01
```

### 4. Removal
- After migration window, remove from template
- Archive decision (don't delete)
- Update PLAYBOOK.md to remove old patterns
- Update generators

---

## Non-Decisions (What We're NOT Doing)

### We are NOT:
1. **Enforcing architecture in legacy code** - Phase 1 is for new work only
2. **Maximizing test coverage** - We have smoke tests, not exhaustive coverage
3. **Supporting multiple frontend stacks** - React only, locked stack
4. **Auto-refactoring existing code** - Manual, sanctioned refactors only
5. **Preventing all technical debt** - We're making debt visible and manageable

These are Phase 2+ concerns. Phase 1 exists to create a safe, repeatable golden path for new work.
