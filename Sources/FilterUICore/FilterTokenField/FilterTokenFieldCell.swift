import AppKit
import ObjectiveC

// TODO: unify background drawing with FilterSearchFieldCell

/// The cell interface for AppKit filter fields with token capabilities.
@objcMembers open class FilterTokenFieldCell: NSTokenFieldCell, NSTokenFieldCellDelegate, FilterTokenTextStorageDelegate {
  public static var representedObjectKey: UInt8 = 0
  public static let wildCardPattern = try! NSRegularExpression(pattern: ".+\\*.+|^\\*.+\\*$")

  public override init(textCell string: String) {
    super.init(textCell: string)
    delegate = self
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    placeholderString = nil
    isScrollable = true
  }

  public required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  // open override var controlSize: NSControl.ControlSize {
  //   didSet { (controlView as? NSControl)?.invalidateIntrinsicContentSize(for: self) }
  // }

  // open func filterButtonRect(forBounds rect: NSRect) -> NSRect {
  //   NSRect(x: rect.minX + 4, y: ((rect.size.height - 15) / 2).rounded(.down), width: 28, height: 15)
  // }

  // open func cancelButtonRect(forBounds rect: NSRect) -> NSRect {
  //   NSRect(x: rect.maxX - 20, y: ((rect.size.height - 15) / 2).rounded(.down), width: 24, height: 15)
  // }

  open override func drawingRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.drawingRect(forBounds: rect)
    rect.origin.x += 28 + 3
    rect.size.width -= 28 + 3 + 24
    return rect
  }

  // MARK: - Drawing

  open override var placeholderString: String? {
    didSet {
      placeholderAttributedString = NSAttributedString(
        string: placeholderString ?? NSLocalizedString("Filter", bundle: .module, comment: ""),
        attributes: [
          .font: font!,
          .foregroundColor: controlView?.effectiveAppearance.allowsVibrancy == true
          ? NSColor(named: "filterFieldVibrantPlaceholderTextColor", bundle: .module)!
          : NSColor(named: "filterFieldNonVibrantPlaceholderTextColor", bundle: .module)!
        ]
      )
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
      NSColor(named: "filterFieldKeyFocusBackgroundColor", bundle: .module)!.setFill()
    } else {
      if allowsVibrancy {
        if isKeyOrMainWindow {
          NSColor(named: "filterFieldVibrantActiveBackgroundColor", bundle: .module)!.setFill()
        } else {
          NSColor(named: "filterFieldVibrantInactiveBackgroundColor", bundle: .module)!.setFill()
        }
      } else {
        if isKeyOrMainWindow {
          NSColor(named: "filterFieldNonVibrantActiveBackgroundColor", bundle: .module)!.setFill()
        } else {
          NSColor(named: "filterFieldNonVibrantInactiveBackgroundColor", bundle: .module)!.setFill()
        }
      }
    }

    if shouldIncreaseContrast {
      if isKeyOrMainWindow {
        NSColor(named: "filterFieldHighContrastActiveBorderColor", bundle: .module)!.setStroke()
      } else {
        NSColor(named: "filterFieldHighContrastInactiveBorderColor", bundle: .module)!.setStroke()
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

    // (hasActiveFilter ? activeFilterImage : filterImage).draw(in: filterButtonRect(forBounds: cellFrame))

    drawInterior(withFrame: cellFrame, in: controlView)
  }

  // MARK: - Token Field Cell Delegate

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, shouldAdd tokens: [Any], at index: Int) -> [Any] {
    print((#function, tokens, index))
    return tokens
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, displayStringForRepresentedObject representedObject: Any) -> String? {
    (representedObject as? FilterTokenValue)?.objectValue as? String
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, editingStringForRepresentedObject representedObject: Any) -> String? {
    guard let value = representedObject as? FilterTokenValue else { return nil }
    return value.objectValue as? String
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, representedObjectForEditing editingString: String) -> Any? {
    //let hasKeyboardFocus = controlView?.window?.firstResponder == (controlView as? NSControl)?.currentEditor()
    // print((#function, editingString, isEditable, isHighlighted))
    let editingString = editingString.trimmingCharacters(in: .whitespacesAndNewlines)
    if Self.wildCardPattern.numberOfMatches(in: editingString, range: NSMakeRange(0, editingString.count)) > 0 {
      return FilterTokenValue(objectValue: editingString, comparisonType: nil)
    } else if editingString.hasPrefix("*") {
      return FilterTokenValue(objectValue: String(editingString.dropFirst()), comparisonType: .endsWith)
    } else if editingString.hasSuffix("*") {
      return FilterTokenValue(objectValue: String(editingString.dropLast()), comparisonType: .beginsWith)
    } else {
      return FilterTokenValue(objectValue: editingString, comparisonType: .contains)
    }
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, readFrom pboard: NSPasteboard) -> [Any]? {
    pboard.readObjects(forClasses: [FilterTokenValue.self])
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
    guard let value = representedObject as? FilterTokenValue else { return nil }

    let menu = NSMenu()
    menu.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    for type in FilterTokenComparisonType.allCases {
      let item = menu.addItem(
        withTitle: type.displayName,
        action: #selector(FilterTokenField.takeComparisonTypeFromSender(_:)),
        keyEquivalent: ""
      )
      item.tag = type.rawValue
      item.state = type == value.comparisonType ? .on : .off
      item.representedObject = representedObject
    }
    menu.autoenablesItems = false
    return menu
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, hasMenuForRepresentedObject representedObject: Any) -> Bool {
    representedObject is FilterTokenValue
  }

  public func tokenFieldCell(_ tokenFieldCell: NSTokenFieldCell, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
    print((#function, representedObject))
    return representedObject is String ? .none : .squared
  }

  // MARK: - Token Text Storage Delegate

  public func tokenTextStorage(_ textStorage: FilterTokenTextStorage, updateTokenAttachment attachment: NSTextAttachment, forRange range: NSRange) {
    if (attachment.attachmentCell as? NSCell)?.representedObject is FilterTokenValue {
      updateTokenAttachment(attachment, forAttributedString: textStorage.attributedSubstring(from: range))
    }
  }

  // MARK: - Attachment Cell Handling

  open override var objectValue: Any? {
    didSet {
      print((Self.self, #function))
    }
  }

//  open override var objectValue: Any? {
//    get { super.objectValue }
//    set { super.objectValue = newValue }
//    didSet { (controlView as? FilterTokenField)?.objectValueDidChange() }
//  }

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
      let attrString = newValue
      // print(attrString)
      attrString.enumerateAttribute(.attachment, in: NSMakeRange(0, attrString.length)) { [self] attachment, range, _ in
        if let attachment = attachment as? NSTextAttachment {
          updateTokenAttachment(attachment, forAttributedString: attrString.attributedSubstring(from: range))
        }
      }
      super.attributedStringValue = attrString
      // (controlView as? FilterTokenField)?.objectValueDidChange()
    }
//    set {
//      var objects = [Any?]()
//      newValue.enumerateAttribute(.attachment, in: NSMakeRange(0, newValue.length)) { attachment, range, _ in
//        if let attachment = attachment as? NSTextAttachment {
//          // print((attachment, (attachment.attachmentCell as? NSCell)?.representedObject as Any))
//          //objects.append(representedObjectWithAttachment(attachment, attributedString: newValue.attributedSubstring(from: range)))
//          objects.append((attachment.attachmentCell as? NSCell)?.representedObject)
//        }
//      }
//      objectValue = objects
//    }
  }

  open override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
    let textObj = super.setUpFieldEditorAttributes(textObj)

    if let textView = textObj as? NSTextView, let layoutManager = textView.textContainer?.layoutManager {
      if let textStorage = layoutManager.textStorage, !(textStorage is FilterTokenTextStorage) {
        let newTextStorage = FilterTokenTextStorage(textStorage: textStorage)
        layoutManager.replaceTextStorage(newTextStorage)
      }

      (layoutManager.textStorage as? FilterTokenTextStorage)?.tokenDelegate = self
    }

    return textObj
  }

  open override func endEditing(_ textObj: NSText) {
    print(#function)
    
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
      return object as? FilterTokenValue
    }

    let cell = NSTokenFieldCell()
    cell.attributedStringValue = attrString
    return (cell.objectValue as? NSArray)?.firstObject ?? attrString.string
  }
}
