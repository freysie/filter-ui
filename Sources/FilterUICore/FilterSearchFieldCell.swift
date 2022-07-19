import AppKit

/// The cell interface for AppKit filter fields.
public class FilterSearchFieldCell: NSSearchFieldCell {
  private static let padding = CGSize(width: -5, height: 3)
  // TODO: make this configurable!!!!
  // var accessoryWidth: CGFloat = 0 // 17
  var accessoryWidth: CGFloat { (controlView as? FilterSearchField)?.accessoryView?.bounds.width ?? 0 }
  var hasFilteringAppearance = false
  
  let filterImage = NSImage(systemSymbolName: .circledFilterIcon, accessibilityDescription: nil)!
    .withSymbolConfiguration(
      NSImage.SymbolConfiguration(paletteColors: [.secondaryLabelColor])
        .applying(.init(pointSize: 12, weight: .regular)) // TODO: get non-retina–friendly 13px version?
    )
  
  let activeFilterImage = NSImage(systemSymbolName: .activeFilterIcon, accessibilityDescription: nil)!
    .withSymbolConfiguration(
      NSImage.SymbolConfiguration(paletteColors: [.controlAccentColor])
        .applying(.init(pointSize: 12, weight: .regular)) // TODO: get non-retina–friendly 13px version?
    )
  
  public override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
    if hasFilteringAppearance {
      NSColor.textBackgroundColor.setFill()
      NSColor.secondaryLabelColor.setStroke()
    } else {
      NSColor.alternatingContentBackgroundColors[1].setFill()
      NSColor.quaternaryLabelColor.setStroke()
    }
    
    let path = NSBezierPath(roundedRect: cellFrame.insetBy(dx: 0.5, dy: 0.5), xRadius: 6, yRadius: 6)
    path.fill()
    path.stroke()

    drawInterior(withFrame: cellFrame, in: controlView)
  }
  
  public override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
    if let textView = textObj as? NSTextView {
      textView.smartInsertDeleteEnabled = false
    }
    
    return textObj
  }
  
  public override func calcDrawInfo(_ rect: NSRect) {
    super.calcDrawInfo(rect)
  }
  
  public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    // guard let filterButtonCell = searchButtonCell, let cancelButtonCell = cancelButtonCell else { return }
    guard let filterButtonCell = searchButtonCell else { return }

    filterButtonCell.image = stringValue.isEmpty ? filterImage : activeFilterImage
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
    super.searchButtonRect(forBounds: rect).offsetBy(dx: 2, dy: 0)
  }

  public override func cancelButtonRect(forBounds rect: NSRect) -> NSRect {
    var rect = super.cancelButtonRect(forBounds: rect).offsetBy(dx: -4, dy: 0)
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
