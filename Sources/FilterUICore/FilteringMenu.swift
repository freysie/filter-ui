import AppKit
import ObjectiveC

/// A filtering menu.
///
/// If there is only one filter result when the enter key is pressed, that item will be selected and the menu will
/// close.
public class FilteringMenu: NSMenu, NSMenuDelegate, NSSearchFieldDelegate {
  public private(set) var wrappedDelegate: NSMenuDelegate? // TODO: make private and only expose through `delegate`
  
  private var initiallyShowsFilterField = false
  private var eventMonitor: Any?
  
  private var delegateRespondsToMenuHasKeyEquivalentForEventTargetAction = false
  private var delegateRespondsToMenuUpdateItemAtIndexShouldCancel = false
  private var delegateRespondsToConfinementRectForMenuOnScreen = false
  private var delegateRespondsToMenuWillHighlightItem = false
  private var delegateRespondsToMenuWillOpen = false
  private var delegateRespondsToMenuDidClose = false
  private var delegateRespondsToNumberOfItemsInMenu = false
  private var delegateRespondsToMenuNeedsUpdate = false
  
  // TODO: fix weird `menuNeedsUpdate` “unrecognized selector sent to instance” bug
  public override var delegate: NSMenuDelegate? {
    get { super.delegate }
    set {
      wrappedDelegate = newValue
      delegateRespondsToMenuHasKeyEquivalentForEventTargetAction = newValue?.responds(to: #selector(NSMenuDelegate.menuHasKeyEquivalent(_:for:target:action:))) ?? false
      delegateRespondsToMenuUpdateItemAtIndexShouldCancel = newValue?.responds(to: #selector(NSMenuDelegate.menu(_:update:at:shouldCancel:))) ?? false
      delegateRespondsToConfinementRectForMenuOnScreen = newValue?.responds(to: #selector(NSMenuDelegate.confinementRect(for:on:))) ?? false
      delegateRespondsToMenuWillHighlightItem = newValue?.responds(to: #selector(NSMenuDelegate.menu(_:willHighlight:))) ?? false
      delegateRespondsToMenuWillOpen = newValue?.responds(to: #selector(NSMenuDelegate.menuWillOpen(_:))) ?? false
      delegateRespondsToMenuDidClose = newValue?.responds(to: #selector(NSMenuDelegate.menuDidClose(_:))) ?? false
      delegateRespondsToNumberOfItemsInMenu = newValue?.responds(to: #selector(NSMenuDelegate.numberOfItems(in:))) ?? false
      delegateRespondsToMenuNeedsUpdate = newValue?.responds(to: #selector(NSMenuDelegate.menuNeedsUpdate(_:))) ?? false
    }
  }
  
  /// Initializes and returns a filtering menu having the specified title and with autoenabling of menu items turned on.
  ///
  /// FilteringMenu needs `-[NSMenu highlightItem:]` in order to work correctly.
  /// The existence of this selector is checked on initialization, and if it doesn’t exist, the menu will fall back to
  /// the standard type-select behavior.
  public override init(title: String) {
    super.init(title: title)
    super.delegate = self
    
    guard responds(to: Selector(("highlightItem:"))) else { return }
    
    setUpFilterField(in: self)
    
    // TODO: move somewhere else
    eventMonitor = NSEvent.addCarbonMonitorForKeyEvents { event in
      guard !ignoredKeyCodes.contains(event.keyCode) else { return false }
      // self.setUpFilterField(in: self)
      self.highlightFilteringItem()
      // self.items.first?.view?.becomeFirstResponder()
      return false
    }
  }

  deinit {
    eventMonitor.map(NSEvent.removeCarbonMonitor)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Creates a filter field and container view, and inserts it as the first item of the menu unless it already exists.
  ///
  /// This method is public in case you need to use `object_setClass()`.
  public func setUpFilterField(in menu: NSMenu) {
    guard !(items.first?.view is FilteringMenuItemView) else { return }

    let view = FilteringMenuItemView()
    view.filterField.delegate = self
    // view.frame.size.height = 1

    let item = NSMenuItem()
    item.view = view
    // item.isHidden = !initiallyShowsFilterField
    menu.insertItem(item, at: 0)
    // menu.update()
  }
  
  private func performFiltering(with string: String, in menu: NSMenu) {
    let items = items.dropFirst()
    
    for item in items {
      item.isHidden = !string.isEmpty
    }
    
    guard !string.isEmpty else { return }
    
    for (item, _) in items.fuzzyMatch(string) {
      item.isHidden = false
    }
    
    // update()
  }
  
  private func highlightFilteringItem() {
    guard let item = items.first, item.view is FilteringMenuItemView else { return }
    guard !(item.view?.window?.firstResponder is NSText) else { return }
    
    // item.isHidden = false
    item.view?.frame.size.height = 28
    
    highlightItem(item)
    print((#function, item.view?.canBecomeKeyView, item.view?.acceptsFirstResponder, item.view?.becomeFirstResponder()))
    
    // TODO: use `currentEditor()`
    guard let editor = item.view?.window?.fieldEditor(false, for: item) else { return }
    editor.selectedRange = NSMakeRange(editor.string.count, 0)
  }
  
//  - (id)_handleCarbonEvents:(const struct EventTypeSpec { unsigned int x1; unsigned int x2; }*)arg1 count:(unsigned long long)arg2 handler:(id)arg3;

  private func handleCarbonEvents() {
//    perform(<#T##aSelector: Selector!##Selector!#>, with: <#T##Any!#>, with: <#T##Any!#>)
    // objc_msgSend(self, Selector(("_handleCarbonEvents:count:handler:")))
  }
  
  private func highlightItem(_ item: NSMenuItem) {
    // TODO: try `CGEvent(keyboardEventSource:virtualKey:keyDown:)` instead of relying on private API? 👹
    perform(Selector(("highlightItem:")), with: item)
  }
  
  // MARK: - NSMenuDelegate
  
  public func menuNeedsUpdate(_ menu: NSMenu) {
    print(className + "." + #function)
    wrappedDelegate?.menuNeedsUpdate?(menu)
  }
  
  public func numberOfItems(in menu: NSMenu) -> Int {
    print(className + "." + #function)
    return wrappedDelegate?.numberOfItems?(in: menu) ?? 0
  }
  
  public func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
    print(className + "." + #function)
    return wrappedDelegate?.menu?(menu, update: item, at: index, shouldCancel: shouldCancel) ?? false
  }
  
  public func menuHasKeyEquivalent(_ menu: NSMenu, for event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>, action: UnsafeMutablePointer<Selector?>) -> Bool {
    print(className + "." + #function)
    return wrappedDelegate?.menuHasKeyEquivalent?(menu, for: event, target: target, action: action) ?? false
  }
  
  public func menuWillOpen(_ menu: NSMenu) {
    print(className + "." + #function)
    wrappedDelegate?.menuWillOpen?(menu)
      
//    guard let fiteringItemView = items.first?.view as? FilteringMenuItemView else { return }
//    fiteringItemView.frame.size.height = 0
    // update()
//    guard let item = items.first, item.view is FilteringMenuItemView else { return }
//    item.isHidden = true
  }
  
  public func menuDidClose(_ menu: NSMenu) {
    print(className + "." + #function)
    wrappedDelegate?.menuDidClose?(menu)
    
    guard let fiteringItemView = items.first?.view as? FilteringMenuItemView else { return }
    fiteringItemView.filterField.stringValue = ""
  }
  
  public func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
    print(className + "." + #function)
    wrappedDelegate?.menu?(menu, willHighlight: item)
  }
  
  public func confinementRect(for menu: NSMenu, on screen: NSScreen?) -> NSRect {
    print(className + "." + #function)
    return wrappedDelegate?.confinementRect?(for: menu, on: screen) ?? .zero
  }
  
  // MARK: - NSControlTextEditingDelegate
  
  public func controlTextDidChange(_ notification: Notification) {
    guard
      let field = notification.object as? FilterSearchField,
      let menu = field.enclosingMenuItem?.menu
    else { return }
    
    // RunLoop.current.perform(inModes: [.eventTracking]) {
      self.performFiltering(with: field.stringValue, in: menu)
    // }
  }
  
  public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    switch commandSelector {
    case #selector(NSResponder.moveDown(_:)):
      let visibleItems = items.dropFirst().filter { !$0.isHidden }
      guard visibleItems.count > 0 else { return true }
      highlightItem(visibleItems[0])
      return true

    case #selector(NSResponder.insertNewline(_:)):
      let visibleItems = items.dropFirst().filter { !$0.isHidden }
      
      guard
        visibleItems.count == 1,
        let returnKeyEvent = CGEvent(keyboardEventSource: nil, virtualKey: .return, keyDown: true)
      else { return false }
      
      highlightItem(visibleItems[0])
      NSEvent(cgEvent: returnKeyEvent).map(NSApp.sendEvent)
      
      return true

    default:
      return false
    }
  }
}

extension CGKeyCode {
  static let `return`: Self = 36
  static let downArrow: Self = 125
  static let upArrow: Self = 126
}

class FilteringMenuItemView: NSView {
  var filterField: FilterSearchField!
  var menuItem: NSMenuItem!
  
  convenience init() {
    self.init(frame: NSMakeRect(0, 0, 120, 28))
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    autoresizingMask = .width

    filterField = FilterSearchField(frame: frameRect.insetBy(dx: 20, dy: 4))
    filterField.autoresizingMask = .width
    addSubview(filterField)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
  }
}

let ignoredKeyCodes: [UInt16] = [
  51 , // Backspace
  115, // Home
  117, // Delete
  116, // PgUp
  119, // End
  121, // PgDn
  123, // Left
  124, // Right
  125, // Down
  126, // Up
  49 , // Space
  36 , // Return
  53 , // Esc
  71 , // Clear
  76 , // Insert
  48 , // Tab
  114, // Help
  122, // F1
  120, // F2
  99 , // F3
  118, // F4
  96 , // F5
  97 , // F6
  98 , // F7
  100, // F8
  101, // F9
  109, // F10
  103, // F11
  111, // F12
  105, // F13
  107, // F14
  113, // F15
  106, // F16
  64 , // F17
  79 , // F18
  80 , // F19
]

extension NSMenu {
  static let defaultFont = NSMenu().font
  var recursiveFont: NSFont { font == Self.defaultFont ? supermenu?.recursiveFont ?? font : font }
}

extension NSMenuItem: FuzzySearchable {
  public var fuzzyStringToMatch: String { title }
}
