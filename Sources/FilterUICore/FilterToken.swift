import AppKit

@objc public enum FilterTokenOperatorType: Int, CaseIterable {
  case contains
  case doesNotContain
  case beginsWith
  case endsWith

  public var displayName: String {
    switch self {
    case .contains: return NSLocalizedString("Contains", bundle: .module, comment: "")
    case .doesNotContain: return NSLocalizedString("Does Not Contain", bundle: .module, comment: "")
    case .beginsWith: return NSLocalizedString("Begins With", bundle: .module, comment: "")
    case .endsWith: return NSLocalizedString("Ends With", bundle: .module, comment: "")
    }
  }
}

@objcMembers open class FilterTokenFieldValue: NSObject, NSCopying, NSPasteboardReading, NSPasteboardWriting {
  public let objectValue: Any?
  public var operatorType: FilterTokenOperatorType

  public init(objectValue: Any?, operatorType: FilterTokenOperatorType) {
    self.objectValue = objectValue
    self.operatorType = operatorType
  }

  public func copy(with zone: NSZone? = nil) -> Any {
    self
  }

  public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
    [NSPasteboard.PasteboardType("local.filter-ui.FilterTokenFieldValue")]
  }

  public static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
    .asPropertyList
  }

  public required convenience init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
    guard let propertyList = propertyList as? [String: Any] else { return nil }
    guard let type = FilterTokenOperatorType(rawValue: propertyList["operatorType"] as? Int ?? 0) else { return nil }
    self.init(objectValue: propertyList["stringValue"], operatorType: type)
  }

  public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
    ["stringValue": objectValue, "operatorType": operatorType.rawValue]
  }

  public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
    [NSPasteboard.PasteboardType("local.filter-ui.FilterTokenFieldValue")]
  }
}
