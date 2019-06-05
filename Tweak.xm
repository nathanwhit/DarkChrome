#include "privateHeaders.h"
#include <math.h>
#include "external/toolbar_utils.mm"
#include "darkchrome_utils.mm"

#define RESOURCEPATH @"/Library/Application Support/com.nwhit.darkchromebund.bundle"

NSDictionary *preferences;
NSString* chosenScheme;
UIColor * bg;
UIColor * fg;
UIColor * altfg;
UIColor * sep;
UIColor * blurColor;
bool useIncognitoIndicator;
bool opaqueKeyboard;
CGFloat fakeLocBarMinHeight;
CGFloat fakeLocBarExpandedHeight;
CGFloat maxHeightDelta;
CGFloat blurWhite;
CGFloat blurAlpha;
CGFloat alphaOffset;
TabModelWatcher *tabObserver;
Tab __weak *activeTab;

NSBundle *resBundle;

%ctor {
    NSString* prefsPath = @"/User/Library/Preferences/com.nwhit.darkchromeprefs.plist";
    bool bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:RESOURCEPATH isDirectory:nil];
    if (bundleExists) {
        resBundle = [[NSBundle alloc] initWithPath:RESOURCEPATH];
    }
    else {
        resBundle = nil;
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
                @"opaqueKeyboard" : @false,
                @"colorScheme" : @"dark"
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

    if ([preferences[@"opaqueKeyboard"] boolValue]) {
        opaqueKeyboard = true;
    } else {
        opaqueKeyboard = false;
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
    
    tabObserver = nil;
    activeTab = nil;
}

// CONSTANTS
// COLORS
static UIColor * kTextColor = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * clear = [UIColor colorWithWhite:0 alpha:0];
static UIColor * hintColor = [UIColor colorWithWhite:0.6 alpha:1];
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
// static Class settingsTextCellClass = %c(SettingsTextCell);
static Class MDCCellClass = %c(MDCCollectionViewCell);
static Class visContentViewClass = %c(_UIVisualEffectContentView);
static Class visEffectViewClass = %c(UIVisualEffectView);
static Class buttonClass = %c(UIButton);
static Class visEffectSubviewClass = %c(_UIVisualEffectSubview);
static Class visEffectBackdropClass = %c(_UIVisualEffectBackdropView);
static Class detailCellClass = %c(TableViewDetailIconCell);

static CGFloat locBarCornerRadius = 25; 

// UTILITIES

@implementation TabModelWatcher
    - (void)tabModel:(TabModel*)model didInsertTab:(Tab*)tab atIndex:(NSUInteger)index inForeground:(BOOL)inForeground {
        if (tab) {
            if (![tab fakeLocBar]) {
                [tab setFakeLocBar:[[FakeLocationBar alloc] init]];
            }
            if (inForeground==YES) {
                activeTab = tab;
            }
        }
    }
    - (void)tabModel:(TabModel*)model didChangeActiveTab:(Tab*)newTab previousTab:(Tab*)previousTab atIndex:(NSUInteger)index {
        activeTab = newTab;
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
        CGRect bgFrame = [(UIImageView*)([[self subviews] objectAtIndex:0]) frame];
        CGFloat buttonHeight = bgFrame.size.height;
        CGFloat buttonWidth = buttonHeight;
        CGSize buttonSize = CGSizeMake(buttonWidth, buttonHeight);
        UIButton *button = [[self subviews] objectAtIndex: 4];
        setButtonBackground(@"autofill_close", button, buttonSize, true);
        button = [self nextButton];
        setButtonBackground(@"autofill_next", button, buttonSize, false);
        button = [self previousButton];
        setButtonBackground(@"autofill_prev", button, buttonSize, false);
        UIView *sepView = [[self subviews] objectAtIndex:2];
        [sepView setHidden:true];
        sepView = [[self subviews] objectAtIndex:5];
        [sepView setHidden:true];
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
        %orig(kTextColor);
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

%hook FormSuggestionLabel
    - (void)setBackgroundColor:(UIColor*)arg {
        %orig(kbSuggestColor);
    }

    - (FormSuggestionLabel*)initWithSuggestion:(id)arg1 index:(NSUInteger)arg2 userInteractionEnabled:(BOOL)arg3 numSuggestions:(NSUInteger)arg4 client:(id)arg5 {
        FormSuggestionLabel* suggest = %orig;
        if ([[suggest subviews] count] < 1) {
            return suggest;
        }
        if (![[[suggest subviews] objectAtIndex:0] isKindOfClass:%c(UIStackView)]) {
            return suggest;
        }
        __weak UIStackView* stack = (UIStackView*)([[suggest subviews] objectAtIndex:0]);
        if ([[stack arrangedSubviews] count] < 1) {
            return suggest;
        }
        __weak id lbl = [[stack arrangedSubviews] objectAtIndex:0];
        if (![lbl isKindOfClass:%c(UILabel)]) {
            return suggest;
        }
        __weak UILabel *label = (UILabel*)(lbl);
        [label setTextColor:kTextColor];
        return suggest;

    }
%end

%hook FormInputAccessoryView
    - (void)setBackgroundColor:(UIColor*)color {
        %orig(kbColor);
    }
    - (void)addSubview:(UIView*)subview {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.hidden = YES;
        }
        else if ([subview isMemberOfClass:[UIView class]]) {
            subview.backgroundColor = kbColor;
        }
        else if ([subview isMemberOfClass:[UIStackView class]]) {
            for (UIView* v in [subview subviews]) {
                if ([v isKindOfClass:[UIButton class]]) {
                    if ([(UIButton*)v titleLabel]) {
                        v.tintColor = kTextColor;
                    }
                }
            }
        }
        %orig;
    }
    - (void)insertSubview:(UIView*)subview aboveSubview:(UIView*)arg2 {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.hidden = YES;
        }
        %orig;
    }
    - (void)insertSubview:(UIView*)subview belowSubview:(UIView*)arg2 {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            subview.hidden = YES;
        }
        %orig;
    }
%end

%hook ManualFillAccessoryViewController
- (id)activeTintColor {
    return kTextColor;
}
%end

%hook UIKBBackdropView
- (void)setBackgroundColor:(UIColor*)color {
    if (opaqueKeyboard) {
        %orig(kbColor);
    }
    else {
        %orig;
    }
}
%end

%hook ToolbarKeyboardAccessoryView
    - (UIView*)shortcutButtonWithTitle:(NSString*)title {
        UIButton* button = (UIButton*)%orig;
        [button setTitleColor:kTextColor forState:UIControlStateNormal];
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

// TAB OVERVIEW
%hook GridCell
    - (void)setTheme:(NSUInteger)arg {
        if (arg != 2) {
            [self setIsIncognito:NO];
        }
        %orig(2);
    }
    - (void)setTitleHidden:(BOOL)hide {
        if ([self isIncognito]==NO) {
            %orig(NO);
        }
        else {
            %orig;
        }
    }
    %property (assign, nonatomic) BOOL isIncognito;
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
        [tblStyler setCellTitleColor:kTextColor];
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
        %orig(kTextColor);
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
            [[arg1 titleLabel] setTextColor:kTextColor];
        }
        
        [[arg1 imageView] setBackgroundColor:clear];
    }
%end
    
%hook TableViewTextLinkItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector:@selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:kTextColor];
            [[arg1 textLabel] setBackgroundColor:fg];
        }   
    }
%end

%hook TableViewDetailIconItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        logf("configuring cell with styler : %{public}@", arg2);
        %orig;
        if ([arg1 isKindOfClass: %c(TableViewDetailIconCell)]) {
            log("Type matches");
            TableViewDetailIconCell *cell = (TableViewDetailIconCell*)arg1;
            logf("Text label : %{public}@", cell.textLabel);
            cell.textLabel.textColor = kTextColor;
            [cell.textLabel _setTextColorFollowsTintColor:YES];
            [cell.textLabel setTintColor: kTextColor];
            cell.backgroundColor = bg;
        }
    }
%end

%hook PopupMenuNavigationItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector:@selector(titleLabel)]) {
            [[arg1 titleLabel] setBackgroundColor:clear];
            [[arg1 titleLabel] setTextColor:kTextColor];
            [[arg1 imageView] setBackgroundColor:clear];
        }
    }
%end
    
    

//  SETTINGS->PAYMENT METHODS/ADDRESSES AND MORE   
    
%hook AutofillDataCell
    - (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2 {
        AutofillDataCell * cell = %orig;
        [[cell textLabel] setTextColor:kTextColor];
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
        if ([arg isKindOfClass:%c(SettingsTextCell)]) {
            __weak SettingsTextCell *cell = (SettingsTextCell*)(arg);
            %orig;
            [[cell textLabel] setTextColor:kTextColor];
            [[cell contentView] setBackgroundColor:fg];
        }
        else {
            %orig;
        }
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
        if ([arg isKindOfClass:%c(SettingsTextCell)]) {
            __weak SettingsTextCell *cell = (SettingsTextCell*)(arg);
            %orig;
            [[cell contentView] setBackgroundColor:fg];
            [[cell inkView] setBackgroundColor:clear];
            [[cell textLabel] setTextColor:[UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1]];
            __weak id separator = MSHookIvar<UIView*>(cell, "_separatorView");
            [separator setBackgroundColor:sep];
            [[cell accessoryView] setTintColor:white];
            [[cell accessoryView] setBackgroundColor:clear];
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
                    [lab setTextColor:kTextColor];
                }
            } else {
                [v setBackgroundColor:clear];
                [v setTextColor:kTextColor];
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
        [lbl setTextColor:kTextColor];
    }
    - (void)drawSeparatorIfNeeded {
        %orig;
        __weak id separator = MSHookIvar<UIView*>(self, "_separatorView");
        [separator setBackgroundColor:sep];
    }
%end
    
static NSMutableSet *imageViewPassSet;
static NSMutableSet *imageViewSuggestSet;
static NSMutableSet *imageViewSettingsSet;

static UIImage* handleSuggestionCell(id cell, __weak id image, __weak id superview) {
    UIImage* img = [(UIImage*)image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell setTintColor: altfg];
    if ([superview isKindOfClass:%c(SettingsTextCell)] && [[cell interactionTintColor] isEqual:altfg]) {
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
        static dispatch_once_t imageViewSetsToken;
        dispatch_once(&imageViewSetsToken, ^{
            imageViewPassSet = [[NSMutableSet alloc] init];
            imageViewSuggestSet = [[NSMutableSet alloc] init];
            imageViewSettingsSet = [[NSMutableSet alloc] init];
        });

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
            } else if ([superview isKindOfClass:%c(SettingsTextCell)]){
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
            [[cell additionalInformationLabel] setTextColor:kTextColor];
        }
    }
%end

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

%hook BrowserViewController       
    - (void)updateWithTabModel:(TabModel*)model browserState:(void*)state {
        %orig;
        if (self && [self isOffTheRecord]==NO && model && !tabObserver) {
            tabObserver = [[TabModelWatcher alloc] init];
            [model addObserver:tabObserver];
            if (Tab __weak *tab=[model currentTab]) {
                activeTab = tab;
            }
        }
    }
%end

%hook TabModel
    - (BOOL)restoreSessionWindow:(id)session forInitialRestore:(BOOL)restore {
        BOOL ret = %orig;
        if ([self isOffTheRecord]==NO) {
            if ([self respondsToSelector:@selector(tabAtIndex:)]) {
                int numTabs = [self count];
                Tab __weak *tab;
                for (NSUInteger i = 0; i < numTabs; i++) {
                    tab = [self tabAtIndex:i];
                    if (tab) {
                        [tab setFakeLocBar:[[FakeLocationBar alloc] init]];
                    }
                }
            }
            activeTab = [self currentTab];
        }
        
        return ret;
    }
%end

%hook Tab
    %property (strong, nonatomic) FakeLocationBar *fakeLocBar;
%end

%hook ContentSuggestionsHeaderView
    - (void)addViewsToSearchField:(id)arg {
        %orig;
        if ([self searchHintLabel] != nil) {
            [[self searchHintLabel] setTextColor:hintColor];
        }
        if (![arg isKindOfClass:buttonClass] || [[arg subviews] count] < 1 || activeTab == nil) {
            return;
        }
        FakeLocationBar __weak *flb = [activeTab fakeLocBar];
        [[self fakeLocationBar] setBackgroundColor:[blurColor colorWithAlphaComponent:alphaOffset]];
        UIVisualEffectView __weak *veff = [[arg subviews] objectAtIndex:0];
        [[activeTab fakeLocBar] setMainVisualEffect:veff];
        [veff setBackgroundColor: [blurColor colorWithAlphaComponent:alphaOffset]];
        if ([[veff subviews] count] >= 2) {
            [flb setSubEffect1:[[veff subviews] objectAtIndex:0]];
            [flb setSubEffect2:[[veff subviews] objectAtIndex:1]];
            UIVisualEffectView __weak *sub1 = [[veff subviews] objectAtIndex:0];
            UIVisualEffectView __weak *sub2 = [[veff subviews] objectAtIndex:1];
            [flb setSubEffect1:sub1];
            [flb setSubEffect2:sub2];
            [[sub1 layer] setCornerRadius:locBarCornerRadius];
            [[sub2 layer] setCornerRadius:locBarCornerRadius];
            [[veff layer] setCornerRadius:locBarCornerRadius];
        }
        else {
            [[veff layer] setCornerRadius:locBarCornerRadius];
        }
    }
    
    - (id)fakeLocationBarHeightConstraint {
        NSLayoutConstraint* bh = %orig;
        CGFloat c = [(NSLayoutConstraint*)bh constant];
        CGFloat minDelt = fabs(fakeLocBarMinHeight - c);
        if (!activeTab) {
            return bh;
        }      
        FakeLocationBar __weak *flb = [activeTab fakeLocBar];
        CGFloat delta = c - [flb oldHeight];
        CGFloat percentMinimized = (minDelt/maxHeightDelta);
        CGFloat radiusDelta = percentMinimized*locBarCornerRadius;
        CGFloat alphaDelta = alphaOffset + ((maxHeightDelta-minDelt)/maxHeightDelta)*blurAlpha;
        [flb setOldHeight: c];
        if (delta != 0) {
            UIVisualEffectView __weak *main = [flb mainVisualEffect];
            UIVisualEffectView __weak *sub1 = [flb subEffect1];
            UIVisualEffectView __weak *sub2 = [flb subEffect2];
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
            [[arg1 titleLabel] setTextColor:kTextColor];
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
        [lbl setTextColor:kTextColor];
        return lbl;
    }
%end
    
%hook SettingsSwitchItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:kTextColor];
        }
    }
    
%end
    
%hook TableViewAccountItem
    - (void)configureCell:(id)arg1 withStyler:(id)arg2 {
        %orig;
        if ([arg1 respondsToSelector: @selector(textLabel)]) {
            [[arg1 textLabel] setTextColor:kTextColor];
        }
    }
%end
    
%hook AccountControlItem
- (void)configureCell:(id)arg1 withStyler:(id)arg2 {
    %orig;
    if ([arg1 respondsToSelector: @selector(textLabel)]) {
        [[arg1 textLabel] setTextColor:kTextColor];
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

%hook SelfSizingTableView
    - (void)setBackgroundColor:(UIColor*)arg {
        %orig(altfg);
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

//  TAB VIEW (iPad version)
%hook TabView
- (void)setIncognitoStyle:(BOOL)arg {
    %orig(YES);
}
%end