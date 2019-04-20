#ifndef DC_UTILS
#define DC_UTILS
#include "privateHeaders.h"
#include "external/tab_model_observer.h"
@interface FakeLocationBar : NSObject
    @property (strong) NSMutableArray *effectViews;
    @property (weak) NSLayoutConstraint *heightConstraint;
    @property CGFloat oldHeight;
    @property bool needsInitialization;
    @property (weak) UIVisualEffectView *mainVisualEffect;
    @property bool effectsHidden;
    @property (weak) UIButton* fakeBox;
    - (id)init;
    - (void)needsReInit;
@end

@implementation FakeLocationBar
- (id)init {
    self.effectViews = [[NSMutableArray alloc] init];
    self.heightConstraint = nil;
    self.oldHeight = -1;
    self.needsInitialization = true;
    self.mainVisualEffect = nil;
    self.effectsHidden = false;
    self.fakeBox = nil;
    return self;
}
- (void)needsReInit {
    [[self effectViews] removeAllObjects];
    self.heightConstraint = nil;
    self.oldHeight = -1;
    self.needsInitialization = true;
    self.mainVisualEffect = nil;
    self.effectsHidden = false;
    self.fakeBox = nil;
}
@end

@interface TabModelWatcher : NSObject <TabModelObserver>
    @property (strong, nonatomic) BrowserViewController *bvc;
    - (instancetype)initWithBvc:(BrowserViewController*) b;
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