# 值物 (Zhizu) — Support

Static support pages for App Store Connect **技术支持网址** (Support URL).

**Local path in the monorepo:** `zhizu/support/` (this folder).

## Source layout

```
support/
  zh/index.html    # Simplified Chinese (source)
  en/index.html    # English (source)
  README.md
```

## Deploy to GitHub Pages (`mybook--privacy`)

Copy source files to the repo root alongside the privacy pages:

| Source (monorepo)        | Deployed (repo root) |
|--------------------------|----------------------|
| `support/zh/index.html`  | `support.html`       |
| `support/en/index.html`  | `support-en.html`    |

Example:

```bash
cp support/zh/index.html /path/to/mybook--privacy/support.html
cp support/en/index.html /path/to/mybook--privacy/support-en.html
```

## Internal links

Source files use **deployment-relative** hrefs:

- Chinese: `support-en.html` (language), `index.html` (privacy)
- English: `support.html` (language), `en.html` (privacy)

## App Store Connect

| Locale              | Support URL |
|---------------------|-------------|
| 简体中文 (zh-Hans)  | `https://wujianrenn.github.io/mybook--privacy/support.html` |
| English (en-US)     | `https://wujianrenn.github.io/mybook--privacy/support-en.html` |
