# 发布清单 — 值物 (Zhizu)

一份完整、有序的指南，带你从零走到「已提交审核」，**优先上架美区 App Store**，中国区后续再跟进。

> 命令行（CLI）构建需要完整版 Xcode（不能只装 Command Line Tools）。先把工具链指向
> Xcode（只需设置一次）：
> ```bash
> sudo xcode-select -s /Applications/Xcode.app
> xcode-select -p   # 应输出 /Applications/Xcode.app/Contents/Developer
> ```

---

## 0. 前置条件

- [ ] **注册 Apple Developer Program**（99 美元/年）：<https://developer.apple.com/programs/enroll/>。审批可能需要 24–48 小时。
- [ ] 已安装并选中完整版 **Xcode**（见上方提示）。

## 1. 签名与身份（在 Xcode 中）

- [ ] 打开 `app/Zhizu.xcodeproj`。选中 **Zhizu** target → **Signing & Capabilities**。
- [ ] 将 **Team** 设置为你自己的开发者账号（替换占位符 `DEVELOPMENT_TEAM = JQZXN7WAV9`）。
- [ ] 确认已开启 **Automatically manage signing**（自动管理签名）。
- [ ] 设置一个**全局唯一的 Bundle Identifier**。当前为 `com.lavendeer.zhizu`。它必须全局
      唯一，并与你在 App Store Connect 注册的一致——如果该反向域名不属于你，请修改
      （例如 `com.<yourname>.zhizu`）。同时更新 app target，并将 tests target 保持为
      `<bundleid>.tests`。

## 2. 版本号与构建号

- [ ] `MARKETING_VERSION`（CFBundleShortVersionString）= **1.0** ✓（已设置）
- [ ] `CURRENT_PROJECT_VERSION`（CFBundleVersion）= **1** ✓（已设置）
- [ ] 同一版本每次重新上传时，都要递增 build 号。

## 3. 提交前自检

- [ ] App 图标已就位，1024×1024 ✓（请勿改动）。
- [ ] 启动屏有效（`UILaunchScreen_Generation = YES`）✓，外加品牌化的 SwiftUI 启动画面。
- [ ] `TARGETED_DEVICE_FAMILY = 1,2` ✓，部署目标 iOS 17 ✓。
- [ ] `ITSAppUsesNonExemptEncryption = NO` ✓（自动回答出口合规问题）。
- [ ] 显示名称 值物 ✓。
- [ ] 运行单元测试：**⌘U**（或 `xcodebuild test -scheme Zhizu -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`）。
- [ ] 在真机上做一次冒烟测试。

## 4. 在 App Store Connect 创建应用

- [ ] <https://appstoreconnect.apple.com> → **My Apps → +**。
- [ ] 平台选 iOS，名称填 **值物**（必须在商店内唯一，请准备一个备用名称），
      主语言、Bundle ID（第 1 步中确定的那个）、SKU（任意字符串，例如 `zhizu-001`）。

## 5. Archive 与上传

- [ ] 在 Xcode 中将运行目标设为 **Any iOS Device (arm64)**。
- [ ] **Product ▸ Archive**。
- [ ] 在 Organizer 中：**Distribute App → App Store Connect → Upload**。
- [ ] 命令行（CLI）替代方案：
      ```bash
      xcodebuild -scheme Zhizu -archivePath build/Zhizu.xcarchive archive
      xcodebuild -exportArchive -archivePath build/Zhizu.xcarchive \
        -exportOptionsPlist ExportOptions.plist -exportPath build/export
      ```
- [ ] 等待 build 在 App Store Connect 中处理完成（几分钟到约 1 小时不等）。

## 6. TestFlight（推荐）

- [ ] 在 **TestFlight** 下，自己或邀请内部测试员测试处理完成的 build。
- [ ] 若邀请外部测试员，需填写测试说明（可能需要一次快速审核）。

## 7. 元数据、隐私与截图

- [ ] 从 `AppStoreListing.md` 粘贴元数据（名称、副标题、宣传文本、描述、关键词）。
- [ ] **分类（Category）：** Finance（推荐）——详见 listing 文档。
- [ ] **隐私政策 URL：** 托管 `PrivacyPolicy.md` / `PrivacyPolicy.en.md`（GitHub Pages 或 Gist），并粘贴链接。
- [ ] **App Privacy → Data Not Collected**（选择「We do not collect data from this app」）。详见 `AppStoreListing.md`。
- [ ] **截图：** 按 `SCREENSHOTS.md` 上传 6.9" iPhone 与 13" iPad 两套。
- [ ] **年龄分级（Age rating）：** 完成问卷 → 预期为 **4+**。
- [ ] **定价（Pricing）：** 免费。
- [ ] **出口合规（Export compliance）：** 已由 Info.plist 中的键自动回答；如有提示再确认一次。

## 8. 上架地区 —— 美区优先，中国区后续

- [ ] 在 **Pricing and Availability** 中，将首次发布的上架地区设为 **United States**
      （以及任何你已准备好的其他地区）。
- [ ] **中国大陆后续再上**，且有额外要求：
  - 该应用需要 **ICP 备案（ICP filing）**，以及
  - 通常还需要 **软件著作权（软著 / software copyright registration）**。
  - 上架地区是**按区域**控制的——你可以**之后再在 Pricing and Availability 中加入中国**，
    **无需提交新的应用版本**；只是该区域需要单独完成其审核 / 合规。

## 9. 提交

- [ ] 为该版本选择处理完成的 build。
- [ ] **Add for Review → Submit**。
- [ ] 选择审核通过后是手动还是自动发布。
- [ ] 审核通常约需 24–48 小时。如收到 Resolution Center 消息，请及时回复。

## 10. 通过审核之后

- [ ] 发布（若为手动发布）。
- [ ] 在 git 中为该版本打 tag；后续更新时保持 `MARKETING_VERSION` / build 号同步递增。
