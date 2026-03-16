# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FilterUI is a macOS-only (12.0+) Swift Package providing AppKit filter controls with SwiftUI wrappers. It replicates native Xcode-style filter fields and filterable menus. The package intentionally uses private AppKit/HIToolbox APIs for menu filtering.

## Build & CI

```bash
# Build
swift build 2>&1 | xcsift

# Build verbose (matches CI)
swift build -v
```

There are **no unit tests**. Visual verification is done through SwiftUI Previews and the Example app (`Example/FilterUIExample.xcodeproj`).

## Architecture

### Targets

- **FilterUI** — main Swift target containing all controls
- **FilterUIObjC** — Objective-C bridging target that exposes private API headers (`NSMenu.h`, `HIToolbox.h`) to Swift

### Core Components

| Component | Base Class | Purpose |
|-----------|-----------|---------|
| `FilterSearchField` + `FilterSearchFieldCell` | `NSSearchField` | Search field with progress indicator, filter buttons, and vibrancy-aware rendering |
| `FilterTokenField` + `FilterTokenFieldCell` | `NSTokenField` | Token-based filter field with comparison types (contains/beginsWith/endsWith/doesNotContain) |
| `FilteringMenu` | `NSMenu` | Filterable menu with fuzzy matching, uses private APIs for keystroke interception and highlight control |

### SwiftUI Layer (`Sources/FilterUI/SwiftUI/`)

- `FilterField` — `NSViewRepresentable` wrapping `FilterSearchField`
- `FilterToggle` — filter toggle button
- `filterFieldStyle(_:)` — environment modifier (`.plain` / `.sourceList`)

### Private API Usage

The `FilteringMenu` relies on private APIs exposed via `FilterUIObjC`:
- `NSMenu.highlightItem:` / `NSMenu._handleCarbonEvents:count:handler:` — menu item highlighting and Carbon event interception during menu tracking
- `HIMenuGetContentView` / `HIViewSetDrawingEnabled` / `HIViewSetNeedsDisplay` — flicker-free menu redrawing

Availability is checked at runtime via `responds(to:)`. An alternative implementation without private APIs exists in `Sources/FilterUI/FilteringMenu (Public)/` but is **not compiled** into the target.

### Key Patterns

- **Combine** is used in `FilterSearchField` to observe window state changes (`keyWindow`, `mainWindow`, `effectiveAppearance`) for triggering redraws
- **KVO** is used on filter button `state` changes to update tint colors
- Custom `NSTextStorage` subclass (`FilterTokenTextStorage`) intercepts attachment insertions to replace cells with `FilterTokenAttachmentCell`
- `FilterTokenValue` implements `NSPasteboardReading/Writing` for drag-and-drop support
- Wildcard syntax parsing: `foo*` → `.beginsWith`, `*foo` → `.endsWith`
- Colors in xcassets cover vibrancy/non-vibrancy × active/inactive × high-contrast variants
- macOS 26+ adaptations use `#available(macOS 26.0, *)` for rounded corners and `extraLarge` control size

### Dependencies

- [FuzzySearch](https://github.com/database-utility/fuzzy-search) — fuzzy string matching for `FilteringMenu`

### Localization

English (default) and Danish. Strings are in `Sources/FilterUI/Localization/`.
