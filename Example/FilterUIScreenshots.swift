import SwiftUI
@_exported import PreviewsCapture

@main
struct ScreenshotApp: App {
  var body: some Scene {
    ScreenshotsScene { settings in
      settings.outputPath = "../../Screenshots"
    }
  }
}
