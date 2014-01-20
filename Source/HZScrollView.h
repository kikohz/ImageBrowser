//
//  HZScrollView.h
//  cnbeta
//
//  Created by x on 13-6-8.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kViewTagOffset       1000


@class HZScrollView;

@protocol HZScrollViewDataSource <NSObject>

- (NSUInteger)numberForHZScrollView:(HZScrollView *)hzscrollView;

- (id)viewOfIndex:(NSUInteger)index HZScrollView:(HZScrollView *)hzscrollView;

@end

@protocol HZScrollViewDelegate <NSObject>

//- (void)didSelectView:(HZScrollView*)hzscrollView selectIndex:(NSUInteger)index;

- (void)hzScrollView:(HZScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex;

@end


@interface HZScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,assign)    NSUInteger                      numberOfPages;
@property (readonly)            NSUInteger                      currentPage;
@property (nonatomic,assign)    id<HZScrollViewDataSource> hzsDataSource;
@property (nonatomic,assign)    id<HZScrollViewDelegate>hzsDelegate;


- (void)reloadData;

- (void)setPage:(NSUInteger )index animated:(BOOL)animated;


@end
