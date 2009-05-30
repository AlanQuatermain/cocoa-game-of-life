#import "Cell.h"

@implementation Cell

@synthesize alive;

- (void)toggle
{
    alive = !alive;
}

@end
