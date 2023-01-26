import AppKit

/// The cell interface for AppKit filter fields.
public class FilterSearchFieldCell: NSSearchFieldCell {
  private static let padding = CGSize(width: -5, height: 3)
  // TODO: make this configurable!!!!
  // var accessoryWidth: CGFloat = 0 // 17
  var accessoryWidth: CGFloat { (controlView as? FilterSearchField)?.accessoryView?.bounds.width ?? 0 }
  var hasSourceListAppearance = false
  var hasFilteringAppearance = false

  var isInActiveWindow = false {
    didSet {
      cancelButtonCell?.isEnabled = isInActiveWindow
      controlView?.setNeedsDisplay(.infinite)
    }
  }

  override init(textCell string: String) {
    super.init(textCell: string)

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

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // isEnabled = isInActiveWindow
  @objc func windowDidBecomeKey(_ notification: Notification) { isInActiveWindow = true }
  @objc func windowDidResignKey(_ notification: Notification) { isInActiveWindow = false }
  
  static let filterImage = Bundle.module.image(forResource: .filterIcon)!
    .tinted(with: NSColor.secondaryLabelColor)
  
  static let activeFilterImage = Bundle.module.image(forResource: .activeFilterIcon)! 
    .tinted(with: .controlAccentColor)
  
  public override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
    // this… i… help——
    if hasFilteringAppearance {
      NSColor.textBackgroundColor.setFill()
      if hasSourceListAppearance {
        if isInActiveWindow {
          NSColor.secondaryLabelColor.withAlphaComponent(0.8).setStroke()
        } else {
          NSColor.secondaryLabelColor.withAlphaComponent(0.4).setStroke()
        }
      } else {
        if isInActiveWindow {
          NSColor.secondaryLabelColor.withAlphaComponent(0.4).setStroke()
        } else {
          NSColor.secondaryLabelColor.withAlphaComponent(0.2).setStroke()
        }
      }
    } else {
      if hasSourceListAppearance {
        if isInActiveWindow {
          // print(NSColor.unemphasizedSelectedContentBackgroundColor)
          // print(NSColor.alternatingContentBackgroundColors[0])
          NSColor.alternatingContentBackgroundColors[0].setFill()
          //NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
          //NSColor.alternatingContentBackgroundColors[0].setFill()
          //NSColor.controlTextColor.withAlphaComponent(0.5).setFill()
        } else {
          NSColor.alternatingContentBackgroundColors[1].setFill()
          // NSColor.alternatingContentBackgroundColors[1].setFill()
          // NSColor.quaternaryLabelColor.setStroke()
        }
        NSColor.secondaryLabelColor.withAlphaComponent(0.3).setStroke()
      } else {
        if isInActiveWindow {
          // NSColor.textBackgroundColor.withAlphaComponent(0.6).setFill()
          // NSColor.quaternaryLabelColor.withAlphaComponent(0.1).setFill()
          NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.6).setFill()
        } else {
          NSColor.textBackgroundColor.setFill()
        }
        NSColor.quaternaryLabelColor.withAlphaComponent(0.2).setStroke()
      }
    }
    
    let path = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 0.5, dy: 0.5), xRadius: 6, yRadius: 6)
//    let path = NSBezierPath(roundedRect: cellFrame, xRadius: 6, yRadius: 6)
    path.lineWidth = 1
    path.fill()
    path.stroke()

    drawInterior(withFrame: cellFrame, in: controlView)
  }
  
  public override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
    guard let textView = textObj as? NSTextView else { return textObj }
    textView.smartInsertDeleteEnabled = false
    return textView
  }
  
  public override func calcDrawInfo(_ rect: NSRect) {
    super.calcDrawInfo(rect)
  }
  
  public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    // guard let filterButtonCell = searchButtonCell, let cancelButtonCell = cancelButtonCell else { return }
    guard let filterButtonCell = searchButtonCell else { return }

    filterButtonCell.image = stringValue.isEmpty ? Self.filterImage : Self.activeFilterImage
    // filterButtonCell.image = filterImage
    filterButtonCell.alternateImage = searchButtonCell!.image
//    filterButtonCell.draw(withFrame: searchButtonRect(forBounds: cellFrame), in: controlView)

    let insetRect = cellFrame.insetBy(dx: Self.padding.width, dy: Self.padding.height)
    super.drawInterior(withFrame: insetRect, in: controlView)

//    if !stringValue.isEmpty {
//      cancelButtonCell.draw(withFrame: cancelButtonRect(forBounds: cellFrame), in: controlView)
//    }
  }
  
  public override func cellSize(forBounds rect: NSRect) -> NSSize {
    var size = super.cellSize(forBounds: rect)
    size.height += (Self.padding.height * 2)
    return size
  }
  
  public override func searchTextRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.searchTextRect(forBounds: rect)
    rect.size.width -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    return rect
  }
  
  public override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
    super.searchButtonRect(forBounds: rect).offsetBy(dx: 2, dy: -0.5)
  }

  public override func cancelButtonRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.cancelButtonRect(forBounds: rect).offsetBy(dx: -4, dy: -0.5)
    rect.origin.x -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    return rect
  }
  
  public override func titleRect(forBounds rect: NSRect) -> NSRect {
    rect.insetBy(dx: Self.padding.width, dy: Self.padding.height)
  }
  
//      public override func drawingRect(forBounds rect: NSRect) -> NSRect {
//        let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height)
//        return super.drawingRect(forBounds: insetRect)
//      }
  
  public override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
    let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height)
    // rect.size.width -= accessoryWidth + (accessoryWidth > 0 ? 1 : 0)
    super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
  }
  
  public override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
    let insetRect = rect.insetBy(dx: Self.padding.width, dy: Self.padding.height)
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
