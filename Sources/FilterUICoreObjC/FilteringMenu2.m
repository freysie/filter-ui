#include "FilteringMenu2.h"

@interface FilteringMenu2 ()
@property (assign) BOOL initiallyShowsFilterField;
@property (assign) MenuRef carbonMenu;
@property (retain) NSCharacterSet *invertedControlAndSpaceCharacterSet;
@end

@implementation FilteringMenu2

- (instancetype)initWithTitle:(NSString *)title {
  self = [super initWithTitle:title];
  self.delegate = self;

  _initiallyShowsFilterField = true;

  EventTypeSpec specs[2];
  specs[0].eventClass = kEventClassMenu;
  specs[0].eventKind = kEventMenuOpening;
  specs[1].eventClass = kEventClassMenu;
  specs[1].eventKind = kEventMenuClosed;

  [self _handleCarbonEvents:specs count:2 handler:^OSStatus(NSMenu *menu, EventHandlerCallRef handler, EventRef event) {
    if (GetEventClass(event) == kEventClassMenu) {
      if (GetEventKind(event) == kEventMenuOpening) {
        NSLog(@"kEventMenuOpening %p", _carbonMenu);
        GetEventParameter(event, kEventParamDirectObject, typeMenuRef, NULL, sizeof(_carbonMenu), NULL, &_carbonMenu);
        NSLog(@"kEventMenuOpening %p", _carbonMenu);

        //HIViewRef contentView;
        //HIMenuGetContentView(_carbonMenu, kThemeMenuItemPlain, &contentView);
        //HIViewSetDrawingEnabled(contentView, false);
        //HIViewSetNeedsDisplay(contentView);
      } else if (GetEventKind(event) == kEventMenuClosed) {
        NSLog(@"kEventMenuClosed");
        _carbonMenu = nil;
      }
    }

    return noErr;
  }];

  return self;

//  NSLog(@"%@", [self _handleCarbonEvents:specs count:2 handler:^int(NSMenu *menu, EventHandlerCallRef callRef, EventRef eventRef) {
//    NSLog(@"%@", eventRef);
//    return 0;
//  }]);
}

- (NSMenuItem *)newFilterFieldItem {
  NSSearchField *field = [NSSearchField new];
  //NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
  NSMenuItem *item = [NSMenuItem new];
  item.tag = 1000;
  item.view = field;
  return item;
}

- (void)setUpFilterFieldInMenu:(NSMenu *)menu withString:(NSString *)string {
  MenuTrackingData data;
  GetMenuTrackingData(_carbonMenu, &data);
  NSLog(@"data.virtualMenuBottom = %i", data.virtualMenuBottom);
  NSLog(@"data.virtualMenuTop = %i", data.virtualMenuTop);
  NSLog(@"data.itemRect.left = %i", data.itemRect.left);
  NSLog(@"data.itemRect.right = %i", data.itemRect.right);
  NSLog(@"data.itemRect.top = %i", data.itemRect.top);
  NSLog(@"data.itemRect.bottom = %i", data.itemRect.bottom);
  NSLog(@"data.itemSelected = %i", data.itemSelected);

  NSMenuItem *filterFieldItem = [self itemWithTag:1000];
  if (!filterFieldItem) {
    filterFieldItem = [self newFilterFieldItem];
    [filterFieldItem.view setFrameSize:NSMakeSize(data.itemRect.right - data.itemRect.left, 21)];
    [menu insertItem:filterFieldItem atIndex:0];
    [self performFilterWithString:string inMenu:menu];
  }

  if ([self _isFilterFieldScrolledOutOfView:menu]) {
    [self _selectFilterFieldItem];
  }
}

- (void)_selectFilterFieldItem {
  [self highlightItem:[self itemWithTag:1000]];
}

- (void)performFilterWithString:(NSString *)string inMenu:(NSMenu *)menu {

}

- (void)menuWillOpen:(NSMenu *)menu {
  NSMenuItem *filterFieldItem = [self itemWithTag:1000];
  if (_initiallyShowsFilterField && !filterFieldItem) {
    [self setUpFilterFieldInMenu:menu withString:@""];
  } else {
    [self removeItem:filterFieldItem];
  }

  [self performFilterWithString:@"" inMenu:self];

  EventTypeSpec specs[2];
  specs[0].eventClass = kEventClassMenu;
  specs[0].eventKind = kEventMenuMatchKey;
  specs[1].eventClass = kEventClassKeyboard;
  specs[1].eventKind = kEventRawKeyDown;

  //FilterSearchField

  [self _handleCarbonEvents:specs count:2 handler:^OSStatus(NSMenu *menu, EventHandlerCallRef handler, EventRef event) {
    if (GetEventClass(event) == kEventClassMenu) {
      if (GetEventKind(event) == kEventMenuMatchKey) {
        EventRef textEvent;
        GetEventParameter(event, kEventParamEventRef, typeEventRef, NULL, sizeof(textEvent), NULL, &textEvent);

        UniChar *text;
        size_t actualSize;
        GetEventParameter(textEvent, kEventParamKeyUnicodes, typeUnicodeText, NULL, 0, &actualSize, NULL);
        text = (UniChar*)malloc(actualSize);
        GetEventParameter(textEvent, kEventParamKeyUnicodes, typeUnicodeText, NULL, actualSize, NULL, text);

        NSString *string = [NSString stringWithCharacters:text length:actualSize];

        if (!_invertedControlAndSpaceCharacterSet) {
          NSMutableCharacterSet *ignoredCharacters = [NSMutableCharacterSet controlCharacterSet];
          [ignoredCharacters addCharactersInString:@" "];
          _invertedControlAndSpaceCharacterSet = [[ignoredCharacters copy] invertedSet];
        }

        NSLog(@"%@", NSStringFromRange([string rangeOfCharacterFromSet:_invertedControlAndSpaceCharacterSet]));

        [self setUpFilterFieldInMenu:menu withString:string];
      }
    } else if (GetEventClass(event) == kEventClassKeyboard) {
      if (GetEventKind(event) == kEventParamMagnificationAmount) {
        NSLog(@"??????????");
      }
    }

    return noErr;
  }];
}

- (void)menuDidClose:(NSMenu *)menu {
  if (!_initiallyShowsFilterField) {
    [self itemWithTag:1000].view = nil;
  }
}

- (BOOL)_isFilterFieldScrolledOutOfView:(FilteringMenu2 *)filteringMenu {
  MenuRef menu = [filteringMenu carbonMenu];
  MenuTrackingData data;
//  NSLog(@"%p", data.menu);
//  NSLog(@"%i", data.itemSelected);
//  NSLog(@"%i", data.itemUnderMouse);

//  NSLog(@"%i", data.itemRect.top);
//  NSLog(@"%i", data.itemRect.left);
//  NSLog(@"%i", data.itemRect.bottom);
//  NSLog(@"%i", data.itemRect.right);

//  NSLog(@"%i", data.virtualMenuTop);
//  NSLog(@"%i", data.virtualMenuBottom);
  return menu && !GetMenuTrackingData(menu, &data) && data.virtualMenuTop < data.itemRect.top;
}

@end

@interface FilteringMenuFilterView : NSView
@end

@interface FilteringMenuFilterView ()
@property (retain) NSSearchField *filterField;
@end

@implementation FilteringMenuFilterView

@end
