//
//  HZZoomingScrollView.h
//  cnbeta
//
//  Created by x on 13-5-30.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"


@class HZImage,ImageBrowserController,HZZoomingScrollView;

@protocol HZZoomingScrollViewDelegate <NSObject>

- (void)clickImage:(HZZoomingScrollView*)scrollView;

@end


@interface HZZoomingScrollView : UIScrollView<UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate>{

}

@property (nonatomic,strong) HZImage *hzImage;
@property (nonatomic,assign) id<HZZoomingScrollViewDelegate> zsvdelegate;

- (id)initWithImageBrowser:(ImageBrowserController *)browser Frame:(CGRect)frame;
- (void)displayImage;

@end
