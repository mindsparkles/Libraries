//
//  LibraryViewController.h
//  FxMediaPicker
//
//  Created by Macmini5 on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOTAL_SLIDES 4

@protocol DataViewControllerDelegate <NSObject>

//@required
//
//- (IBAction)nextButtonPressed:(id)sender;

@end

@interface LibraryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;
@property (assign, nonatomic) BOOL isFromProfile;
@property (assign, nonatomic) BOOL isFromEditPost;
@property (assign, nonatomic) BOOL isVideoMode;

@property (assign, nonatomic) NSInteger index;
@property (nonatomic,strong) id<DataViewControllerDelegate> delegate;

@end

