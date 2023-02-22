import AppKit
import Combine

// FIXME: cancel button highlight glitch (the right edge’s highlight gets stuck when moving the mouse outside while holding down the mouse button)

/// An AppKit filter field.
@objcMembers open class FilterSearchField: NSSearchField, CALayerDelegate {
  open override class var cellClass: AnyClass? { get { FilterSearchFieldCell.self } set {} }
  public static let indeterminateProgress: Double = -1

  private var subscriptions = Set<AnyCancellable>()

  open var isHovered = false
  open var progressIndicator = NSProgressIndicator()
  open var progress: Double? { didSet { updateProgressIndicator() } }

  open var trackingTag: TrackingRectTag?

  // open override var allowsVibrancy: Bool { !hasFilteringAppearance }

  open override var allowsVibrancy: Bool {
    let isFirstResponder = window?.firstResponder == currentEditor()
    let isFiltering = !stringValue.isEmpty
    return !(isFirstResponder || isFiltering)
  }

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
    
    font = .systemFont(ofSize: NSFont.smallSystemFontSize)

    progressIndicator.style = .spinning
    progressIndicator.controlSize = .small
    progressIndicator.usesThreadedAnimation = true
    progressIndicator.maxValue = 1
    progressIndicator.isHidden = true
    progressIndicator.isIndeterminate = false
    progressIndicator.translatesAutoresizingMaskIntoConstraints = false
    // TODO: make smaller:
    //progressIndicator.wantsLayer = true
    //progressIndicator.layer?.sublayerTransform = CATransform3DMakeScale(0.8, 0.8, 0.8)
    addSubview(progressIndicator)

    NSLayoutConstraint.activate([
      progressIndicator.widthAnchor.constraint(equalToConstant: 16),
      progressIndicator.heightAnchor.constraint(equalToConstant: 16),
      progressIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
      progressIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])

    Publishers.MergeMany(
      NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification, object: nil),
      NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification, object: nil)
    )
    .sink { _ in self.needsDisplay = true }
    .store(in: &subscriptions)
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewWillDraw() {
    guard let cell = cell as? FilterSearchFieldCell else { return }
    cell.hasSourceListAppearance = hasSourceListAppearance
    cell.hasFilteringAppearance = hasFilteringAppearance
  }

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

  open func updateProgressIndicator() {
    guard let cell = cell as? FilterSearchFieldCell else { return }

    progressIndicator.isHidden = progress == nil || (isHovered && stringValue != "")
    progressIndicator.isIndeterminate = progress == Self.indeterminateProgress
    progressIndicator.doubleValue = progress ?? 0

    if progress == Self.indeterminateProgress {
      progressIndicator.startAnimation(nil)
    } else {
      progressIndicator.stopAnimation(nil)
    }

    cell.showsProgressIndicator = !progressIndicator.isHidden
    updateCell(cell)
  }

  open override func mouseEntered(with event: NSEvent) {
    isHovered = true
    updateProgressIndicator()
  }

  open override func mouseExited(with event: NSEvent) {
    isHovered = false
    updateProgressIndicator()
  }

  open override func viewWillMove(toWindow newWindow: NSWindow?) {
    if newWindow == nil, let trackingTag {
      removeTrackingRect(trackingTag)
    }
  }

  open override func viewDidMoveToWindow() {
    if window != nil {
      trackingTag = addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
  }
}

// TODO: fix this:

//open class FlatProgressIndicator: NSProgressIndicator, CALayerDelegate {
//  open override var isFlipped: Bool { true }

//  public override init(frame frameRect: NSRect) {
//    super.init(frame: frameRect)
//    wantsLayer = true
//    layer?.delegate = self
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  public func draw(_ layer: CALayer, in ctx: CGContext) {
//    NSColor.secondaryLabelColor.setStroke()
//    NSColor.secondaryLabelColor.setFill()
//
//    do {
//      let path = NSBezierPath(ovalIn: bounds.insetBy(dx: 0.5, dy: 0.5))
//      path.stroke()
//    }
//
//    do {
//      let center = NSPoint(x: bounds.midX, y: bounds.midY)
//      let radius = (min(frame.size.width, frame.size.height) - 4) * 0.5
//
//      let path = NSBezierPath()
//      path.move(to: center)
//      path.appendArc(withCenter: center, radius: radius, startAngle: -.pi * 0.5, endAngle: (-.pi * 0.5) + (.pi * 2 * doubleValue), clockwise: false)
//      path.fill()
//    }
//  }

  //  open override func draw(_ dirtyRect: NSRect) {
//    super.draw(dirtyRect)
//    guard !isIndeterminate else { return super.draw(dirtyRect) }

//    NSColor.secondaryLabelColor.setStroke()
//    NSColor.secondaryLabelColor.setFill()
//
//    do {
//      let path = NSBezierPath(ovalIn: bounds.insetBy(dx: 0.5, dy: 0.5))
//      path.stroke()
//    }
//
//    do {
//      let center = NSPoint(x: bounds.midX, y: bounds.midY)
//      let radius = (min(frame.size.width, frame.size.height) - 4) * 0.5
//
//      let path = NSBezierPath()
//      path.move(to: center)
//      path.appendArc(withCenter: center, radius: radius, startAngle: -.pi * 0.5, endAngle: (-.pi * 0.5) + (.pi * 2 * doubleValue), clockwise: false)
//      path.fill()
//    }
//  }
//}
