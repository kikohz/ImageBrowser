//
//  HZScrollView.m
//  cnbeta
//
//  Created by x on 13-6-8.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import "HZScrollView.h"

@implementation HZScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setScrollEnabled:YES];
        //设置scrollview的contentSize,必须和实际内容的宽度一致，还要大于scrollview的宽度，不然是滑不动的
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        //设置滚动条是否可见
        [self setShowsVerticalScrollIndicator:NO];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled:YES];        //这个属性如果是YES, 并非是滚动整屏, 而是每次滚动为scrollView的宽度
        self.alwaysBounceHorizontal=YES;
        self.delegate = self;
        _currentPage = NSNotFound;
    }
    return self;
}



- (void)reloadData
{
    
    if(!self.hzsDataSource && ![self.hzsDataSource respondsToSelector:@selector(numberForHZScrollView:)])
        return;
    if(![self.hzsDataSource respondsToSelector:@selector(viewOfIndex:HZScrollView:)])
        return;
    
    NSUInteger viewCount = [self.hzsDataSource numberForHZScrollView:self];
    if(viewCount == 0)
        return;
    //删除原来的
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentSize = CGSizeMake(self.bounds.size.width*viewCount, self.bounds.size.height);
    _numberOfPages = viewCount;
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    [self setContentOffset:CGPointMake(0, 0)];
}
- (void)updatedContentSize
{
    NSUInteger viewCount = [self.hzsDataSource numberForHZScrollView:self];
    if(viewCount == 0)
        return;
    self.contentSize = CGSizeMake(self.bounds.size.width*viewCount, self.bounds.size.height);
    _numberOfPages = viewCount;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if(page == _currentPage)
        return;
    if (page >= [self.hzsDataSource numberForHZScrollView:self])
        return;
    
    _currentPage = page;
    
    UIView *tempView = [self viewWithTag:page+kViewTagOffset];
    if(tempView == nil)
    {
        tempView = (UIView *)[self.hzsDataSource viewOfIndex:_currentPage HZScrollView:self];
        tempView.frame = CGRectMake(page*tempView.frame.size.width, 0, tempView.frame.size.width, tempView.frame.size.height);
    }
    [self addSubview:tempView];
}

- (void)setPage:(NSUInteger)index animated:(BOOL)animated
{
    if(index > _numberOfPages)
        return;
    [self setContentOffset:[self contentOffsetForPage:index] animated:animated];
}

//计算当前页或者偏移量
- (NSInteger) pageForContentOffset
{
    return (int)self.contentOffset.x / (int)self.bounds.size.width;
}

- (CGPoint) contentOffsetForPage:(NSInteger) page
{
    return CGPointMake(page * self.bounds.size.width, 0);
}

//清空隐藏的view保证内存不浪费
- (void) HKClearView
{
    for (UIView * subview in self.subviews)
    {
        if (CGRectGetMinX(subview.frame)+CGRectGetWidth(self.bounds) < [self contentOffsetForPage:_currentPage].x
            || CGRectGetMinX(subview.frame)-2*CGRectGetWidth(self.bounds) > [self contentOffsetForPage:_currentPage].x)
        {
            [subview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [subview removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    NSUInteger page = [self pageForContentOffset];
    [self loadScrollViewWithPage:page+1];
    [self loadScrollViewWithPage:page];
    [self HKClearView];
    
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.hzsDelegate && [self.hzsDelegate respondsToSelector:@selector(hzScrollView:currentPageChanged:)])
    {
        [self.hzsDelegate hzScrollView:self currentPageChanged:_currentPage];
    }
}

@end
