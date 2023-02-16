# Filter UI (🚧 Work in Progress 🚧)

Filter field <!--and menu filtering--> for AppKit and SwiftUI.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Screenshots/Logo~dark@2x.png?raw=true 2x, Screenshots/Logo~dark@1x.png?raw=true 1x">
  <source media="(prefers-color-scheme: light)" srcset="Screenshots/Logo~light@2x.png?raw=true 2x, Screenshots/Logo~light@1x.png?raw=true 1x">
  <img alt="" src="Screenshots/Logo~dark@2x.png?raw=true" width="640">
</picture>


## Installation

```swift
.package(url: "https://github.com/freyaalminde/filter-ui.git", branch: "main"),
```

```swift
.product(name: "FilterUI", package: "filter-ui"),
.product(name: "FilterUICore", package: "filter-ui"),
```


## Overview

### Filter Field

```swift
FilterField(text: $filterText)
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Screenshots/BasicUsage~dark@2x.png?raw=true 2x, Screenshots/BasicUsage~dark@1x.png?raw=true 1x">
  <source media="(prefers-color-scheme: light)" srcset="Screenshots/BasicUsage~light@2x.png?raw=true 2x, Screenshots/BasicUsage~light@1x.png?raw=true 1x">
  <img alt="" src="Screenshots/BasicUsage~dark@2x.png?raw=true" width="200">
</picture>


<!--### Filter Field with Custom Prompt-->
<!---->
<!--```swift-->
<!--FilterField(text: $filterText, prompt: "Hello")-->
<!--```-->


### Filter Field with Accessory Toggles

Toggles can be added to the trailing edge of the filter field by using `FilterToggle`.

```swift
FilterField(text: $filterText, isFiltering: locationRequired) {
  FilterToggle(systemImage: "location.square", isOn: $locationRequired)
    .help("Show only items with location data")
}
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Screenshots/AccessoryToggles~dark@2x.png?raw=true 2x, Screenshots/AccessoryToggles~dark@1x.png?raw=true 1x">
  <source media="(prefers-color-scheme: light)" srcset="Screenshots/AccessoryToggles~light@2x.png?raw=true 2x, Screenshots/AccessoryToggles~light@1x.png?raw=true 1x">
  <img alt="" src="Screenshots/AccessoryToggles~dark@2x.png?raw=true" width="200">
</picture>


### AppKit-Compatible Filter Field

`FilterField`’s underlying `NSSearchField` and `NSSearchFieldCell` subclasses can be used directly by importing `FilterUICore`.

```swift
import FilterUICore

FilterSearchField(frame: …)
FilterSearchFieldCell()
```


### Menu Filtering

FilterUI provides a subclass of `NSMenu` called `FilteringMenu` which add a filter field to the menu and its submenus, similar to how some menus in Xcode are filterable.

Menu filtering works by replacing the standard keystroke-based selection (type select). When a user presses a key, the filter field appears at the top of the menu and is focused.

While typing, menu items are filtered based on fuzzy search matching of the items’ titles. Matching parts of the titles will be displayed in bold and non-matching parts are grayed out.


## Roadmap

### 1.0

* Menu filtering
* Token field
* AppKit-based accessory views
* ~~Find solution to border issue~~
* Resolve text wrapping issue
* ~~Menu w/ pill-shaped icon?~~
* ~~Pixel-perfect 13 px filter icon?~~


### Later

* Mini, small, and large sizes
* Token fields should support keys


## Acknowledgements

Fuzzy search implementation is based on [FuzzySearch](https://github.com/viktorasl/FuzzySearch) by Viktoras Laukevičius.

Big thanks goes out to [OEXTokenField](https://github.com/octiplex/OEXTokenField) by 
Octiplex.

