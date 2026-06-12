# App Store Listing — 值物 (Zhizu)

Ready-to-paste App Store Connect metadata in **Simplified Chinese** and **English**.
Character limits noted are Apple's hard limits — stay at or under them.

---

## Category (recommendation)

**Primary: Finance** — the app's core value is tracking what you own, purchase
cost, and **daily cost (日均成本)**, which is a personal‑finance framing.
**Secondary: Utilities** (or Productivity).

> The build sets `LSApplicationCategoryType = public.app-category.finance` to match.
> If you'd rather position it as a tool, switch the primary to **Utilities** in App
> Store Connect and update that build setting accordingly.

---

## 简体中文 (zh-Hans) — primary language suggestion

**App 名称 (App Name, ≤30 chars)**
```
值物 - 资产记录与日均成本
```
(If too long for your locale, use just `值物`.)

**副标题 (Subtitle, ≤30 chars)**
```
记录拥有，看清日均成本
```

**宣传文本 (Promotional Text, ≤170 chars)**
```
完全免费，没有数量限制，没有内购。所有数据只存在你的设备上。记录你拥有的物品，算清每天的真实成本，理性种草，物有所值。
```

**描述 (Description, ≤4000 chars)**
```
值物，是一款帮你「看清拥有」的极简资产记录工具。名字取「物有所值、物尽其用」，也谐音「植物」，呼应那只小胡萝卜吉祥物。

不是让你买更多，而是帮你用好已经拥有的东西。把每一件物品的购入价格和使用时间记下来，值物会自动算出它的「日均成本」——用得越久，每天越便宜。这会让你更珍惜手边之物，也更理性地面对下一次「种草」。

为什么选择值物：
• 完全免费 —— 没有数量限制，没有内购，没有订阅，没有广告。
• 日均成本 —— 自动计算每件物品每天的真实花费，越用越值。
• 资产总览 —— 在用 / 已退役 / 收藏，状态一目了然。
• 统计图表 —— 按分类查看资产分布与价值，消费结构更清晰。
• 心愿单 —— 把想买的东西先记下来，理性消费，避免冲动。
• 自定义主题 —— 内置柔和薰衣草配色，也可自定义专属渐变与浅色/深色/跟随系统外观。
• 隐私至上 —— 全部数据保存在你的设备本地（SwiftData），不收集任何个人信息、无第三方追踪、无需账号。

值物，让每件东西都物有所值。
```

**关键词 (Keywords, comma-separated, ≤100 chars total)**
```
值物,资产,记账,日均成本,物品管理,极简,心愿单,理性消费,断舍离,统计
```

**Support URL**
```
https://wujianrenn.github.io/mybook--privacy/support.html
```

**Marketing/隐私政策 URL**
```
https://wujianrenn.github.io/mybook--privacy/
```

---

## English (en-US)

**App Name (≤30 chars)**
```
Zhizu: Asset & Cost Tracker
```
(28 chars. Or simply `Zhizu`.)

**Subtitle (≤30 chars)**
```
Track what you own, per day
```

**Promotional Text (≤170 chars)**
```
Completely free. No item limit, no in‑app purchases. All data stays on your device. Track what you own and see its true cost per day.
```

**Description (≤4000 chars)**
```
Zhizu is a minimalist tracker that helps you appreciate what you already own.

Instead of nudging you to buy more, Zhizu helps you make the most of what you have. Record each item's purchase price and how long you've used it, and Zhizu automatically calculates its daily cost — the longer you use something, the cheaper each day becomes. It's a gentle, honest way to value your belongings and think twice before the next impulse buy.

Why Zhizu:
• Completely free — no item limit, no in‑app purchases, no subscriptions, no ads.
• Daily cost — see the real per‑day cost of every item; value grows the more you use it.
• Asset overview — In use / Retired / Favorites, all at a glance.
• Statistics — charts of your assets by category and value for a clear picture.
• Wishlist — capture things you want to buy and spend more intentionally.
• Custom themes — a soft lavender palette built in, plus your own custom gradients and Light / Dark / System appearance.
• Privacy first — all data is stored locally on your device (SwiftData). No personal data collected, no third‑party tracking, no account required.

Own less, enjoy more.
```

**Keywords (comma-separated, ≤100 chars total)**
```
asset,tracker,daily cost,minimalist,wishlist,budget,inventory,expense,belongings,declutter
```

**Support URL**
```
https://wujianrenn.github.io/mybook--privacy/support-en.html
```

**Marketing / Privacy Policy URL**
```
https://wujianrenn.github.io/mybook--privacy/en.html
```

---

## App Privacy — Nutrition Label answers (App Store Connect)

In App Store Connect → your app → **App Privacy**, choose:

> **Data Not Collected** ✅
>
> Select: **"We do not collect data from this app."**

Rationale you can rely on: the app stores everything locally with SwiftData,
contains no analytics/ads/third‑party SDKs, requires no account, and transmits no
user data off the device. Therefore every data category should be left **unchecked**
and the top‑level answer is **Data Not Collected**.

If you later add optional iCloud (CloudKit) sync to the user's private iCloud, that
still typically qualifies as **not collected by the developer** (Apple hosts it in
the user's own account) — but re‑review the questionnaire when you ship that feature.

## Export Compliance

The build sets `ITSAppUsesNonExemptEncryption = NO` in the Info.plist keys, so the
**export compliance** question is auto‑answered at upload. (The app uses only
standard OS encryption, if any.)

## Age Rating

Expect **4+** — no objectionable content. Answer all questionnaire items as "None".
