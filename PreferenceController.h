#import <Cocoa/Cocoa.h>

extern NSString * const CGLBackgroundColorKey;
extern NSString * const CGLBorderColorKey;
extern NSString * const CGLCellAliveColorKey;
extern NSString * const CGLCellDeadColorKey;
extern NSString * const CGLColorChangedNotification;
extern NSString * const CGLBorderSizeKey;
extern NSString * const CGLBorderSizeChangedNotification;

@interface PreferenceController : NSWindowController
{
    IBOutlet NSColorWell *borderColor;
    IBOutlet NSColorWell *backgroundColor;
    IBOutlet NSColorWell *cellAliveColor;
    IBOutlet NSColorWell *cellDeadColor;

    IBOutlet NSSliderCell *borderSize;

    NSUserDefaults *defaults;
    NSNotificationCenter *nc;
}

- (NSColor *)backgroundColor;
- (NSColor *)borderColor;
- (NSColor *)cellAliveColor;
- (NSColor *)cellDeadColor;
- (int)borderSize;

#pragma mark Events
- (IBAction)changeBorderColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeCellAliveColor:(id)sender;
- (IBAction)changeCellDeadColor:(id)sender;
- (IBAction)changeBorderSize:(id)sender;

@end
