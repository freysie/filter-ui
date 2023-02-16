import AppKit
import Combine

// ✓ TODO: type “foo*” to make startsWith token
// ✓ TODO: type “foo*bar” or “*foo*” to make special token which can’t change type
// TODO: recents menu
// ✓ TODO: inactive appearance
// ✓ TODO: clear button
// ✓ TODO: menu should trigger on right click
// ✓ TODO: ≠, ••• with different font color
// ✓ TODO: light mode
// ✓ TODO: don’t interfere with standard token fields
// TODO: ability to leave a string in the field without it turning into a token
// FIXME: Y offset jitter
// ✓ FIXME: search icon shouldn’t select all tokens on click
// ✓ FIXME: single-line field editor

/// An AppKit filter field with token capabilities.
@objcMembers open class FilterTokenField: NSTokenField, NSTextViewDelegate {
  open override class var cellClass: AnyClass? { get { FilterTokenFieldCell.self } set {} }

  open var searchButton: FilterTokenFieldButton!
  open var cancelButton: FilterTokenFieldButton!

  open var filterImage = Bundle.module.image(forResource: "filter.menu")!//.tinted(with: .secondaryLabelColor)
  open var activeFilterImage = Bundle.module.image(forResource: "filter.menu.fill")!.tinted(with: .controlAccentColor)

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

    searchButton = FilterTokenFieldButton(frame: NSMakeRect(2, 0, 32, frameRect.height))
    searchButton.autoresizingMask = [.maxXMargin, .height]
    searchButton.setButtonType(.momentaryLight)
    searchButton.sendAction(on: .leftMouseDown)
    searchButton.image = filterImage
    searchButton.target = self
    searchButton.action = #selector(popUpMenu)
    addSubview(searchButton)

    cancelButton = FilterTokenFieldButton(frame: NSMakeRect(frameRect.width - 24, 0, 24, frameRect.height))
    cancelButton.autoresizingMask = [.minXMargin, .height]
    cancelButton.setButtonType(.momentaryChange)
    cancelButton.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)!
      .withSymbolConfiguration(
        NSImage.SymbolConfiguration(paletteColors: [.textBackgroundColor, .secondaryLabelColor])
          .applying(NSImage.SymbolConfiguration(pointSize: 12, weight: .regular))
      )
    cancelButton.alternateImage = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil)!
      .withSymbolConfiguration(
        NSImage.SymbolConfiguration(paletteColors: [.textBackgroundColor, .textColor])
          .applying(NSImage.SymbolConfiguration(pointSize: 12, weight: .regular))
      )
    cancelButton.target = self
    cancelButton.action = #selector(clearTokens)
    cancelButton.wantsLayer = true
    cancelButton.layer?.sublayerTransform = CATransform3DMakeTranslation(0, -1, 0)
    addSubview(cancelButton)

    Publishers.MergeMany(
      NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification, object: nil),
      NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification, object: nil)
    )
    .sink { _ in self.needsDisplay = true }
    .store(in: &subscriptions)

    objectValueDidChange()
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open func objectValueDidChange() {
    cancelButton?.isHidden = stringValue.isEmpty
    searchButton?.image = stringValue.isEmpty ? filterImage : activeFilterImage
  }

  open override func textDidChange(_ notification: Notification) {
    super.textDidChange(notification)
    objectValueDidChange()
  }

  open func takeComparisonTypeFromSender(_ sender: NSMenuItem) {
    if let type = FilterTokenComparisonType(rawValue: sender.tag) {
      (sender.representedObject as? FilterTokenValue)?.comparisonType = type
      refreshTokens()
    }
  }

  open func popUpMenu() {
    let menu = NSMenu()
    menu.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    menu.autoenablesItems = false
    menu.addItem(withTitle: NSLocalizedString("Recent Filters", bundle: .module, comment: ""), action: nil, keyEquivalent: "")
      .isEnabled = false
    for value in ["aaaA", "aaaaaa", "aaa"] {
      menu.addItem(
        withTitle: String(format: NSLocalizedString("Matching %@", bundle: .module, comment: ""), "“\(value)”"),
        action: nil,
        keyEquivalent: ""
      )
        .indentationLevel = 1
    }
    menu.addItem(.separator())
    menu.addItem(withTitle: NSLocalizedString("Clear Recents", bundle: .module, comment: ""), action: nil, keyEquivalent: "")
    menu.popUp(positioning: nil, at: NSMakePoint(1, -menu.size.height + 6), in: searchButton)
  }

  open func refreshTokens() {
    if let range = currentEditor()?.selectedRange {
      // let value = attributedStringValue
      // objectValue = nil
      // attributedStringValue = value
      let value = objectValue
      objectValue = nil
      objectValue = value
      currentEditor()?.selectedRange = range
      currentEditor()?.scrollRangeToVisible(range)
    }

    validateEditing()
  }

  open func clearTokens() {
    stringValue = ""
    objectValueDidChange()
  }

  open override func cancelOperation(_ sender: Any?) {
    clearTokens()
  }

//  open func untokenizeAttachment(_ attachment: NSTextAttachment, at range: NSRange) {}

//  open override func textDidChange(_ notification: Notification) {
//    super.textDidChange(notification)
//    print((#function, notification))
//  }

//  public func textView(_ textView: NSTextView, shouldChangeTypingAttributes oldTypingAttributes: [String : Any] = [:], toAttributes newTypingAttributes: [NSAttributedString.Key : Any] = [:]) -> [NSAttributedString.Key : Any] {
//    print((#function, oldTypingAttributes, newTypingAttributes))
//    return newTypingAttributes
//  }

  open override func textShouldEndEditing(_ textObject: NSText) -> Bool {
    print(#function)
    return super.textShouldEndEditing(textObject)
  }

  // var isBecomingFirstResponder = false
  // open override func becomeFirstResponder() -> Bool {
  //   isBecomingFirstResponder = true
  //   let returnValue = super.becomeFirstResponder()
  //   isBecomingFirstResponder = false
  //   return returnValue
  // }

//  public func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
//    print(#function)
//    return newSelectedCharRange
//  }

  open override func textDidEndEditing(_ notification: Notification) {
    let text = notification.object as! NSText
    print((#function, text.string))
    super.textDidEndEditing(notification)
    // print((#function, text.string, objectValue))
    // cell!.endEditing(notification.object as! NSText)
  }

  open override func resignFirstResponder() -> Bool {
    // print(#function)
    return super.resignFirstResponder()
  }

  // MARK: - Text View Delegate

  public func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
    textView.setSelectedRange(NSMakeRange(charIndex, 1))
  }

  public func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
    textView.replaceCharacters(in: NSMakeRange(charIndex, 1), with: (cell as? NSCell)?.stringValue ?? "")
  }
}

// MARK: -

import SwiftUI
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
