#define INSPECT 1

#include <os/log.h>
#include "privateHeaders.h"
#include <math.h>
#include "external/toolbar_utils.mm"

#define log(str) os_log(OS_LOG_DEFAULT, str)
#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)

#define RESOURCEPATH @"/Library/Application Support/com.nwhit.darkchromebund.bundle"

NSDictionary *preferences;
NSString* chosenScheme;
UIColor * bg;
UIColor * fg;
UIColor * altfg;
UIColor * sep;
UIColor * blurColor;
bool useIncognitoIndicator;
CGFloat fakeLocBarMinHeight;
CGFloat fakeLocBarExpandedHeight;
CGFloat maxHeightDelta;
__weak BrowserViewWrangler *wrangler; 
CGFloat blurWhite;
CGFloat blurAlpha;
CGFloat alphaOffset;

NSBundle *resBundle;

#if INSPECT==1
#include "InspCWrapper.m"
#endif


%ctor {
    #if INSPECT==1
    // watchClass(%c(FormSuggestionView));
    watchClass(%c(TableViewURLCell));
    #endif

    NSString* prefsPath = @"/User/Library/Preferences/com.nwhit.darkchromeprefs.plist";
    bool bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:RESOURCEPATH isDirectory:nil];
    if (bundleExists) {
        resBundle = [[NSBundle alloc] initWithPath:RESOURCEPATH];
    }
    else {
        resBundle = nil;
        log("BUNDLE DOES NOT CURRENTLY EXIST IN FILESYSTEM");
    }
    NSError* errorThrown;
    BOOL isDir;
    bool prefsInitialized = [[NSFileManager defaultManager] fileExistsAtPath:prefsPath isDirectory:&isDir];
        if  (prefsInitialized && !isDir) {
            if (@available(iOS 11, *)) {
                NSURL * prefsURL = [[NSURL alloc] initFileURLWithPath:prefsPath isDirectory:false];
                preferences = [[NSDictionary alloc] initWithContentsOfURL:prefsURL error:&errorThrown];
            }
            else {
                preferences = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
            }
        }
        else {
            preferences = @{
                @"useIncognitoIndicator" : @true,
                @"colorScheme" : @"dark",
            };
        }
    
    UIColor* dark_color1 = [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha: 1];
    UIColor* dark_color2 = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha: 1];
    UIColor* dark_color3 = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha: 1];
    UIColor* dark_color4 = [UIColor colorWithWhite:0.9 alpha: 0.4];
    UIColor* clear = [UIColor colorWithWhite:0 alpha:0];
    UIColor* black_color1 = [UIColor colorWithWhite:0 alpha: 1];
    UIColor* black_color2 = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    UIColor* black_color4 = [UIColor colorWithWhite:0.3 alpha: 0.6];
    if (!preferences[@"useIncognitoIndicator"] || ![preferences[@"useIncognitoIndicator"] boolValue]) {
        useIncognitoIndicator = false;
    } else {
        useIncognitoIndicator = true;
    }

    NSDictionary *darkScheme = @{
        @"background" : dark_color1,
        @"foreground" : dark_color2,
        @"altforeground" : dark_color2,
        @"separ" : dark_color3,
        @"blur": dark_color4,
        @"offset": @(0.09)
    };

    NSDictionary *flatDarkScheme = @{
        @"background" : dark_color1,
        @"foreground" : dark_color1,
        @"altforeground" : dark_color2,
        @"separ" : clear,
        @"blur": dark_color4,
        @"offset": @(0.09)
    };

    NSDictionary *trueBlackScheme = @{
        @"background" : black_color1,
        @"foreground" : black_color1,
        @"altforeground" : black_color2,
        @"separ" : clear,
        @"blur": black_color4,
        @"offset": @(0.16)
            
    };
    chosenScheme = [[NSString alloc] initWithString:[preferences objectForKey:@"colorScheme"]];
    
    NSDictionary* schemeForString = @{@"dark" : darkScheme, @"flatDark" : flatDarkScheme, @"trueBlack" : trueBlackScheme};
    bg = [schemeForString[chosenScheme] objectForKey:@"background"];
    fg = [schemeForString[chosenScheme] objectForKey:@"foreground"];
    altfg = [schemeForString[chosenScheme] objectForKey:@"altforeground"];
    sep = [schemeForString[chosenScheme] objectForKey:@"separ"];
    blurColor = [schemeForString[chosenScheme] objectForKey:@"blur"];
    [blurColor getWhite: &blurWhite alpha: &blurAlpha];
    alphaOffset = [(NSNumber*)[schemeForString[chosenScheme] objectForKey:@"offset"] doubleValue];
    
    fakeLocBarMinHeight = LocationBarHeight([[UIApplication sharedApplication] preferredContentSizeCategory]);
    fakeLocBarExpandedHeight = ToolbarExpandedHeight([[UIApplication sharedApplication] preferredContentSizeCategory]);
    maxHeightDelta = fakeLocBarExpandedHeight - fakeLocBarMinHeight;
    
    wrangler=nil; 
}

// COLORS
static UIColor * txt = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * clear = [UIColor colorWithWhite:0 alpha:0];
static UIColor * hint = [UIColor colorWithWhite:0.6 alpha:1];
static UIColor * white = [UIColor colorWithWhite:1 alpha:1];
static UIColor * tab_bar = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * detail = [UIColor colorWithWhite:1 alpha:0.5];
static UIColor * incognitoIndicatorColor = [UIColor colorWithWhite:0.9 alpha:0.5];
static UIColor * kbColor = [UIColor colorWithWhite:0.18 alpha:1];
static UIColor * kbSuggestColor = [UIColor colorWithWhite:0.25 alpha:1];

// CLASS OBJECTS FOR TYPE VERIFICATION
static Class articlesHeaderCellClass = %c(ContentSuggestionsArticlesHeaderCell);
static Class suggestCellClass = %c(ContentSuggestionsCell);
static Class suggestFooterClass = %c(ContentSuggestionsFooterCell);
static Class settingsTextCellClass = %c(SettingsTextCell);
static Class MDCCellClass = %c(MDCCollectionViewCell);
static Class visContentViewClass = %c(_UIVisualEffectContentView);
static Class visEffectViewClass = %c(UIVisualEffectView);
static Class buttonClass = %c(UIButton);
static Class visEffectSubviewClass = %c(_UIVisualEffectSubview);
static Class visEffectBackdropClass = %c(_UIVisualEffectBackdropView);

static CGFloat locBarCornerRadius = 25; 

// UTILITY
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

static void setButtonBackground(NSString* name, __weak UIButton* button, CGSize size, bool closeButton) {
    NSString* imagePath = [resBundle pathForResource:name ofType:@"png"];
    if (size.height == 0 && size.width == 0) {
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
        UIImage *selectedImage = [UIImage imageWithContentsOfFile:[imagePath stringByAppendingString:@"_pressed"]];
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
        if (!closeButton) {
            [button setBackgroundImage:[UIImage imageWithContentsOfFile:[imagePath stringByAppendingString:@"_inactive"]] forState:UIControlStateDisabled];
        }
        return;
    }
    [button setBackgroundImage:[[UIImage imageWithContentsOfFile:imagePath] imageWithSize:size] forState:UIControlStateNormal];
    UIImage *selectedImage = [[UIImage imageWithContentsOfFile:[imagePath stringByAppendingString:@"_pressed"]] imageWithSize:size];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    if (!closeButton) {
        [button setBackgroundImage:[[UIImage imageWithContentsOfFile:[imagePath stringByAppendingString:@"_inactive"]] imageWithSize:size] forState:UIControlStateDisabled];
    }
}

// AUTOFILL UI
%hook AutofillEditAccessoryView
    -(void)setupSubviews {
        %orig;
        [self setBackgroundColor:kbColor];
        if ([[self subviews] count] < 5) {
            return;
        }
        CGRect bgFrame = [reinterpret_cast<UIImageView*>([[self subviews] objectAtIndex:0]) frame];
        CGFloat buttonHeight = bgFrame.size.height;
        CGFloat buttonWidth = buttonHeight;
        CGSize buttonSize = CGSizeMake(buttonWidth, buttonHeight);
        UIButton *button = [[self subviews] objectAtIndex: 4];
        setButtonBackground(@"autofill_close", button, buttonSize, true);
        button = [self nextButton];
        setButtonBackground(@"autofill_next", button, buttonSize, false);
        button = [self previousButton];
        setButtonBackground(@"autofill_prev", button, buttonSize, false);
        // CGSize sepSize = CGSizeMake(1, buttonHeight);
        // UIImageView *sepView = reinterpret_cast<UIImageView*>([[self subviews] objectAtIndex:2]);
        UIView *sepView = [[self subviews] objectAtIndex:2];
        [sepView setHidden:true];
        // [sepView setImage:[[UIImage imageWithContentsOfFile:[resBundle pathForResource:@"autofill_left_sep" ofType:@"png"]] imageWithSize:sepSize]];
        // sepView = reinterpret_cast<UIImageView*>([[self subviews] objectAtIndex:5]);
        sepView = [[self subviews] objectAtIndex:5];
        [sepView setHidden:true];
        // [sepView setImage:[[UIImage imageWithContentsOfFile:[resBundle pathForResource:@"autofill_right_sep" ofType:@"png"]] imageWithSize:sepSize]];
    }
    - (void)addBackgroundImage {
        %orig;
        if ([[self subviews] count] > 0) {
            UIImage * img = [UIImage imageWithContentsOfFile: [resBundle pathForResource:@"autofill_keyboard_background" ofType:@"png"]];
            // THE FOLLOWING CODE ADAPTED FROM THE CHROMIUM PROJECT, SEE LICENSE IN "EXTERNAL" FOLDER
            double topInset = floor(img.size.height/2.0);
            double leftInset = floor(img.size.width/2.0);
            UIEdgeInsets insets = UIEdgeInsetsMake(topInset, leftInset, img.size.height-topInset+1.0, img.size.width-leftInset+1.0);
            [[[self subviews] objectAtIndex:0] setImage: [img resizableImageWithCapInsets:insets]];
            [[[self subviews] objectAtIndex:0] setBackgroundColor: kbColor];
        }
        [self setBackgroundColor:kbColor];
    }
%end

// FIND BAR UI

%hook FindBarView
    - (void)setDarkMode:(BOOL)arg {
        %orig(true);
    }
    - (id)initWithDarkAppearance:(BOOL)arg {
        return %orig(true);
    }
    - (BOOL)darkMode {
        return true;
    }
%end

%hook FindBarControllerIOS
    - (void)setIsIncognito:(BOOL)arg {
        %orig(true);
    }
    - (BOOL)isIncognito {
        return true;
    }
    - (id)initWithIncognito:(BOOL)arg {
        id cont = %orig(true);
        return cont;
    }
    - (void)setView:(UIView*)arg {
        [arg setBackgroundColor:altfg];
        %orig(arg);
    }
%end

// VOICE SEARCH UI
%hook GSKGlifVoiceSearchContainerView
    - (void)setBackgroundColor:(UIColor*)color {
        %orig(fg);
    }
%end

%hook GSKStreamingTextView
    - (void)setFillColor:(UIColor*)color {
        %orig(fg);
    }

    - (void)setStableColor:(UIColor*)color {
        %orig(txt);
    }

    - (void)setUnstableColor:(UIColor*)color {
        %orig(detail);
    }
%end

%hook QTMButton
    - (void)setTintColor:(UIColor*)color {
        %orig(white);
    }
%end

// KEYBOARD

// %hook FormSuggestionView
//     - (void)setBackgroundColor:(UIColor*)arg {
//         %orig(altfg);
//     }
//     - (UIColor*)backgroundColor {
//         return altfg;
//     }
// %end

%hook FormSuggestionLabel
    - (void)setBackgroundColor:(UIColor*)arg {
        %orig(kbSuggestColor);
    }

    - (FormSuggestionLabel*)initWithSuggestion:(id)arg1 index:(NSUInteger)arg2 userInteractionEnabled:(BOOL)arg3 numSuggestions:(NSUInteger)arg4 client:(id)arg5 {
        __strong FormSuggestionLabel* suggest = %orig;
        if ([[suggest subviews] count] < 1) {
            return suggest;
        }
        if (![[[suggest subviews] objectAtIndex:0] isKindOfClass:%c(UIStackView)]) {
            return suggest;
        }
        __weak UIStackView* stack = reinterpret_cast<UIStackView*>([[suggest subviews] objectAtIndex:0]);
        if ([[stack arrangedSubviews] count] < 1) {
            return suggest;
        }
        __weak id lbl = [[stack arrangedSubviews] objectAtIndex:0];
        if (![lbl isKindOfClass:%c(UILabel)]) {
            return suggest;
        }
        __weak UILabel *label = reinterpret_cast<UILabel*>(lbl);
        [label setTextColor:txt];
        return suggest;

    }
%end

%hook FormInputAccessoryView
    - (void)setUpWithLeadingView:(id)arg1 navigationDelegate:(id)arg2 {
        %orig;
        __weak id v = [self leadingView];
        [v setBackgroundColor:kbColor];
        [v setOpaque:false];
    }
    - (void)setLeadingView:(id)arg {
        %orig;
        __weak id v = arg;
        [v setBackgroundColor:kbColor];
        [v setOpaque:false];
    }

    - (void)setUpWithLeadingView:(id)arg1 customTrailingView:(id)arg2 navigationDelegate:(id)arg3 {
        %orig;
        __weak id v = [self leadingView];
        [v setBackgroundColor:kbColor];
        [v setOpaque:false];
    }

    - (UIView*)viewForNavigationButtons {
        UIView* v = %orig;
        UIButton *button = [self nextButton];
        CGSize size = CGSizeMake(0, 0);
        setButtonBackground(@"autofill_next", button, size, false);
        [button setBackgroundColor:kbColor];

        button = [self previousButton];
        setButtonBackground(@"autofill_prev", button, size, false);
        [button setBackgroundColor:kbColor];

        if ([[v subviews] count] < 5) {
            return v;
        }

        button = [[v subviews] objectAtIndex: 5];
        setButtonBackground(@"autofill_close", button, size, true);
        [button setBackgroundColor:kbColor];

        UIImageView *sepView = [[v subviews] objectAtIndex: 0];
        [sepView setImage:[UIImage imageWithContentsOfFile:[resBundle pathForResource:@"autofill_left_sep" ofType:@"png"]]];
        sepView = [[v subviews] objectAtIndex: 2];
        // [sepView setImage:[UIImage imageWithContentsOfFile:[resBundle pathForResource:@"autofill_left_sep" ofType:@"png"]]];
        [sepView setHidden:true];
        sepView = [[v subviews] objectAtIndex: 4];
        // [sepView setImage:[UIImage imageWithContentsOfFile:[resBundle pathForResource:@"autofill_right_sep" ofType:@"png"]]];
        [sepView setHidden:true];

        [v setBackgroundColor: kbColor];
        return v;
    }

%end

%hook ToolbarKeyboardAccessoryView
    - (UIView*)shortcutButtonWithTitle:(NSString*)title {
        UIButton* button = (UIButton*)%orig;
        [button setTitleColor:txt forState:UIControlStateNormal];
        [button setTitleColor:detail forState:UIControlStateHighlighted];
        return button;
    }

%end

%hook UIKBRenderConfig
    - (void)setLightKeyboard:(BOOL)arg {
        %orig(false);
    }
%end

%hook OmniboxTextFieldIOS
    - (id)initWithFrame:(CGRect)arg1 textColor:(id)arg2 tintColor:(id)arg3 {
        id ret = %orig;
        if ([ret respondsToSelector: @selector(setKeyboardAppearance:)]) {
            [ret setKeyboardAppearance: UIKeyboardAppearanceDark];
        }
        return ret;
    }
%end

%hook UITextField
    - (id)init {
        id ret =  %orig;
        [ret setKeyboardAppearance: UIKeyboardAppearanceDark];
        return ret;
    }
%end

%hook UISearchBar
    - (id)initWithFrame:(CGRect)arg {
        id ret =  %orig;
        [ret setKeyboardAppearance: UIKeyboardAppearanceDark];
        return ret;
    }
%end

// INCOGNITO
%hook IncognitoView
    - (void)setBackgroundColor:(id)arg {
        %orig(bg);
    }
%end
   
%hook BrowserViewWrangler
    - (void)createMainBrowser {
        %orig;
        wrangler = (BrowserViewWrangler*)self;
    }
%end

// TAB OVERVIEW
%hook GridCell
    - (void)setTheme:(NSUInteger)arg {
        %orig(2);
    }
%end
    
%hook GridViewController
    - (void)loadView {
        %orig;
        [[self collectionView] setBackgroundColor:bg];
        [[[self collectionView] backgroundView] setBackgroundColor:bg];
    }
%end
    
// TABLES
%hook ChromeTableViewStyler
    - (id)init {
        ChromeTableViewStyler * tblStyler = %orig;
        [tblStyler setTableViewSectionHeaderBlurEffect:[UIBlurEffect effectWithStyle:2]];
        [tblStyler setCellBackgroundColor:fg];
        [tblStyler setCellTitleColor:txt];
        [tblStyler setCellSeparatorColor:sep];
        return tblStyler;
    }
    
    - (void)setTableViewBackgroundColor:(id)arg {
        %orig(bg);
    }

    - (void)setCellBackgroundColor:(id)arg {
        %orig(fg);
    }

    - (void)setCellTitleColor:(id)arg {
        %orig(txt);
    }

    - (void)setCellSeparatorColor:(id)arg {
        %orig(sep);
    }
%end
    
%hook TableViewTextHeaderFooterView
    - (id)initWithReuseIdentifier:(id)arg {
        TableViewTextHeaderFooterView* vw = %orig;
        [[vw textLabel] setTextColor:white];
        return vw;
    }
%end

    
%hook TableViewDisclosureHeaderFooterItem
    - (void)configureHeaderFooterView:(id)arg1 withStyler:(id)arg2 {
        %orig;
        [[arg1 titleLabel] setBackgroundColor:clear];
        [[arg1 titleLabel] setTextColor:white];
    }
%end  
    
%hook TableViewActivityIndicatorHeaderFooterItem
    - (void)configureHeaderFooterView:(id)arg1 withStyler:(id)arg2 {
        %orig;
        [[arg1 titleLabel] setBackgroundColor:clear];
        [[arg1 titleLabel] setTextColor:white];
        [[arg1 contentView] setBackgroundColor:bg];
    }
%end
    
%hook TableViewImageItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector:@selector(titleLabel)]) {
            [[arg1 titleLabel] setBackgroundColor:clear];
            [[arg1 titleLabel] setTextColor:txt];
        }
        
        [[arg1 imageView] setBackgroundColor:clear];
    }
%end
    
%hook TableViewTextLinkItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector:@selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:txt];
            [[arg1 textLabel] setBackgroundColor:fg];
        }   
    }
%end

%hook PopupMenuNavigationItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector:@selector(titleLabel)]) {
            [[arg1 titleLabel] setBackgroundColor:clear];
            [[arg1 titleLabel] setTextColor:txt];
            [[arg1 imageView] setBackgroundColor:clear];
        }
    }
%end
    
    

//  SETTINGS->PAYMENT METHODS/ADDRESSES AND MORE   
    
%hook AutofillDataCell
    - (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 {
        AutofillDataCell * cell = %orig;
        [[cell textLabel] setTextColor:txt];
        return cell;
    }
%end    
%hook AutofillEditCell
    - (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 {
        AutofillEditCell * cell = %orig;
        [[cell textLabel] setTextColor:white];
        return cell;
    }
%end  
    
    //  SETTINGS -> PRIVACY -> CLEAR BROWSING DATA

%hook ClearBrowsingDataItem
    - (void)configureCell:(id)arg {
        %orig;
        [[arg textLabel] setTextColor:txt];
        [[arg contentView] setBackgroundColor:fg];
    }
%end

%hook ClearBrowsingDataCollectionViewController
    - (void)loadModel {
        %orig;
        [[self collectionView] setBackgroundColor:bg];
    }
%end

%hook SettingsTextItem
    - (void)configureCell:(id)arg {
        %orig;
        [[arg contentView] setBackgroundColor:fg];
        [[arg inkView] setBackgroundColor:clear];
        [[arg textLabel] setTextColor:[UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1]];
        if ([arg isKindOfClass:settingsTextCellClass]) {
            __weak id separator = MSHookIvar<UIView*>(arg, "_separatorView");
            [separator setBackgroundColor:sep];
            [[arg accessoryView] setTintColor:white];
            [[arg accessoryView] setBackgroundColor:clear];
        }
    }
%end

%hook TableViewURLCell

    -(void)setBackgroundColor:(id)arg {
        %orig(fg);
    }
    - (void)configureUILayout {
        if (![self respondsToSelector:@selector(horizontalStack)]) {
            %orig;
            return;
        }
        __weak UIStackView* stack = [self horizontalStack];
        for (__weak id v in [stack arrangedSubviews]) {
            if ([v isKindOfClass:%c(UIStackView)]) {
                for (__weak UILabel* lab in [v arrangedSubviews]) {
                    [lab setBackgroundColor:clear];
                    [lab setTextColor:txt];
                }
            } else {
                [v setBackgroundColor:clear];
                [v setTextColor:txt];
            }
        }
        if (stack) {
            [self setHorizontalStack: stack];
        }
        if ([self respondsToSelector:@selector(faviconContainerView)]) {
            [[self faviconContainerView] setBackgroundColor:fg];
        }
        %orig;
    }
%end
    
    //  CONTENT SUGGESTIONS/NEW TAB PAGE

%hook ContentSuggestionsViewController
    - (id)collectionView {
        __weak id v = %orig;
        [v setBackgroundColor:bg];
        return v;
    }
%end
    
%hook NTPMostVisitedTileView
    - (id)initWithFrame:(CGRect)arg {
        id tile = %orig;
        [[tile titleLabel] setTextColor:white];
        __weak id imgView = [tile imageBackgroundView];
        [imgView setImage: [(UIImage*)[imgView image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imgView setTintColor: altfg];
        return tile;
    }
%end
    
%hook NTPShortcutTileView
    - (id)initWithFrame:(CGRect)arg {
        id tile = %orig;
        [[tile titleLabel] setTextColor:white];
        __weak id imgView = [tile imageBackgroundView];
        [imgView setImage: [(UIImage*)[imgView image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imgView setTintColor: altfg];
        return tile;
    }
%end
    
%hook ContentSuggestionsArticlesHeaderCell
    - (void)drawSeparatorIfNeeded {
        %orig;
        __weak id separator = MSHookIvar<UIView*>(self, "_separatorView");
        [separator setBackgroundColor:sep];
    }
    - (void)configureCell:(id)cell {
        %orig;
        [[self label] setTextColor:white];
    }
%end
    
%hook ContentSuggestionsCell
    + (void)configureTitleLabel:(id)lbl {
        %orig;
        [lbl setTextColor:txt];
    }
    - (void)drawSeparatorIfNeeded {
        %orig;
        __weak id separator = MSHookIvar<UIView*>(self, "_separatorView");
        [separator setBackgroundColor:sep];
    }
%end
    
static NSMutableSet *imageViewPassSet = [[NSMutableSet alloc] init];
static NSMutableSet *imageViewSuggestSet = [[NSMutableSet alloc] init];
static NSMutableSet *imageViewSettingsSet = [[NSMutableSet alloc] init];

static UIImage* handleSuggestionCell(id cell, __weak id image, __weak id superview) {
    UIImage* img = [(UIImage*)image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell setTintColor: altfg];
    if ([superview isKindOfClass:settingsTextCellClass] && [[cell interactionTintColor] isEqual:altfg]) {
        [cell setBackgroundColor:altfg];
    }
    [[superview contentView] setBackgroundColor:nil];
    return img;
}

static UIImage* handleSettingsCell(id cell, __weak id image, __weak id superview) {
    UIImage* img = [(UIImage*)image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell setTintColor: fg];
    if ([[cell interactionTintColor] isEqual:fg]) {
        [cell setBackgroundColor:fg];
    }
    [[superview contentView] setBackgroundColor:nil];
    return img;
}

%hook UIImageView
    - (void)setImage:(id)arg {
        if ([imageViewPassSet containsObject: self]) {
            %orig;
            return;
        }
        if ([imageViewSuggestSet containsObject: self]) {
            UIImage* img = handleSuggestionCell(self, arg, [self superview]);
            %orig(img);
            return;
        }
        else if ([imageViewSettingsSet containsObject: self]) {
            __weak id superview = [self superview];
            UIImage* img = handleSettingsCell(self, arg, superview);
            %orig(img);
            return;
        }
        
        if ([self respondsToSelector:@selector(superview)] && [[self superview] isKindOfClass: MDCCellClass]) {
            __weak id superview = [self superview];
            if ([superview isKindOfClass:articlesHeaderCellClass] || [superview isKindOfClass:suggestCellClass] || [superview isKindOfClass:suggestFooterClass]) {
                [imageViewSuggestSet addObject: self];
                UIImage* img = handleSuggestionCell(self, arg, superview);
                %orig(img); 
                return;
            } else if ([superview isKindOfClass:settingsTextCellClass]){
                [imageViewSettingsSet addObject: self];
                UIImage* img = handleSettingsCell(self, arg, superview);
                %orig(img);
                return;
            }
            else {
                [imageViewPassSet addObject: self];
                %orig;
            }
        }
        else {
            [imageViewPassSet addObject: self];
            %orig;
        }
    }
%end
    
%hook ContentSuggestionsItem
    - (void)configureCell:(id)cell {
        %orig;
        if ([cell respondsToSelector: @selector(additionalInformationLabel)]) {
            [[cell additionalInformationLabel] setTextColor:txt];
        }
    }
%end
    
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

static NSNumber* activeTabID = nil;
static __strong NSMutableDictionary<NSNumber*, FakeLocationBar*> *fakeLocBars = [[NSMutableDictionary alloc] init];
static __strong NSMutableDictionary<NSNumber*, FakeLocationBar*> *headerViews = [[NSMutableDictionary alloc] init];

%hook TabGridViewController
    -(void)setView:(id)arg {
        %orig;
        [arg setBackgroundColor:bg];
    }
    -(void)setupRegularTabsViewController {
        %orig;
        [[self view] setBackgroundColor:bg];
        
    }
%end
    
%hook Tab
    - (id)initWithWebState:(id)ws {
        __strong id tab = %orig;
        if (tab == nil) {
            return tab;
        }
        NSNumber *t = @((NSInteger)tab);
        if (fakeLocBars == nil) {
            fakeLocBars = [[NSMutableDictionary alloc] init];
        }
        if (t != nil) {
            if (!fakeLocBars[t]) {
                fakeLocBars[t] = [[FakeLocationBar alloc] init];
            }
        }
        return tab;
    }
    - (void)webStateDestroyed:(id)ws {
        __weak id tab = (id)self;
        NSNumber *t = @((NSInteger)tab);
        if (fakeLocBars[t]) {
            [fakeLocBars removeObjectForKey:t];
        }
        %orig;
    }
%end

%hook BrowserViewController
    - (void)displayTab:(id)tab {
        NSNumber *t = @((NSInteger)tab);
        if (t != nil) {
            activeTabID = t;
            if (!fakeLocBars[activeTabID]) {
                fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
            }
        }
        %orig;
    }
%end
        
%hook TabModel
    - (void)applicationDidEnterBackground {
        %orig;
        for (NSNumber* tabID in fakeLocBars) {
            if (fakeLocBars[tabID] != nil) {
                [fakeLocBars[tabID] needsReInit];
            }
        }
    }
%end

%hook ContentSuggestionsHeaderView
    - (void)addViewsToSearchField:(id)arg {
        %orig;
        if ([self searchHintLabel] != nil) {
            [[self searchHintLabel] setTextColor:hint];
        }
        if (![arg isKindOfClass:buttonClass] || [[arg subviews] count] < 1) {
            return;
        }
        if (activeTabID == nil) {
            if (wrangler != nil) {
                NSNumber* t = @((NSInteger)[[[wrangler mainInterface] tabModel] currentTab]);
                if (t == nil) {
                    return;
                }
                activeTabID = t;
            }
        } 
        if (!fakeLocBars[activeTabID]) {
            fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
        }
        if ([fakeLocBars[activeTabID] needsInitialization]) {
            [fakeLocBars[activeTabID] setHeightConstraint: [self fakeLocationBarHeightConstraint]];
            [[self fakeLocationBar] setBackgroundColor:[blurColor colorWithAlphaComponent:0.2]];
            [fakeLocBars[activeTabID] setFakeBox:arg];
            __weak id veff = [[arg subviews] objectAtIndex:0];
            [fakeLocBars[activeTabID] setMainVisualEffect:veff];
            headerViews[[[NSNumber alloc] initWithUnsignedInteger:[self hash]]] = fakeLocBars[activeTabID];
            [veff setBackgroundColor: [blurColor colorWithAlphaComponent:0.1]];
            if ([[veff subviews] count] >= 2) {
                [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:0]];
                [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:1]];
                __weak id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
                __weak id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
                [[sub1 layer] setCornerRadius:locBarCornerRadius];
                [[sub2 layer] setCornerRadius:locBarCornerRadius];
                [[veff layer] setCornerRadius:locBarCornerRadius];
                [fakeLocBars[activeTabID] setNeedsInitialization: false];
            }
            else {
                [[veff layer] setCornerRadius:locBarCornerRadius];
                [fakeLocBars[activeTabID] setNeedsInitialization: true];
            }
        }
    }
    
    - (void)setFakeLocationBarHeightConstraint:(id)arg {
        %orig;
        if (arg != nil && fakeLocBars[activeTabID] != nil) {
            [fakeLocBars[activeTabID] setHeightConstraint: arg];
        }
    }
    
    - (id)fakeLocationBarHeightConstraint {
        NSLayoutConstraint* bh = %orig;
        CGFloat c = [(NSLayoutConstraint*)bh constant];
        CGFloat minDelt = fabs(fakeLocBarMinHeight - c);
        if (activeTabID == nil) {
            return bh;
        }
        if (!fakeLocBars[activeTabID]) {
            fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
            return bh;
        }
        if ([fakeLocBars[activeTabID] needsInitialization] || [[fakeLocBars[activeTabID] effectViews] count] < 2) {
            return bh;
        }        
        CGFloat delta = c - [fakeLocBars[activeTabID] oldHeight];
        CGFloat percentMinimized = (minDelt/maxHeightDelta);
        CGFloat radiusDelta = percentMinimized*locBarCornerRadius;
        CGFloat alphaDelta = alphaOffset + ((maxHeightDelta-minDelt)/maxHeightDelta)*blurAlpha;
        [fakeLocBars[activeTabID] setOldHeight: c];
        if (delta != 0) {
            UIVisualEffectView* main = [fakeLocBars[activeTabID] mainVisualEffect];
            __weak id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            __weak id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            [[self fakeLocationBar] setBackgroundColor:[blurColor colorWithAlphaComponent: alphaOffset]];
            [main setBackgroundColor: [blurColor colorWithAlphaComponent: alphaDelta]];
            [[main layer] setCornerRadius:radiusDelta];
            [[sub1 layer] setCornerRadius:radiusDelta];
            [[sub2 layer] setCornerRadius:radiusDelta];
        }
        return bh;
    }
    
    - (void)setFakeboxHighlighted:(BOOL)arg {
        return;
    }
    
    - (void)dealloc {
        log("ContentHeaderSuggestionsView dealloced");
        NSNumber* hsh = [[NSNumber alloc] initWithUnsignedInteger:[self hash]];
        if (headerViews[hsh]) {
            [headerViews[hsh] needsReInit];
            [headerViews removeObjectForKey:hsh];
        }
        logf("%{public}@", [fakeLocBars description]);
        %orig;
    }
    
%end    
 
 // NAVBARS/TOOLBARS IN MENUS (e.g. bookmarks, recent tabs)
    

    
%hook UINavigationBar
    - (id)initWithCoder:(id)arg {
        UINavigationBar * nav = %orig;
        [nav setBarStyle: UIBarStyleBlack];
        [nav setBarTintColor:bg];
        return nav;
    }
    
    - (id)initWithFrame:(CGRect)arg {
        UINavigationBar * nav = %orig;
        [nav setBarStyle: UIBarStyleBlack];
        [nav setBarTintColor:bg];
        return nav;
    }
        
%end
    
%hook UIToolbar
    - (id)initWithCoder:(id)arg {
        UIToolbar * bar = %orig;
        [bar setBarStyle: UIBarStyleBlack];
        [bar setBarTintColor:bg];
        return bar;
    }

    - (id)initWithFrame:(CGRect)arg {
        UIToolbar * bar = %orig;
        [bar setBarStyle: UIBarStyleBlack];
        [bar setBarTintColor:bg];
        return bar;
    }
    
    - (id)initInView:(id)arg1 withFrame:(CGRect)arg2 withItemList:(id)arg3 {
        UIToolbar * bar = %orig;
        [bar setBarStyle: UIBarStyleBlack];
        [bar setBarTintColor:bg];
        return bar;
    }
    
%end
    
    // POPUP MENU
%hook PopupMenuTableViewController
    - (id)init {
        id cont = %orig;
        [[cont tableView] setBackgroundColor: fg];
        return cont;
    }    
%end
    
%hook PopupMenuViewController
    - (void)setUpContentContainer {
        %orig;
        __weak id cont = [self contentContainer];
        for (id v in [cont subviews]) {
            if ([v isKindOfClass:visEffectViewClass]) {
                [v setHidden:true];
            }
        }
    }    
%end
    
    // BOOKMARKS

%hook BookmarkHomeViewController
    - (void)viewWillAppear:(BOOL)arg {
        %orig;
        [[self tableView] setBackgroundColor:bg];
    }
%end
    
%hook BookmarkEditViewController
    - (void)updateUIFromBookmark {
        %orig;
        [[self tableView] setBackgroundColor:fg];
        [[[self tableView] footerViewForSection:0] setHidden:true];
    }
    - (void)viewDidLayoutSubviews {
        %orig;
        [[[self tableView] footerViewForSection:0] setHidden:true];
    }
%end
    
%hook BookmarkParentFolderItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(stackView)]) {
            for (id v in [[arg1 stackView] arrangedSubviews]) {
                if ([v respondsToSelector: @selector(textColor)]) {
                    if ([[v textColor] isEqual:[UIColor colorWithWhite:0 alpha:1]]) {
                        [v setTextColor:white];
                    }
                }
            }
        }
    }
%end

%hook BookmarkTextFieldItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(titleLabel)]) {
            [[arg1 titleLabel] setTextColor:txt];
        }
    }
%end
    
%hook TableViewBookmarkFolderCell
    -(id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 {
        id ret = %orig;
        [[ret folderTitleTextField] setTextColor:white];
        return ret;
    }
%end
    
    // READING LIST

%hook ReadingListTableViewController
    - (void)viewWillAppear:(BOOL)arg {
        %orig;
        [[self tableView] setBackgroundColor:bg];
    }
%end
    
    // RECENT TABS
    
%hook RecentTabsTableViewController
    - (void)viewWillAppear:(BOOL)arg {
        %orig;
        [[self tableView] setBackgroundColor:bg];
    }
%end
    
    // HISTORY
    
%hook HistoryTableViewController
    - (void)viewWillAppear:(BOOL)arg {
        %orig;
        [[self tableView] setBackgroundColor:bg];
    }
%end
    
    //  SETTINGS

%hook SettingsDetailCell
    - (void)setBackgroundColor:(id)arg {
        %orig(fg);
    }
    - (id)textLabel {
        UILabel * lbl = %orig;
        [lbl setTextColor:txt];
        return lbl;
    }
%end
    
%hook SettingsSwitchItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:txt];
        }
    }
    
%end
    
%hook TableViewAccountItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:txt];
        }
    }
%end
    
%hook AccountControlItem
- (void)configureCell:(id)arg1 withStyler:(id)arg2 {
    %orig;
    if ([arg1 respondsToSelector: @selector(textLabel)]) {
        [[arg1 textLabel] setTextColor:txt];
    }
}
%end

    //  TOOLBARS
    
%hook OverscrollActionsView
    - (void)setStyle:(NSInteger)arg {
        %orig(1);
    }
    - (void)setBackgroundColor:(UIColor*)arg {
        %orig(bg);
    }
%end

%hook WKScrollView
    - (void)setBackgroundColor:(UIColor*)arg {
        %orig(bg);
    }
%end

%hook ToolbarConfiguration
    %property (strong) NSNumber *incognito;
%end
    
%hook ToolbarButtonFactory
    -(id)initWithStyle:(NSInteger)arg {
        ToolbarButtonFactory* factory = %orig(1);
        if (arg==1 && useIncognitoIndicator) {
            [[factory toolbarConfiguration] setIncognito: @true];
        }
        else {
            [[factory toolbarConfiguration] setIncognito: @false];
        }
        return factory;
    }
%end
    
%hook SecondaryToolbarView
    -(id)initWithButtonFactory:(id)arg {
        id ret = %orig;
        [[self blur] setBackgroundColor: blurColor];
        return ret;
    }
%end
    
%hook PrimaryToolbarView
    -(id)initWithButtonFactory:(id)arg {
        id ret = %orig;
        [[self blur] setBackgroundColor: blurColor];
        return ret;
    }
    -(void)setBlur:(id)blur {
        %orig;
        [blur setBackgroundColor: blurColor];
    }
    -(id)blur {
        __weak id ret = %orig;
        if (ret != nil) {
            [ret setBackgroundColor: blurColor];
        }
        return ret;
    }
%end

%hook ToolbarSearchButton
    - (void)setConfiguration:(ToolbarConfiguration*)config {
        %orig;
        if ([[config incognito] boolValue] == true) {
            [[(ToolbarSearchButton*)self imageView] setImage:[(UIImage*)[[(ToolbarSearchButton*)self imageView] image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [[(ToolbarSearchButton*)self imageView] setTintColor: bg];
            [[(ToolbarSearchButton*)self spotlightView] setBackgroundColor: white];
        }
    }
    - (void)setTintColor:(UIColor*)tint {
        if ([[[(ToolbarSearchButton*)self configuration] incognito] boolValue] == true) {
            %orig(bg);
        }
        else {
            %orig;
        }
    }
    - (void)setDimmed:(BOOL)dim {
        %orig;
        if ([[[(ToolbarSearchButton*)self configuration] incognito] boolValue] == true) {
            [[(ToolbarSearchButton*)self spotlightView] setBackgroundColor: white];
        }
    }
%end
    
%hook LocationBarViewController
    -(void)setIncognito:(BOOL)arg {
        %orig(true);
    }
%end
    
%hook OmniboxViewController
    - (id)initWithIncognito:(BOOL)arg {
        return %orig(true);
    }
%end
    
    
%hook OmniboxPopupPresenter 
    - (id)initWithPopupPositioner:(id)arg1 popupViewController:(id)arg2 incognito:(BOOL)arg3 {
        return %orig(arg1, arg2, true);
    }
    
%end
    
%hook OmniboxPopupViewController
    - (void)setIncognito:(BOOL)arg {
        %orig(true);
    }
%end
    
%hook OmniboxPopupRow
    -(void)initWithIncognito:(BOOL)arg {
        %orig(true);
    }
    - (void)layoutAccessoryViews {
        %orig;
        [[self textTruncatingLabel] setTextColor: white];
        [[self detailTruncatingLabel] setTextColor: detail];
    }
%end
    
    //  STATUSBAR
%hook BrowserViewController
    - (NSInteger)preferredStatusBarStyle {
        return UIStatusBarStyleLightContent;
    }
%end