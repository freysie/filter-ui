import SwiftUI
@testable import FilterUI
@testable import FilterUICore
import Screenshotting
import ScreenshottingRNG

@main
struct ScreenshottingApp: App {
  var body: some Scene {
    ScreenshottingScene()
  }
}

class FilterUI_Screenshots: PreviewProvider {
  static var previews: some View {
    FilterFieldStacks()
      .background()
      .previewDisplayName("README Banner")
      .screenshot("FilterUI-1", scale: 2)

    FilterFieldStacks(caret: true)
      .background()
      .previewDisplayName("README Banner w/ caret")
      .screenshot("FilterUI-2", scale: 2)

    VStack {
      NSViewPreview<FilterSearchField>()
        .background(.bar)
      NSViewPreview<FilterSearchField>()
      NSViewPreview<FilterSearchField> { f in
        f.stringValue = "Hello Filter UI"
      }
    }
    .padding()
    //.background(Color(red: 41/255, green: 42/255, blue: 48/255))
    .background()
    .frame(width: 232)
    .previewDisplayName("Search Field")
    .screenshot("FilterSearchField", colorScheme: .dark, scale: 2)

    VStack {
      NSViewPreview<FilterSearchField> { f in
        f.addFilterButton(symbolName: "doc.raster", toolTip: "")
      }
      .background(.bar)
      NSViewPreview<FilterSearchField> { f in
        f.addFilterButton(symbolName: "doc.raster", toolTip: "").state = .on
      }
      .background(.bar)
      NSViewPreview<FilterSearchField> { f in
        f.stringValue = "Hello Filter UI"
        f.addFilterButton(symbolName: "doc.raster", toolTip: "").state = .on
      }
      .background(.bar)
    }
    .padding()
    .background()
    .frame(width: 232)
    .previewDisplayName("Search Field w/ Filter Button")
    .screenshot("FilterSearchField_filterButton", colorScheme: .dark, scale: 2)

    VStack {
      NSViewPreview<FilterSearchField> { f in f.progress = FilterSearchField.indeterminateProgress }
        .background(.bar)
      NSViewPreview<FilterSearchField> { f in f.progress = 0.25 }
        .background(.bar)

      NSViewPreview<FilterSearchField> { f in f.progress = FilterSearchField.indeterminateProgress }
      NSViewPreview<FilterSearchField> { f in f.progress = 0.25 }
    }
    .padding()
    .background()
    .frame(width: 232)
    .previewDisplayName("Search Field w/ Progress")
    .screenshot("FilterSearchField_progress", colorScheme: .dark, scale: 2)

    VStack {
      NSViewPreview<FilterTokenField>()
        .background(.bar)

      NSViewPreview<FilterTokenField>()

      NSViewPreview<FilterTokenField> { f in
        f.objectValue = [
          FilterTokenValue(objectValue: "Hello", comparisonType: .contains),
          FilterTokenValue(objectValue: "Filter UI", comparisonType: .contains),
        ]
      }
      .background(.bar)

      // Divider()
      //   .opacity(0)

      NSViewPreview<FilterTokenField> { f in
        f.objectValue = [FilterTokenValue(objectValue: "Does Not Contain", comparisonType: .doesNotContain)]
      }
      .background(.bar)

      NSViewPreview<FilterTokenField> { f in
        f.objectValue = [FilterTokenValue(objectValue: "Begins With", comparisonType: .beginsWith)]
      }
      .background(.bar)

      NSViewPreview<FilterTokenField> { f in
        f.objectValue = [FilterTokenValue(objectValue: "Ends With", comparisonType: .endsWith)]
      }
      .background(.bar)
    }
    .padding()
    .background()
    .frame(width: 232)
    .previewDisplayName("Token Field")
    .screenshot("FilterTokenField", colorScheme: .dark, scale: 2)
  }

  // TODO: don’t offset but have varying widths instead?
  struct FilterFieldStacks: View {
    var caret = false

    //@State var rng = Rand48RandomNumberGenerator(seed: 0x1)
    //@State var rng = Xoroshiro256StarStarRandomNumberGenerator(seed: (0, 0, 0, 2))
    @State var rng = GKMersenneTwisterRandomSource(seed: 0x1)

    var body: some View {
      let offset: CGFloat = 8
      return VStack {
        row().offset(x: offset * -3)
        row().offset(x: offset * -2)//.offset(x: 50, y: 0)
        row().offset(x: offset * -1)//.offset(x: -50, y: 0)

        HStack(alignment: .top) {
          field()
          //NSViewPreview { FilterTokenField() }.frame(width: 172)
          FilterField(text: .constant("Filter UI")).frame(width: 172)
            .overlay { if caret { Rectangle().size(width: 1, height: 14).offset(x: 63, y: 4).fill(.primary) } }

          //          Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath))) ?? NSImage())
          //            .padding(-20)

          //          FilterSearchField(text: .constant("!!!")).frame(width: 172)
          //            .overlay {
          //              Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath)))!)
          //            }

          field()
        }

        row().offset(x: offset * 1)//.offset(x: 50, y: 0)
        row().offset(x: offset * 2)//.offset(x: -50, y: 0)
        row().offset(x: offset * 3)
      }
      .frame(width: 640, height: 240)
    }

    func row() -> some View {
      HStack {
        ForEach(0..<3) { _ in
          field()
        }
      }
    }

    func field() -> some View {
      FilterField(text: .constant(""), onMake: { f in
        // for _ in 0..<Int.random(in: 0...3, using: &rng) { addToggle(f) }
      })
      .background(.bar)
      .frame(width: 172)
    }

    func addToggle(_ field: FilterSearchField) {
      field.addFilterButton(systemSymbolName: Self.logoToggleImages.randomElement(using: &rng)!, toolTip: "")
    }

    static let logoToggleImages = [
      //"location.square",
      //"tag.square",
      //"wifi.square",
      //"bookmark.square",
      //"heart.square",
      //"star.square",
      //"flag.square",
      //"bolt.square",
      //"eye.square",
      //"icloud.square",
      //"lock.square",
      //"square.text.square",
      //"person.crop.square",
      //"bell.square",
      //"dot.square",
      //"pin.square",
      //"mic.square",
      "clock",
      "doc",
      //"c.square",
    ]
  }
}
