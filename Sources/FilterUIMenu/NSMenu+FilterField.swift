import AppKit

public extension NSMenu {
  /// A Boolean that indicates whether the menu allows in-menu item filtering.
  /// 
  /// The default value of this property is `false`. Setting it to `true` enables in-menu filtering and disables
  /// keystroke-based selection (type select).
  var allowsFiltering: Bool {
    get { items.first is FilterMenuItem }
    set {
      if newValue {
        if items.first is FilterMenuItem { return }
        insertItem(FilterMenuItem(), at: 0)
      } else {
        guard items.first is FilterMenuItem else { return }
        removeItem(at: 0)
      }
    }
  }
}
