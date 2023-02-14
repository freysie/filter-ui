import AppKit
import ObjectiveC

/// The cell interface for AppKit filter fields with token capabilities.
@objcMembers open class FilterTokenFieldCell: NSTokenFieldCell, NSTokenFieldCellDelegate, FilterTokenTextStorageDelegate {
  public static var representedObjectKey: UInt8 = 0

  open var filterImage = Bundle.module.image(forResource: .filterMenuIcon)!.tinted(with: NSColor.secondaryLabelColor)
  open var activeFilterImage = Bundle.module.image(forResource: .activeFilterMenuIcon)!.tinted(with: .controlAccentColor)

  public override init(textCell string: String) {
    super.init(textCell: string)
    delegate = self
  }

  required public init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  open override var controlSize: NSControl.ControlSize {
    didSet { (controlView as? NSControl)?.invalidateIntrinsicContentSize(for: self) }
  }

  open func filterButtonRect(forBounds rect: NSRect) -> NSRect {
    NSRect(x: rect.minX + 4, y: ((rect.size.height - 15) / 2).rounded(.down), width: 28, height: 15)
  }

  open override func drawingRect(forBounds rect: NSRect) -> NSRect {
    super.drawingRect(forBounds: rect).insetBy(dx: 15.5, dy: 0).offsetBy(dx: 15.5, dy: 0)
  }

  // MARK: - Drawing

  open override var placeholderString: String? {
    didSet {
      placeholderAttributedString = placeholderString.map {
        NSAttributedString(string: $0, attributes: [
          .font: font!,
          .foregroundColor: controlView?.effectiveAppearance.allowsVibrancy == true
          ? NSColor(named: "vibrantPlaceholderText", bundle: .module)!
          : NSColor(named: "nonVibrantPlaceholderText", bundle: .module)!
        ])
      }
    }
  }

  open override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {}

  open override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
    //super.draw(withFrame: cellFrame, in: controlView)
    // NSDottedFrameRect(cellFrame)
    let shouldIncreaseContrast = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
    let allowsVibrancy = controlView.effectiveAppearance.allowsVibrancy
    let isKeyOrMainWindow = controlView.window?.isKeyWindow == true || controlView.window?.isMainWindow == true
    let hasKeyboardFocus = controlView.window?.firstResponder == (controlView as? NSControl)?.currentEditor()
    let hasActiveFilter = !stringValue.isEmpty

    if shouldIncreaseContrast || (isKeyOrMainWindow && (hasKeyboardFocus || hasActiveFilter)) {
      NSColor(named: "keyFocusBackground", bundle: .module)!.setFill()
    } else {
      if allowsVibrancy {
        if isKeyOrMainWindow {
          NSColor(named: "vibrantActiveBackground", bundle: .module)!.setFill()
        } else {
          NSColor(named: "vibrantInactiveBackground", bundle: .module)!.setFill()
        }
      } else {
        if isKeyOrMainWindow {
          NSColor(named: "nonVibrantActiveBackground", bundle: .module)!.setFill()
        } else {
          NSColor(named: "nonVibrantInactiveBackground", bundle: .module)!.setFill()
        }
      }
    }

    if shouldIncreaseContrast {
      if isKeyOrMainWindow {
        NSColor(named: "highContrastActiveBorder", bundle: .module)!.setStroke()
      } else {
        NSColor(named: "highContrastInactiveBorder", bundle: .module)!.setStroke()
      }
    } else {
      if allowsVibrancy {
        NSColor(calibratedWhite: 0.5, alpha: 0.25).setStroke()
      } else {
        if isKeyOrMainWindow && (hasActiveFilter || hasKeyboardFocus) {
          NSColor(calibratedWhite: 0.5, alpha: 0.7).setStroke()
        } else {
          NSColor(calibratedWhite: 0.5, alpha: 0.35).setStroke()
        }
      }
    }

    let path = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 0.5, dy: 0.5), xRadius: 6, yRadius: 6)
    // let path = NSBezierPath(roundedRect: cellFrame.integral, xRadius: 6, yRadius: 6)
    path.lineWidth = 1
    path.fill()
    path.stroke()

    (hasActiveFilter ? activeFilterImage : filterImage).draw(in: filterButtonRect(forBounds: cellFrame))

    drawInterior(withFrame: cellFrame, in: controlView)
  }

  //  public func tokenFieldCell(_ tokenFieldCell: FilterTokenFieldCell!, attachmentCellForRepresentedObject representedObject: Any!) -> NSTextAttachmentCell! {
  ////    let cell = FilterTokenAttachmentCell()
  ////    cell.representedObject = representedObject
  ////    return cell
  //    let cell = FilterTokenAttachmentCell(textCell: representedObject)!
  //    cell.tokenStyle = .squared
  //    return cell
  //  }

  // MARK: - Recents Menu
  // TODO: use NSView instead? at least fix the bug where clicking the icon selects all tokens

  open override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
    let location = controlView.convert(event.locationInWindow, from: nil)
    if filterButtonRect(forBounds: cellFrame).contains(location) {
      if let menu = menu(for: event, in: cellFrame, of: controlView) {
        return menu.popUp(positioning: nil, at: NSMakePoint(3, -menu.size.height + 6), in: controlView)
      }
    }

    return false
  }

  open override func menu(for event: NSEvent, in cellFrame: NSRect, of view: NSView) -> NSMenu? {
    let menu = NSMenu()
    menu.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    menu.addItem(withTitle: "Recent Filters", action: nil, keyEquivalent: "").isEnabled = false
    menu.addItem(withTitle: "Matching “aaaa”", action: nil, keyEquivalent: "").indentationLevel = 1
    menu.addItem(withTitle: "Matching “aaaaaaa”", action: nil, keyEquivalent: "").indentationLevel = 1
    menu.addItem(withTitle: "Matching “aa”", action: nil, keyEquivalent: "").indentationLevel = 1
    menu.addItem(.separator())
    menu.addItem(withTitle: "Clear Recents", action: nil, keyEquivalent: "")
    menu.autoenablesItems = false
    return menu
  }

  // MARK: - Attachment Cells

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, displayStringForRepresentedObject representedObject: Any) -> String? {
    guard let value = representedObject as? FilterTokenFieldValue, let string = value.objectValue as? String else { return nil }
    switch value.operatorType {
    case .contains: return string
    case .doesNotContain: return "≠" + string
    case .beginsWith: return string + "···"
    case .endsWith: return "•••" + string
    }
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, editingStringForRepresentedObject representedObject: Any) -> String? {
    guard let value = representedObject as? FilterTokenFieldValue else { return nil }
    return value.objectValue as? String
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, representedObjectForEditing editingString: String) -> Any? {
    FilterTokenFieldValue(objectValue: editingString, operatorType: .contains)
    // FilterTokenAttachmentCell()
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, readFrom pboard: NSPasteboard) -> [Any]? {
    pboard.readObjects(forClasses: [FilterTokenFieldValue.self])
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, writeRepresentedObjects objects: [Any], to pboard: NSPasteboard) -> Bool {
    // print(pboard)
    pboard.clearContents()
    if let objects = objects as? [NSPasteboardWriting] {
      return pboard.writeObjects(objects)
    } else {
      return false
    }
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, menuForRepresentedObject representedObject: Any) -> NSMenu? {
    guard let value = representedObject as? FilterTokenFieldValue else { return nil }

    let menu = FilterTokenFieldMenu()
    menu.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    menu.representedObject = representedObject as AnyObject
    for type in FilterTokenOperatorType.allCases {
      let item = menu.addItem(withTitle: type.displayName, action: #selector(FilterTokenField.takeOperatorTypeFromSender(_:)), keyEquivalent: "")
      item.state = type == value.operatorType ? .on : .off
      item.representedObject = type
    }
    menu.autoenablesItems = false
    return menu
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, hasMenuForRepresentedObject representedObject: Any) -> Bool {
    representedObject is FilterTokenFieldValue
  }

  public func tokenTextStorage(_ textStorage: FilterTokenTextStorage, updateTokenAttachment attachment: NSTextAttachment, forRange range: NSRange) {
    updateTokenAttachment(attachment, forAttributedString: textStorage.attributedSubstring(from: range))
  }

  open override var attributedStringValue: NSAttributedString {
    get {
      let attrString = super.attributedStringValue
      attrString.enumerateAttribute(.attachment, in: NSMakeRange(0, attrString.length)) { [self] attachment, range, _ in
        if let attachment = attachment as? NSTextAttachment {
          updateTokenAttachment(attachment, forAttributedString: attrString.attributedSubstring(from: range))
        }
      }
      return attrString
    }
    set {
      var objects = [Any?]()
      newValue.enumerateAttribute(.attachment, in: NSMakeRange(0, newValue.length)) { attachment, range, _ in
        if let attachment = attachment as? NSTextAttachment {
          // print((attachment, (attachment.attachmentCell as? NSCell)?.representedObject as Any))
          //objects.append(representedObjectWithAttachment(attachment, attributedString: newValue.attributedSubstring(from: range)))
          objects.append((attachment.attachmentCell as? NSCell)?.representedObject)
        }
      }
      objectValue = objects
    }
  }

  open override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
    let textObj = super.setUpFieldEditorAttributes(textObj)

    if let textView = textObj as? NSTextView, let layoutManager = textView.textContainer?.layoutManager {
      print(textView)

      if let textStorage = layoutManager.textStorage, !(textStorage is FilterTokenTextStorage) {
        let newTextStorage = FilterTokenTextStorage(textStorage: textStorage)
        layoutManager.replaceTextStorage(newTextStorage)
      }

      (layoutManager.textStorage as? FilterTokenTextStorage)?.tokenDelegate = self
    }

    return textObj
  }

  open override func endEditing(_ textObj: NSText) {
    if let textView = textObj as? NSTextView, let layoutManager = textView.textContainer?.layoutManager {
      (layoutManager.textStorage as? FilterTokenTextStorage)?.tokenDelegate = nil
    }

    super.endEditing(textObj)
  }

  func updateTokenAttachment(_ attachment: NSTextAttachment, forAttributedString attrString: NSAttributedString) {
    // print((attachment, (attachment.attachmentCell as? NSCell)?.objectValue, (attachment.attachmentCell as? NSCell)?.menu, (attachment.attachmentCell as? NSCell)?.representedObject, (attachment.attachmentCell as? NSCell)?.value(forKey: "_view"), (attachment.attachmentCell as? NSCell)?.value(forKey: "_representedObject"), (attachment.attachmentCell as? NSCell)?.value(forKey: "_textColor"), (attachment.attachmentCell as? NSCell)?.value(forKey: "menu"), (attachment.attachmentCell as? NSCell)?.value(forKey: "pullDownImage")))

    guard objc_getAssociatedObject(attachment, &Self.representedObjectKey) == nil else { return }
    guard let cell = attachment.attachmentCell as? NSCell else { return }

    let object = representedObjectWithAttachment(attachment, attributedString: attrString)
    objc_setAssociatedObject(attachment, &Self.representedObjectKey, object, .OBJC_ASSOCIATION_RETAIN)

    let newCell = FilterTokenAttachmentCell()
    newCell.font = font
    newCell.menu = cell.menu
    newCell.objectValue = cell.objectValue
    newCell.representedObject = cell.representedObject
    newCell.attachment = attachment
    attachment.attachmentCell = newCell
  }

  func representedObjectWithAttachment(_ attachment: NSTextAttachment, attributedString attrString: NSAttributedString) -> Any? {
    if let object = objc_getAssociatedObject(attachment, &Self.representedObjectKey) {
      return object as? FilterTokenFieldValue
    }

    let cell = NSTokenFieldCell()
    cell.attributedStringValue = attrString
    return (cell.objectValue as? NSArray)?.firstObject ?? attrString.string
    //return FilterTokenFieldValue(objectValue: (cell.objectValue as? NSArray)?.firstObject ?? attrString.string, operatorType: .beginsWith)
  }

}

open class FilterTokenFieldMenu: NSMenu {
  open weak var representedObject: AnyObject?
}
