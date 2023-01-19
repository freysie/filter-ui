import SwiftUI
@testable import FilterUI
import FilterUICore

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
//      NSMenuPreview_Previews.previews
      
//      FilterUI_Previews.previews
      
//      FilteringMenu_Previews.previews
      
//      FilterMenuItem_Previews.previews
      
      FilterField_Previews.previews
        .onAppear {
          print(FilterUICore.FilterSearchField())
        }
    }
  }
}
