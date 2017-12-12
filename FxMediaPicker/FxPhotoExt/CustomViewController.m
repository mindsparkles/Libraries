//
//  PhotoEditingViewController.m
//  FxPhotoExt
//
//  Created by Samkit on 11/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "CustomViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@interface CustomViewController () <PHContentEditingController>
@property (strong) PHContentEditingInput *input;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return NO;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    
    [self.imageView setImage:placeholderImage];
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    self.input = contentEditingInput;
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.
    
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        
        UIImage *imageGrayScale = [self convertImageToGrayScale:self.imageView.image];
        
        // Provide new adjustments and render output to given location.
//         output.adjustmentData = renderedJPEGData;
        
        NSData *renderedJPEGData = UIImageJPEGRepresentation(imageGrayScale, 1.0);
        ;
        output.adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"com.fx.yoga.FxMediaPicker.FxPhotoExt" formatVersion:@"1.0" data:renderedJPEGData];
        
         [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
        
        // Call completion handler to commit edit to Photos.
        completionHandler(output);
        
        // Clean up temporary files, etc.
    });
}

- (BOOL)shouldShowCancelConfirmation {
    // Returns whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, you should return YES if there are any unsaved changes.)
    return NO;
}

- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}
- (IBAction)onClickSepia:(id)sender {
}
- (IBAction)onClickMono:(id)sender {
}
- (IBAction)onClickInvert:(id)sender {
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
//    image = [self rotateImage:image];//THIS IS WHERE REPAIR THE ROTATION PROBLEM
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

@end
