import SwiftUI
@testable import FilterUI

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        Form { Example() }.padding(5).frame(minWidth: 240) // .filterFieldStyle(.sourceList)
        Form { Example() }.padding().frame(minWidth: 380, maxWidth: 480) // .background(.regularMaterial)
      }
      .background {
        FilteringMenu_Previews.previews
      }
    }
  }
}

struct Example: View {
  @State var text1 = ""
  @State var text2 = "Hello!"
  @State var accessoryIsOn1 = false
  @State var accessoryIsOn2 = false
  @State var accessoryIsOn3 = false

  var body: some View {
    Group {
      //  FilterField(text: $text1)
      //    .filterFieldRecentsMenu(.visible)
      //
      //  FilterField(text: $text1, prompt: "Hello", isFiltering: onlyWithLocation)
      //    .filterToggle(systemImage: "location.square", isOn: $onlyWithLocation, "Show only items with location data")

      FilterSearchField_Previews.previews
      FilterTokenField_Previews.previews
    }
  }
}
