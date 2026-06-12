# 值物 (Zhizu) — Privacy Policy

Static privacy policy pages for App Store Connect, hosted on GitHub Pages.

**Local path in the monorepo:** `zhizu/privacy/` (this folder).

## Before you push

Search and replace `REPLACE_WITH_YOUR_EMAIL@example.com` in `index.html` and `en.html` with your real contact email.

## Deploy to GitHub Pages

The GitHub repo name can stay **`zhizu-privacy`** even though these files live under `zhizu/privacy/` locally.

1. Create a new **public** GitHub repository named `zhizu-privacy` (e.g. `wujianrenn/zhizu-privacy`).
2. Push **only the contents of this `privacy/` folder** to the `main` branch (repo root — not the whole `zhizu` monorepo).
3. In the repo: **Settings → Pages → Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: `main` / **/ (root)**
4. After a minute or two, the site will be live at:

   ```
   https://<your-github-username>.github.io/zhizu-privacy/
   ```

   Example: `https://wujianrenn.github.io/zhizu-privacy/`

> **Tip:** From this folder, run `git init && git add . && git remote add origin …` in a separate clone, or copy these three files into your existing `zhizu-privacy` repo.

## App Store Connect

Paste the URL above into **App Store Connect → your app → App Information → Privacy Policy URL** (隐私政策网址).

- Default (Simplified Chinese): `https://<username>.github.io/zhizu-privacy/`
- English: `https://<username>.github.io/zhizu-privacy/en.html`

Either URL is fine; the Chinese page is the default `index.html`.

## Files

| File | Purpose |
|------|---------|
| `index.html` | Simplified Chinese privacy policy |
| `en.html` | English privacy policy |

No build step or external dependencies required.
