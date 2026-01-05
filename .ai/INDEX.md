# Repository Index

## Purpose
Golden path template for new Sensand web applications. Clone this to start any new React project with hexagonal architecture baked in.

## Key Modules
- **Domain**: `src/domain/` - Pure TypeScript business logic (no React)
- **Adapters**: `src/adapters/` - API normalization layer (backend → frontend)
- **Features**: `src/features/` - UI feature slices (vertical architecture)
- **Shared**: `src/shared/` - Reusable components and UI-only state

## Entry Points
- **Main**: `src/main.tsx` - React app entry with QueryClient setup
- **Styles**: `src/index.css` - Global Tailwind imports
- **HTML**: `index.html` - Root HTML template

## Critical Files
- **ARCHITECTURE.md** - 10 non-negotiable rules + Rule 0 (golden path only)
- **docs/START_HERE.md** - One-page onboarding guide (5 commands)
- **scripts/doctor.sh** - Health check script (canonical entry point)

## Technology Stack
- **React 18** + **Vite** + **TypeScript 5**
- **TanStack Query** (server state) + **Zustand** (UI state)
- **ts-rest** (type-safe API client)
- **Radix UI** (components) + **Tailwind** (styling)
- **Vitest** (unit tests) + **Playwright** (E2E)

## Quick Start
```bash
pnpm doctor              # Validates setup
pnpm dev                 # Start dev server
pnpm gen:feature <name>  # Generate new feature
pnpm help                # Show START_HERE guide
```

## Project Structure
```
src/
├── domain/           # Pure TS (no React imports)
├── adapters/         # API normalization (BFF)
├── features/         # Vertical slices
├── shared/
│   ├── components/   # Radix wrappers
│   └── stores/       # UI-only state (Zustand)
├── app/              # Routing, providers
└── data/             # API client
```
