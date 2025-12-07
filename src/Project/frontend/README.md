# Frontend (Web Client)

This folder contains the frontend application for the project. It is a Vite-powered Vue 3 + TypeScript single-page application (SPA) that provides the user interface for interacting with the backend APIs.

## Key Features

- Built with Vite and Vue 3 (TypeScript).
- Modular structure with components, views, router, and services.
- Simple HTTP client and service modules for API integration.

## Prerequisites

- Node.js (recommended LTS, e.g. Node 16+ or newer)
- npm, yarn or pnpm (any package manager supported by the project)

## Quick Start

1. Install dependencies:

```bash
cd src/Project/frontend
npm install
```

2. Run development server:

```bash
npm run dev
```

Open the address shown in the terminal (usually `http://localhost:5173`).

3. Build for production:

```bash
npm run build
```

4. Preview the production build locally (optional):

```bash
npm run preview
```

If your project uses another package manager (yarn/pnpm), replace `npm` with `yarn` or `pnpm`.

## Available Scripts

- `dev` - Starts Vite dev server.
- `build` - Produces a production build in the `dist/` folder.
- `preview` - Serves the production build locally for previewing.

Check `package.json` for the exact scripts available in this project.

## Project Structure (important files)

- `index.html` — App entry HTML file used by Vite.
- `src/main.ts` — App bootstrap and global setup.
- `src/App.vue` — Root Vue component.
- `src/router/index.ts` — Vue Router configuration and routes.
- `src/services/` — API clients and services (auth, http client, research/admin services).
- `src/components/` — Reusable UI components.
- `src/views/` — Top-level views for routes (Landing, Login, dashboards, settings).
- `public/` — Static assets served by Vite.

## Environment and API

- The frontend consumes backend APIs. API base URL and any environment configuration are typically provided via environment variables (e.g., `.env`, `.env.local`) or a configuration file used by the `httpClient` service in `src/services`.
- Confirm and update the base URL in `src/services/httpClient.ts` (or equivalent) before running the app against a remote or local backend.

## Notes for Developers

- Follow the repository's branch and commit policies when contributing (do not commit directly to `main`/`develop`).
- Keep UI text and code comments in English to match project conventions.
- Add unit or integration tests for new components or services where appropriate.

## Troubleshooting

- If you see TypeScript or build errors, verify Node.js version and installed dependencies.
- If the app cannot reach the backend, confirm the API base URL, CORS settings on the backend, and that the backend is running.

## Contributing

Please open issues or pull requests following the project's contribution guidelines. Use descriptive commit messages (Conventional Commits are recommended).

## License

See the repository `LICENSE` file at the project root for licensing details.

---

If you'd like, I can also:

- Add an example `.env.example` showing the expected environment variables.
- Add a short development checklist or common troubleshooting commands.

Feel free to tell me which of those you want next.
