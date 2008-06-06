#import <Cocoa/Cocoa.h>

extern NSString * const CGLBackgroundColorKey;
extern NSString * const CGLBorderColorKey;
extern NSString * const CGLCellAliveColorKey;
extern NSString * const CGLCellDeadColorKey;
extern NSString * const CGLColorChangedNotification;

@interface PreferenceController : NSWindowController {
    IBOutlet NSColorWell *borderColor;
    IBOutlet NSColorWell *backgroundColor;
    IBOutlet NSColorWell *cellAliveColor;    
    IBOutlet NSColorWell *cellDeadColor;
	
	NSUserDefaults *defaults;
	NSNotificationCenter *nc;
}
- (NSColor *)backgroundColor;
- (NSColor *)borderColor;
- (NSColor *)cellAliveColor;
- (NSColor *)cellDeadColor;

#pragma mark Events
- (IBAction)changeBorderColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeCellAliveColor:(id)sender;
- (IBAction)changeCellDeadColor:(id)sender;

@end
