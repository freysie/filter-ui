import AppKit

/// The cell interface for AppKit filter fields.
@objcMembers open class FilterSearchFieldCell: NSSearchFieldCell {
  private static let padding = CGSize(width: -5, height: 3)
  var accessoryWidth: CGFloat { (controlView as? FilterSearchField)?.accessoryView?.bounds.width ?? 0 }
  var hasSourceListAppearance = false
  var hasFilteringAppearance = false

  private var isInActiveWindow = false {
    didSet {
      cancelButtonCell?.isEnabled = isInActiveWindow
      controlView?.needsDisplay = true
    }
  }

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

  public override init(textCell string: String) {
    super.init(textCell: string)

    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    placeholderString = nil

    NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)), name: NSWindow.didBecomeKeyNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey(_:)), name: NSWindow.didResignKeyNotification, object: nil)

    if let cancelButtonCell {
      cancelButtonCell.image = NSImage(systemSymbolName: .clearIcon, accessibilityDescription: nil)!
//        .withSymbolConfiguration(
//          NSImage.SymbolConfiguration(paletteColors: [.textBackgroundColor, .secondaryLabelColor])
//            .applying(.init(pointSize: 12, weight: .regular))
//        )

      cancelButtonCell.alternateImage = NSImage(systemSymbolName: .clearIcon, accessibilityDescription: nil)!
        .withSymbolConfiguration(
          NSImage.SymbolConfiguration(paletteColors: [.textBackgroundColor, .textColor])
        //    .applying(.init(pointSize: 12, weight: .regular))
        )
    }
  }

  public required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc func windowDidBecomeKey(_ notification: Notification) { isInActiveWindow = true }
  @objc func windowDidResignKey(_ notification: Notification) { isInActiveWindow = false }
  
  open var filterImage = Bundle.module.image(forResource: .filterIcon)!
    .tinted(with: NSColor.secondaryLabelColor)
  
  open var activeFilterImage = Bundle.module.image(forResource: .activeFilterIcon)!
    .tinted(with: .controlAccentColor)

  open override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {}

  open override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
//    // this… i… help——
//    if hasFilteringAppearance {
//      NSColor.textBackgroundColor.setFill()
//      if hasSourceListAppearance {
//        if isInActiveWindow {
//          NSColor.secondaryLabelColor.withAlphaComponent(0.8).setStroke()
//        } else {
//          NSColor.secondaryLabelColor.withAlphaComponent(0.4).setStroke()
//        }
//      } else {
//        if isInActiveWindow {
//          NSColor.secondaryLabelColor.withAlphaComponent(0.4).setStroke()
//        } else {
//          NSColor.secondaryLabelColor.withAlphaComponent(0.2).setStroke()
//        }
//      }
//    } else {
//      if hasSourceListAppearance {
//        if isInActiveWindow {
//          // print(NSColor.unemphasizedSelectedContentBackgroundColor)
//          // print(NSColor.alternatingContentBackgroundColors[0])
//          NSColor.alternatingContentBackgroundColors[0].setFill()
//          //NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
//          //NSColor.alternatingContentBackgroundColors[0].setFill()
//          //NSColor.controlTextColor.withAlphaComponent(0.5).setFill()
//        } else {
//          NSColor.alternatingContentBackgroundColors[1].setFill()
//          // NSColor.alternatingContentBackgroundColors[1].setFill()
//          // NSColor.quaternaryLabelColor.setStroke()
//        }
//        NSColor.secondaryLabelColor.withAlphaComponent(0.3).setStroke()
//      } else {
//        if isInActiveWindow {
//          NSColor.windowBackgroundColor.setFill()
//        } else {
//          NSColor.textBackgroundColor.setFill()
//        }
//        NSColor.quaternaryLabelColor.withAlphaComponent(0.2).setStroke()
//      }
//    }

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
//    let path = NSBezierPath(roundedRect: cellFrame, xRadius: 6, yRadius: 6)
    path.lineWidth = 1
    path.fill()
    path.stroke()

    drawInterior(withFrame: cellFrame, in: controlView)
  }
  
  open override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
    let textObj = super.setUpFieldEditorAttributes(textObj)
    guard let textView = textObj as? NSTextView else { return textObj }
    print(textView)
    textView.smartInsertDeleteEnabled = false
    return textView
  }
  
  open override func calcDrawInfo(_ rect: NSRect) {
    super.calcDrawInfo(rect)
  }
  
  open override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    // guard let filterButtonCell = searchButtonCell, let cancelButtonCell = cancelButtonCell else { return }
    guard let filterButtonCell = searchButtonCell else { return }

    filterButtonCell.image = stringValue.isEmpty ? filterImage : activeFilterImage
    // filterButtonCell.image = filterImage
    filterButtonCell.alternateImage = searchButtonCell!.image
//    filterButtonCell.draw(withFrame: searchButtonRect(forBounds: cellFrame), in: controlView)

    let insetRect = cellFrame.insetBy(dx: Self.padding.width, dy: Self.padding.height - (controlSize == .small ? 1 : 0))
    super.drawInterior(withFrame: insetRect, in: controlView)

//    if !stringValue.isEmpty {
//      cancelButtonCell.draw(withFrame: cancelButtonRect(forBounds: cellFrame), in: controlView)
//    }
  }
  
  open override func cellSize(forBounds rect: NSRect) -> NSSize {
    var size = super.cellSize(forBounds: rect)
    size.height += ((Self.padding.height - (controlSize == .small ? 1 : 0)) * 2)
    return size
  }
  
  open override func searchTextRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.searchTextRect(forBounds: rect)
    rect.size.width -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    return rect
  }
  
  open override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
    super.searchButtonRect(forBounds: rect).offsetBy(dx: 2, dy: controlSize == .small ? 0 : -0.5)
  }

  open override func cancelButtonRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.cancelButtonRect(forBounds: rect).offsetBy(dx: -4, dy: controlSize == .small ? 0 : -0.5)
    rect.origin.x -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    return rect
  }
  
  open override func titleRect(forBounds rect: NSRect) -> NSRect {
    rect.insetBy(dx: Self.padding.width, dy: Self.padding.height - (controlSize == .small ? 1 : 0))
  }
  
//      open override func drawingRect(forBounds rect: NSRect) -> NSRect {
//        let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height - (controlSize == .small ? 1 : 0))
//        return super.drawingRect(forBounds: insetRect)
//      }
  
  open override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
    let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height - (controlSize == .small ? 1 : 0))
    // rect.size.width -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
  }
  
  open override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
    let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height - (controlSize == .small ? 1 : 0))
    super.select(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
  }
}

extension NSImage {
  func tinted(with color: NSColor) -> NSImage {
    return NSImage(size: size, flipped: false) { rect in
      color.set()
      rect.fill()
      self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1)
      return true
    }
  }
}
