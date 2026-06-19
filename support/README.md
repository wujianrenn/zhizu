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

## Deploy to GitHub Pages ([`wujianrenn/apps-privacy`](https://github.com/wujianrenn/apps-privacy))

Copy source files into the **`zhizu/`** subfolder alongside the privacy pages:

| Source (monorepo)        | Deployed (`apps-privacy/zhizu/`) |
|--------------------------|-----------------------------------|
| `support/zh/index.html`  | `support.html`                    |
| `support/en/index.html`  | `support-en.html`                 |

Example:

```bash
cp support/zh/index.html /path/to/apps-privacy/zhizu/support.html
cp support/en/index.html /path/to/apps-privacy/zhizu/support-en.html
```

## Internal links

Source files use **deployment-relative** hrefs:

- Chinese: `support-en.html` (language), `index.html` (privacy)
- English: `support.html` (language), `en.html` (privacy)

## App Store Connect

| Locale              | Support URL |
|---------------------|-------------|
| 简体中文 (zh-Hans)  | `https://wujianrenn.github.io/apps-privacy/zhizu/support.html` |
| English (en-US)     | `https://wujianrenn.github.io/apps-privacy/zhizu/support-en.html` |
