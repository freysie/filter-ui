import AppKit
import Combine

/// An AppKit filter field.
@objcMembers open class FilterSearchField: NSSearchField, CALayerDelegate {
  open override class var cellClass: AnyClass? { get { FilterSearchFieldCell.self } set {} }

  private var subscriptions = Set<AnyCancellable>()

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
}
