import SwiftUI
import FilterUICore

extension ControlSize {
  var nsControlSize: NSControl.ControlSize {
    switch self {
    case .regular: return .regular
    case .small: return .small
    case .mini: return .mini
    case .large: return .large
    @unknown default: return .regular
    }
  }
}

/// A control that displays an editable text interface optimized for performing text-based searches.
public struct FilterField<Accessory: View>: NSViewRepresentable {
  @Binding var text: String
  var prompt: String = "Filter"
  var isFiltering: Bool
  var introspect: ((_ searchField: FilterUICore.FilterField) -> Void)?
  var onCommit: ((_ text: String) -> Void)?
  var accessory: Accessory
  @Environment(\.controlSize) private var controlSize
  
  public init(
    text: Binding<String>,
    prompt: String? = nil,
    isFiltering: Bool? = nil,
    introspect: ((_ searchField: FilterUICore.FilterField) -> Void)? = nil,
    onCommit: ((_ text: String) -> Void)? = nil
  ) where Accessory == EmptyView {
    self.init(
      text: text,
      prompt: prompt,
      isFiltering: isFiltering,
      accessory: { EmptyView() },
      introspect: introspect,
      onCommit: onCommit
    )
  }
  
  public init(
    text: Binding<String>,
    prompt: String? = nil,
    isFiltering: Bool? = nil,
    @ViewBuilder accessory: () -> Accessory,
    introspect: ((_ searchField: FilterUICore.FilterField) -> Void)? = nil,
    onCommit: ((_ text: String) -> Void)? = nil
  ) {
    _text = text
    if let prompt = prompt { self.prompt = prompt }
    self.isFiltering = isFiltering ?? false
    self.accessory = accessory()
    self.introspect = introspect
    self.onCommit = onCommit
  }
  
  public func makeNSView(context: Context) -> FilterUICore.FilterField {
    let view = FilterUICore.FilterField()
    // view.placeholderString = prompt
    view.delegate = context.coordinator
    // view.isFiltering = isFiltering
    if type(of: accessory) != EmptyView.self {
      view.accessoryView = NSHostingView(rootView: HStack(spacing: -5) { accessory }.padding(.horizontal, -3))
    }
    introspect?(view)
    return view
  }
  
  public func updateNSView(_ view: FilterUICore.FilterField, context: Context) {
    view.placeholderString = prompt
    view.stringValue = text
    view.isFiltering = isFiltering
    view.controlSize = controlSize.nsControlSize
//    // TODO: profile performance of this
//    if type(of: accessory) != EmptyView.self {
//      view.accessoryView = NSHostingView(rootView: accessory)
//    } else {
////    if type(of: accessory) == EmptyView.self {
//      view.accessoryView = nil
//    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  public final class Coordinator: NSObject, NSSearchFieldDelegate {
    let parent: FilterField
    
    init(parent: FilterField) {
      self.parent = parent
    }
    
    public func controlTextDidBeginEditing(_ notification: Notification) {
//      let view = notification.object as! FilterUICore.FilterField
    }
    
    public func controlTextDidChange(_ notification: Notification) {
      let view = notification.object as! FilterUICore.FilterField
      parent.text = view.objectValue as? String ?? ""
    }
    
    public func controlTextDidEndEditing(_ notification: Notification) {
//      let view = notification.object as! FilterUICore.FilterField
    }
  }
}

struct FilterField_Previews: PreviewProvider {
  struct Example: View {
    @State var text1 = ""
    @State var text2 = "Hello!"
    @State var accessoryIsOn1 = false
    @State var accessoryIsOn2 = false
    @State var accessoryIsOn3 = false
    
    var body: some View {
      FilterField(text: $text1)
      
      FilterField(text: $text1, prompt: "Hello")

      FilterField(text: $text1, isFiltering: accessoryIsOn1) {
        FilterFieldToggle(systemImage: "location.square", isOn: $accessoryIsOn1)
          .help("Show only items with location data")
      }

      FilterField(text: $text2)

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterFieldToggle(systemImage: "location.square", isOn: $accessoryIsOn1)
          .help("Show only items with location data")
        FilterFieldToggle(systemImage: "tag.square", isOn: $accessoryIsOn2)
          .help("Show only tagged items")
        FilterFieldToggle(systemImage: "wifi.square", isOn: $accessoryIsOn3)
          .help("Show only items with Wi-Fi data")
      }

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterFieldToggle(systemImage: "bookmark.square", isOn: $accessoryIsOn1)
        FilterFieldToggle(systemImage: "heart.square", isOn: $accessoryIsOn1)
        FilterFieldToggle(systemImage: "star.square", isOn: $accessoryIsOn3)
      }

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterFieldToggle(systemImage: "flag.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "bolt.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "eye.square", isOn: $accessoryIsOn2)
      }

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterFieldToggle(systemImage: "icloud.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "lock.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "square.text.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "person.crop.square", isOn: $accessoryIsOn2)
      }

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterFieldToggle(systemImage: "bell.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "dot.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "pin.square", isOn: $accessoryIsOn2)
        FilterFieldToggle(systemImage: "mic.square", isOn: $accessoryIsOn2)
      }
    }
  }
  
  static var previews: some View {
    Form { Example() }.padding().frame(maxWidth: 200).background(.regularMaterial)
    
//    ForEach(Font.Weight.allCases) { weight in
//      HStack {
//        ForEach(8..<32, id: \.self) { i in
//          Image(systemName: "tag.square")
//            .resizable()
//            .frame(width: Double(i), height: Double(i))
//            .help("\(i)px \(String(reflecting: weight))")
//        }
//      }
//      .font(.body.weight(weight))
//    }
//
//    ForEach(Font.Weight.allCases) { weight in
//      HStack {
//        ForEach(8..<32, id: \.self) { i in
//          Image(systemName: "line.3.horizontal.decrease.circle")
//            .resizable()
//            .frame(width: Double(i), height: Double(i))
//            .help("\(i)px \(String(describing: weight))")
//        }
//      }
//      .font(.body.weight(weight))
//    }
//
//    ForEach(Font.Weight.allCases) { weight in
//      HStack {
//        ForEach(8..<32, id: \.self) { i in
//          Image(systemName: "xmark.circle.fill")
//            .resizable()
//            .frame(width: Double(i), height: Double(i))
//            .help("\(i)px \(String(describing: weight))")
//        }
//      }
//      .font(.body.weight(weight))
//    }

//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .resizable()
//          .frame(width: Double(i), height: Double(i))
//      }
//    }
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .font(.system(size: Double(i)))
//      }
//    }
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .frame(width: Double(i), height: Double(i))
//      }
//    }
//    .imageScale(.small)
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .resizable()
//          .frame(width: Double(i), height: Double(i))
//      }
//    }
//    .imageScale(.small)
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .font(.system(size: Double(i)))
//      }
//    }
//    .imageScale(.small)
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .frame(width: Double(i), height: Double(i))
//      }
//    }
//    .imageScale(.large)
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .resizable()
//          .frame(width: Double(i), height: Double(i))
//      }
//    }
//    .imageScale(.large)
//
//    HStack {
//      ForEach(8..<32, id: \.self) { i in
//        Image(systemName: "line.3.horizontal.decrease.circle")
//          .font(.system(size: Double(i)))
//      }
//    }
//    .imageScale(.large)
  }
}

extension Font.Weight: CaseIterable, Identifiable {
  public var id: Self { self }
  public static var allCases: [Font.Weight] {
    [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
  }
}
