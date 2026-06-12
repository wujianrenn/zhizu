# Screenshots Guide — 值物 (Zhizu)

Apple requires **real screenshots of the running app** for each required display
class. You only need to upload the two sets below; App Store Connect scales them for
smaller devices.

## Required sets (current App Store requirements)

| Display set | Required pixels (portrait) | Capture on this Simulator |
|---|---|---|
| **6.9" iPhone** (covers 6.7"/6.5") | **1320 × 2868** (or 6.7" **1290 × 2796**) | iPhone 16 Pro Max / iPhone 15 Pro Max |
| **13" iPad** | **2064 × 2752** (portrait) or **2752 × 2064** (landscape) | iPad Pro 13‑inch (M4) |

Notes:
- Uploading the **6.9"** (1320×2868) and **13" iPad** (2064×2752) sets satisfies the
  current required display classes; older iPhone/iPad sizes are optional and
  auto‑derived. If App Store Connect still asks for a 6.7" set, 1290×2796 from an
  iPhone 15 Pro Max also works.
- Use **portrait** to match the app's primary layout.
- Each set allows **up to 10** screenshots. **Recommended: 4–6.**

## How to capture in the Simulator

1. Open the project, choose the target device (e.g. *iPhone 16 Pro Max*), run with **⌘R**.
2. Navigate to the screen you want.
3. Capture one of these ways:
   - **Simulator menu:** `File ▸ Save Screen` (**⌘S**) — saves to Desktop at exact device pixels.
   - **Device menu:** `Device ▸ Trigger Screenshot`.
   - **Command line** (Simulator already booted):
     ```bash
     xcrun simctl io booted screenshot ~/Desktop/zhizu-01.png
     ```
   - To target a specific simulator by name instead of `booted`:
     ```bash
     xcrun simctl list devices            # find the UDID / name
     xcrun simctl io "iPhone 16 Pro Max" screenshot ~/Desktop/iphone-01.png
     ```
4. Repeat for the iPad Pro 13" simulator.

Screenshots captured this way are already the exact required pixel size — no resizing
needed. Verify with:
```bash
sips -g pixelWidth -g pixelHeight ~/Desktop/zhizu-01.png
```

## Suggested shot list (4–6)

Seed a few good‑looking sample assets first (add them manually, or temporarily use
`SampleData` in a preview) so the screens aren't empty:

1. **资产首页 / Assets home** — the list with the header card (total value + daily cost).
2. **资产详情 + 图表 / Asset detail with chart** — daily‑cost curve and status pills.
3. **统计 / Statistics** — category donut + value bars.
4. **心愿单 / Wishlist** — a couple of wish items.
5. **自定义主题 / 外观 / Custom theme & appearance** — the live‑preview theme picker.
6. **空状态 / Empty state** (optional) — the friendly first‑launch screen with the CTA.

## Optional: framed marketing screenshots

You may overlay device frames and a short caption (e.g. with Fastlane `frameit`,
Figma, or Picsew) for a more polished look. This is optional — but the underlying
image must still be a genuine screen from the app at the required pixel dimensions.
Apple rejects mockups that don't reflect the actual UI.
