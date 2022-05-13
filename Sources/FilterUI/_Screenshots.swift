import SwiftUI
import PreviewScreenshots

struct FilterUI_Previews: PreviewProvider {
  static var previews: some View {
    ScreenshotGroup("../../Screenshots", relativeTo: #filePath) {
      BasicUsage().preferredColorScheme(.light).screenshotName("BasicUsage~light")
      BasicUsage().preferredColorScheme(.dark).screenshotName("BasicUsage~dark")
      // CustomPrompt().screenshotName("CustomPrompt")
      AccessoryToggles().preferredColorScheme(.light).screenshotName("AccessoryToggles~light")
      AccessoryToggles().preferredColorScheme(.dark).screenshotName("AccessoryToggles~dark")
    }
  }
  
  struct BasicUsage: View {
    var body: some View {
      VStack(spacing: 15) {
        VStack(alignment: .leading) {
          Text("Unfocused")
          FilterField(text: .constant(""))
        }
        
        VStack(alignment: .leading) {
          Text("Focused")
          FilterField(text: .constant(""), isFiltering: true)
        }
        
        VStack(alignment: .leading) {
          Text("Non-Empty")
          FilterField(text: .constant("Lorem Ipsum"), isFiltering: true)
        }
      }
      .padding(.horizontal)
      .frame(width: 200)
    }
  }
  
  struct CustomPrompt: View {
    var body: some View {
      FilterField(text: .constant(""), prompt: "Hello, Filter!")
        .frame(width: 200)
    }
  }
  
  struct AccessoryToggles: View {
    var body: some View {
      VStack(spacing: 15) {
        VStack(alignment: .leading) {
          Text("Toggled Off")
          FilterField(text: .constant("")) {
            FilterFieldToggle(systemImage: "location.square", isOn: .constant(false))
          }
        }

        VStack(alignment: .leading) {
          Text("Toggled On")
          FilterField(text: .constant(""), isFiltering: true) {
            FilterFieldToggle(systemImage: "location.square", isOn: .constant(true))
          }
        }

        VStack(alignment: .leading) {
          Text("Toggled On, Non-Empty")
          FilterField(text: .constant("Lorem Ipsum"), isFiltering: true) {
            FilterFieldToggle(systemImage: "location.square", isOn: .constant(true))
          }
        }
      }
      // .background(.background)
      .padding(.horizontal)
      .frame(width: 200)
    }
  }
}
