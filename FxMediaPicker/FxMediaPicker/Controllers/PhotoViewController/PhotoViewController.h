//
//  PhotoViewController.h
//  FxMediaPicker
//
//  Created by Macmini5 on 1/11/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOTAL_SLIDES 4

@interface PhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;
@property (strong, nonatomic) NSString *titleString;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) BOOL isVideoMode;
@property (assign, nonatomic) BOOL isFromProfile;
@property (assign, nonatomic) BOOL isFromEditPost;

@end

