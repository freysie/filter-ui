import SwiftUI

struct NSViewPreview<View: NSView>: NSViewRepresentable {
  let view: View

  init(_ builder: @escaping () -> View) {
    view = builder()
  }

  init(_ setUp: ((View) -> ())? = nil) {
    view = View()
    setUp?(view)
  }

  func makeNSView(context: Context) -> NSView {
    view
  }

  func updateNSView(_ view: NSView, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}
