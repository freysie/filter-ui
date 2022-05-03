import SwiftUI
@testable import FilterUI
import FilterUICore

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      FilterField_Previews.previews
        .onAppear {
          print(FilterUICore.FilterField())
        }
    }
  }
}
