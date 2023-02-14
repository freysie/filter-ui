import SwiftUI
@testable import FilterUI
@testable import FilterUICore
@testable import FilterUICoreObjC

@main
struct FilterUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      // FilterUI_Previews.previews
      
      FilterField_Previews.previews
        .onAppear { _ = FilterUICore.FilterSearchField() }
        .background {
          FilteringMenu_Previews.previews
            .onAppear { _ = FilterUICoreObjC.FilteringMenu2() }
        }

      // Colors()
    }
  }
}

struct Colors: View {
  var body: some View {
    VStack(alignment: .leading) {
      Group {
        Label { Text("labelColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.labelColor)) }
        Label { Text("secondaryLabelColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.secondaryLabelColor)) }
        Label { Text("tertiaryLabelColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.tertiaryLabelColor)) }
        Label { Text("quaternaryLabelColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.quaternaryLabelColor)) }
        Label { Text("linkColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.linkColor)) }
        Label { Text("placeholderTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.placeholderTextColor)) }
        Label { Text("windowFrameTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.windowFrameTextColor)) }
        Label { Text("selectedMenuItemTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedMenuItemTextColor)) }
        Label { Text("alternateSelectedControlTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.alternateSelectedControlTextColor)) }
        Label { Text("headerTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.headerTextColor)) }
      }
      Group {
        Label { Text("separatorColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.separatorColor)) }
        Label { Text("gridColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.gridColor)) }
        Label { Text("windowBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.windowBackgroundColor)) }
        Label { Text("underPageBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.underPageBackgroundColor)) }
        Label { Text("controlBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.controlBackgroundColor)) }
        Label { Text("selectedContentBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedContentBackgroundColor)) }
        Label { Text("unemphasizedSelectedContentBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.unemphasizedSelectedContentBackgroundColor)) }
        //Label { Text("alternatingContentBackgroundColors") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.alternatingContentBackgroundColors)) }
        Label { Text("findHighlightColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.findHighlightColor)) }
        Label { Text("textColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.textColor)) }
      }
      Group {
        Label { Text("textBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.textBackgroundColor)) }
        Label { Text("selectedTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedTextColor)) }
        Label { Text("selectedTextBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedTextBackgroundColor)) }
        Label { Text("unemphasizedSelectedTextBackgroundColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.unemphasizedSelectedTextBackgroundColor)) }
        Label { Text("unemphasizedSelectedTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.unemphasizedSelectedTextColor)) }
        Label { Text("controlColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.controlColor)) }
        Label { Text("controlTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.controlTextColor)) }
        Label { Text("selectedControlColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedControlColor)) }
        Label { Text("selectedControlTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.selectedControlTextColor)) }
        Label { Text("disabledControlTextColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.disabledControlTextColor)) }
      }
//      Group {
//        Label { Text("keyboardFocusIndicatorColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.keyboardFocusIndicatorColor)) }
//        Label { Text("scrubberTexturedBackground") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.scrubberTexturedBackground)) }
//        Label { Text("controlAccentColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.controlAccentColor)) }
//        Label { Text("highlightColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.highlightColor)) }
//        Label { Text("shadowColor") } icon: { Rectangle().size(width: 16, height: 16).fill(Color(NSColor.shadowColor)) }
//      }
    }
  }
}
