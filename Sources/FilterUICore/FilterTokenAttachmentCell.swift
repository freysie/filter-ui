import AppKit

@preconcurrency @objcMembers open class FilterTokenAttachmentCell: NSTextAttachmentCell {
  open var isSelected = false

  public var tokenFieldValue: FilterTokenFieldValue? { representedObject as? FilterTokenFieldValue }

//  open override var objectValue: Any? {
////    get { tokenFieldValue?.objectValue }
////    set { super.objectValue = newValue }
//    didSet { print(("objectValue = ", objectValue)) }
//  }

//  open override var stringValue: String {
//    get {
//      // let stringValue = objectValue as? String ?? ""
//      switch tokenFieldValue?.operatorType ?? .contains {
//      case .contains: return super.stringValue
//      case .doesNotContain: return "≠" + super.stringValue
//      case .beginsWith: return super.stringValue + "•••"
//      case .endsWith: return "•••" + super.stringValue
//      }
//    }
//    set {}
//  }

//  open override var attributedStringValue: NSAttributedString {
//    get {}
//    set {}
//  }

  // MARK: - Layout

  open override func cellBaselineOffset() -> NSPoint {
    //print(NSMakePoint(0, font?.descender ?? 0))
    //return NSMakePoint(0, ((font?.descender ?? 0) - 1).rounded())
    NSMakePoint(0, font?.descender ?? 0)
  }

  open override func cellSize() -> NSSize {
    let textSize = (stringValue as NSString).size(withAttributes: [.font: font!])
    return NSMakeSize(textSize.width.rounded() + 12 + 1 + 3 * 2 + 2 * 2, 15)
  }
  
  func menuChevronRect(forBounds rect: NSRect) -> NSRect {
    NSMakeRect(rect.minX + 1, rect.minY, 14, 15)
  }

  open override func titleRect(forBounds rect: NSRect) -> NSRect {
    NSMakeRect(rect.minX + 2 + 12 + 1 + 3, rect.minY, rect.width - 12 - 1 - 3 * 2 - 2, rect.height).integral
  }

  // MARK: - Drawing

  open override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
    isSelected = false
    if let selectedRanges = (controlView as? NSTextView)?.selectedRanges {
      if selectedRanges.contains(where: { $0.rangeValue.contains(charIndex) }) {
        isSelected = true
      }
    }

    drawInterior(withFrame: cellFrame, in: controlView ?? NSView())
  }

  open override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int) {
    drawInterior(withFrame: cellFrame, in: controlView ?? NSView())
  }

  open override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    drawInterior(withFrame: cellFrame, in: controlView ?? NSView())
  }

  open override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    drawBackground(withFrame: cellFrame, in: controlView)
    drawMenuChevron(withFrame: cellFrame, in: controlView)
    drawTitle(withFrame: cellFrame.integral, in: controlView)
  }

  func drawBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
    var (firstRect, secondRect) = cellFrame.divided(atDistance: 14, from: .minXEdge)
    secondRect.origin.x += 1
    secondRect.size.width -= 1

    NSGraphicsContext.current?.saveGraphicsState()
    (isSelected ? NSColor.lightGray : NSColor.darkGray).setFill()
    firstRect.clip()
    NSBezierPath(roundedRect: cellFrame.insetBy(dx: 2, dy: 0), xRadius: 2, yRadius: 2).fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    NSGraphicsContext.current?.saveGraphicsState()
    (isSelected ? NSColor.lightGray : NSColor.darkGray.withAlphaComponent(0.65)).setFill()
    secondRect.clip()
    NSBezierPath(roundedRect: cellFrame.insetBy(dx: 2, dy: 0), xRadius: 2, yRadius: 2).fill()
    NSGraphicsContext.current?.restoreGraphicsState()
  }

  func drawMenuChevron(withFrame cellFrame: NSRect, in controlView: NSView) {
    guard let image = NSImage(systemSymbolName: "chevron.down", accessibilityDescription: nil)?
      .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 6, weight: .bold, scale: .medium))?
      .tinted(with: .textColor) else { return }

    image.draw(in: image.size.centered(in: menuChevronRect(forBounds: cellFrame)).integral)
  }

  func drawTitle(withFrame cellFrame: NSRect, in controlView: NSView) {
    (stringValue as NSString).draw(in: titleRect(forBounds: cellFrame), withAttributes: [
      .font: font!,
      .foregroundColor: NSColor.controlTextColor
    ])
  }

  // MARK: - Menu

  open override func wantsToTrackMouse(for theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, atCharacterIndex charIndex: Int) -> Bool {
    guard let controlView else { return false }

    let location = controlView.convert(theEvent.locationInWindow, from: nil)
    if menuChevronRect(forBounds: cellFrame).contains(location) {
      return true
    }

    return super.wantsToTrackMouse(for: theEvent, in: cellFrame, of: controlView, atCharacterIndex: charIndex)
  }

  open override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, untilMouseUp flag: Bool) -> Bool {
    guard let controlView else { return false }

    let location = controlView.convert(theEvent.locationInWindow, from: nil)
    if menuChevronRect(forBounds: cellFrame).contains(location), let menu {
      return menu.popUp(positioning: nil, at: NSMakePoint(cellFrame.minX, -menu.size.height + 3), in: controlView)
    }

    return super.trackMouse(with: theEvent, in: cellFrame, of: controlView, untilMouseUp: flag)
  }
}
