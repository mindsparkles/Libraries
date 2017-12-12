//
//  MediaViewController.m
//  FxMediaPicker
//
//  Created by Macmini5 on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "MediaViewController.h"
#import "LibraryViewController.h"
#import "PhotoViewController.h"

@interface MediaViewController ()

@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (readonly, strong, nonatomic) NSArray *pageData;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIViewController *libraryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LibraryViewController"];
    libraryViewController.view.tag=0;
    
    PhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.titleString = @"Photo";
    photoViewController.view.tag=1;
    
    PhotoViewController *videoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    videoViewController.titleString = @"Video";
    videoViewController.isVideoMode = YES;
    videoViewController.view.tag=2;
    
    _pageData = @[libraryViewController,photoViewController,videoViewController];//[[dateFormatter monthSymbols] copy];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.delegate = self;

    UIViewController *startingViewController = [self.pageData objectAtIndex:0];
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

//    self.pageViewController.dataSource = self;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }else{
        pageViewRect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-44);
    }
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.tabBarController.tabBar.hidden = YES;
    [self setupButtonUIForIndex:0];
    [self changePage:UIPageViewControllerNavigationDirectionReverse atIndex:0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Methods
- (IBAction)onClickButton:(UIButton*)sender {
    
    if (sender.tag == 0) {
        [self changePage:UIPageViewControllerNavigationDirectionReverse atIndex:sender.tag];

    }else if (sender.tag==1){
        if (self.libraryButton.enabled) {
            [self changePage:UIPageViewControllerNavigationDirectionReverse atIndex:sender.tag];
        }else{
            [self changePage:UIPageViewControllerNavigationDirectionForward atIndex:sender.tag];
        }
    }else if (sender.tag==2){
        [self changePage:UIPageViewControllerNavigationDirectionForward atIndex:sender.tag];
    }
    [self setupButtonUIForIndex:sender.tag];
    
}
-(void)setupButtonUIForIndex:(NSInteger)index{
    self.libraryButton.enabled=YES;
    self.photoButton.enabled=YES;
    self.videoButton.enabled=YES;
    
    if (index == 0) {
        self.libraryButton.enabled=NO;
    }else if (index==1){
        self.photoButton.enabled=NO;
    }else if (index==2){
        self.videoButton.enabled=NO;
    }
}
#pragma mark - Custom Methods

- (void)changePage:(UIPageViewControllerNavigationDirection)direction atIndex:(NSInteger)index {

//    if (direction == UIPageViewControllerNavigationDirectionForward){
//        index++;
//    }else {
//        index--;
//    }

    UIViewController *viewController = [self.pageData objectAtIndex:index];
    
    if (viewController == nil) {
        return;
    }
    
    [self.pageViewController setViewControllers:@[viewController] direction:direction animated:YES completion:nil];
}

//- (IBAction)previousButtonPressed:(id)sender {
//    [self changePage:UIPageViewControllerNavigationDirectionReverse];
//}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        [self setupButtonUIForIndex:currentViewController.view.tag];
        
        NSArray *viewControllers = @[currentViewController];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    LibraryViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = currentViewController.view.tag;
    [self setupButtonUIForIndex:indexOfCurrentViewController];
    
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    return UIPageViewControllerSpineLocationMid;
}

#pragma mark - Datasource
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    UIViewController *viewController = [self.pageData objectAtIndex:index];
    viewController.view.tag = index;
    //    dataViewController.dataObject = self.pageData[index];
    
//    if (index == 0) {
//        viewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
//        viewController.view.tag=0;
//    }else if (index == 1){
//        viewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
//        viewController.view.tag=1;
//    }else if (index == 2){
//        viewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
//        viewController.view.tag=2;
//    }
    
    return viewController;
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    
    return [self.pageData indexOfObject:viewController];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageData indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    [self setupButtonUIForIndex:index];
    
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageData indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    [self setupButtonUIForIndex:index];
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
