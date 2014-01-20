ImageBrowser
============

ios image browser

A simple picture viewer


Usage

	ImageBrowserController *imageBrowser = [[ImageBrowserController alloc] initWithFrame:self.view.frame DataSource:self Delegate:self];
    imageBrowser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:imageBrowser animated:YES completion:nil];


DataSource delegate


	#pragma mark
	#pragma mark ImageBrowserDataSource

	- (NSUInteger)imageCount:(ImageBrowserController *)imageBrowser
	{	
    return images.count;
	}
	- (HZImage *)imageAtIndex:(NSUInteger)index
	{
    if(self.htmlView.images.count <=0)
        return nil;
    HZImage *hzimage = [[HZImage alloc] init];
    hzimage.url = @"";
    hzimage.image =   [UIImage imageNamed:@"1.png"];
    hzimage.caption = @"";
    return hzimage;
	}
	#pragma mark
	#pragma mark ImageBrowserDelegate

	- (void)saveImage:(HZImage *)hzimage
	{
   	
	}