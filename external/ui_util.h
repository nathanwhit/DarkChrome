// Copyright 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_UI_UTIL_UI_UTIL_H_
#define IOS_CHROME_BROWSER_UI_UTIL_UI_UTIL_H_

#include <CoreGraphics/CoreGraphics.h>

// Returns the closest pixel-aligned value less than |value|, taking the scale
// factor into account. At a scale of 1, equivalent to floor().
CGFloat AlignValueToPixel(CGFloat value);

#endif  // IOS_CHROME_BROWSER_UI_UTIL_UI_UTIL_H_
