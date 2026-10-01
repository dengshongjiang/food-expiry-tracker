# 食物保质期 App — 离线 APK 打包工程说明

这个工程把已经上线的 PWA（`https://dengshongjiang.github.io/food-expiry-tracker/`）
**整包塞进 APK 内部（assets）**，用一个全屏 WebView 打开，特点：

- ✅ 真·安卓安装包，装到手机就是独立 App（桌面有图标）
- ✅ **完全离线**：网页、图标、脚本全在包里，断网也能用、秒开
- ✅ **全屏无地址栏**，没有任何浏览器外壳
- ✅ 不需要 PWABuilder、不需要 Java、不需要 Android Studio

包名：`com.family.foodtracker`，最低 Android 5.1（API 23）。

---

## 路径 0：应急路线 —— 在线打包服务（5 分钟，立刻拿到一个能装的 APK）

如果你不想等 GitHub Actions，直接用现成的在线打包服务，填个网址就能出 APK：

1. 打开 https://appsgeyser.com （已验证可正常访问）
2. 注册一个账号（免费，填邮箱即可）
3. 选 **Website / URL** 模式（不是 HTML、也不是 ZIP）
4. 网址填：`https://dengshongjiang.github.io/food-expiry-tracker/`
5. 应用名填英文：`Food Expiry Tracker`（中文名在这类平台偶尔会因编码出问题）
6. 一路 Next → **Generate**，完成后下载 APK，传到手机安装

**代价（说清楚）：**
- 生成的 APK 是「联网加载网页」的壳，**断网用不了**（本次要的离线能力会丢）
- 免费版带服务商品牌画面 / 可能有广告分成
- 数据存在远程域名下，和这条「离线工程」里的不是一套

> 所以：想要**干净、离线、自己掌控的工程**，走下面的**路径 B**；只是想先装个能用的玩玩，走**路径 0**。

---

## 路径 B：用 GitHub Actions 自动构建（推荐，自包含离线 APK）

本机（这台电脑）没有 Java / Android SDK，编译跑不了，交给 GitHub 的云端 Linux 机器跑，
它自带 JDK 17 + Android SDK，跑完直接下载 APK。

### 步骤

1. 打开你自己的仓库 👉 https://github.com/dengshongjiang/food-expiry-tracker
2. 进入 **Add file → Upload files**，把**本文件夹 `apk-builder/` 里的所有内容**
   直接拖进仓库**根目录**（注意是根目录，不是子目录）。
   - 拖拽时 GitHub 会自动保留目录结构，`apk-builder/` 和 `.github/` 会一起上传。
   - 上传后仓库里应该有：
     ```
     .github/workflows/build-apk.yml
     app/build.gradle
     app/src/...
     settings.gradle
     build.gradle
     gradle.properties
     ```
3. 点上方标签 **Actions** → 左侧 **All workflows** → 选 **Build Android APK** → 点 **Run workflow**（绿色按钮，分支选 `main`）→ 确认。
4. 等 **8~15 分钟**，页面右上角会出现一个绿勾 ✅，点开 **Artifacts**，
   下载 `food-tracker-apk`，里面那个 `food-tracker.apk` 就是安装包。
5. 把 `food-tracker.apk` 传到手机安装即可（首次安装：手机设置里允许「安装未知来源应用」）。

> 以后每次改应用内容，只要重新上传 `index.html` 到仓库根目录，Actions 也会自动重新构建。

### 调试小技巧
如果 Actions 页面构建失败（红叉），点那一行 → **Jobs** → 看红色的错误日志截图发我，
我改配置重跑。常见原因就是 Gradle 版本或 SDK 组件，都很好修。

---

## 路径 B：本地自己编译（可选，适合你装了 Java）

1. 装 Java 17：https://adoptium.net → 下 **Temurin 17 (LTS)** 装好，记住安装路径。
2. 装 Android 命令行工具并装 SDK 组件：platforms;android-34、build-tools;34.0.0。
3. 在本目录建 `local.properties`，内容写一行（路径换成你的）：
   ```
   sdk.dir=C\:\\Users\\你的用户名\\AppData\\Local\\Android\\Sdk
   ```
4. 双击 **`build-apk.bat`**（或命令行运行 `gradlew assembleDebug`），
   输出在 `apk-builder/app/build/outputs/apk/debug/app-debug.apk`。

> 路径 B 需要下载约 1.5GB 的 Android SDK，**普通用户建议直接用路径 A**。

---

## 安装到手机

1. 手机设置 → 安全/隐私 → 允许「安装未知来源应用」（不同品牌叫法不同，给浏览器或文件管理器开就行）。
2. 打开 `food-tracker.apk` → 安装 → 桌面出现「食物保质期」绿色时钟图标。
3. 打开即用，**断网也能录数据**（数据存在 App 自己的本地存储里）。

## 数据说明（重要）

- APK 里的数据和浏览器里的数据是**两套独立的**，装完 App 是空白的，需要重新录入，
  或者用 App 内的「导出 JSON → 导入」把浏览器里的数据搬过去。
- 数据在 App 卸载时会一起清掉，重要数据记得定期在 App 里「导出」一份 JSON 备份。

## 文件都是干什么用的

| 文件 | 作用 |
| --- | --- |
| `app/src/main/assets/index.html` 等 8 个 | 整个 PWA 应用本体（内嵌进 APK） |
| `app/src/main/java/.../MainActivity.java` | 全屏 WebView 外壳（约 100 行） |
| `app/src/main/AndroidManifest.xml` | 应用配置（图标、全屏、启动页） |
| `app/src/main/res/` | 桌面图标（自适应图标 + PNG 兜底） |
| `settings.gradle` / `build.gradle` / `app/build.gradle` | Gradle 构建配置 |
| `.github/workflows/build-apk.yml` | GitHub Actions 自动打包脚本 |
| `build-apk.bat` | 本地编译一键脚本（路径 B 用） |
