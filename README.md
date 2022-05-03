# Filter UI

Filter field for AppKit and SwiftUI.

![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/FilterField.png?raw=true)


## Installation

```swift
.package(url: "https://github.com/freyaariel/filter-ui.git", branch: "main")
```

```swift
import FilterUI
```


## Usage

### Basic Usage

```swift
FilterField(text: $filterText)
```


### Accessory Toggles

```swift
FilterField(text: $filterText, isFiltering: locationRequired) {
  FilterFieldToggle(systemImage: "location.square", isOn: $locationRequired)
    .help("Show only items with location data")
}
```


### AppKit Integration

`FilterField`’s underlying `NSSearchField` subclass can be used directly.

```swift
import FilterUICore

FilterField()

```
