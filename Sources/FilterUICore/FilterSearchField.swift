import AppKit

// TODO: change background and border colors based on window key state

/// An AppKit filter field.
open class FilterSearchField: NSSearchField, CALayerDelegate {
  open override class var cellClass: AnyClass? { get { FilterSearchFieldCell.self } set {} }

  /// Whether accessory views are filtering.
  open var isFiltering = false {
    didSet {
      self.needsDisplay = true
      layer?.setNeedsDisplay()
    }
  }
  
  // public override var canBecomeKeyView: Bool { true }
  
  // public override var needsPanelToBecomeKey: Bool { true }
  
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
  
  open override var allowsVibrancy: Bool { !hasFilteringAppearance }

  // FIXME?
  open override var placeholderString: String? {
    get { super.placeholderString }
    set {
      super.placeholderString = newValue ?? NSLocalizedString("Filter", bundle: .module, comment: "")
      placeholderAttributedString = NSAttributedString(
        string: placeholderString!,
        attributes: [.font: font!, .foregroundColor: NSColor.secondaryLabelColor]
      )
    }
  }

  open override var intrinsicContentSize: NSSize {
    switch controlSize {
    case .mini: return NSMakeSize(-1, 18)
    case .small: return NSMakeSize(-1, 20)
    case .large: return NSMakeSize(-1, 24)
    default: return NSMakeSize(-1, 22)
    }
  }
  
  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    // TODO: move most of this to the cell so it can be used individually
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)
    textColor = .textColor
    isBezeled = false
    isBordered = true
    wantsLayer = true
    focusRingType = .none
    drawsBackground = false
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
