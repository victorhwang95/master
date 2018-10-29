// MXScrollView.h
//
// Copyright (c) 2015 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MXParallaxHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class MXScrollView;

/**
 The delegate of a MXScrollView object may adopt the MXScrollViewDelegate protocol to control subview's scrolling effect.
 */
@protocol MXScrollViewDelegate <UIScrollViewDelegate>

@optional
/**
 Asks the page if the scrollview should scroll with the subview.
 
 @param scrollView The scrollview. This is the object sending the message.
 @param subView    An instance of a sub view.
 
 @return YES to allow scrollview and subview to scroll together. YES by default.
 */
- (BOOL)scrollView:(MXScrollView *)scrollView shouldScrollWithSubView:(UIScrollView *)subView;

@end

/**
 The MXScrollView is a UIScrollView subclass with the ability to hook the vertical scroll from its subviews.
 */
@interface MXScrollView : UIScrollView

/**
 Delegate instance that adopt the MXScrollViewDelegate.
 */
@property (nonatomic, weak, nullable) IBOutlet id<MXScrollViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
