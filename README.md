ImageBrowser
============

ios image browser

A simple picture viewer


Usage

	ImageBrowserController *imageBrowser = [[ImageBrowserController alloc] initWithFrame:self.view.frame DataSource:self Delegate:self];
    imageBrowser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:imageBrowser animated:YES completion:nil];
