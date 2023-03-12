# Filter UI

Filter field and menu filtering for AppKit and SwiftUI.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Screenshots/FilterUI~dark@2x.png?raw=true 2x, Screenshots/FilterUI~dark@1x.png?raw=true 1x">
  <source media="(prefers-color-scheme: light)" srcset="Screenshots/FilterUI~light@2x.png?raw=true 2x, Screenshots/FilterUI~light@1x.png?raw=true 1x">
  <img alt="" src="Screenshots/FilterUI~dark@2x.png?raw=true" width="640">
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

### Filter Search Field

A filter search field is a search field with special appearance and added functionality.

**Note:** Vibrancy affects the appearance.

```swift
let field = FilterSearchField()
```

<img alt="" src="Screenshots/FilterSearchField~dark@2x.png?raw=true" width="232">


Filter buttons can be added to the trailing edge of the filter field.

```swift
let field = FilterSearchField()
field.addFilterButton(systemSymbolName: "doc", toolTip: …)
field.addFilterButton(image: …, alternateImage: …, toolTip: …)
```

<img alt="" src="Screenshots/FilterSearchField_filterButton~dark@2x.png?raw=true" width="232">

Progress can be displayed, either indeterminate or determinate.

```swift
let field = FilterSearchField()
field.progress = FilterSearchField.indeterminateProgress
field.progress = 0.25 
```

<img alt="" src="Screenshots/FilterSearchField_progress~dark@2x.png?raw=true" width="232">


### Filter Token Field

Different operators can be used with the filter token field.

```swift
let field = FilterTokenField()
field.objectValue = [
    FilterTokenValue(objectValue: "Hello", comparisonType: .contains),
    FilterTokenValue(objectValue: "Filter UI", comparisonType: .doesNotContain),
]
```

<img alt="" src="Screenshots/FilterTokenField~dark@2x.png?raw=true" width="232">


### Filtering Menu

Filter UI provides a subclass of `NSMenu` called `FilteringMenu` which adds a filter field to the menu, similar to how the jump bar menus in Xcode are filterable.

Menu filtering works by replacing the standard keystroke-based selection (type select). When a user presses a key, the filter field appears at the top of the menu and is focused. While typing, menu items are filtered based on fuzzy matching of the items’ titles. Matching parts are displayed in bold while non-matching parts are grayed out.

<img alt="" src="Screenshots/FilteringMenu~dark@2x.png?raw=true" width="228">


## Roadmap

### 1.0

* ~~Menu filtering~~
* Token field
  - 1px top clipping issue
  - Users should be able to leave text without it turning into a token
* ~~AppKit-based accessory views~~
* ~~Find solution to border issue~~
* ~~Resolve text wrapping issue~~
* ~~Menu w/ pill-shaped icon?~~
* ~~Pixel-perfect 13 px filter icon?~~
* Resolve issues with cancel buttons
* Redo README


### Later

* Mini, small, and large sizes
* Token fields should support keys


## Acknowledgements

Fuzzy search implementation is based on [FuzzySearch](https://github.com/viktorasl/FuzzySearch) by Viktoras Laukevičius.

Big thanks goes out to [OEXTokenField](https://github.com/octiplex/OEXTokenField) by 
Octiplex for ideas on how to customize token fields.

