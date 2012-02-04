//
//  HudDemoViewController.m
//  HudDemo
//
//  Created by Matej Bukovinski on 30.9.09.
//  Copyright bukovinski.com 2009. All rights reserved.
//

#import "HudDemoViewController.h"
#import "MBProgressHUD.h"
#import <unistd.h>

@implementation HudDemoViewController

#pragma mark - View controller

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;	
}

#pragma mark - Actions

- (IBAction)showSimple:(id)sender {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [MBProgressHUD new];
    [self.navigationController.view addSubview:HUD];
	
    // Remove it from the window at the right time
	HUD.wasHiddenBlock = ^(MBProgressHUD *view) {
		[view removeFromSuperview];
	};
	
	// Show the HUD while the provided block executes in the background
	[HUD showWhileExecuting:^{
		[self myTask];
	}];
}

- (IBAction)showWithLabel:(id)sender {
    HUD = [MBProgressHUD new];
	[self.navigationController.view addSubview:HUD];
	
	HUD.label.text = @"Loading";
	HUD.wasHiddenBlock = ^(MBProgressHUD *view) {
		[view removeFromSuperview];
	};
	
	[HUD showWhileExecuting:^{
		[self myTask];
	}];
}

- (IBAction)showWithLabelDeterminate:(id)sender {
    HUD = [MBProgressHUD new];
	[self.navigationController.view addSubview:HUD];
	
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.label.text = @"Loading";
	HUD.wasHiddenBlock = ^(MBProgressHUD *view) {
		[view removeFromSuperview];
	};
	
	// myProgressTask uses the HUD instance to update progress
	[HUD showWhileExecuting:^{
		[self myProgressTask];
	}];
}

- (IBAction)showWithLabelMixed:(id)sender {
    HUD = [MBProgressHUD new];
	[self.navigationController.view addSubview:HUD];
	
    HUD.label.text = @"Connecting";
	HUD.wasHiddenBlock = ^(MBProgressHUD *view) {
		[view removeFromSuperview];
	};
	
	[HUD showWhileExecuting:^{
		[self myMixedTask];
	}];
}

- (IBAction)showUsingBlocks:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD new];
	[self.navigationController.view addSubview:hud];
	hud.label.text = @"Loading";
	hud.removeFromSuperViewOnHide = YES;
	[hud showWhileExecuting:^{
		[self myTask];
	}];
}

- (IBAction)showURL:(id)sender {
	NSURL *URL = [NSURL URLWithString:@"https://github.com/matej/MBProgressHUD/zipball/master"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
	
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.minimumShowTime = 2.0;
}

- (IBAction)showWithSuccess:(id)sender {
	MBProgressHUD *inlineHUD = [MBProgressHUD new];
	[self.navigationController.view addSubview:inlineHUD];
	
	inlineHUD.customView = MBProgressHUDSuccessImageView;
    inlineHUD.mode = MBProgressHUDModeCustomView;
    inlineHUD.label.text = @"Completed";
	inlineHUD.removeFromSuperViewOnHide = YES;
	inlineHUD.minimumShowTime = 2.0f;
	
    [inlineHUD show:YES];
	[inlineHUD hide:YES];
}

- (IBAction)showWithError:(id)sender {
	MBProgressHUD *inlineHUD = [MBProgressHUD new];
	[self.navigationController.view addSubview:inlineHUD];
	
	inlineHUD.customView = MBProgressHUDErrorImageView;
    inlineHUD.mode = MBProgressHUDModeCustomView;
    inlineHUD.label.text = @"Failed";
	inlineHUD.removeFromSuperViewOnHide = YES;
	inlineHUD.minimumShowTime = 2.0f;
	
    [inlineHUD show:YES];
	[inlineHUD hide:YES];
}

#pragma mark -
#pragma mark Execution code

- (void)myTask {
    // Do something usefull in here instead of sleeping ...
    sleep(3);
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    CGFloat progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(50000);
    }
}

- (void)myMixedTask {
    // Indeterminate mode
    sleep(2);
    // Switch to determinate mode
	
	[HUD performChanges:^{
		HUD.mode = MBProgressHUDModeDeterminate;
		HUD.label.text = @"Progress";
	}];
	
    CGFloat progress = 0.0f;
    while (progress < 1.0f)
    {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(50000);
    }
    // Back to indeterminate mode
	[HUD performChanges:^{
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.label.text = @"Cleaning up";
	}];
	
    sleep(2);
	
	[HUD performChanges:^{
		HUD.customView = MBProgressHUDSuccessImageView;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.label.text = @"Completed";
	}];
	
	sleep(2);
}

#pragma mark - NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedLength = [response expectedContentLength];
	currentLength = 0;
	HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	currentLength += [data length];
	HUD.progress = currentLength / (CGFloat)expectedLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	HUD.customView = MBProgressHUDSuccessImageView;
    HUD.mode = MBProgressHUDModeCustomView;
	[HUD hide:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[HUD hide:YES];
}

@end
