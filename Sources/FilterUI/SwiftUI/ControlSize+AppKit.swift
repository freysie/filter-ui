import SwiftUI

extension ControlSize {
  var nsControlSize: NSControl.ControlSize {
    switch self {
    case .regular: return .regular
    case .small: return .small
    case .mini: return .mini
    case .large: return .large
    case .extraLarge: if #available(macOS 26.0, *) {
        return .extraLarge
    } else {
        return .large
    }
    @unknown default: return .regular
    }
  }
}
