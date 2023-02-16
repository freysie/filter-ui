import SwiftUI

struct NSViewPreview<View: NSView>: NSViewRepresentable {
  let view: View
  init(_ builder: @escaping () -> View) { view = builder() }
  func makeNSView(context: Context) -> NSView { view }
  func updateNSView(_ view: NSView, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}
