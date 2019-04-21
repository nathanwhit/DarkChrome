#ifndef DC_UTILS
#define DC_UTILS

#include "privateHeaders.h"
#include "external/tab_model_observer.h"
#include <os/log.h>

#define log(str) os_log(OS_LOG_DEFAULT, str)
#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)

@interface FakeLocationBar : NSObject
    @property (weak) UIVisualEffectView *subEffect1;
    @property (weak) UIVisualEffectView *subEffect2;
    @property (weak) UIVisualEffectView *mainVisualEffect;
    @property CGFloat oldHeight;
@end

@implementation FakeLocationBar
@end

@interface TabModelWatcher : NSObject <TabModelObserver>
@end

@interface UIImage (ResizeCategory)
- (UIImage*)imageWithSize:(CGSize)newSize;
@end

@implementation UIImage (ResizeCategory)
- (UIImage*)imageWithSize:(CGSize)newSize
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext) {
        [self drawInRect:(CGRect) {.origin = CGPointZero, .size = newSize}];
    }];
    return image;
}
@end
#endif