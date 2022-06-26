import SwiftUI
import PreviewScreenshots

struct FilterUI_Previews: PreviewProvider {
  static var previews: some View {
    ScreenshotGroup("../../Screenshots", relativeTo: #filePath) {
//       MenuPreview(makeExampleMenu())//.screenshotName("MenuTestttttt~dark")
      Logo().preferredColorScheme(.dark).background().screenshotName("Logo~dark")
//      BasicUsage().preferredColorScheme(.light)//.screenshotName("BasicUsage~light")
//      BasicUsage().preferredColorScheme(.dark)//.screenshotName("BasicUsage~dark")
//      // CustomPrompt().screenshotName("CustomPrompt")
//      AccessoryToggles().preferredColorScheme(.light)//.screenshotName("AccessoryToggles~light")
//      AccessoryToggles().preferredColorScheme(.dark)//.screenshotName("AccessoryToggles~dark")
    }
  }
  
  struct Logo: View {
    var body: some View {
//      LazyVGrid(rows: [
//        GridItem(.fixed(172)),
//        GridItem(.fixed(172)),
//        GridItem(.fixed(172)),
//        GridItem(.fixed(172)),
//        GridItem(.fixed(172)),
//        GridItem(.fixed(172)),
//      ]) {
//        row()
//        row().offset(x: 50, y: 0)
//        row().offset(x: -50, y: 0)
//      }
//      .frame(width: 640, height: 240)
      
      VStack {
        row()
        row().offset(x: 50, y: 0)
        row().offset(x: -50, y: 0)
        
        HStack(alignment: .top) {
          FilterField(text: .constant("")).frame(width: 172)
          FilterField(text: .constant("")).frame(width: 172)
          FilterField(text: .constant("Filter UI")).frame(width: 172)
            // .overlay { Rectangle().size(width: 1, height: 14).offset(x: 63, y: 4).fill(.primary) }
  
//          Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath))) ?? NSImage())
//            .padding(-20)
          
//          FilterField(text: .constant("!!!")).frame(width: 172)
//            .overlay {
//              Image(nsImage: NSImage(contentsOf: URL(fileURLWithPath: "../../Screenshots/FilteringMenu.png", relativeTo: URL(fileURLWithPath: #filePath)))!)
//            }
          
          FilterField(text: .constant("")).frame(width: 172)
          FilterField(text: .constant("")).frame(width: 172)
        }

        row().offset(x: 50, y: 0)
        row().offset(x: -50, y: 0)
        row()
      }
      .frame(width: 640, height: 240)
    }
    
    func row() -> some View {
      HStack {
        ForEach(0..<6) { _ in
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
      FilterFieldToggle(systemImage: logoToggleImages.randomElement(using: &r)!, isOn: .constant(isOn))
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
          Text("Off")
          FilterField(text: .constant("")) {
            FilterFieldToggle(systemImage: "location.square", isOn: .constant(false))
          }
        }

        VStack(alignment: .leading) {
          Text("On")
          FilterField(text: .constant(""), isFiltering: true) {
            FilterFieldToggle(systemImage: "location.square", isOn: .constant(true))
          }
        }

        VStack(alignment: .leading) {
          Text("On, Non-Empty")
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

// import GameplayKit

//class PreviewRandomSource: RandomNumberGenerator {
//  var i: UInt64 = 0
//  func next() -> UInt64 { i += 1000; return i }
//}

// var r = PreviewRandomSource()
//var r = SystemRandomNumberGenerator()

//var r = GKLinearCongruentialRandomSource(seed: 0)
//
//extension GKRandomSource: RandomNumberGenerator {
//  public func next() -> UInt64 { UInt64(nextInt()) }
//}
// let rng = RandomNumberGenerator

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
