import SwiftUI

public struct FilterToggle: View {
  let systemImage: String
  @Binding var isOn: Bool
  
  public init(systemImage: String, isOn: Binding<Bool>) {
    self.systemImage = systemImage
    _isOn = isOn
  }
    
  public var body: some View {
    Button(action: { isOn.toggle() }) {
      Image(systemName: systemImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 14, height: 14)
        // .font(.body.weight(.thin))
        // .font(.system(size: 16))
        // .font(.system(size: 14, weight: .thin))
    }
    .frame(width: 22, height: 14)
    .buttonStyle(.borderless)
    // .focusable()
    .tint(isOn ? .accentColor : nil)
    .symbolVariant(isOn ? .fill : .none)
  }
}

struct FilterToggle_Previews: PreviewProvider {
  static var previews: some View {
    FilterToggle(systemImage: "folder", isOn: .constant(false)).padding()
    FilterToggle(systemImage: "folder", isOn: .constant(true)).padding()
    FilterToggle(systemImage: "doc", isOn: .constant(false)).padding()
    FilterToggle(systemImage: "doc", isOn: .constant(true)).padding()
    FilterToggle(systemImage: "clock", isOn: .constant(false)).padding()
    FilterToggle(systemImage: "clock", isOn: .constant(true)).padding()
  }
}
