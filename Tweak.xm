#define INSPECT 1


#include <os/log.h>
#include "privateHeaders.h"
#include <math.h>
#include "external/toolbar_utils.mm"

#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)
#define log(str) os_log(OS_LOG_DEFAULT, str)

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
bool coldStart;
bool firstTabSeen;
CGFloat blurWhite;
CGFloat blurAlpha;
bool buildIncognito;

#if INSPECT == 1
#include "InspCWrapper.m"
static void startInspection() {
    watchClass(%c(UIVisualEffectView));
    setMaximumRelativeLoggingDepth(25);
    return;
}
#endif

%ctor {
    #if INSPECT == 1
    startInspection();
    #endif
    
    
    NSString* prefsPath = @"/User/Library/Preferences/com.nwhit.darkchromeprefs.plist";
    if (@available(iOS 11, *)) {
        NSURL * prefsURL = [[NSURL alloc] initFileURLWithPath:prefsPath isDirectory:false];
        preferences = [[NSDictionary alloc] initWithContentsOfURL:prefsURL error:nil];
    }
    else {
        preferences = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
    }
    UIColor* dark_color1 = [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha: 1];
    UIColor* dark_color2 = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha: 1];
    UIColor* dark_color3 = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha: 1];
    UIColor* dark_color4 = [UIColor colorWithWhite:0.9 alpha: 0.4];
    UIColor* clear = [UIColor colorWithWhite:0 alpha:0];
    UIColor* black_color1 = [UIColor colorWithWhite:0 alpha: 1];
    UIColor* black_color2 = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    UIColor* black_color4 = [UIColor colorWithWhite:0.3 alpha: 0.5];
    
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
        @"blur": dark_color4
    };

    NSDictionary *flatDarkScheme = @{
        @"background" : dark_color1,
        @"foreground" : dark_color1,
        @"altforeground" : dark_color2,
        @"separ" : clear,
        @"blur": dark_color4
    };

    NSDictionary *trueBlackScheme = @{
        @"background" : black_color1,
        @"foreground" : black_color1,
        @"altforeground" : black_color2,
        @"separ" : clear,
        @"blur": black_color4
            
    };
    chosenScheme = [[NSString alloc] initWithString:[preferences objectForKey:@"colorScheme"]];
    
    NSDictionary* schemeForString = @{@"dark" : darkScheme, @"flatDark" : flatDarkScheme, @"trueBlack" : trueBlackScheme};
    bg = [schemeForString[chosenScheme] objectForKey:@"background"];
    fg = [schemeForString[chosenScheme] objectForKey:@"foreground"];
    altfg = [schemeForString[chosenScheme] objectForKey:@"altforeground"];
    sep = [schemeForString[chosenScheme] objectForKey:@"separ"];
    blurColor = [schemeForString[chosenScheme] objectForKey:@"blur"];
    [blurColor getWhite: &blurWhite alpha: &blurAlpha];
    
    fakeLocBarMinHeight = LocationBarHeight([[UIApplication sharedApplication] preferredContentSizeCategory]);
    fakeLocBarExpandedHeight = ToolbarExpandedHeight([[UIApplication sharedApplication] preferredContentSizeCategory]);
    maxHeightDelta = fakeLocBarExpandedHeight - fakeLocBarMinHeight;
    
    wrangler=nil;
    coldStart = false;
    firstTabSeen = false;
    
    buildIncognito = false;
}

// COLORS
static UIColor * txt = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * clear = [UIColor colorWithWhite:0 alpha:0];
static UIColor * hint = [UIColor colorWithWhite:0.6 alpha:1];
static UIColor * white = [UIColor colorWithWhite:1 alpha:1];
static UIColor * tab_bar = [UIColor colorWithWhite:0.9 alpha:1];
// static UIColor * locBarColor = [UIColor colorWithWhite:0.2 alpha:0.8];
static UIColor * detail = [UIColor colorWithWhite:1 alpha:0.5];
static UIColor * incognitoIndicatorColor = [UIColor colorWithWhite:1 alpha:0.7];

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

// static bool buildIncognito = false;

bool inIncognito() {
    if (wrangler != nil) {
        return [[wrangler currentInterface] incognito];
    }
    else {
        return false;
    }
}

// KEYBOARD

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
        if (firstTabSeen == false) {
            coldStart = [[(MainApplicationDelegate*)[[UIApplication sharedApplication] delegate] mainController] isColdStart];
        }
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
        [[arg1 titleLabel] setBackgroundColor:clear];
        [[arg1 titleLabel] setTextColor:txt];
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
            id separator = MSHookIvar<UIView*>(arg, "_separatorView");
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

    -(void)configureUILayout {
        %orig;
        UIStackView* stack = [self horizontalStack];
        for (id v in [stack arrangedSubviews]) {
            if ([v isKindOfClass:[UIStackView class]]) {
                for (UILabel* lab in [v arrangedSubviews]) {
                    [lab setBackgroundColor:clear];
                    [lab setTextColor:txt];
                }
            } else {
                [v setBackgroundColor:clear];
                [v setTextColor:txt];
            }
        }
        [self setHorizontalStack: stack];
        [[self faviconContainerView] setBackgroundColor:fg];
    }
%end
    
    //  CONTENT SUGGESTIONS/NEW TAB PAGE

%hook ContentSuggestionsViewController
    - (id)collectionView {
        id v = %orig;
        [v setBackgroundColor:bg];
        return v;
    }
%end
    
%hook NTPMostVisitedTileView
    - (id)initWithFrame:(CGRect)arg {
        id tile = %orig;
        [[tile titleLabel] setTextColor:white];
        id imgView = [tile imageBackgroundView];
        [imgView setImage: [(UIImage*)[imgView image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imgView setTintColor: altfg];
        return tile;
    }
%end
    
%hook NTPShortcutTileView
    - (id)initWithFrame:(CGRect)arg {
        id tile = %orig;
        [[tile titleLabel] setTextColor:white];
        id imgView = [tile imageBackgroundView];
        [imgView setImage: [(UIImage*)[imgView image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imgView setTintColor: altfg];
        return tile;
    }
%end
    
%hook ContentSuggestionsArticlesHeaderCell
    - (void)drawSeparatorIfNeeded {
        %orig;
        id separator = MSHookIvar<UIView*>(self, "_separatorView");
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
        id separator = MSHookIvar<UIView*>(self, "_separatorView");
        [separator setBackgroundColor:sep];
    }
%end
    
static NSMutableSet *imageViewPassSet = [[NSMutableSet alloc] init];
static NSMutableSet *imageViewSuggestSet = [[NSMutableSet alloc] init];
static NSMutableSet *imageViewSettingsSet = [[NSMutableSet alloc] init];

static UIImage* handleSuggestionCell(id cell, id image, id superview) {
    UIImage* img = [(UIImage*)image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell setTintColor: altfg];
    if ([superview isKindOfClass:settingsTextCellClass] && [[cell interactionTintColor] isEqual:altfg]) {
        [cell setBackgroundColor:altfg];
    }
    [[superview contentView] setBackgroundColor:nil];
    return img;
}

static UIImage* handleSettingsCell(id cell, id image, id superview) {
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
            id superview = [self superview];
            UIImage* img = handleSettingsCell(self, arg, superview);
            %orig(img);
            return;
        }
        
        if ([self respondsToSelector:@selector(superview)] && [[self superview] isKindOfClass: MDCCellClass]) {
            id superview = [self superview];
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
static NSMutableDictionary<NSNumber*, FakeLocationBar*> *fakeLocBars = [[NSMutableDictionary alloc] init];
static NSMutableDictionary<NSNumber*, FakeLocationBar*> *headerViews = [[NSMutableDictionary alloc] init];
// static const CGFloat minBarHeight = 36;

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
        id tab = %orig;
        NSNumber *t = @((NSInteger)tab);
        if (!fakeLocBars[t]) {
            fakeLocBars[t] = [[FakeLocationBar alloc] init];
        }
        else {
            [fakeLocBars[t] needsReInit];
        }
        return tab;
    }
    - (void)webStateDestroyed:(id)ws {
        id tab = (id)self;
        NSNumber *t = @((NSInteger)tab);
        if (fakeLocBars[t]) {
            [fakeLocBars removeObjectForKey:t];
        }
        %orig;
    }
%end

%hook BrowserViewController
    - (void)displayTab:(id)tab {
        if (![self isActive] || inIncognito()) {
            %orig;
            return;
        }
        if (coldStart && firstTabSeen) {
            coldStart = false;
            %orig;
            return;
        }
        NSNumber *t = @((NSInteger)tab);
        logf("%{public}@", t);
        firstTabSeen = true;
        if (t != nil) {
            activeTabID = t;
            if (!fakeLocBars[activeTabID]) {
                fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
            }
            // [fakeLocBars[activeTabID] needsReInit];
        }
        %orig;
    }
%end
        
%hook TabModel
    - (BOOL)restoreSessionWindow:(id)session forInitialRestore:(BOOL)restore {
        BOOL ret = %orig;
        if ([self currentTab] != nil) {
            activeTabID = @((NSInteger)[self currentTab]);
            if (fakeLocBars == nil) {
                fakeLocBars = [[NSMutableDictionary alloc] init];
            }
        }
        for (NSUInteger i = 0; i < [self count]; i++) {
            fakeLocBars[@((NSInteger)[self tabAtIndex:i])] = [[FakeLocationBar alloc] init];
        }
        return ret;
    }
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
        logf("Adding views to tab: %{public}@", activeTabID);
        %orig;
        if ([self searchHintLabel] != nil) {
            [[self searchHintLabel] setTextColor:hint];
        }
        if (![arg isKindOfClass:buttonClass] || [[arg subviews] count] < 1) {
            log("Failed");
            return;
        }
        if (activeTabID == nil) {
            log("Caught activeTabID equal to nil");
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
            id veff = [[arg subviews] objectAtIndex:0];
            [fakeLocBars[activeTabID] setMainVisualEffect:veff];
            headerViews[[[NSNumber alloc] initWithUnsignedInteger:[self hash]]] = fakeLocBars[activeTabID];
            [veff setBackgroundColor: [blurColor colorWithAlphaComponent:0.1]];
            [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:0]];
            [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:1]];
            id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            [[veff layer] setCornerRadius:locBarCornerRadius];
            [[sub1 layer] setCornerRadius:locBarCornerRadius];
            [[sub2 layer] setCornerRadius:locBarCornerRadius];
            [fakeLocBars[activeTabID] setNeedsInitialization: false];
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
        if ([fakeLocBars[activeTabID] needsInitialization]) {
            return bh;
        }        
        CGFloat delta = c - [fakeLocBars[activeTabID] oldHeight];
        CGFloat percentMinimized = (minDelt/maxHeightDelta);
        // CGFloat percentExpanded = 1 - percentMinimized;
        CGFloat radiusDelta = percentMinimized*locBarCornerRadius;
        CGFloat alphaOffset = 0.1;
        CGFloat alphaDelta = alphaOffset + ((maxHeightDelta-minDelt)/maxHeightDelta)*blurAlpha;
        [fakeLocBars[activeTabID] setOldHeight: c];
        if (delta != 0) {
            UIVisualEffectView* main = [fakeLocBars[activeTabID] mainVisualEffect];
            id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            [[self fakeLocationBar] setBackgroundColor:[blurColor colorWithAlphaComponent: fmin(alphaOffset, alphaDelta)]];
            [main setBackgroundColor: [blurColor colorWithAlphaComponent: alphaDelta]];
            [[main layer] setCornerRadius:radiusDelta];
            [[sub1 layer] setCornerRadius:radiusDelta];
            [[sub2 layer] setCornerRadius:radiusDelta];
        }
        return bh;
    }
    
    - (void)dealloc {
        NSNumber* hsh = [[NSNumber alloc] initWithUnsignedInteger:[self hash]];
        if (headerViews[hsh]) {
            [headerViews[hsh] needsReInit];
            [headerViews removeObjectForKey:hsh];
        }
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
        id cont = [self contentContainer];
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
%end
    
%hook ToolbarButtonFactory
    -(id)initWithStyle:(NSInteger)arg {
        if (arg==1) {
            buildIncognito = true;
        }
        else {
            buildIncognito = false;
        }
        return %orig(1);
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
    -(void)setUpBlurredBackground {
        %orig;
        // [[self blur] setBackgroundColor: blurColor];
    }
%end
    
%hook LocationBarViewController
    -(void)setIncognito:(BOOL)arg {
        %orig(true);
    }
    -(BOOL)incognito {
        return true;
    }
%end
    
%hook OmniboxViewController
    - (id)initWithIncognito:(BOOL)arg {
        return %orig(true);
    }
%end
    
    
%hook OmniboxPopupPresenter 
    - (id)initWithPopupPositioner:(id)arg1 popupViewController:(id)arg2 inIncognito:(BOOL)arg3 {
        return %orig(arg1, arg2, true);
    }
    
%end
    
%hook OmniboxPopupViewController
    - (void)setIncognito:(BOOL)arg {
        %orig(true);
    }
    - (BOOL)incognito {
        return true;
    }
%end
    
%hook OmniboxPopupBaseViewController
    - (BOOL)incognito {
        return true;
    }
    - (void)setIncognito:(BOOL)arg {
        %orig(true);
    }
    - (void)viewDidLoad {
        %orig;
        [[self view] setBackgroundColor:fg];
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
    
%hook SelfSizingTableView
    - (id)initWithFrame:(CGRect)arg1 style:(NSInteger)arg2 {
        return %orig(arg1, 1);
    }
%end
    
    //  STATUSBAR
%hook BrowserViewController
    - (NSInteger)preferredStatusBarStyle {
        return UIStatusBarStyleLightContent;
    }
    
    - (void)buildToolbarAndTabStrip {
        %orig;
        if (buildIncognito && useIncognitoIndicator) {
            id buttonBackLayer = [[[[[[self secondaryToolbarCoordinator] viewController] view] omniboxButton] spotlightView] layer];
            [buttonBackLayer setBorderColor: [incognitoIndicatorColor CGColor]];
            [buttonBackLayer setBorderWidth:2];
        }
        return;
    }
%end