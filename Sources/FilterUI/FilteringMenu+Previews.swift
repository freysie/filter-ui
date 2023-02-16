import SwiftUI
import FilterUICore

struct FilteringMenu_Previews: PreviewProvider {
  static var previews: some View { Example() }

  struct Example: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
      let menu = makeExampleMenu()
      menu.delegate = context.coordinator

//      defer {
//        DispatchQueue.main.async {
//          menu.popUp(positioning: nil, at: .zero, in: view)
//        }
//      }

      let view = NSView()
      view.menu = menu
      return view
    }

    func updateNSView(_ view: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeExampleMenu() -> NSMenu {
      let menu = FilteringMenu()
      menu.autoenablesItems = false
      addExampleItems(to: menu)

      let submenu = FilteringMenu()
      // let submenu = NSMenu()
      submenu.autoenablesItems = false
      addExampleItems(to: submenu)

      submenu.addItem(.separator())

      let subsubmenu = FilteringMenu()
      subsubmenu.autoenablesItems = false
      addExampleItems(to: subsubmenu)

      let subitem = submenu.addItem(withTitle: "Menu", action: nil, keyEquivalent: "")
      subitem.submenu = subsubmenu

      submenu.addItem(.separator())

      for _ in 0..<40 { addExampleItems(to: submenu) }

      let item = menu.addItem(withTitle: "Menu", action: nil, keyEquivalent: "")
      item.submenu = submenu

      return menu
    }

    func addExampleItems(to menu: NSMenu) {
      menu.addItem(withTitle: "Hello", action: nil, keyEquivalent: "")
      menu.addItem(withTitle: "There", action: nil, keyEquivalent: "")
      menu.addItem(withTitle: "Filtering", action: nil, keyEquivalent: "")
    }

    @objc(Coordinator)
    class Coordinator: NSObject, NSMenuDelegate {
      func menuNeedsUpdate(_ menu: NSMenu) {
        print("Coordinator." + #function)
      }

      func menuWillOpen(_ menu: NSMenu) {
        print("Coordinator." + #function)
      }
    }
  }
}
