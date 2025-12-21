# Stacks Arcade

Playground of Stacks smart-contract mini-games with a matching Next.js frontend and curated learning resources.

## Layout
- `stacks-arcade/` — Clarity contracts for each mini-game plus Vitest suites (`npm test`) and Clarinet config.
- `frontend/` — Next.js app for the arcade UI (`npm run dev`, `npm run build`).
- `docs/` — Short gameplay and contract notes (e.g., `docs/games/coin-flip.md`, `docs/games/emoji-battle.md`).
- `stacks/` — Stacks knowledge base with a quick index at `stacks/INDEX.md`.

## Quickstart
1. Install dependencies:
   - `cd stacks-arcade && npm install`
   - `cd frontend && npm install`
2. Run contract tests from `stacks-arcade/`:
   - `npm test` for unit tests (Vitest + clarinet simnet env)
   - `npm run test:report` for coverage and cost output
   - `npm run test:watch` to re-run on contract/test changes (uses chokidar)
3. Run the frontend from `frontend/`:
   - `npm run dev` then open `http://localhost:3000`
4. Optional: Clarinet CLI
   - `clarinet check` to lint contracts
   - `clarinet console` for quick manual calls

## Prerequisites
- Node.js 18+ (tested) and npm.
- Clarinet CLI if you want local REPL/inspection (not required for Vitest runs).
- Git for branching and workflow.

## Notes
- Node.js 18+ is recommended for both workspaces.
- Clarinet CLI is optional for extra contract inspection; core tests run via `vitest` with the Clarinet SDK environment.
- Vitest is configured with `maxWorkers: 1` to avoid simnet contention—keep it when adding tests.
