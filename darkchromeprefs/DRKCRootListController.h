#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface DRKCRootListController : PSListController
- (id)readPreferenceValue:(PSSpecifier*)specifier;
- (NSArray *)specifiers;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier;
@end
