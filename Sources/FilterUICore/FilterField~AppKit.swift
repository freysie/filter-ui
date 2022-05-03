import AppKit

/// An AppKit filter field.
public class FilterField: NSSearchField, CALayerDelegate {
  /// Whether accessory views are filtering.
  public var isFiltering = false {
    didSet {
      self.needsDisplay = true
      layer?.setNeedsDisplay()
    }
  }
  
  /// The field’s accessory view.
  public var accessoryView: NSView? {
    didSet {
      if let accessoryView = accessoryView {
        addSubview(accessoryView)
        
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          accessoryView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
          accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
        
        // (cell as? FilterFieldCell)?.accessoryWidth = accessoryView.bounds.width
      }
    }
    willSet {
      if newValue == nil {
        accessoryView?.removeFromSuperview()
      }
    }
  }

  public var iconColor = NSColor.secondaryLabelColor
  
  var hasFilteringAppearing: Bool {
    isFiltering || !stringValue.isEmpty || window?.firstResponder == currentEditor()
  }
  
  public override var allowsVibrancy: Bool { !hasFilteringAppearing }
  
  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    textColor = .textColor
    isBezeled = false
    isBordered = true
    wantsLayer = true
    focusRingType = .none
    drawsBackground = false
    // layerContentsRedrawPolicy = .onSetNeedsDisplay
    placeholderString = NSLocalizedString("Filter", comment: "")
    placeholderAttributedString = NSAttributedString(
      string: placeholderString!,
      attributes: [.font: font!, .foregroundColor: NSColor.tertiaryLabelColor]
    )
    
    //  print(layer!)
    //  print(layer!.sublayers as Any)
    //  print(layer!.debugDescription)
    //  print(heightAnchor.constraintsAffectingLayout as NSArray)
    
    translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 22)
    ])
    
    if let cancelButtonCell = (cell as! NSSearchFieldCell).cancelButtonCell {
      cancelButtonCell.image = NSImage(systemSymbolName: .clearIcon, accessibilityDescription: nil)!
        .withSymbolConfiguration(
          NSImage.SymbolConfiguration(paletteColors: [.secondaryLabelColor])
            .applying(.init(pointSize: 12, weight: .regular))
        )
      
      cancelButtonCell.alternateImage = NSImage(systemSymbolName: .clearIcon, accessibilityDescription: nil)!
        .withSymbolConfiguration(
          NSImage.SymbolConfiguration(paletteColors: [.textColor])
            .applying(.init(pointSize: 12, weight: .regular))
        )
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidChangeEffectiveAppearance() {
    self.needsDisplay = true
    layer?.setNeedsDisplay()
//      print((#function, layer))
  }
  
  public func layerWillDraw(_ layer: CALayer) {
//      print((#function, layer))
    // layer.cornerCurve = .continuous
    layer.cornerRadius = 7
    layer.borderWidth = 1
    
    if hasFilteringAppearing {
//        layer.borderColor = NSColor(r: 111, g: 111, b: 114).cgColor
      layer.borderColor = NSColor.tertiaryLabelColor.cgColor
      layer.backgroundColor = NSColor.textBackgroundColor.cgColor
//        layer.backgroundColor = NSColor(r: 30, g: 30, b: 30).cgColor
//        layer.backgroundColor = .black
    } else {
      layer.borderColor = NSColor.gridColor.cgColor
      layer.backgroundColor = NSColor.alternatingContentBackgroundColors[1].cgColor
    }
    
    if let searchButtonCell = (cell as! NSSearchFieldCell).searchButtonCell {
      if !stringValue.isEmpty {
        searchButtonCell.image = NSImage(systemSymbolName: .activeFilterIcon, accessibilityDescription: nil)!
          .withSymbolConfiguration(
            NSImage.SymbolConfiguration(paletteColors: [.controlAccentColor])
              .applying(.init(pointSize: 12, weight: .regular)) // TODO: get non-retina–friendly 13px version?
          )
      } else {
        searchButtonCell.image = NSImage(systemSymbolName: .filterIcon, accessibilityDescription: nil)!
          .withSymbolConfiguration(
            NSImage.SymbolConfiguration(paletteColors: [iconColor])
              .applying(.init(pointSize: 12, weight: .regular)) // TODO: get non-retina–friendly 13px version?
          )
      }
      
      searchButtonCell.alternateImage = searchButtonCell.image
    }
  }
  
  public override class var cellClass: AnyClass? { get { FilterFieldCell.self } set {} }
}

/// The cell interface for AppKit filter fields.
public class FilterFieldCell: NSSearchFieldCell {
  private static let padding = CGSize(width: -5, height: 3)
  // TODO: make this configurable!!!!
  // var accessoryWidth: CGFloat = 0 // 17
  var accessoryWidth: CGFloat { (controlView as? FilterField)?.accessoryView?.bounds.width ?? 0 }
  
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
  
  public override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    let insetRect = cellFrame.insetBy(dx: Self.padding.width, dy: Self.padding.height)
    super.drawInterior(withFrame: insetRect, in: controlView)
  }
}

fileprivate extension String {
  static let filterIcon = "line.3.horizontal.decrease.circle"
  static let activeFilterIcon = "line.3.horizontal.decrease.circle.fill"
  static let clearIcon = "xmark.circle.fill"
}
