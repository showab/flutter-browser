# 🧭 Fluent Browser

A modern, lightweight Android browser built with **Flutter**, featuring a clean light theme, desktop mode, tabbed browsing, download manager, and bookmarks.

> ⚠️ **Note:** This is a browser app for general web browsing. YouTube video downloading and Chrome Extension support are **not** included due to platform limitations and legal restrictions.

---

## 🎨 UI Layout (ASCII)

```
┌──────────────────────────────────────────────┐
│  🔍  Search or enter URL        🖥️  ⭐  ⋮  │  ◄── Navigation Bar
├──────────────────────────────────────────────┤
│  [🌐 Google]  [🌐 GitHub]  [🌐 New Tab]  [+] │  ◄── Tab Bar
├──────────────────────────────────────────────┤
│                                              │
│              🌐 WebView Area                 │
│          (Web Page Rendered Here)            │
│                                              │
│                                              │
├──────────────────────────────────────────────┤
│  [◀] [▶] [🔄] [🏠] — Tab Switcher (bottom)  │  ◄── Bottom Nav (optional)
└──────────────────────────────────────────────┘
```

### Screen Flow
```
 ┌──────────┐     ┌───────────┐     ┌──────────┐
 │ Browser  │────▶│ Bookmarks │     │ Downloads│
 │  (Home)  │     └───────────┘     └──────────┘
 └────┬─────┘
      │
      ├────────▶ ┌──────────┐
      │          │ Settings  │
      │          └──────────┘
      │
      └────────▶ ┌──────────────────┐
                 │  Menu (Bottom     │
                 │   Sheet)          │
                 │  · Bookmarks      │
                 │  · Downloads      │
                 │  · Settings       │
                 │  · Dark/Light     │
                 └──────────────────┘
```

---

## 🎨 Design System

| Property | Light Theme | Dark Theme |
|---|---|---|
| **Primary Color** | `#4A90D9` | `#4A90D9` |
| **Background** | `#F5F7FA` | `#121212` |
| **Surface / Cards** | `#FFFFFF` | `#1E1E1E` |
| **Input Field Background** | `#EDF1F7` | `#2A2A2A` |
| **Text Primary** | `#1A1A2E` | `#FFFFFF` |
| **Text Secondary** | `#808080` | `#808080` |
| **Tab Active** | `#4A90D9` (10% opacity bg) | `#4A90D9` (10% opacity bg) |
| **Border Radius (Cards)** | `12px` | `12px` |
| **Border Radius (URL Bar)** | `25px` | `25px` |
| **Border Radius (Tabs)** | `8px` | `8px` |
| **Font Family** | Inter | Inter |
| **Title Font Size** | `18px` (w600) | `18px` (w600) |
| **Body Font Size** | `14px` (w400) | `14px` (w400) |
| **Caption Font Size** | `12px` (w400) | `12px` (w400) |
| **Card Elevation** | `1` | `1` |
| **Icon Size (Nav)** | `18-22px` | `18-22px` |
| **Material Version** | Material 3 | Material 3 |

### Navigation Bar Layout
```
 ┌───────────────────────────────────────────────────────────┐
 │  [◀] [▶] [⟳] [🏠] │  🔍 URL Bar + Icons  │  [⋮]       │
 │  18px 18px 20px 20  │  40px height, pill   │  22px      │
 │                     │  radius: 25px         │            │
 └──────────────────────────────────────────────────────────┘
   Nav Buttons (38×38)   URL Field (flexible)     Menu Button
```

### Tab Bar Layout
```
 ┌──────────────────────────────────────────────────┐
 │  [🌐 Tab 1]  [🌐 Tab 2]  [🌐 Tab 3]  ...  [+]  │
 │   100-160px     min-width       close btn  38×38 │
 └──────────────────────────────────────────────────┘
   Height: 42px  ·  Active tab: primary bg at 10% opacity
```

---

## ✨ Features

| Feature | Status |
|---|---|
| 🌐 Web Browsing (WebView) | ✅ |
| ☀️ Clean Light Theme | ✅ |
| 🌙 Dark Mode | ✅ |
| 🖥️ Desktop Mode (User-Agent toggle) | ✅ |
| 📑 Tabbed Browsing | ✅ |
| ⬅️ Back / Forward / Refresh | ✅ |
| 🔍 URL Bar with Search | ✅ |
| ⭐ Bookmarks (persistent) | ✅ |
| 📥 Download Manager | ✅ |
| ⚙️ Settings (Search engine, Home page) | ✅ |
| ⏳ Loading Progress Bar | ✅ |

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter 3.x (Dart)** | Cross-platform UI framework |
| **flutter_inappwebview** | WebView engine with native features |
| **SharedPreferences** | Persistent local storage (settings, bookmarks) |
| **path_provider** | File system paths for downloads |
| **Dio** | HTTP client for file downloads |
| **permission_handler** | Runtime permissions (storage) |
| **Google Fonts (Inter)** | Typography |
| **StatefulWidget + setState** | Local state management |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point + Light/Dark theme config
├── models/
│   └── tab_model.dart           # BrowserTab & DownloadItem models
├── screens/
│   ├── browser_screen.dart      # Main browser with WebView + tabs
│   ├── bookmarks_screen.dart    # Bookmark list with delete
│   ├── downloads_screen.dart    # Download manager with file icons
│   └── settings_screen.dart     # Theme, Desktop mode, Search engine, Home page
├── utils/
│   └── user_agents.dart         # Desktop & Mobile User-Agent strings
└── widgets/
    ├── navigation_bar_widget.dart  # URL bar + nav buttons + desktop toggle
    └── tab_bar_widget.dart         # Horizontal scrollable tab switcher
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.2.0
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

```bash
git clone https://github.com/showab/flutter-browser.git
cd flutter-browser
flutter pub get
flutter run
```

### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name=android.permission.INTERNET/>
<uses-permission android:name=android.permission.WRITE_EXTERNAL_STORAGE/>
<uses-permission android:name=android.permission.READ_EXTERNAL_STORAGE/>
<uses-permission android:name=android.permission.ACCESS_NETWORK_STATE/>

<application android:usesCleartextTraffic=true ...>
```

---

## 👨‍💻 Author

**Showab Ahammad**
- GitHub: [@showab](https://github.com/showab)
- Portfolio Projects: RAG Chatbot, AI Agent, Realtime Chat, MLOps Pipeline, URL Shortener, AI SaaS

---

## 📄 License

MIT License — feel free to use, modify, and distribute.

---

⭐ **Star this repo** if you find it useful!
