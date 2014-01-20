//
//  ImageBrowserController.h
//  cnbeta
//
//  Created by x on 13-5-30.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZImage.h"
@class ImageBrowserController;


@protocol ImageBrowserDataSource <NSObject>
//获取图片个数
- (NSUInteger)imageCount:(ImageBrowserController *)imageBrowser;
- ( HZImage*)imageAtIndex:(NSUInteger)index;

@end

@protocol  ImageBrowserDelegate <NSObject>

- (void)saveImage:(HZImage *)hzimage;

@end

@interface ImageBrowserController : UIViewController
@property (nonatomic,assign) id<ImageBrowserDataSource> imageDataSource;
@property (nonatomic,assign) id<ImageBrowserDelegate> imageDelegate;

@property (nonatomic,assign) NSUInteger startIndex;   //设置起始图片，不设置，默认从第0个显示

- (id)initWithFrame:(CGRect)frame DataSource:(id)dataSource Delegate:(id)delegate;


//control
- (void)hideImageBrowser;
@end
