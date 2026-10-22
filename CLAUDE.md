# Project instructions

## UI review
After creating or changing any web UI (HTML, CSS, JSX/TSX, Vue, Svelte, etc.), review the changed files against `.claude/commands/web-interface-guidelines.md` (Vercel Web Interface Guidelines) before finishing, and fix any violations found.

## Design styles
`design-library/<name>/DESIGN.md` holds 84 design systems (from VoltAgent/awesome-design-md), one per brand (e.g. `stripe`, `linear.app`, `apple`). Each website in this repo gets its own style:
- When starting a new website, ask the user which style to use (suggest 2–3 that fit the site's purpose) unless they already named one.
- Copy the chosen `DESIGN.md` into that website's root folder and follow it for all UI work on that site.
- Never mix styles within one website; never use a library file directly for a site that already has its own `DESIGN.md`.
