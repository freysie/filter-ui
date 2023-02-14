import AppKit
import Carbon
import FilterUICoreObjC
import ObjectiveC

/// A filtering menu.
///
/// If there is only one filter result when the enter key is pressed, that item will be selected and the menu will
/// close.
public class _FilteringMenu: NSMenu, NSMenuDelegate, NSSearchFieldDelegate, FilteringMenuFilterViewDelegate {
  public private(set) var wrappedDelegate: NSMenuDelegate? // TODO: make private and only expose through `delegate`

  private var initiallyShowsFilterField = false
  var carbonMenu: Unmanaged<Menu>?
  
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

  private static var invertedControlAndSpaceCharacterSet = {
    var set = NSMutableCharacterSet.controlCharacters
    set.insert(charactersIn: " ")
    return set.inverted
  }()

  private var singleVisibleMenuItem: NSMenuItem? {
    let visibleItems = items.dropFirst().filter { !$0.isHidden }
    return visibleItems.count == 1 ? visibleItems.first! : nil
  }

  /// Initializes and returns a filtering menu having the specified title and with autoenabling of menu items turned on.
  ///
  /// FilteringMenu needs `-[NSMenu highlightItem:]` and `-[NSMenu _handleCarbonEvents:count:handler:]` in order to work.
  /// The existence of these selectors is checked on initialization. If they doesn’t exist the menu will fall back to the standard type-select behavior.
  public override init(title: String) {
    super.init(title: title)
    super.delegate = self

    guard responds(to: #selector(highlight(_:))) else { return }
    guard responds(to: #selector(_handleCarbonEvents(_:count:handler:))) else { return }

    let eventTypes = [
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: UInt32(kEventMenuOpening)),
      EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: UInt32(kEventMenuClosed))
    ]

    _handleCarbonEvents(eventTypes, count: 2) { menu, handler, event in
      guard let menu = menu as? Self else { return noErr }

      if GetEventClass(event) == kEventClassMenu {
        if GetEventKind(event) == kEventMenuOpening {
          GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeMenuRef),
            nil,
            MemoryLayout.size(ofValue: menu.carbonMenu),
            nil,
            &menu.carbonMenu
          )
        } else if GetEventKind(event) == kEventMenuClosed {
          menu.carbonMenu = nil
        }
      }

      return noErr
    }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func makeFilterFieldItem() -> NSMenuItem {
    let view = FilteringMenuFilterView()
    view.delegate = self
    view.filterField.delegate = self

    let item = NSMenuItem()
    item.tag = 1000
    item.view = view
    view.menuItem = item
    return item
  }
  
  private func setUpFilterField(in menu: NSMenu, with string: String) {
    // print((#function, menu, string))

    // TODO: loop all the way in
    var menu = menu
    if menu.highlightedItem?.hasSubmenu == true {
      // print("highlighted item has submenu, reeeeee")
      if let submenu = menu.highlightedItem?.submenu {
        if let carbonMenu = (submenu as? Self)?.carbonMenu?.takeUnretainedValue() {
          var data = MenuTrackingData()
          if GetMenuTrackingData(carbonMenu, &data) == noErr {
            menu = submenu
          }
        }
      }
    }

    var filterFieldItem = menu.item(withTag: 1000)
    if filterFieldItem == nil {
      filterFieldItem = makeFilterFieldItem()
      if let view = filterFieldItem!.view as? FilteringMenuFilterView {
        view.setFrameSize(NSMakeSize(max(size.width, 182), view.frame.height))
        view.initialStringValue = string
        filterFieldItem!.title = string
        menu.insertItem(filterFieldItem!, at: 0)
        highlightFilterFieldItem(in: menu)
        performFiltering(with: string, in: menu)
      }
    }

    if isFilterFieldScrolledOutOfView(in: menu) {
      highlightFilterFieldItem(in: menu)
      performFiltering(with: string, in: menu)
    }
  }

  private func highlightFilterFieldItem(in menu: NSMenu) {
    menu.highlight(menu.item(withTag: 1000))
  }

  private func isFilterFieldScrolledOutOfView(in menu: NSMenu) -> Bool {
    guard let menu = menu as? _FilteringMenu, let menu = menu.carbonMenu?.takeUnretainedValue() else { return false }

    var data = MenuTrackingData()
    guard GetMenuTrackingData(menu, &data) == noErr else { return false }
    // print(data.virtualMenuBottom as Any)
    // print(data.virtualMenuTop as Any)
    // print(data.itemSelected as Any)
    // return data.itemSelected != 1
    return data.virtualMenuTop < data.itemRect.top
  }
  
  private func performFiltering(with string: String, in menu: NSMenu) {
    guard let menu = menu as? _FilteringMenu else { return }

    //var contentView: Unmanaged<HIView>
    let contentView = UnsafeMutablePointer<Unmanaged<HIView>>.allocate(capacity: 1)
    if let carbonMenu = menu.carbonMenu {
      HIMenuGetContentView(carbonMenu.takeUnretainedValue(), ThemeMenuType(kThemeMenuItemHierarchical), contentView)
      HIViewSetDrawingEnabled(contentView.pointee.takeUnretainedValue(), false)
    }

    let items = menu.items.dropFirst()
    for item in items { item.isHidden = !string.isEmpty }
    for (item, _) in items.fuzzyMatch(string) { item.isHidden = false }

    HIViewSetDrawingEnabled(contentView.pointee.takeUnretainedValue(), true)
    HIViewSetNeedsDisplay(contentView.pointee.takeUnretainedValue(), true)
  }
  
  private func filterFieldShouldTakeFocus(_ filterField: FilterSearchField) -> Bool {
    let firstResponder = filterField.window?.firstResponder
    let textView = firstResponder as? NSTextView
    if firstResponder == filterField || (textView?.isFieldEditor == true && textView?.delegate as? Self? == self) {
      return false
    } else {
      filterField.window?.makeFirstResponder(filterField)
      return true
    }

//    let textView = filterField.window?.firstResponder as? NSTextView
//    print((#function, textView))
//    if textView?.isFieldEditor == false || textView?.delegate as? _FilteringMenu != self {
//      print((#function, "yas"))
//      filterField.window?.makeFirstResponder(filterField)
//    }
//    return true
  }

  // MARK: - Menu Delegate
  
  public func menuNeedsUpdate(_ menu: NSMenu) {
    wrappedDelegate?.menuNeedsUpdate?(menu)
  }
  
  public func numberOfItems(in menu: NSMenu) -> Int {
    return wrappedDelegate?.numberOfItems?(in: menu) ?? 0
  }
  
  public func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
    return wrappedDelegate?.menu?(menu, update: item, at: index, shouldCancel: shouldCancel) ?? false
  }
  
  public func menuHasKeyEquivalent(_ menu: NSMenu, for event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>, action: UnsafeMutablePointer<Selector?>) -> Bool {
    return wrappedDelegate?.menuHasKeyEquivalent?(menu, for: event, target: target, action: action) ?? false
  }
  
  public func menuWillOpen(_ menu: NSMenu) {
    wrappedDelegate?.menuWillOpen?(menu)

    let filterFieldItem = menu.item(withTag: 1000)
    if initiallyShowsFilterField {
      if filterFieldItem == nil {
        setUpFilterField(in: menu, with: "")
      }
    } else if let filterFieldItem {
      menu.removeItem(filterFieldItem)
    }

    performFiltering(with: "", in: menu)

    if menu.supermenu == nil || !(menu.supermenu is Self) {
      let eventTypes = [
        EventTypeSpec(eventClass: OSType(kEventClassMenu), eventKind: UInt32(kEventMenuMatchKey)),
        EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventRawKeyDown))
      ]

      menu._handleCarbonEvents(eventTypes, count: 2) { [self] menu, handler, event in
        if GetEventClass(event) == kEventClassMenu && GetEventKind(event) == kEventMenuMatchKey {
          var textEvent: EventRef!
          GetEventParameter(event, EventParamName(kEventParamEventRef), typeEventRef, nil, MemoryLayout.size(ofValue: textEvent), nil, &textEvent)

          var actualSize: size_t = -1
          GetEventParameter(textEvent, EventParamName(kEventParamKeyUnicodes), typeUnicodeText, nil, 0, &actualSize, nil)
          let text = UnsafeMutablePointer<UniChar>.allocate(capacity: actualSize)
          GetEventParameter(textEvent, EventParamName(kEventParamKeyUnicodes), typeUnicodeText, nil, actualSize, nil, text)

          var modifiers: UInt32 = 0
          GetEventParameter(textEvent, EventParamName(kEventParamKeyModifiers), typeUInt32, nil, 4, nil, &modifiers)
//          let controlDown = modifiers & UInt32(controlKey) == UInt32(controlKey)
//          let optionDown = modifiers & UInt32(optionKey) == UInt32(optionKey)
          let cmdDown = modifiers & UInt32(cmdKey) == UInt32(cmdKey)

          let string = NSString(characters: text, length: actualSize >> 1) as String
          // print((#function, string, modifiers, controlDown: controlDown, optionDown: optionDown, cmdDown: cmdDown))
          text.deallocate()

          if string.rangeOfCharacter(from: Self.invertedControlAndSpaceCharacterSet) != nil {
            if !cmdDown {
              setUpFilterField(in: menu, with: string)
              return OSStatus(menuItemNotFoundErr)
            }
//          } else {
//            print(("reeeeeE", string.rangeOfCharacter(from: Self.invertedControlAndSpaceCharacterSet)))
          }
        }

        return OSStatus(eventNotHandledErr)
      }
    }
  }
  
  public func menuDidClose(_ menu: NSMenu) {
    if !initiallyShowsFilterField {
      item(withTag: 1000)?.view = nil
    }

    wrappedDelegate?.menuDidClose?(menu)
  }
  
  public func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
    wrappedDelegate?.menu?(menu, willHighlight: item)
  }
  
  public func confinementRect(for menu: NSMenu, on screen: NSScreen?) -> NSRect {
    return wrappedDelegate?.confinementRect?(for: menu, on: screen) ?? .zero
  }
  
  // MARK: - Control Text Editing Delegate
  
  public func controlTextDidChange(_ notification: Notification) {
    guard
      let field = notification.object as? FilterSearchField,
      let view = field.superview as? FilteringMenuFilterView,
      let menu = view.menuItem.menu
    else { return }
    
    performFiltering(with: field.stringValue, in: menu)
  }
  
  public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    switch commandSelector {
    case #selector(NSResponder.moveDown(_:)):
      control.nextResponder?.keyDown(with: NSApp.currentEvent!)
      return true

    case #selector(NSResponder.moveLeft(_:)):
      if textView.string.count == 0 {
        control.nextResponder?.keyDown(with: NSApp.currentEvent!)
        return true
      } else {
        return false
      }

    case #selector(NSResponder.insertNewline(_:)):
      if let item = singleVisibleMenuItem {
        highlight(item)
        control.nextResponder?.keyDown(with: NSApp.currentEvent!)
        return true
      } else {
        return false
      }

    default:
      return false
    }

//    switch commandSelector {
//    case #selector(NSResponder.moveDown(_:)):
//      let visibleItems = items.dropFirst().filter { !$0.isHidden }
//      guard visibleItems.count > 0 else { return true }
//      highlight(visibleItems[0])
//      return true
//
//    case #selector(NSResponder.insertNewline(_:)):
//      let visibleItems = items.dropFirst().filter { !$0.isHidden }
//
//      guard
//        visibleItems.count == 1,
//        let returnKeyEvent = CGEvent(keyboardEventSource: nil, virtualKey: .return, keyDown: true)
//      else { return false }
//
//      highlight(visibleItems[0])
//      NSEvent(cgEvent: returnKeyEvent).map(NSApp.sendEvent)
//
//      // control.nextResponder?.keyDown(with: NSApp.currentEvent!)
//
//      return true
//
//    default:
//      return false
//    }
  }

  // MARK: - Filter View Delegate

  func filterView(_ filterView: FilteringMenuFilterView, makeFilterFieldKey filterField: FilterSearchField) {
    guard let window = filterView.window else { fatalError() }

    if !window.isKeyWindow {
      window.makeKey()
      window.acceptsMouseMovedEvents = true
    }

    if filterFieldShouldTakeFocus(filterField) {
      highlightFilterFieldItem(in: filterView.menuItem.menu!)
      //window.makeFirstResponder(nil)
      window.makeFirstResponder(filterField)
    }

    performFiltering(with: filterField.stringValue, in: filterView.menuItem.menu!)
  }
}

protocol FilteringMenuFilterViewDelegate: NSObjectProtocol {
  func filterView(_ filterView: FilteringMenuFilterView, makeFilterFieldKey filterField: FilterSearchField)
}

class FilteringMenuFilterView: NSView {
  static let horizontalPadding: CGFloat = 20

  var initialStringValue: String?
  var filterField: FilterSearchField!
  var menuItem: NSMenuItem!
  weak var delegate: FilteringMenuFilterViewDelegate?
  
  convenience init() {
    self.init(frame: NSMakeRect(0, 0, 120, 27))
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    autoresizingMask = .width

    filterField = FilterSearchField(frame: frameRect.insetBy(dx: Self.horizontalPadding, dy: 4))
    filterField.hasSourceListAppearance = true
    filterField.controlSize = .small
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

    // print((#function, window))
    guard window != nil else { return }

    if let initialStringValue {
      filterField.stringValue = initialStringValue
      self.initialStringValue = nil
    } else {
      filterField.stringValue = ""
    }

    delegate?.filterView(self, makeFilterFieldKey: filterField)

    if let currentEditor = filterField.currentEditor() {
      // currentEditor.selectedRange = NSMakeRange(0, currentEditor.string.count)
      currentEditor.selectedRange = NSMakeRange(currentEditor.string.count, 0)
    }
  }
}
