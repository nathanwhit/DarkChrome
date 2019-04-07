#define INSPECT 0


#include <os/log.h>
#include "privateHeaders.h"
#include <math.h>
#include <Cephei/HBPreferences.h>

#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)
#define log(str) os_log(OS_LOG_DEFAULT, str)

#if INSPECT==1
#include "InspCWrapper.m"
#endif




HBPreferences *preferences;
UIColor * bg;
UIColor * fg;
UIColor * altfg;
UIColor * sep;

%ctor {
    UIColor* dark_color1 = [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha: 1];
    UIColor* dark_color2 = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha: 1];
    UIColor* dark_color3 = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha: 1];
    UIColor* clear = [UIColor colorWithWhite:0 alpha:0];
    UIColor* black_color1 = [UIColor colorWithWhite:0 alpha: 1];
    UIColor* black_color2 = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];

    NSDictionary *darkScheme = @{
        @"background" : dark_color1,
        @"foreground" : dark_color2,
        @"altforeground" : dark_color2,
        @"separ" : dark_color3
    };

    NSDictionary *flatDarkScheme = @{
        @"background" : dark_color1,
        @"foreground" : dark_color1,
        @"altforeground" : dark_color2,
        @"separ" : clear
    };

    NSDictionary *trueBlackScheme = @{
        @"background" : black_color1,
        @"foreground" : black_color1,
        @"altforeground" : black_color2,
        @"separ" : clear
    };
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nwhit.darkchromeprefs"];    
    NSString* chosenScheme = [[NSString alloc] initWithString:[preferences objectForKey:@"colorScheme"]];
    os_log(OS_LOG_DEFAULT, "%{public}@", chosenScheme);
    NSDictionary* schemeForString = @{@"dark" : darkScheme, @"flatDark" : flatDarkScheme, @"trueBlack" : trueBlackScheme};
    bg = [[[schemeForString objectForKey:chosenScheme] objectForKey:@"background"] copy];
    os_log(OS_LOG_DEFAULT, "%{public}p", schemeForString[chosenScheme]);
    fg = [[schemeForString[chosenScheme] objectForKey:@"foreground"] copy];
    altfg = [[schemeForString[chosenScheme] objectForKey:@"altforeground"] copy];
    sep = [[schemeForString[chosenScheme] objectForKey:@"separ"] copy];
}

// COLORS
static UIColor * txt = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * clear = [UIColor colorWithWhite:0 alpha:0];
static UIColor * hint = [UIColor colorWithWhite:0.6 alpha:1];
static UIColor * oldeff = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.4];
static UIColor * white = [UIColor colorWithWhite:1 alpha:1];
static UIColor * tab_bar = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * locBarColor = [UIColor colorWithWhite:1 alpha:0.12];
static UIColor * detail = [UIColor colorWithWhite:1 alpha:0.5];
static CGFloat locbar_viseffect_rgb = 0.98;
static CGFloat locbar_viseffect_alph = 0.4;

// CLASS OBJECTS FOR TYPE VERIFICATION
static Class articlesHeaderCellClass = %c(ContentSuggestionsArticlesHeaderCell);
static Class suggestCellClass = %c(ContentSuggestionsCell);
static Class suggestFooterClass = %c(ContentSuggestionsFooterCell);
static Class settingsTextCellClass = %c(SettingsTextCell);
static Class visContentViewClass = %c(_UIVisualEffectContentView);
static Class visEffectViewClass = %c(UIVisualEffectView);
static Class buttonClass = %c(UIButton);
static Class visEffectSubviewClass = %c(_UIVisualEffectSubview);
static Class visEffectBackdropClass = %c(_UIVisualEffectBackdropView);

static CGFloat locBarCornerRadius = 25;

// INCOGNITO
%hook IncognitoView
    - (void)setBackgroundColor:(id)arg {
        %orig(bg);
    }
%end

// TAB OVERVIEW
%hook GridCell
    - (void)setTheme:(NSUInteger)arg {
        %orig(2);
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
        log("Loading model");
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
    
%hook ContentSuggestionsFooterCell
    - (void)drawSeparatorIfNeeded {
        %orig;
        id separator = MSHookIvar<UIView*>(self, "_separatorView");
        [separator setBackgroundColor:sep];
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
    


%hook UIImageView
    - (void)setImage:(id)arg {
        if ([self respondsToSelector:@selector(_ui_superview)]) {
            id superview = [self _ui_superview];
            if ([superview isKindOfClass:articlesHeaderCellClass] || [superview isKindOfClass:suggestCellClass] || [superview isKindOfClass:suggestFooterClass]) {
                UIImage* img = [(UIImage*)arg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self setTintColor: altfg];
                if ([superview isKindOfClass:settingsTextCellClass] && [[self interactionTintColor] isEqual:altfg]) {
                    [self setBackgroundColor:altfg];
                    [self setTintColor: altfg];
                }
                [[superview contentView] setBackgroundColor:nil];
                %orig(img);
            } else if ([superview isKindOfClass:settingsTextCellClass]){
                UIImage* img = [(UIImage*)arg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self setTintColor: fg];
                if ([superview isKindOfClass:settingsTextCellClass] && [[self interactionTintColor] isEqual:fg]) {
                    [self setBackgroundColor:fg];
                    [self setTintColor: fg];
                }
                [[superview contentView] setBackgroundColor:nil];
                %orig(img);
            }
            else {
                %orig;
            }
        }
         else {
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

static NSString* activeTabID = nil;
static NSMutableDictionary<NSString*, FakeLocationBar*> *fakeLocBars = [[NSMutableDictionary alloc] init];
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

%hook GridViewController
    - (void)insertItem:(id)item atIndex:(NSUInteger)index selectedItemID:(NSString*)arg {
        %orig;
        if ([item respondsToSelector:@selector(identifier)]) {
            NSString* itemID = [item identifier];
            if (itemID && !fakeLocBars[itemID]) {
                fakeLocBars[itemID] = [[FakeLocationBar alloc] init];
            }
        }
    }
    
    - (void)setSelectedItemID:(NSString*)itemID {
        %orig;
        if (!itemID) {
            return;
        }
        if (activeTabID == nil) {
            activeTabID = itemID;
        }
        if (!fakeLocBars[itemID]) {
            fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
        }
        activeTabID = itemID;
    }
    - (void)removeItemWithID:(NSString*)itemID selectedItemID:(NSString*)selectedID {
        [fakeLocBars removeObjectForKey:itemID];
        activeTabID = selectedID;
        %orig;
    }
    - (void)setCollectionView:(id)v {
        if ([v respondsToSelector:@selector(backgroundView)]) {
            [[v backgroundView] setBackgroundColor:bg];
        }
        %orig;
    } 
%end
        
%hook TabModel
    - (void)setCurrentTab:(id)tab {
        %orig;
        if ([self currentTab] != nil) {
            activeTabID = [[self currentTab] tabId];
            if (!fakeLocBars[activeTabID]) {
                fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
            }
            else {
                [fakeLocBars[activeTabID] needsReInit];
            }
        }
    }
    - (BOOL)restoreSessionWindow:(id)session forInitialRestore:(BOOL)restore {
        BOOL ret = %orig;
        if ([self currentTab] != nil && [[self currentTab] tabId] != nil) {
            activeTabID = [[self currentTab] tabId];
            if (fakeLocBars == nil) {
                fakeLocBars = [[NSMutableDictionary alloc] init];
            }
            for (NSUInteger i = 0; i < [self count]; i++) {
                fakeLocBars[[[self tabAtIndex:i] tabId]] = [[FakeLocationBar alloc] init];
            }
        }
        return ret;
    }
    - (void)browserStateDestroyed {
        for (NSString* tabID in fakeLocBars) {
            if (fakeLocBars[tabID] != nil) {
                [fakeLocBars[tabID] needsReInit];
            }
        }
        %orig;
    }
    - (void)applicationDidEnterBackground {
        %orig;
        for (NSString* tabID in fakeLocBars) {
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
        if ([fakeLocBars[activeTabID] needsInitialization]) {
            [fakeLocBars[activeTabID] setHeightConstraint: [self fakeLocationBarHeightConstraint]];
            [[self fakeLocationBar] setBackgroundColor:locBarColor];
            [fakeLocBars[activeTabID] setFakeBox:arg];
            id veff = [[arg subviews] objectAtIndex:0];
            [fakeLocBars[activeTabID] setMainVisualEffect:veff];
            headerViews[[[NSNumber alloc] initWithUnsignedInteger:[self hash]]] = fakeLocBars[activeTabID];
            [veff setBackgroundColor:oldeff];
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
    
    - (void)setFakeboxHighlighted:(BOOL)highlighted {
        %orig;
        [[self fakeLocationBar] setBackgroundColor: [UIColor colorWithWhite:0.2 alpha:1]];
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
        CGFloat minDelt = fabs(36.0 - c);
        if (activeTabID == nil || [[self subviews] count] < 3 || [fakeLocBars[activeTabID] needsInitialization]) {
            return bh;
        }
        if (!fakeLocBars[activeTabID]) {
            fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
        }        
        if ([fakeLocBars[activeTabID] needsInitialization]) {

            UIButton* button = [[self subviews] objectAtIndex:3];
            [fakeLocBars[activeTabID] setHeightConstraint: [self fakeLocationBarHeightConstraint]];
            [[self fakeLocationBar] setBackgroundColor:locBarColor];
            [fakeLocBars[activeTabID] setFakeBox:button];
            id veff = [[button subviews] objectAtIndex:0];
            [fakeLocBars[activeTabID] setMainVisualEffect:veff];
            headerViews[[[NSNumber alloc] initWithUnsignedInteger:[self hash]]] = fakeLocBars[activeTabID];
            [veff setBackgroundColor:oldeff];
            [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:0]];
            [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:1]];
            id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            [[veff layer] setCornerRadius:locBarCornerRadius];
            [[sub1 layer] setCornerRadius:locBarCornerRadius];
            [[sub2 layer] setCornerRadius:locBarCornerRadius];
            [fakeLocBars[activeTabID] setNeedsInitialization: false];
        }
        
        CGFloat delta = c - [fakeLocBars[activeTabID] oldHeight];
        [fakeLocBars[activeTabID] setOldHeight: c];
        if (minDelt <= 10 && delta < 0) {
            CGFloat radiusDelta = (minDelt/12)*locBarCornerRadius;
            UIVisualEffectView* main = [fakeLocBars[activeTabID] mainVisualEffect];
            id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            [[main layer] setCornerRadius:radiusDelta];
            [[sub1 layer] setCornerRadius:radiusDelta];
            [[sub2 layer] setCornerRadius:radiusDelta];
            [main setBackgroundColor:oldeff];
            CGFloat alph = ((12-minDelt)/12)*locbar_viseffect_alph;
            [main setBackgroundColor: [UIColor colorWithRed:locbar_viseffect_rgb green:locbar_viseffect_rgb blue:locbar_viseffect_rgb alpha:alph]];
        }
        else if (delta > 0) {
            CGFloat radiusDelta = (minDelt/12)*locBarCornerRadius;
            UIVisualEffectView* main = [fakeLocBars[activeTabID] mainVisualEffect];
            id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
            id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
            CGFloat alph = ((12-minDelt)/12)*locbar_viseffect_alph;
            [main setBackgroundColor: [UIColor colorWithRed:locbar_viseffect_rgb green:locbar_viseffect_rgb blue:locbar_viseffect_rgb alpha:alph]];
            [[main layer] setCornerRadius:radiusDelta];
            [[sub1 layer] setCornerRadius:radiusDelta];
            [[sub2 layer] setCornerRadius:radiusDelta];
        }
        return bh;
    }
    
%end    
    
%hook ContentSuggestionsHeaderView
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
        return %orig(1);
    }
%end
    
%hook LocationBarViewController
    -(void)setIncognito:(BOOL)arg {
        %orig(YES);
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
    -(void)initWithIncognito:(BOOL)incog {
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