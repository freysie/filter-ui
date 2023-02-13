#include <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

NS_ASSUME_NONNULL_BEGIN

extern OSStatus HIMenuGetContentView(MenuRef inMenu, ThemeMenuType inMenuType, HIViewRef _Nonnull * _Nonnull outView);
extern OSStatus HIViewSetDrawingEnabled(HIViewRef inView, Boolean inEnabled);
extern OSStatus HIViewSetNeedsDisplay(HIViewRef inView, Boolean inNeedsDisplay);

typedef OSStatus (^CarbonEventHandler)(NSMenu *menu, EventHandlerCallRef handler, EventRef event);

@interface NSMenu ()
- (void)highlightItem:(nullable NSMenuItem *)item;
- (id)_handleCarbonEvents:(const struct EventTypeSpec *)events count:(unsigned long long)count handler:(CarbonEventHandler)handler;
@end

@interface FilteringMenu2 : NSMenu <NSMenuDelegate>
@end

NS_ASSUME_NONNULL_END
