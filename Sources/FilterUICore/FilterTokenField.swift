import AppKit
import Combine

// TODO: type “foo*” to make startsWith token
// TODO: type “foo*bar” to make special token which can’t change type
// TODO: recents menu
// TODO: inactive appearance
// TODO: clear button
// TODO: menu should trigger on right click
// TODO: ≠, ••• with different font color
// FIXME: Y offset jitter
// FIXME: search icon shouldn’t select all tokens on click
// FIXME: single-line field editor

/// An AppKit filter field with token capabilities.
@objcMembers open class FilterTokenField: NSTokenField, NSTextViewDelegate {
  open override class var cellClass: AnyClass? { get { FilterTokenFieldCell.self } set {} }

  private var subscriptions = Set<AnyCancellable>()

  open override var intrinsicContentSize: NSSize {
    switch controlSize {
    case .mini: return NSMakeSize(NSView.noIntrinsicMetric, 16)
    case .small: return NSMakeSize(NSView.noIntrinsicMetric, 19)
    case .regular: return NSMakeSize(NSView.noIntrinsicMetric, 22)
    case .large: return NSMakeSize(NSView.noIntrinsicMetric, 24)
    @unknown default: fatalError()
    }
  }

  open override var allowsVibrancy: Bool {
    let isFirstResponder = window?.firstResponder == currentEditor()
    let isFiltering = !stringValue.isEmpty
    return !(isFirstResponder || isFiltering)
  }

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    tokenStyle = .squared
    usesSingleLineMode = true
    placeholderString = NSLocalizedString("Filter", bundle: .module, comment: "")

    Publishers.MergeMany(
      NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification, object: nil),
      NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification, object: nil)
    )
    .sink { _ in self.needsDisplay = true }
    .store(in: &subscriptions)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func takeOperatorTypeFromSender(_ sender: NSMenuItem?) {
    if let type = sender?.representedObject as? FilterTokenOperatorType {
      ((sender?.menu as? FilterTokenFieldMenu)?.representedObject as? FilterTokenFieldValue)?.operatorType = type
      refreshTokens()
    }
  }

  open func refreshTokens() {
    if let range = currentEditor()?.selectedRange {
//      let value = attributedStringValue
//      objectValue = nil
//      attributedStringValue = value
      let value = objectValue
      objectValue = nil
      objectValue = value
      currentEditor()?.selectedRange = range
      currentEditor()?.scrollRangeToVisible(range)
    }

    //validateEditing()
  }

//  open func untokenizeAttachment(_ attachment: NSTextAttachment, at range: NSRange) {}

  public func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
    textView.setSelectedRange(NSMakeRange(charIndex, 1))
  }

  public func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
    textView.replaceCharacters(in: NSMakeRange(charIndex, 1), with: (cell as? NSCell)?.stringValue ?? "")
  }
}

import SwiftUI

struct NSViewPreview<View: NSView>: NSViewRepresentable {
  let view: View
  init(_ builder: @escaping () -> View) {
    view = builder()
  }
  func makeNSView(context: Context) -> NSView {
    view
  }
  func updateNSView(_ view: NSView, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}

struct FilterTokenField_Previews: PreviewProvider {
  static var previews: some View {
    NSViewPreview {
      let field = FilterTokenField()
      // field.controlSize = .large
      return field
    }
    .padding()
  }
}
