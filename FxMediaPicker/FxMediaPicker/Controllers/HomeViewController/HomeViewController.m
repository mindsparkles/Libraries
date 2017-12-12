//
//  HomeViewController.m
//  FxMediaPicker
//
//  Created by Samkit Shah on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "HomeViewController.h"
#import "MediaViewController.h"
#import <StoreKit/StoreKit.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Methods
- (IBAction)onClickOpenMediaPicker:(id)sender {
    
    MediaViewController *mediaController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:VIEWCONTROLLER_MEDIAPICKER];
    
    [self presentViewController:mediaController animated:YES completion:nil];
}
- (IBAction)onClickRating:(id)sender {
    if([SKStoreReviewController class]){
        [SKStoreReviewController requestReview] ;
    }
}

- (IBAction)onClickReview:(id)sender {
    
    //https://itunes.apple.com/au/app/lmcc-alerts/id785074809?mt=8#?action=write-review
    
    NSString *iTunesLink = @"https://itunes.apple.com/au/app/lmcc-alerts/id785074809?mt=8#?action=write-review";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
}

@end
