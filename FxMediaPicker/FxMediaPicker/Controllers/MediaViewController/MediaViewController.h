//
//  MediaViewController.h
//  FxMediaPicker
//
//  Created by Macmini5 on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

