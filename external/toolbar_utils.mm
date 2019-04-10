// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "toolbar_utils.h"

#import "toolbar_constants.mm"
#import "ui_util.mm"
#import "dynamic_type_util.mm"



namespace {

// Returns the |category| unchanged, unless it is ||, in which case it returns
// the preferred content size category from the shared application.
UIContentSizeCategory NormalizedCategory(UIContentSizeCategory category) {
  if ([category isEqualToString:UIContentSizeCategoryUnspecified])
    return [UIApplication sharedApplication].preferredContentSizeCategory;
  return category;
}

// Returns an interpolation of the height based on the multiplier associated
// with |category|, clamped between UIContentSizeCategoryLarge and
// UIContentSizeCategoryAccessibilityExtraLarge. This multiplier is applied to
// |default_height| - |non_dynamic_height|.
CGFloat Interpolate(UIContentSizeCategory category,
                    CGFloat default_height,
                    CGFloat non_dynamic_height) {
  return AlignValueToPixel((default_height - non_dynamic_height) *
                               ToolbarClampedFontSizeMultiplier(category) +
                           non_dynamic_height);
}

}  // namespace

CGFloat ToolbarClampedFontSizeMultiplier(UIContentSizeCategory category) {
  return SystemSuggestedFontSizeMultiplier(
      category, UIContentSizeCategoryLarge,
      UIContentSizeCategoryAccessibilityExtraLarge);
}

CGFloat ToolbarExpandedHeight(UIContentSizeCategory category) {
  category = NormalizedCategory(category);
  return Interpolate(category, kAdaptiveToolbarHeight,
                     kNonDynamicToolbarHeight);
}

CGFloat LocationBarHeight(UIContentSizeCategory category) {
  category = NormalizedCategory(category);
  CGFloat verticalMargin = 2 * kAdaptiveLocationBarVerticalMargin;
  CGFloat dynamicTypeVerticalAdjustment =
      (ToolbarClampedFontSizeMultiplier(category) - 1) *
      (kLocationBarVerticalMarginDynamicType +
       kAdaptiveLocationBarVerticalMargin);
  verticalMargin = verticalMargin + dynamicTypeVerticalAdjustment;
  return AlignValueToPixel(ToolbarExpandedHeight(category) - verticalMargin);
}
