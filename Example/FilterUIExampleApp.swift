import SwiftUI
@testable import FilterUI
import FilterUICore

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      FilterMenuItem_Previews.previews
//      FilterField_Previews.previews
//        .onAppear {
//          print(FilterUICore.FilterField())
//        }
    }
  }
}
