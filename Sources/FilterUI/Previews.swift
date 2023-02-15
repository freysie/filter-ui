import SwiftUI
import FilterUICore
import PreviewsCapture

class FilterUI_Previews: PreviewProvider, PreviewCaptureBatch {
  static var previews: some View {
    Logo()
      //.preferredColorScheme(.dark)
      .background()
      .previewScreenshot("Logo-1")

    Logo(caret: true)
      //.preferredColorScheme(.dark)
      .background()
      .previewScreenshot("Logo-2")

    //Logo()
    //  .preferredColorScheme(.light)
    //  .background()
    //  .previewScreenshot("_Logo~light")

    BasicUsage()
      .background()
      .previewScreenshot("BasicUsage")

    AccessoryToggles()
      .background()
      .previewScreenshot("AccessoryToggles")

//      BasicUsage().preferredColorScheme(.light)//.screenshotName("BasicUsage~light")
//      BasicUsage().preferredColorScheme(.dark)//.screenshotName("BasicUsage~dark")
//      // CustomPrompt().screenshotName("CustomPrompt")
//      AccessoryToggles().preferredColorScheme(.light)//.screenshotName("AccessoryToggles~light")
//      AccessoryToggles().preferredColorScheme(.dark)//.screenshotName("AccessoryToggles~dark")
  }

  // TODO: don’t offset but have varying widths instead?
  struct Logo: View {
    var caret = false
    var body: some View {
      let offset: CGFloat = 8
      return VStack {
        row().offset(x: offset * -3)
        row().offset(x: offset * -2)//.offset(x: 50, y: 0)
        row().offset(x: offset * -1)//.offset(x: -50, y: 0)
        
        HStack(alignment: .top) {
          field()
          //NSViewPreview { FilterTokenField() }.frame(width: 172)
          FilterField(text: .constant("Filter UI")).frame(width: 172)
            .overlay { if caret { Rectangle().size(width: 1, height: 14).offset(x: 63, y: 4).fill(.primary) } }
  
//          Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath))) ?? NSImage())
//            .padding(-20)
          
//          FilterSearchField(text: .constant("!!!")).frame(width: 172)
//            .overlay {
//              Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath)))!)
//            }
          
          field()
        }

        row().offset(x: offset * 1)//.offset(x: 50, y: 0)
        row().offset(x: offset * 2)//.offset(x: -50, y: 0)
        row().offset(x: offset * 3)
      }
      .frame(width: 640, height: 240)
    }
    
    func row() -> some View {
      HStack {
        ForEach(0..<3) { _ in
          field()
        }
      }
    }
    
    func field() -> some View {
      FilterField(text: .constant("")) {
        if Bool.random(using: &r) { toggle() }
        if Bool.random(using: &r) { toggle() }
        if Bool.random(using: &r) { toggle() }
      }
      .frame(width: 172)
    }
    
    func toggle(isOn: Bool = false) -> some View {
      FilterToggle(systemImage: logoToggleImages.randomElement(using: &r)!, isOn: .constant(isOn))
    }
  }
  
  struct BasicUsage: View {
    var body: some View {
      VStack(spacing: 15) {
        VStack(alignment: .leading) {
          Text("Regular")
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
      .padding()
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
          Text("Off")
          FilterField(text: .constant("")) {
            FilterToggle(systemImage: "location.square", isOn: .constant(false))
          }
        }

        VStack(alignment: .leading) {
          Text("On")
          FilterField(text: .constant(""), isFiltering: true) {
            FilterToggle(systemImage: "location.square", isOn: .constant(true))
          }
        }

        VStack(alignment: .leading) {
          Text("On, Non-Empty")
          FilterField(text: .constant("Lorem Ipsum"), isFiltering: true) {
            FilterToggle(systemImage: "location.square", isOn: .constant(true))
          }
        }
      }
      // .background(.background)
      .padding()
      .frame(width: 200)
    }
  }
}

let logoToggleImages = [
  "location.square",
  "tag.square",
  "wifi.square",
  "bookmark.square",
  "heart.square",
  "star.square",
  "flag.square",
  "bolt.square",
  "eye.square",
  "icloud.square",
  "lock.square",
  "square.text.square",
  "person.crop.square",
  "bell.square",
  "dot.square",
  "pin.square",
  "mic.square",
  "clock",
  "doc",
  "c.square",
]

var r = Xoroshiro256StarStar.init(seed: (0, 0, 0, 1))

protocol PseudoRandomGenerator: RandomNumberGenerator {
  associatedtype State
  init(seed: State)
  init<Source: RandomNumberGenerator>(from source: inout Source)
}

extension PseudoRandomGenerator {
  init() {
    var source = SystemRandomNumberGenerator()
    self.init(from: &source)
  }
}

private func rotl(_ x: UInt64, _ k: UInt64) -> UInt64 {
  return (x << k) | (x >> (64 &- k))
}

struct Xoroshiro256StarStar: PseudoRandomGenerator {
  typealias State = (UInt64, UInt64, UInt64, UInt64)
  var state: State
  
  init(seed: State) {
    precondition(seed != (0, 0, 0, 0))
    state = seed
  }
  
  init<Source: RandomNumberGenerator>(from source: inout Source) {
    repeat {
      state = (source.next(), source.next(), source.next(), source.next())
    } while state == (0, 0, 0, 0)
  }
  
  mutating func next() -> UInt64 {
    let result = rotl(state.1 &* 5, 7) &* 9
    
    let t = state.1 << 17
    state.2 ^= state.0
    state.3 ^= state.1
    state.1 ^= state.2
    state.0 ^= state.3
    
    state.2 ^= t
    
    state.3 = rotl(state.3, 45)
    
    return result
  }
}
