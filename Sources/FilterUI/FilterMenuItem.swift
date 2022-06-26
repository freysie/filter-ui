import SwiftUI
//import IDECore
import AppKit
import FilterUICore
import Fuse
import ObjectiveC

//extension NSMenuItem: Fuseable {
//  public var properties: [FuseProperty] { [.init(name: "title")] }
//}

//@objc class FilterableMenu: NSMenu {
//  override func performKeyEquivalent(with event: NSEvent) -> Bool {
//    print((#function, event))
//    return super.performKeyEquivalent(with: event)
//  }
//}

//public class FilterableMenu: NSMenu {
//
//}

public class FilterMenuItem: NSMenuItem {
  static private let height = 27.0
  
  static private var current: FilterMenuItem?
  static private var currentMenu: NSMenu?
  static private var eventMonitor: Any?
  // static private var eventHandler: EventHandlerRef?
  
  static func startObservingEvents(for menu: NSMenu) {
    current = menu.item(at: 0) as? FilterMenuItem
    currentMenu = menu
    print(("setting current…", current))

    guard eventMonitor == nil else { return }
    print(("starting…", current))
    eventMonitor = NSEvent.addCarbonMonitorForKeyEvents { event in
      guard let filterField = current?.field else { return false }
      if event.keyCode == 125 {
        print("AAAAAA")
        print(filterField.resignFirstResponder())
        return false
      }
      if filterField.window?.firstResponder is NSTextView {
        DispatchQueue.main.async { current?.filter() }
        return false
      }
      if ignoredKeyCodes.contains(event.keyCode) { return false }
      if event.modifierFlags.contains(.command) { return false }
      if event.modifierFlags.contains(.control) { return false }
      if event.modifierFlags.contains(.option) { return false }
      guard let characters = event.charactersIgnoringModifiers else { return false }
      print((event, filterField.window?.firstResponder))
      current?.view?.frame.size.height = Self.height
      filterField.isHidden = false
      filterField.stringValue = characters
      print("becomeFirstResponder!")
      filterField.becomeFirstResponder()
      let editor = current?.view?.window?.fieldEditor(false, for: filterField)
      editor?.selectedRange = NSMakeRange(editor?.string.count ?? 0, 0)
      print(editor as Any)
      current?.filter()
      return true
    }
  }
  
  static func stopObservingEvents() {
    current = nil
    currentMenu = nil
    eventMonitor.map(NSEvent.removeCarbonMonitor)
    eventMonitor = nil
  }
  
//  var fuse: Fuse!
  var field: FilterUICore.FilterField!
  
  init() {
    super.init(title: "", action: nil, keyEquivalent: "")
    
    view = MenuFilterView(frame: NSMakeRect(0, 0, 320, Self.height))
//    view = MenuFilterView(frame: NSMakeRect(0, 0, 320, 1))
    guard let view = view else { return }
    view.autoresizingMask = .width
    
//    fuse = Fuse()
    
    field = FilterUICore.FilterField(frame: NSMakeRect(0, 4, 320, 20).insetBy(dx: 20, dy: 0))
    field.autoresizingMask = .width
    field.isFiltering = true
    // field.iconColor = .textColor // FIXME: add this property back to `FilterField`
    field.target = self
    field.action = #selector(filter)
    field.sendsWholeSearchString = false
    field.sendsSearchStringImmediately = true
    field.isHidden = true
    view.addSubview(field)
    view.frame.size.height = 1
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var isFiltering: Bool { !field.stringValue.isEmpty }
  
  @objc func filter() {
    guard let font = menu?.recursiveFont, let items = menu?.items.filter({ !($0 is Self) }) else { return }
    items.forEach { $0.isHidden = isFiltering }
    guard isFiltering else { return }
    // GetThemeMetric(kThemeMenuItemFont, <#T##outMetric: UnsafeMutablePointer<Int32>!##UnsafeMutablePointer<Int32>!#>)?
    // print((NSMenu().font, NSFont.systemFont(ofSize: NSFont.systemFontSize), NSMenu().font == NSMenu().font))
    // menu?.font.font
    
    let highlightedAttributes = [
      NSAttributedString.Key.font: NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask),
      NSAttributedString.Key.foregroundColor: NSColor.textColor
    ]
    
    for item in items {
      item.attributedTitle = nil // TODO: somehow support attributed titles?
    }
    
    for (item, result) in items.fuzzyMatch(field.stringValue) {
      let string = NSMutableAttributedString(string: item.title, attributes: [
        .font: font,
        .foregroundColor: NSColor.secondaryLabelColor
      ])
      
      for range in result.parts {
        string.addAttributes(highlightedAttributes, range: range)
      }
      
      item.attributedTitle = string
      item.isHidden = false
    }
    
//    let results = fuse.search(field.stringValue, in: items.map { $0.title })
//    for (index, _, matchedRanges) in results {
//      let string = NSMutableAttributedString(string: items[index].title, attributes: [
//        .foregroundColor: NSColor.secondaryLabelColor
//      ])
//
//      for range in matchedRanges.map(Range.init).map(NSRange.init) {
//        string.addAttributes(highlightedAttributes, range: range)
//      }
//
//      items[index].attributedTitle = string
//      items[index].isHidden = false
//    }
  }
}

extension NSMenu {
  static let defaultFont = NSMenu().font
  var recursiveFont: NSFont { font == Self.defaultFont ? supermenu?.recursiveFont ?? font : font }
}

extension NSMenuItem: FuzzySearchable {
  public var fuzzyStringToMatch: String { title }
}

class MenuFilterView: NSView {
//  override func viewDidHide() {
//    super.viewDidHide()
//    print(#function)
//  }
//  
//  override func viewDidUnhide() {
//    super.viewDidUnhide()
//    print(#function)
//  }
//  
//  override func viewDidMoveToSuperview() {
//    super.viewDidMoveToSuperview()
//    print(#function)
//  }
//  
//  override func viewDidChangeBackingProperties() {
//    super.viewDidChangeBackingProperties()
//    print(#function)
//  }
//  
//  override func viewDidChangeEffectiveAppearance() {
//    super.viewDidChangeEffectiveAppearance()
//    print(#function)
//  }
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    guard let menu = enclosingMenuItem?.menu else { return }
    if window != nil {
      frame.size.height = 0
      FilterMenuItem.startObservingEvents(for: menu)
    } else {
      frame.size.height = 1
      if menu.supermenu == nil {
        FilterMenuItem.stopObservingEvents()
      }
    }
    print((#function, window))
    
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

struct FilterMenuItem_Previews: PreviewProvider {
  static var previews: some View { Example() }

  struct Example: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
      let menu = NSMenu()
      menu.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
      menu.allowsFiltering = true
      menu.autoenablesItems = false
      
      for title in titlesA {
        let item = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        if Bool.random() {
          item.submenu = NSMenu()
          item.submenu!.allowsFiltering = true
          item.submenu!.autoenablesItems = false
          for title in titlesB {
            let item = item.submenu!.addItem(withTitle: title, action: nil, keyEquivalent: "")
            if Bool.random() {
              item.submenu = NSMenu()
              item.submenu!.allowsFiltering = true
              item.submenu!.autoenablesItems = false
              for title in titlesA {
                item.submenu!.addItem(withTitle: title, action: nil, keyEquivalent: "")
              }
            }
          }
        }
      }

      let view = NSView()
      view.menu = menu
      
      // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      DispatchQueue.main.async {
        menu.popUp(positioning: nil, at: .zero, in: view)
      }
      
      return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {}
  
    let titlesA = [
      "Here’s to the crazy ones",
      "The misfits",
      "The rebels",
      "The troublemakers",
      "The round pegs in the square holes",
      "The ones who see things differently",
      "They're not fond of rules",
      "And they have no respect for the status quo"
    ]
    
    let titlesB = [
      "You can quote them, disagree with them, glorify or vilify them",
      "About the only thing you can't do is ignore them",
      "Because they change things",
      "They push the human race forward",
    ]
  }
}
