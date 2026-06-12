# 值物 · Zhizu

> 物尽其用，物有所值。

**值物（Zhizu）** 是一款完全免费的 iOS / iPadOS 资产记录 App。记录你拥有的每一件物品，App 会自动算出它的 **日均成本（日均）= 购入价格 ÷ 持有天数**——东西用得越久，日均越低，越「值」。

和某些把记录数量锁在 8 件、藏在付费墙后面的同类应用不同，**值物没有任何数量上限，也没有任何付费墙。所有功能永久免费。**

本目录是值物产品的**单一工作区**，包含 iOS 应用源码、单元测试、App Store 上架材料，以及 GitHub Pages 隐私政策页面。

---

## 📁 目录结构

```
zhizu/
├── README.md              # 本文件 — 项目总览
├── app/                   # iOS Xcode 工程（SwiftUI + SwiftData）
│   ├── Zhizu.xcodeproj/
│   ├── Zhizu/             # App target 源码
│   └── ZhizuTests/        # 单元测试
├── privacy/               # GitHub Pages 隐私政策（静态 HTML）
│   ├── index.html         # 简体中文（默认）
│   ├── en.html            # English
│   └── README.md          # 部署说明
└── store/                 # App Store 上架文档
    ├── RELEASE_CHECKLIST.md
    ├── AppStoreListing.md
    ├── PrivacyPolicy.md
    ├── PrivacyPolicy.en.md
    └── SCREENSHOTS.md
```

---

## ▶️ 在 Xcode 中打开并运行

1. 用 Xcode（建议 Xcode 16 及以上）打开 **`app/Zhizu.xcodeproj`**。
2. 选择 **Zhizu** scheme，并选择任意 iPhone 或 iPad 模拟器。
3. 按 **⌘R** 运行。首次启动为空，点击「添加」即可创建第一件资产。

> 工程使用 **PBXFileSystemSynchronizedRootGroup**（`objectVersion = 77`），`app/Zhizu/` 与 `app/ZhizuTests/` 会被自动纳入对应 target。

真机调试：在 **Project ▸ Target "Zhizu" ▸ Signing & Capabilities** 中设置 **Team**（Bundle ID 默认 `com.lavendeer.zhizu`）。

---

## 🧪 运行测试

在 Xcode 中按 **⌘U** 运行 `ZhizuTests` target。测试覆盖纯逻辑（`CostCalculator`、`Formatters`、`SortOption`、`StatsCalculator`、`WishlistCalculator`），不依赖 SwiftData 容器。

---

## 🌐 多语言（中 / 英）

- 默认跟随系统语言；可在「我的 → 自定义设置 → 语言」中手动切换。
- String Catalog：`app/Zhizu/Resources/Localizable.xcstrings`

---

## 🔒 隐私政策（GitHub Pages）

本地文件位于 **`privacy/`**。上线步骤见 [`privacy/README.md`](privacy/README.md)。

简要说明：将 **`privacy/` 文件夹内的内容**（不是整个 monorepo）推送到 GitHub 仓库 `zhizu-privacy`，启用 Pages 后得到：

```
https://wujianrenn.github.io/zhizu-privacy/
```

在 App Store Connect 的「隐私政策网址」中填入上述 URL。

---

## 🚀 上架 App Store

发布材料在 [`store/`](store/) 目录，从 [`store/RELEASE_CHECKLIST.md`](store/RELEASE_CHECKLIST.md) 开始按步骤操作。

---

## 🆓 免费理念

- 完全免费，**没有内购、没有会员墙**。
- 记录**不设上限**。
- 数据存在本地（SwiftData），**导出 / 导入由你掌控**。

愿你买得开心，用得长久。
