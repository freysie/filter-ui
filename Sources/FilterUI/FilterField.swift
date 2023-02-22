import SwiftUI
import FilterUICore

/// Contains the possible style values for a filter field.
public enum FilterFieldStyle {
  /// The filter field style resolves to a plain style.
  case plain
  /// The filter field style resolves to a source-list style.
  case sourceList
}

/// A control that displays an editable text interface optimized for performing text-based filtering.
public struct FilterField<Accessory: View>: NSViewRepresentable {
  @Binding var text: String
  var prompt: LocalizedStringKey? = nil
  var isFiltering: Bool // TODO: do this with preference values instead
  var onMake: ((_ searchField: FilterSearchField) -> Void)?
  var onCommit: ((_ text: String) -> Void)?
  var accessory: Accessory
  @Environment(\.filterFieldStyle) private var style
  @Environment(\.controlSize) private var controlSize

  public init(
    text: Binding<String>,
    prompt: LocalizedStringKey? = nil,
    isFiltering: Bool? = nil,
    onMake: ((_ searchField: FilterSearchField) -> Void)? = nil,
    onCommit: ((_ text: String) -> Void)? = nil
  ) where Accessory == EmptyView {
    self.init(
      text: text,
      prompt: prompt,
      isFiltering: isFiltering,
      accessory: { EmptyView() },
      onMake: onMake,
      onCommit: onCommit
    )
  }
  
  public init(
    text: Binding<String>,
    prompt: LocalizedStringKey? = nil,
    isFiltering: Bool? = nil,
    @ViewBuilder accessory: () -> Accessory,
    onMake: ((_ searchField: FilterSearchField) -> Void)? = nil,
    onCommit: ((_ text: String) -> Void)? = nil
  ) {
    _text = text
    self.prompt = prompt
    self.isFiltering = isFiltering ?? false
    self.accessory = accessory()
    self.onMake = onMake
    self.onCommit = onCommit
  }
  
  public func makeNSView(context: Context) -> FilterSearchField {
    let view = FilterSearchField()
    view.placeholderString = prompt?.string
    view.delegate = context.coordinator
    // view.isFiltering = isFiltering
    if type(of: accessory) != EmptyView.self {
      view.accessoryView = NSHostingView(rootView: HStack(spacing: -5) { accessory }.padding(.horizontal, -3))
    }
    onMake?(view)
    return view
  }
  
  public func updateNSView(_ view: FilterSearchField, context: Context) {
    view.placeholderString = prompt?.string
    view.stringValue = text
    view.isFiltering = isFiltering
    view.controlSize = controlSize.nsControlSize
    view.hasSourceListAppearance = style == .sourceList
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
//      let view = notification.object as! FilterSearchField
    }
    
    public func controlTextDidChange(_ notification: Notification) {
      let view = notification.object as! FilterSearchField
      parent.text = view.objectValue as? String ?? ""
    }
    
    public func controlTextDidEndEditing(_ notification: Notification) {
      let view = notification.object as! FilterSearchField
      parent.onCommit?(view.stringValue)
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
        // .filterFieldRecentsMenu(.visible)

      FilterField(text: $text1, prompt: "Hello", isFiltering: accessoryIsOn1) {
        FilterToggle(systemImage: "location.square", isOn: $accessoryIsOn1)
          .help("Show only items with location data")
      }

      FilterField(text: $text2, isFiltering: accessoryIsOn1 || accessoryIsOn2 || accessoryIsOn3) {
        FilterToggle(systemImage: "location.square", isOn: $accessoryIsOn1)
          .help("Show only items with location data")
        FilterToggle(systemImage: "tag.square", isOn: $accessoryIsOn2)
          .help("Show only tagged items")
        FilterToggle(systemImage: "wifi.square", isOn: $accessoryIsOn3)
          .help("Show only items with Wi-Fi data")
      }

      Group {
        NSViewPreview { FilterSearchField() }

        NSViewPreview<FilterSearchField> { f in
          f.progress = FilterSearchField.indeterminateProgress
        }

        NSViewPreview<FilterSearchField> { f in
          f.stringValue = "Lorem Ipsum"
        }

        NSViewPreview<FilterSearchField> { f in
          f.progress = 0
          Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let progress = f.progress { f.progress = progress >= 1 ? 0 : progress + 0.05 }
          }
        }

        // NSViewPreview { let f = FilterSearchField(); f.controlSize = .small; return f }
        // NSViewPreview { let f = FilterSearchField(); f.controlSize = .mini; return f }

        NSViewPreview { FilterTokenField() }
        // NSViewPreview { let f = FilterTokenField(); f.controlSize = .small; return f }
        // NSViewPreview { let f = FilterTokenField(); f.controlSize = .mini; return f }

        NSViewPreview {
          let f = FilterTokenField()
          f.objectValue = [
            FilterTokenValue(objectValue: "hi", comparisonType: .contains),
            FilterTokenValue(objectValue: "there", comparisonType: .doesNotContain),
            FilterTokenValue(objectValue: "token", comparisonType: .beginsWith),
            FilterTokenValue(objectValue: "field", comparisonType: .endsWith)
          ]
          return f
        }

        NSViewPreview {
          let f = NSTokenField()
          f.cell!.isScrollable = true
          return f
        }
      }
    }
  }
  
  static var previews: some View {
    NavigationView {
      Form { Example() }.padding().frame(maxWidth: 240).filterFieldStyle(.sourceList)
      Form { Example() }.padding().frame(maxWidth: 400)// .background(.regularMaterial)
    }
    
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

//extension Font.Weight: CaseIterable, Identifiable {
//  public var id: Self { self }
//  public static var allCases: [Font.Weight] {
//    [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
//  }
//}

extension LocalizedStringKey {
  var key: String {
    Mirror(reflecting: self).children.first { $0.label == "key" }?.value as? String ?? ""
  }

  var string: String {
    NSLocalizedString(key, comment: "")
  }
}

struct NSViewPreview<View: NSView>: NSViewRepresentable {
  let view: View

  init(_ builder: @escaping () -> View) {
    view = builder()
  }

  init(_ setUp: @escaping (View) -> ()) {
    view = View()
    setUp(view)
  }

  func makeNSView(context: Context) -> NSView {
    view
  }

  func updateNSView(_ view: NSView, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}
