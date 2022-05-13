# Filter UI

Filter field for AppKit and SwiftUI.

![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/FilterUI.png?raw=true)


## Installation

```swift
.package(url: "https://github.com/freyaariel/filter-ui.git", branch: "main")
```

```swift
import FilterUI
```


## Usage

### SwiftUI Usage

```swift
FilterField(text: $filterText)
```

![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/BasicUsage~light.png?raw=true#gh-light-mode-only)
![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/BasicUsage~dark.png?raw=true#gh-dark-mode-only)


<!--### Custom Prompt-->
<!---->
<!--```swift-->
<!--FilterField(text: $filterText, prompt: "Hello")-->
<!--```-->
<!---->

#### Accessory Toggles

Toggles can be added to the end of the filter field by using `FilterFieldToggle`.

```swift
FilterField(text: $filterText, isFiltering: locationRequired) {
  FilterFieldToggle(systemImage: "location.square", isOn: $locationRequired)
    .help("Show only items with location data")
}
```

![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/AccessoryToggles~light.png?raw=true#gh-light-mode-only)
![](https://github.com/freyaariel/filter-ui/blob/main/Screenshots/AccessoryToggles~dark.png?raw=true#gh-dark-mode-only)


### AppKit Usage

`FilterField`’s underlying `NSSearchField` subclass can be used directly by importing `FilterUICore`.

```swift
import FilterUICore

FilterUICore.FilterField(frame: …)
```


## Roadmap

### 1.0

* Find solution to border issue
* Resolve text wrapping issue


### Later

* More sizes?
* Menu w/ pill-shaped icon?
* Pixel-perfect 13 px filter icon?

