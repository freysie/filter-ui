import AppKit

/// An AppKit filter field.
@objcMembers open class FilterSearchField: NSSearchField, CALayerDelegate {
  open override class var cellClass: AnyClass? { get { FilterSearchFieldCell.self } set {} }

  /// Whether accessory views are filtering.
  open var isFiltering = false {
    didSet {
      self.needsDisplay = true
      layer?.setNeedsDisplay()
    }
  }
  
  /// The field’s accessory view.
  open var accessoryView: NSView? {
    didSet {
      if let accessoryView = accessoryView {
        addSubview(accessoryView)
        
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          accessoryView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
          accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
        
        // (cell as? FilterSearchFieldCell)?.accessoryWidth = accessoryView.bounds.width
      }
    }
    willSet {
      if newValue == nil {
        accessoryView?.removeFromSuperview()
      }
    }
  }

  open var hasSourceListAppearance = false

  open var hasFilteringAppearance: Bool {
    isFiltering || !stringValue.isEmpty || window?.firstResponder == currentEditor()
  }
  
  open override func viewWillDraw() {
    guard let cell = cell as? FilterSearchFieldCell else { return }
    cell.hasSourceListAppearance = hasSourceListAppearance
    cell.hasFilteringAppearance = hasFilteringAppearance
  }
  
//  open override var allowsVibrancy: Bool { !hasFilteringAppearance }

  open override var allowsVibrancy: Bool {
    let isFirstResponder = window?.firstResponder == currentEditor()
    let isFiltering = !stringValue.isEmpty
    return !(isFirstResponder || isFiltering)
  }

//  // FIXME?
//  open override var placeholderString: String? {
//    get { super.placeholderString }
//    set {
//      super.placeholderString = newValue ?? NSLocalizedString("Filter", bundle: .module, comment: "")
//      placeholderAttributedString = NSAttributedString(
//        string: placeholderString!,
//        attributes: [.font: font!, .foregroundColor: NSColor.secondaryLabelColor]
//      )
//    }
//  }

  open override var controlSize: NSControl.ControlSize {
    didSet { invalidateIntrinsicContentSize() }
  }

  open override var intrinsicContentSize: NSSize {
    switch controlSize {
    case .mini: return NSMakeSize(NSView.noIntrinsicMetric, 16)
    case .small: return NSMakeSize(NSView.noIntrinsicMetric, 19)
    case .regular: return NSMakeSize(NSView.noIntrinsicMetric, 22)
    case .large: return NSMakeSize(NSView.noIntrinsicMetric, 24)
    @unknown default: fatalError()
    }
  }

  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    // TODO: move most of this to the cell so it can be used individually
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    placeholderString = NSLocalizedString("Filter", bundle: .module, comment: "")
//    textColor = .textColor
//    isBezeled = false
//    isBordered = true
//    wantsLayer = true
//    focusRingType = .none
//    drawsBackground = false
    // layerContentsRedrawPolicy = .onSetNeedsDisplay

    // TODO: searchMenuTemplate
//    do {
//      let menu = NSMenu(title: "Search Options")
//
//      let noRecentsItem = NSMenuItem(title: NSLocalizedString("No Recents", comment: ""), action: nil, keyEquivalent: "")
//      noRecentsItem.tag = Self.noRecentsMenuItemTag
//      menu.addItem(noRecentsItem)
//
//      let titleItem = NSMenuItem(title: NSLocalizedString("Recents", comment: ""), action: nil, keyEquivalent: "")
//      titleItem.tag = Self.recentsTitleMenuItemTag
//      menu.addItem(titleItem)
//
//      let recentsItem = NSMenuItem(title: NSLocalizedString("Recents", comment: ""), action: nil, keyEquivalent: "")
//      recentsItem.tag = Self.recentsMenuItemTag
//      recentsItem.indentationLevel = 1
//      menu.addItem(recentsItem)
//
//      menu.addItem(.separator())
//
//      let clearItem = NSMenuItem(title: NSLocalizedString("Clear", comment: ""), action: nil, keyEquivalent: "")
//      clearItem.tag = Self.clearRecentsMenuItemTag
//      menu.addItem(clearItem)
//
//      searchMenuTemplate = menu
//    }
    
    //  print(layer!)
    //  print(layer!.sublayers as Any)
    //  print(layer!.debugDescription)
    //  print(heightAnchor.constraintsAffectingLayout as NSArray)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
