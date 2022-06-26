import SwiftUI
import ObjectiveC

struct MenuPreview: View {
  let menu: NSMenu
  @State var image = NSImage?.none
  
  init(_ menu: NSMenu) {
    self.menu = menu
  }
  
  var body: some View {
    Image(nsImage: image ?? NSImage())
      .frame(maxWidth: image?.size.width ?? .infinity, maxHeight: image?.size.height ?? .infinity)
      .onAppear {
        DispatchQueue.main.async {
          if image == nil {
            image = menu.createWindowImage()
          }
        }
      }
  }
}

extension NSMenu {
//  func saveWindowImage(path: String) {
  func createWindowImage() -> NSImage {
    var result = NSImage()
    let firstViewer = self.items.first!.value(forKey: "_menuItemViewer") as? NSView
//    print((firstViewer, firstViewer?.window))
    
    let timer = Timer(timeInterval: 0, repeats: false) { _ in
      guard let window = firstViewer?.window else { return }
//      print(window)
      
      let image = CGWindowListCreateImage(
        .null,
        .optionIncludingWindow,
        CGWindowID(window.windowNumber),
        .bestResolution
      )
      
//      print(image)
      
      guard let image = image else { return }
      
//      let url = NSURL(fileURLWithPath: path)
//      let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil)!
//      CGImageDestinationAddImage(dest, image, nil)
//      CGImageDestinationFinalize(dest)
      
      result = NSImage(cgImage: image, size: window.contentView!.bounds.size)
//      print(result)

//      self.cancelTrackingWithoutAnimation()
    }
    
    RunLoop.main.add(timer, forMode: .common)
    
    popUp(positioning: nil, at: .zero, in: NSApp.windows.first?.contentView)
    
    return result
  }
  
//  var preview: some View {
////    let path = "/tmp/\(UUID()).png"
////    let image = screenshot(path: path)
//    return Image(nsImage: createWindowImage())
//  }
}

struct NSMenuPreview_Previews: PreviewProvider {
  static var previews: some View { Example() }
  
  struct Example: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
      let menu = makeExampleMenu()
      
      let view = NSView()
      view.menu = menu

//      DispatchQueue.main.async {
////        let image = menu.screenshot(path: "/tmp/ddd.png")
//        let image = menu.createWindowImage()
//
////        guard let data = imageRep.representation(using: .png, properties: [:]) else {
////          preconditionFailure()
////        }
////
////        try? data.write(to: URL(fileURLWithPath: path).appendingPathExtension("png"))
////
////        let url = NSURL(fileURLWithPath: "/tmp/test.png")
////        let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil)!
////        CGImageDestinationAddImage(dest, image, nil)
////        CGImageDestinationFinalize(dest)
//      }
      
      return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
      
    }
    
    let titlesA = [
      "Here’s to the crazy ones",
      "The misfits",
      "The rebels",
      "The troublemakers",
      "The round pegs in the square holes",
      "The ones who see things differently",
      "They're not fond of rules",
      "And they have no respect for the status quo"
    ]
    
    let titlesB = [
      "You can quote them, disagree with them, glorify or vilify them",
      "About the only thing you can't do is ignore them",
      "Because they change things",
      "They push the human race forward",
    ]
  }
}

class MenuWindowAccessor: NSMenuItem {
  convenience init(block: @escaping (NSWindow) -> Void) {
    self.init()
    let view = MenuWindowAccessorView()
    view.block = block
    self.view = view
  }
}

class MenuWindowAccessorView: NSView {
  var block: ((NSWindow) -> Void)!
  
  override func viewDidMoveToWindow() {
    guard let window = window else { return }
    block(window)
    
    guard let item = enclosingMenuItem else { return }
    item.menu?.removeItem(item)
  }
}

//class MenuScreenshotGenerator: NSView {
//  override func viewDidMoveToWindow() {
//    guard let window = window else { return }
//
//    DispatchQueue.main.async {
//      if let item = self.enclosingMenuItem {
//        item.menu?.removeItem(item)
//      }
//
//      let image = CGWindowListCreateImage(
//        .null,
//        .optionIncludingWindow,
//        CGWindowID(window.windowNumber),
//        .bestResolution
//      )
//
//      print((window, window.windowNumber, image))
//
//      guard let image = image else { return }
//
//      let url = NSURL(fileURLWithPath: "/tmp/test.png")
//      let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil)!
//      CGImageDestinationAddImage(dest, image, nil)
//      CGImageDestinationFinalize(dest)
//    }
//  }
//}
