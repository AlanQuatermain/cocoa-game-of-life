#import <Cocoa/Cocoa.h>

@interface Cell : NSObject
{
    bool    alive;
}

@property(readwrite, assign) bool alive;

- (void)toggle;

@end
