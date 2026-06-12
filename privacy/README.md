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

## Deploy to GitHub Pages (`mybook--privacy`)

The live site is served from the repo root. When deploying, copy source files to these filenames:

| Source (monorepo)       | Deployed (repo root) |
|-------------------------|----------------------|
| `privacy/zh/index.html` | `index.html`         |
| `privacy/en/index.html` | `en.html`            |

Example from the monorepo root:

```bash
cp privacy/zh/index.html /path/to/mybook--privacy/index.html
cp privacy/en/index.html /path/to/mybook--privacy/en.html
```

Then commit and push `mybook--privacy` to `main`. Pages will be live at:

```
https://wujianrenn.github.io/mybook--privacy/
```

## Internal links

Source files use **deployment-relative** hrefs (same as on GitHub Pages):

- Chinese (`zh/index.html`): links to `en.html`
- English (`en/index.html`): links to `index.html`

Do **not** use `../en/index.html` in the HTML — that path only exists in the monorepo, not on Pages.

## App Store Connect

| Locale              | Privacy Policy URL |
|---------------------|--------------------|
| 简体中文 (zh-Hans)  | `https://wujianrenn.github.io/mybook--privacy/` |
| English (en-US)     | `https://wujianrenn.github.io/mybook--privacy/` or `https://wujianrenn.github.io/mybook--privacy/en.html` |

Either English URL is valid; the pages cross-link to each other.
