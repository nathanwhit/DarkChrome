#ifndef PRIVATEHEADERS_H
#define PRIVATEHEADERS_H
@interface UIImageView (cells)
- (void)_setDefaultRenderingMode:(NSInteger)arg;
- (void)setInteractionTintColor:(id)arg;
- (id)interactionTintColor;

@end;

@interface UIView (secondtoolbar)
- (id)blurEffect;
- (void)setEffect:(id)arg1;
- (id)initWithEffect:(id)arg1;
@end

@interface PrimaryToolbarCoordinator
- (id)buttonFactoryWithType:(NSInteger)arg;
- (id)commandDispatcher;
@end

@interface SecondaryToolbarCoordinator
- (id)buttonFactoryWithType:(NSInteger)arg;
- (id)dispatcher;
@end

@interface ToolbarButtonVisibilityConfiguration
- (id)initWithType:(NSInteger)arg;
+ (id)alloc;
@end

@interface ToolbarButtonFactory
- (id)initWithStyle:(NSInteger)arg;
- (void)setDispatcher:(id)arg;
- (void)setVisibilityConfiguration:(id)arg;
+ (id)alloc;
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

@interface UIBlurEffect (chrome)
+ (id)effectWithStyle:(NSInteger)arg;
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

@interface ClearBrowsingDataItem 
{
    UIColor* textColor;
}
@property(nonatomic, assign) UIColor* textColor;

@end

@interface ClearBrowsingDataManager
- (id)clearButtonItem;
- (void)addClearDataButtonToModel:(id)arg;
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
@end

@interface UIView (locbar)
- (CGFloat)ogl_height;
@end
#endif