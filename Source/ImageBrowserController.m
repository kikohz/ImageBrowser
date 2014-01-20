//
//  ImageBrowserController.m
//  cnbeta
//
//  Created by x on 13-5-30.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import "ImageBrowserController.h"
#import "HZZoomingScrollView.h"
#import "TipStatusBar.h"
#import "Toast+UIView.h"
#import "HZScrollView.h"

#define NSLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#define imageForName(fileName,type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:type]]
@interface ImageBrowserController ()<HZZoomingScrollViewDelegate,HZScrollViewDataSource,HZScrollViewDelegate>{

    CGRect _viewFrame;
    
}

@property (nonatomic,strong) HZScrollView *hzscrollView;  

@property (nonatomic,strong) UIButton *downloadButton;  //下载按钮
@property (nonatomic,strong) UILabel *imageCount;       //显示浏览个数
@end

@implementation ImageBrowserController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame DataSource:(id)dataSource Delegate:(id)delegate
{
    self = [super init];
    if(self){
    
        _viewFrame = frame;
        self.imageDataSource = dataSource;
        self.imageDelegate = delegate;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = _viewFrame;
	// Do any additional setup after loading the view.
    //创建image显示view
    [self initHzScrollView];
    //control是放在LazyScrollView之上
    [self creatControl];
    
    
}

- (void)viewDidUnload
{
    self.imageCount = nil;
    self.downloadButton = nil;
//    self.lazyScrollView = nil;
    self.hzscrollView = nil;
}

- (void)initHzScrollView
{
    
    self.hzscrollView = [[HZScrollView alloc] initWithFrame:self.view.frame];
    self.hzscrollView.hzsDataSource = self;
    self.hzscrollView.hzsDelegate = self;
    [self.hzscrollView reloadData];
    [self.view addSubview:self.hzscrollView];
}

- (void)creatControl
{
    UIView *toobar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.bounds.size.width, 40)];
    [toobar setBackgroundColor:[UIColor colorWithRed:0.0627 green:0.0627 blue:0.0627 alpha:0.7000]];
    [self.view addSubview:toobar];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadButton.frame = CGRectMake(toobar.bounds.size.width-27-10, toobar.bounds.size.height-22-10, 27, 22);
    [self.downloadButton setImage:imageForName(@"imageset_toolbar_download", @"png") forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
    [toobar addSubview:self.downloadButton];
    
    self.imageCount = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50, self.view.bounds.size.height-toobar.frame.size.height-20-10, 50, 20)];
    self.imageCount.backgroundColor = [UIColor clearColor];
    self.imageCount.textColor = [UIColor whiteColor];
    [self.view addSubview:self.imageCount];
    
}


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    if (![self isViewLoaded]) {
        return; // 这里做好异常处理
    }
    //如果是6.0就执行下面的代码
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        if (self.view.window == nil)// 是否是正在使用的视图
        {
            [self viewDidUnload];
            // 下面这句代码，目的是再次进入时能够重新加载
            self.view = nil;
        }
    }
}


- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

}
- (void)dealloc
{
    
}
#pragma mark
#pragma mark 横竖屏控制
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark
#pragma mark HZScrollViewDataSource
- (NSUInteger)numberForHZScrollView:(HZScrollView *)hzscrollView
{
    return [self.imageDataSource imageCount:self];
}

- (id)viewOfIndex:(NSUInteger)index HZScrollView:(HZScrollView *)hzscrollView
{
    HZZoomingScrollView *scrollView = [[HZZoomingScrollView alloc] initWithImageBrowser:self Frame:self.view.frame];
    scrollView.tag = index+kViewTagOffset;
    scrollView.hzImage = [self.imageDataSource imageAtIndex:index];
    scrollView.zsvdelegate = self;
    [scrollView displayImage];
    return scrollView;
}



- (void)setStartIndex:(NSUInteger)startIndex
{
    if(startIndex > self.hzscrollView.numberOfPages)
        return;
    _startIndex = startIndex;
    [self.hzscrollView setPage:startIndex animated:NO];
    if(self.imageCount)
        self.imageCount.text = [NSString stringWithFormat:@"%d/%d",startIndex+1,self.hzscrollView.numberOfPages];
}


//操作
- (void)hideImageBrowser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage:(UIButton *)sender
{
    HZImage *temp;
    if(self.imageDataSource && [self.imageDataSource respondsToSelector:@selector(imageAtIndex:)])
    {
//        [self.view makeToast:@"正在保存中" duration:0.3 position:@"center"];
      
        temp = [self.imageDataSource imageAtIndex:self.hzscrollView.currentPage];
//        UIImageWriteToSavedPhotosAlbum(temp.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    }
//    else
//        [[TipStatusBar sharedClient] showStatusBarTip:@"保存失败" statusBarColor:[UIColor redColor]];
  if(self.imageDelegate && [self.imageDelegate respondsToSelector:@selector(saveImage:)]){
  
    
    [self.imageDelegate saveImage:temp];
  
  
  }
}

#pragma mark
#pragma mark HZZoomingScrollViewDelegate
- (void)clickImage:(HZZoomingScrollView *)scrollView
{
    [self performSelector:@selector(hideImageBrowser) withObject:nil afterDelay:0.2];
}

#pragma mark
#pragma mark HZScrollViewDelegate
- (void)hzScrollView:(HZScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex
{
    if(self.imageCount)
    {
        NSString *strText = [NSString stringWithFormat:@"%d/%d",currentPageIndex+1,pagingView.numberOfPages];
        self.imageCount.text = strText;
    }
}

@end
