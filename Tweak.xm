#define INSPECT 1


#include <os/log.h>
#include "privateHeaders.h"
#include <math.h>

#define logf(form, str) os_log(OS_LOG_DEFAULT, form, str)
#define log(str) os_log(OS_LOG_DEFAULT, str)

#if INSPECT==1
#include "InspCWrapper.m"
%ctor {
    // watchClass(%c(ContentSuggestionHeaderView));
    // watchSelector(@selector(updateFakeOmniboxForOffset:screenWidth:safeAreaInsets:));
    // watchSelector(@selector(populateItems:selectedItemID:));
    // setMaximumRelativeLoggingDepth(20);
    enableCompleteLogging();
    // watchClass(%c(OmniboxPopupTruncatingLabel));
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
static UIColor * locBarColor = [UIColor colorWithWhite:1 alpha:0.12];
static CGFloat locbar_viseffect_rgb = 0.98;
static CGFloat locbar_viseffect_alph = 0.4;

// CLASS OBJECTS FOR TYPE VERIFICATION
// static Class gridCellClass = %c(GridCell);
static Class articlesHeaderCellClass = %c(ContentSuggestionsArticlesHeaderCell);
static Class suggestCellClass = %c(ContentSuggestionsCell);
static Class suggestFooterClass = %c(ContentSuggestionsFooterCell);
static Class settingsTextCellClass = %c(SettingsTextCell);
static Class visContentViewClass = %c(_UIVisualEffectContentView);
static Class visEffectViewClass = %c(UIVisualEffectView);
static Class buttonClass = %c(UIButton);
static Class visEffectSubviewClass = %c(_UIVisualEffectSubview);
static Class visEffectBackdropClass = %c(_UIVisualEffectBackdropView);

static CGFloat locBarCornerRadius = 30;

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
    
// %hook ContentSuggestionsViewController
//     - (void)addSuggestions:(id)arg1 toSectionInfo:(id)arg2 {
//         %orig;
//         log("Hooked");
//         [view]
//     }
// %end
    
%hook ContentSuggestionsItem
    - (void)configureCell:(id)cell {
        %orig;
        if ([cell respondsToSelector: @selector(additionalInformationLabel)]) {
            [[cell additionalInformationLabel] setTextColor:txt];
        }
    }
%end
    
@interface FakeLocationBar : NSObject
    @property (assign) NSMutableArray *effectViews;
    @property (retain) NSLayoutConstraint *heightConstraint;
    @property CGFloat oldHeight;
    @property bool needsInitialization;
    @property (retain) UIVisualEffectView *mainVisualEffect;
    @property bool effectsHidden;
    @property (retain) UIButton* fakeBox;
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

// static BOOL isContentView(id v) {
//     return [v isKindOfClass: visContentViewClass];
// }

// static void hideSubviews(FakeLocationBar* bar) {
//     // log("Hiding");
//     [[bar mainVisualEffect] setBackgroundColor:clear];
//     [[[bar mainVisualEffect] layer] setCornerRadius:30];
//     for (id vw in [bar effectViews]) {
//         [vw setHidden:true];
//         [[vw layer] setCornerRadius:30];
//     }
//     [bar setEffectsHidden:true];
// }
// static void unhideSubviews(FakeLocationBar* bar) {
//     // log("Unhiding");
//     [[[bar mainVisualEffect] layer] setCornerRadius:0];
//     [[bar mainVisualEffect] setBackgroundColor:oldeff];
//     for (id vw in [bar effectViews]) {
//         [vw setHidden:false];
//         [[vw layer] setCornerRadius:0];
//     }
//     [bar setEffectsHidden:false];
// }

%hook GridViewController
    // - (void)populateItems:(id)
    - (void)insertItem:(id)item atIndex:(NSUInteger)index selectedItemID:(NSString*)arg {
        // logf("%@", NSStringFromClass([item class]));
        %orig;
        if ([item respondsToSelector:@selector(identifier)]) {
            NSString* itemID = [item identifier];
            if (itemID && !fakeLocBars[itemID]) {
                fakeLocBars[itemID] = [[FakeLocationBar alloc] init];
            }
        }
        else {
            // log("Item didn't respond");
        }
        // activeTabID = srg;
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
    
%end
        
%hook TabModel
    - (void)setCurrentTab:(id)tab {
        %orig;
        // log("set");
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
    // - (void)app
    - (void)restoreSessionWindow:(id)session forInitialRestore:(id)restore {
        %orig;
        activeTabID = [[self currentTab] tabId];
        for (FakeLocationBar* bar in fakeLocBars) {
            [bar needsReInit];
        }
        // [fakeLocBars[activeTabID] needsReInit];
    }
    - (void)browserStateDestroyed {
        for (FakeLocationBar* bar in fakeLocBars) {
            [bar needsReInit];
        }
        %orig;
    }
    - (void)applicationDidEnterBackground {
        %orig;
        for (FakeLocationBar* bar in fakeLocBars) {
            [bar needsReInit];
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
        // if (activeTabID != nil) {
            if ([fakeLocBars[activeTabID] needsInitialization]) {
                [fakeLocBars[activeTabID] setHeightConstraint: [self fakeLocationBarHeightConstraint]];
                // [[self fakeLocationBar] setBackgroundColor:fg];
                [[self fakeLocationBar] setBackgroundColor:locBarColor];
                [fakeLocBars[activeTabID] setFakeBox:arg];
                // for (id sv in [arg subviews]) {
                    // if ([sv isKindOfClass: visEffectViewClass]) {
                id veff = [[arg subviews] objectAtIndex:0];
                [fakeLocBars[activeTabID] setMainVisualEffect:veff];
                headerViews[[[NSNumber alloc] initWithUnsignedInteger:[self hash]]] = fakeLocBars[activeTabID];
                [veff setBackgroundColor:oldeff];
                [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:0]];
                // [[[veff subviews] objectAtIndex:0] setHidden:true];
                [[fakeLocBars[activeTabID] effectViews] addObject:[[veff subviews] objectAtIndex:1]];
                // [[[veff subviews] objectAtIndex:1] setHidden:true];
                    // }
                // }
                // if (![fakeLocBars[activeTabID] effectsHidden]) {
                // hideSubviews(fakeLocBars[activeTabID]);
                // }
                // [fakeLocBars[activeTabID] setEffectsHidden: true];
                id sub1 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:0];
                id sub2 = [[fakeLocBars[activeTabID] effectViews] objectAtIndex:1];
                [[veff layer] setCornerRadius:locBarCornerRadius];
                [[sub1 layer] setCornerRadius:locBarCornerRadius];
                [[sub2 layer] setCornerRadius:locBarCornerRadius];
                [fakeLocBars[activeTabID] setNeedsInitialization: false];
                        // return;
                    // }
                // }
            }
        // }
    }
    
    - (void)setFakeboxHighlighted:(BOOL)highlighted {
        %orig;
        // if (highlighted) {
        [[self fakeLocationBar] setBackgroundColor: fg];
        // [[fakeLocBars[activeTabID] fakeBox] setBackgroundColor: fg];
        // }
    }
    
    - (void)setFakeLocationBarHeightConstraint:(id)arg {
        %orig;
        if (arg != nil && fakeLocBars[activeTabID] != nil && [fakeLocBars[activeTabID] needsInitialization]) {
            [fakeLocBars[activeTabID] setHeightConstraint: arg];
        }
    }
    
    - (id)fakeLocationBarHeightConstraint {
        NSLayoutConstraint* bh = %orig;
        // watchObject(bh);
        CGFloat c = [(NSLayoutConstraint*)bh constant];
        CGFloat minDelt = fabs(36.0 - c);
        if (activeTabID == nil || fakeLocBars[activeTabID] == nil || [fakeLocBars[activeTabID] needsInitialization]) {
            return bh;
        }
        CGFloat delta = c - [fakeLocBars[activeTabID] oldHeight];
        // CGFloat mult = 3;
        [fakeLocBars[activeTabID] setOldHeight: c];
        // if (minDelt <= 0.5 && [fakeLocBars[activeTabID] effectsHidden]) {
//             unhideSubviews(fakeLocBars[activeTabID]);
//         }
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
            // [sub1 setHidden:false];
//             [sub2 setHidden:false];
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
        // else if (minDelt >= 11 && ![fakeLocBars[activeTabID] effectsHidden]) {
//             hideSubviews(fakeLocBars[activeTabID]);
//         }
        return bh;
    }
    
   //  - (void)updateSearchFieldWidth:(id)w height:(id)h topMargin:(id)top forOffset:offset screenWidth:screenWidth safeAreaInsets:insets {
//         %orig;
//         CGFloat c = [[fakeLocBars[activeTabID] heightConstraint] constant];
//         logf("%.2f", c);
//         CGFloat minDelt = fabs(36.0 - c);
//         logf("%.2f", minDelt);
//         if (activeTabID == nil || !fakeLocBars[activeTabID] || [fakeLocBars[activeTabID] needsInitialization]) {
//             %orig;
//             return;
//         }
//         if (minDelt <= 4 && [fakeLocBars[activeTabID] effectsHidden]) {
//             unhideSubviews(fakeLocBars[activeTabID]);
//         }
//         else if (![fakeLocBars[activeTabID] effectsHidden]) {
//             hideSubviews(fakeLocBars[activeTabID]);
//         }
// }
    
%end    
    
%hook ContentSuggestionsHeaderView
    - (void)dealloc {
        NSNumber* hsh = [[NSNumber alloc] initWithUnsignedInteger:[self hash]];
        if (headerViews[hsh]) {
            [headerViews[hsh] needsReInit];
            // log("Deallocated");
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
        // [[cont styler] setCellSeparatorColor: sep];
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

%hook SelfSizingTableView
    // - (void)setBackgroundColor:(id)color {
//         %orig(fg);
//     }
%end
    
%hook OmniboxPopupTruncatingLabel
    // - (void)setTextColor:(id)color {
   //      if ([color isEqual:[UIColor colorWithWhite:0 alpha:0.41]] && ![color isEqual:hint]) {
   //          %orig(hint);
   //      }
   //      else {
   //          %orig(txt);
   //      }
   //  }
   //
   //  - (id)textColor {
   //      id color = %orig;
   //      if ([color isEqual:[UIColor colorWithWhite:0 alpha:0.41]]) {
   //          return hint;
   //      }
   //      else {
   //          return txt;
   //      }
   //  }
    // - (id)getLinearGradient:(CGRect)grad {
//         id ret = %orig;
//         [self setTextColor:txt];
//         return ret;
//     }
    - (void)setup {
        // log("Hooked setup");
        %orig;
        // [self setTextColor:txt];
        watchObject([self textColor]);
    }
%end
    
%hook OmniboxPopupPresenter 
    - (id)initWithPopupPositioner:(id)arg1 popupViewController:(id)arg2 incognito:(BOOL)arg3 {
        return %orig(arg1, arg2, true);
    }
%end
    
// %hook OmniboxPopupPresenter
//     - (id)initWithPopupPositioner:(id)arg1 popupViewController:(id)arg2 incognito:(BOOL)arg3 {
//         return %orig(arg1, arg2, true);
//     }
// %end
    
%hook OmniboxPopupViewController
    - (void)setIncognito:(BOOL)arg {
        %orig(true);
    }
%end
    
%hook OmniboxPopupRow
    -(void)initWithIncognito:(BOOL)incog {
        %orig(false);
    }
%end
    
    //  STATUSBAR
%hook BrowserViewController
    - (NSInteger)preferredStatusBarStyle {
        return UIStatusBarStyleLightContent;
    }
%end