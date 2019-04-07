#ifndef PRIVATEHEADERS_H
#define PRIVATEHEADERS_H

@interface UITableView (bookmark_edit)
- (id)_visibleHeaderFooterViews;
@end
@interface ClearBrowsingDataCollectionViewController
- (id)collectionView;
- (void)loadModel;
@end
@interface OmniboxPopupTruncatingLabel : UILabel
@end

@interface OmniboxPopupRow		
- (id)detailTruncatingLabel;		
- (id)textTruncatingLabel;	
@end


@interface GridViewController
- (void)setSelectedItemID:(NSString*)itemID;
- (NSString*)selectedItemID;
- (NSMutableArray*)items;
- (UIView*)view;
@end

@interface GridItem
- (NSString*)identifier;
@end

@interface GridCell
- (void)setTheme:(NSUInteger)arg;
- (id)topBar;
- (void)updateTopBar;
@end

@interface TabGridViewController
- (id)view;

@end

@interface TabModel
- (void)restoreSessionWindow:(id)session forInitialRestore:(id)restore;
- (id)currentTab;
- (void)browserStateDestroyed;
- (NSUInteger)count;
- (id)tabAtIndex:(NSUInteger)index;
@end

@interface Tab
- (NSString*)tabId;
@end

@interface UIImageView (cells)
- (void)_setDefaultRenderingMode:(NSInteger)arg;
- (void)setInteractionTintColor:(id)arg;
- (id)interactionTintColor;

@end

@interface ChromeTableViewStyler
- (id)init;
- (void)setCellBackgroundColor:(id)arg;
- (void)setTableViewBackgroundColor:(id)arg;
- (void)setTableViewSectionHeaderBlurEffect:(id)arg;
- (id)tableViewSectionHeaderBlurEffect;
- (void)setCellTitleColor:(id)arg;
- (void)setCellSeparatorColor:(id)arg;
@end

@interface SettingsDetailCell
- (void)setBackgroundColor:(id)arg;
- (id)textLabel;
- (void)setTextLabel:(id)arg;
@end

@interface SettingsSwitchCell : SettingsDetailCell
- (id)contentView;
- (id)detailTextLabel;

@end
@interface SettingsSwitchItem
- (void)configureCell:(id)arg1 withStyler:(id)arg2;
@end

@interface TableViewAccountItem : SettingsSwitchItem
@end

@interface SettingsNavigationController
- (id)initWithRootViewController:(id)arg1 browserState:(id)arg2 delegate:(id)arg3;
- (UINavigationBar*)navigationBar;
- (id)preferredFocusedView;
@end

@interface BookmarkHomeViewController
- (id)initWithLoader:(id)arg1 browserState:(id)arg2 dispatcher:(id)arg3 webStateList:(id)arg4;
- (id)tableView;
@end

@interface ReadingListTableViewController : BookmarkHomeViewController
@end

@interface RecentTabsTableViewController : BookmarkHomeViewController
@end

@interface TableViewURLCell
- (UILabel*)URLLabel;
- (UILabel*)titleLabel;
- (void)setHorizontalStack:(id)arg;
- (id)horizontalStack;
- (id)faviconContainerView;
@end

@interface TableViewBookmarkFolderCell
- (id)folderTitleTextField;
- (id)stackView;
@end

@interface SettingsTextCell
- (id)inkView;
- (id)textLabel;
- (id)detailTextLabel;
@end

@interface HistoryTableViewController
- (id)tableView;
@end

@interface BookmarkEditViewController
- (id)tableView;
- (id)styler;
- (id)initWithBookmark:(const struct BookmarkNode *)arg1 browserState:(struct ChromeBrowserState *)arg2;
@end

@interface AutofillEditCell
- (id)textLabel;
@end

@interface TableViewTextHeaderFooterView
- (id)textLabel;
@end

@interface AutofillDataCell
- (id)textLabel;
@end

@interface PopupMenuTableViewController
- (id)init;
- (id)tableView;
- (id)styler;
@end

@interface PopupMenuViewController
- (void)setupContentContainer;
- (id)contentContainer;
@end

@interface NTPMostVisitedTileView
- (id)initWithFrame:(CGRect)arg;
- (id)titleLabel;
- (id)imageBackgroundView;
- (void)setImageBackgroundView:(id)arg;
@end

@interface UIImage (suggestiontile)
+ (id)colorImage:(id)arg1 withColor:(id)arg2;
@end

@interface ContentSuggestionsCell
- (id)init;
- (id)titleLabel;
- (id)contentView;
- (id)additionalInformationLabel;
- (void)commonMDCCollectionViewCellInit;
- (id)inkView;
+ (void)configureTitleLabel:(id)lbl;
@end

@interface ContentSuggestionsArticlesHeaderCell : ContentSuggestionsCell
- (id)backgroundView;
- (id)label;
- (void)configureCell:(id)cell;
@end

@interface UIView (suggestions)
- (id)_ui_superview;
@end

@interface ContentSuggestionsHeaderView
- (id)searchHintLabel;
- (void)addViewsToSearchField:(id)arg;
- (UIView*)fakeLocationBar;
- (id)subviews;
- (NSLayoutConstraint*)fakeLocationBarHeightConstraint;
- (NSUInteger)hash;
@end

#endif