#define INSPECT 0


#include <os/log.h>
#include "privateHeaders.h"

#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)
#define log(str) os_log(OS_LOG_DEFAULT, "%", str)

#if INSPECT==1
#include "InspCWrapper.m"
%ctor {
    // watchClass(%c(ContentSuggestionHeaderView));
    // watchSelector(@selector(setSelectedItemID:));
}
#endif

// COLORS
static UIColor * bg = [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:1];
static UIColor * fg = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
static UIColor * txt = [UIColor colorWithWhite:0.9 alpha:1];
static UIColor * sep = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha: 1];
static UIColor * clear = [UIColor colorWithWhite:0 alpha:0];
static UIColor * hint = [UIColor colorWithWhite:0.6 alpha:1];
static UIColor * oldeff = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.4];
static UIColor * white = [UIColor colorWithWhite:1 alpha:1];
static UIColor * tab_bar = [UIColor colorWithWhite:0.9 alpha:1];

// CLASS OBJECTS FOR TYPE VERIFICATION
static Class gridCellClass = %c(GridCell);
static Class articlesHeaderCellClass = %c(ContentSuggestionsArticlesHeaderCell);
static Class suggestCellClass = %c(ContentSuggestionsCell);
static Class suggestFooterClass = %c(ContentSuggestionsFooterCell);
static Class settingsTextCellClass = %c(SettingsTextCell);
static Class visEffContentViewClass = %c(_UIVisualEffectContentView);
static Class visEffViewClass = %c(UIVisualEffectView);
static Class buttonClass = %c(UIButton);

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
        // watchObject(arg);
        [[arg textLabel] setTextColor:txt];
        [[arg contentView] setBackgroundColor:fg];        
    }
%end
    
%hook ClearBrowsingDataCollectionViewController
    - (id)initWithBrowserState:(id)arg {
        id cont = %orig;
        [[cont collectionView] setBackgroundColor:bg];
        return cont;
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
        [imgView setTintColor: fg];
        return tile;
    }
%end
    
%hook NTPShortcutTileView
    - (id)initWithFrame:(CGRect)arg {
        id tile = %orig;
        [[tile titleLabel] setTextColor:white];
        id imgView = [tile imageBackgroundView];
        [imgView setImage: [(UIImage*)[imgView image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imgView setTintColor: fg];
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
            if ([superview isKindOfClass:articlesHeaderCellClass] || [superview isKindOfClass:suggestCellClass] || [superview isKindOfClass:suggestFooterClass] || [superview isKindOfClass:settingsTextCellClass]) {
                
                UIImage* img = [(UIImage*)arg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self setTintColor: fg];
                if ([superview isKindOfClass:settingsTextCellClass] && [[self interactionTintColor] isEqual:fg]) {
                    [self setBackgroundColor:fg];
                    [self setTintColor: fg];
                }
                [[superview contentView] setBackgroundColor:nil];
                %orig(img);
            } else {
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
    @property (assign) NSMutableArray<UIVisualEffectView*> *effectViews;
    @property (retain) NSLayoutConstraint *heightConstraint;
    @property CGFloat oldHeight;
    @property BOOL needsInitialization;
    @property (retain) UIVisualEffectView *mainVisualEffect;
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
    return self;
}
- (void)needsReInit {
    [[self effectViews] removeAllObjects];
    self.heightConstraint = nil;
    self.oldHeight = -1;
    self.needsInitialization = true;
    self.mainVisualEffect = nil;
}
@end

static NSString* activeTabID = nil;
static NSMutableDictionary<NSString*, FakeLocationBar*> *fakeLocBars = [[NSMutableDictionary alloc] init];

static BOOL isContentView(id v) {
    return [v isKindOfClass: visEffContentViewClass];
}

static void hideSubviews(UIVisualEffectView* eff, NSMutableArray* subs) {
    [eff setBackgroundColor:clear];
    for (id vw in subs) {
        [vw setHidden:true];
    }
}
static void unhideSubviews(UIVisualEffectView* eff, NSMutableArray* subs) {
    [eff setBackgroundColor:oldeff];
    for (id vw in subs) {
        [vw setHidden:false];
    }
}

%hook GridViewController
    - (void)insertItem:(id)item atIndex:(NSUInteger)index selectedItemID:(NSString*)itemID {
        itemID = [item identifier];
        if (!fakeLocBars[itemID]) {
            fakeLocBars[itemID] = [[FakeLocationBar alloc] init];
        }
        %orig;
        
    }
    - (void)setSelectedItemID:(NSString*)itemID {
        if (!itemID) {
            %orig;
            return;
        }
        bool beenSet = false;
        if (!activeTabID) {
            activeTabID = [[NSString alloc] initWithString:itemID];
            beenSet = true;
        }
        if (!fakeLocBars[activeTabID]) {
            fakeLocBars[activeTabID] = [[FakeLocationBar alloc] init];
        }
        if (!beenSet) {
            activeTabID = [[NSString alloc] initWithString:itemID];   
        }
        // if (!fakeLocBars[itemID]) {
//             fakeLocBars[itemID] = [[FakeLocationBar alloc] init];
//         }
        // if (activeTabID) {
        // }
        else {
            [fakeLocBars[activeTabID] needsReInit];
        }
        %orig;
        
    }
    - (void)removeItemWithID:(NSString*)itemID selectedItemID:(NSString*)selectedID {
        [fakeLocBars removeObjectForKey:itemID];
        activeTabID = nil;
        %orig;
    }
    
%end

%hook ContentSuggestionsHeaderView
    - (void)addViewsToSearchField:(id)arg {
        %orig;
        if ([self searchHintLabel] != nil) {
            [[self searchHintLabel] setTextColor:hint];
        }
        if (activeTabID) {
            if ([fakeLocBars[activeTabID] heightConstraint] == nil) {
                [fakeLocBars[activeTabID] setHeightConstraint: [self fakeLocationBarHeightConstraint]];
            }
            [fakeLocBars[activeTabID] setOldHeight:[[self fakeLocationBarHeightConstraint] constant]];
            [[self fakeLocationBar] setBackgroundColor:fg];
            if ([fakeLocBars[activeTabID] needsInitialization]) {
                for (id sv in [arg subviews]) {
                    if ([sv isKindOfClass: visEffViewClass]) {
                        [fakeLocBars[activeTabID] setMainVisualEffect:sv];
                        [fakeLocBars[activeTabID] setNeedsInitialization: false];
                        for (id ssv in [sv subviews]) {
                            if (!isContentView(ssv)) {
                                [[fakeLocBars[activeTabID] effectViews] addObject:ssv];
                            }
                        }
                        hideSubviews([fakeLocBars[activeTabID] mainVisualEffect], [fakeLocBars[activeTabID] effectViews]);
                    }
                }
            }
        }
    }
    
    - (void)setFakeLocationBarHeightConstraint:(id)arg {
        %orig;
        if ([fakeLocBars[activeTabID] heightConstraint] == nil) {
            [fakeLocBars[activeTabID] setHeightConstraint: arg];
        }
    }
    
    - (id)fakeLocationBarHeightConstraint {
        NSLayoutConstraint* bh = %orig;
        CGFloat c = [bh constant];
        if (c == [fakeLocBars[activeTabID] oldHeight]) {
            return bh; 
        }
        if (![fakeLocBars[activeTabID] needsInitialization]) {
            if (c > [fakeLocBars[activeTabID] oldHeight]) {
                hideSubviews([fakeLocBars[activeTabID] mainVisualEffect], [fakeLocBars[activeTabID] effectViews]);
                [fakeLocBars[activeTabID] setOldHeight:c];
            }
            else if (c < [fakeLocBars[activeTabID] oldHeight]) {
                unhideSubviews([fakeLocBars[activeTabID] mainVisualEffect], [fakeLocBars[activeTabID] effectViews]);
                [fakeLocBars[activeTabID] setOldHeight:c];
            }
        }
        return bh;
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
        // [[cont styler] setCellSeparatorColor: sep];
        return cont;
    }    
%end
    
%hook PopupMenuViewController
    - (void)setUpContentContainer {
        %orig;
        id cont = [self contentContainer];
        for (id v in [cont subviews]) {
            if ([v isKindOfClass:visEffViewClass]) {
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
    - (void)viewWillAppear:(BOOL)arg {
        %orig;
        [[self tableView] setBackgroundColor:bg];
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
    
    //  STATUSBAR
%hook BrowserViewController
    - (NSInteger)preferredStatusBarStyle {
        return UIStatusBarStyleLightContent;
    }
%end