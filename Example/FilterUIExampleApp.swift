import SwiftUI
@testable import FilterUI
@testable import FilterUICore

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      // FilterUI_Previews.previews
      
      FilterField_Previews.previews
        .onAppear { _ = FilterUICore.FilterSearchField() }
        .background {
          FilteringMenu_Previews.previews
        }
    }
  }
}
