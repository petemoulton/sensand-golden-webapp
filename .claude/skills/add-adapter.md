---
name: add-adapter
description: Add adapter + query hook pattern
location: project
---

# Add Adapter

Create:
- src/adapters/<entity>-adapter.ts
- src/domain/<entity>/<entity>.queries.ts

Rules:
- Keep minimal. No code unless asked.
- Output: 3–6 bullets max.

Smoke test:
If creation fails, print exact command + error snippet only.
