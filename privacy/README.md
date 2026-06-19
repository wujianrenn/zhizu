# 值物 (Zhizu) — Privacy Policy

Static privacy policy pages for App Store Connect, hosted on GitHub Pages.

**Local path in the monorepo:** `zhizu/privacy/` (this folder).

## Source layout

```
privacy/
  zh/index.html    # Simplified Chinese (source)
  en/index.html    # English (source)
  README.md
```

## Deploy to GitHub Pages ([`wujianrenn/apps-privacy`](https://github.com/wujianrenn/apps-privacy))

Live pages live under the **`zhizu/`** subfolder in the shared public repo (app source stays private). Copy source files when updating:

| Source (monorepo)       | Deployed (`apps-privacy/zhizu/`) |
|-------------------------|-----------------------------------|
| `privacy/zh/index.html` | `index.html`                      |
| `privacy/en/index.html` | `en.html`                         |

Example from the monorepo root:

```bash
cp privacy/zh/index.html /path/to/apps-privacy/zhizu/index.html
cp privacy/en/index.html /path/to/apps-privacy/zhizu/en.html
```

Then commit and push `apps-privacy` to `main`. Pages will be live at:

```
https://wujianrenn.github.io/apps-privacy/zhizu/
```

See the [apps-privacy README](https://github.com/wujianrenn/apps-privacy/blob/main/README.md) for Pages settings and other apps.

## Internal links

Source files use **deployment-relative** hrefs (same as on GitHub Pages):

- Chinese (`zh/index.html`): links to `en.html`
- English (`en/index.html`): links to `index.html`

Do **not** use `../en/index.html` in the HTML — that path only exists in the monorepo, not on Pages.

## App Store Connect

| Locale              | Privacy Policy URL |
|---------------------|--------------------|
| 简体中文 (zh-Hans)  | `https://wujianrenn.github.io/apps-privacy/zhizu/` |
| English (en-US)     | `https://wujianrenn.github.io/apps-privacy/zhizu/en.html` |
