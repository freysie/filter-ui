import SwiftUI
@testable import FilterUI
@testable import FilterUICore

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
//      FilterUI_Previews.previews
      
//      FilteringMenu_Previews.previews

      FilterField_Previews.previews
        .onAppear {
          print(FilterUICore.FilterSearchField())
        }
    }
  }
}
