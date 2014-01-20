//
//  HZZoomingScrollView.m
//  cnbeta
//
//  Created by x on 13-5-30.
//  Copyright (c) 2013年 x. All rights reserved.
//

#import "HZZoomingScrollView.h"
#import "HZImage.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface HZZoomingScrollView()

@property (nonatomic,strong) MWTapDetectingView *tapView; // for background taps
@property (nonatomic,strong) MWTapDetectingImageView *photoImageView;
@property (nonatomic,strong) UIActivityIndicatorView *spinner;
@property (nonatomic,weak) ImageBrowserController *imageBrowser;

@property (nonatomic,assign) QCImageViewEffect QCImageType;

@end


@implementation HZZoomingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithImageBrowser:(ImageBrowserController *)browser Frame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if(self){
        self.imageBrowser = browser;
        
        // Tap view for background
		_tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
		_tapView.tapDelegate = self;
		_tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:_tapView];
		
		// Image view
		_photoImageView = [[MWTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.contentMode = UIViewContentModeCenter;
		_photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:_photoImageView];
		
		// Spinner
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.hidesWhenStopped = YES;
		_spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_spinner];
		
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    }
    return self;
}




//更具固定的宽度做等比缩放  这里的photoview是tableview
- (CGSize)imageZoomSize:(CGSize)imagesize
{
    if(imagesize.width == 0.0 || imagesize.height == 0.0)
        return CGSizeZero;
    CGSize temp;
    //高度优先做等比缩放
    //CGRect ddd2 = self.photoView.frame;
    float offsize = self.photoImageView.frame.size.height/imagesize.height;
    temp = CGSizeMake(imagesize.width*offsize, imagesize.height*offsize);
    
    self.QCImageType = QCImageViewEffectOriginal;
    if (temp.width>800)//320-5=315
    {
        temp.width=315;
        self.QCImageType = QCImageViewEffectDefaultCutTop;//QCImageViewEffectDefaultCutTop
    }else if(temp.width<122)//(320-15)/2.5=122
    {
        temp.width=122;
        self.QCImageType = QCImageViewEffectDefaultCutTop;
    }
    
    return temp;
}
#pragma mark - Image

// Get and display image
- (void)displayImage {
	if (self.hzImage && _photoImageView.image == nil) {
		
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
		
		// Get image from browser as it handles ordering of fetching
		UIImage *img = self.hzImage.image;
		if (img) {
			
			// Hide spinner
			[_spinner stopAnimating];
			
			// Set image
            
//            [[SDImageCache sharedImageCache] storeImage:img forKey:self.hzImage.url toDisk:YES];
            //大图特殊处理
            CGSize tempsize = img.size;
            if(img.size.width > 1200 || img.size.height >2000)
            {
            float offsize = 2000/img.size.height;
            tempsize = CGSizeMake(img.size.width*offsize, img.size.height*offsize);
            }
            if(!CGSizeEqualToSize(tempsize, img.size))
            {
                img = [self scaleImage:img ToSize:tempsize];
            }
            
            
            
			_photoImageView.image = img;
//			_photoImageView.hidden = NO;
            
//            CGSize tempSize = [self imageZoomSize:img.size];
			
			// Setup photo frame
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
//            photoImageViewFrame.size = tempSize;
			_photoImageView.frame = photoImageViewFrame;
            
//            [_photoImageView setImageWithURL:[NSURL URLWithString:self.hzImage.url] placeholderImage:nil effect:_QCImageType];
            
			self.contentSize = photoImageViewFrame.size;
            
			// Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
			
		} else {
			
			// Hide image view
//			_photoImageView.hidden = YES;
			[_spinner startAnimating];
            __weak typeof (&*self)weakself = self;
            [_photoImageView setImageWithURL:[NSURL URLWithString:self.hzImage.url] placeholderImage:nil effect:_QCImageType success:^(UIImage *image) {
                
                [weakself.spinner stopAnimating];
            } failure:^(NSError *error) {
                [weakself.spinner stopAnimating];
            }];
			
		}
		[self setNeedsLayout];
	}
}

// Image failed so just show black!
- (void)displayImageFailure {
	[_spinner stopAnimating];
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (_photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
	
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}
    
	// Calculate Max
	CGFloat maxScale = 2.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	// Reset position
	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
	[self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
	
	// Update tap view frame
	_tapView.frame = self.bounds;
	
	// Spinner
	if (!_spinner.hidden) _spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
                                                        floorf(self.bounds.size.height/2.0));
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
	
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    if(self.zsvdelegate && [self.zsvdelegate respondsToSelector:@selector(clickImage:)])
    {
        [self.zsvdelegate clickImage:self];
    }
    
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	
	// Cancel any single tap handling
	[NSObject cancelPreviousPerformRequestsWithTarget:_imageBrowser];
	
	// Zoom
	if (self.zoomScale == self.maximumZoomScale) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
	
	// Delay controls
//	[_photoBrowser hideControlsAfterDelay];
	
}


// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}


-(UIImage*)scaleImage:(UIImage *) image ToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    if (width < size.width || height < size.height) {
        return image;
    }else {
        float verticalRadio = size.height*1.0/height;
        float horizontalRadio = size.width*1.0/width;
        
        float radio = 1;
        if(verticalRadio>1 && horizontalRadio>1)
        {
            radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
        }
        else
        {
            radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
        }
        
        width = width*radio;
        height = height*radio;
        
        //        int xPos = (size.width - width)/2;
        //        int yPos = (size.height-height)/2;
        
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        
        // 绘制改变大小的图片
        [image drawInRect:CGRectMake(0, 0, width, height)];
        
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        
        // 返回新的改变大小后的图片
        return scaledImage;
    }
}



@end
