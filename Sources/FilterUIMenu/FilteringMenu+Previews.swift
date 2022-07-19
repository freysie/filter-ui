import SwiftUI

struct FilteringMenu_Previews: PreviewProvider {
  static var previews: some View { Example() }

  struct Example: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
      let menu = makeExampleMenu()
      menu.delegate = context.coordinator

      defer {
        DispatchQueue.main.async {
          menu.popUp(positioning: nil, at: .zero, in: view)
        }
      }
      
      let view = NSView()
      view.menu = menu
      return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
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

func makeExampleMenu() -> NSMenu {
  let menu = FilteringMenu()
  menu.autoenablesItems = false
  addExampleItems(to: menu)
  
  let submenu = FilteringMenu()
  // let submenu = NSMenu()
  submenu.autoenablesItems = false
  addExampleItems(to: submenu)

  let item = menu.addItem(withTitle: "Menu", action: nil, keyEquivalent: "")
  item.submenu = submenu

  return menu
}

fileprivate func addExampleItems(to menu: NSMenu) {
  menu.addItem(withTitle: "Hello", action: nil, keyEquivalent: "")
  menu.addItem(withTitle: "There", action: nil, keyEquivalent: "")
  menu.addItem(withTitle: "Filtering", action: nil, keyEquivalent: "")
}
