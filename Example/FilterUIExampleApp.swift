import SwiftUI
@testable import FilterUI
@testable import FilterUICore
@testable import FilterUICoreObjC

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
//      FilterUI_Previews.previews
      
      FilteringMenu_Previews.previews
        .onAppear {
          print(FilterUICoreObjC.FilteringMenu2())
        }

      FilterField_Previews.previews
        .onAppear {
          print(FilterUICore.FilterSearchField())
        }
    }
  }
}
