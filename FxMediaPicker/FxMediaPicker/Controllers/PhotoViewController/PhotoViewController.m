//
//  PhotoViewController.m
//  FxMediaPicker
//
//  Created by Macmini5 on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "PhotoViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PECropViewController.h"
#import <Photos/Photos.h>
#define CAPTURE_FRAMES_PER_SECOND		20

#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1.12412
//iphone screen dimensions
//#define SCREEN_WIDTH  320
//#define SCREEN_HEIGTH 480

#define VIDEO_MINIMUM_LENGTH 5
#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width

static int videoCounter;

@interface PhotoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureFileOutputRecordingDelegate, PECropViewControllerDelegate>
{
    BOOL WeAreRecording;
    MPMoviePlayerController * moviePlayer;
    NSURL *outputVideoPath;
    int videoLength;
}
//UIX
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraModeButton;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIProgressView *videoProgressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captureButtonCenter;

//Data
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) UIImage *bufferCaptureImage;
@property (nonatomic, strong) NSTimer *myTimer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
    if (self.isVideoMode) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        self.capturedImageView.userInteractionEnabled = YES;
        [self.capturedImageView addGestureRecognizer:tapGesture];
        self.nextButton.hidden = NO;
        self.nextButton.enabled = NO;
    }
    float cellWidth = DEVICE_WIDTH/4;
    self.viewHeight.constant = (cellWidth*2);
    videoCounter = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titleLabel.text = self.titleString;
    if (self.isFromProfile)self.captureButtonCenter.constant = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self openCameraInFronrMode:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];

    if (WeAreRecording)
        [self stopRecording];
    
    [self.session stopRunning];
}
#pragma mark - UINavigation Methods

-(void)captureNow {
    self.captureButton.enabled = NO;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        self.captureButton.enabled = YES;
        
        if (imageSampleBuffer == nil) return;
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (image!=nil) {
            if (self.isFromProfile || self.isFromEditPost) {
                NSDictionary* infoDict = [NSDictionary dictionaryWithObject:image forKey:API_KEY_PROFILEIMAGE];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatePostPhoto object:nil userInfo:infoDict];
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                
                image = [self imageByScalingToMaxSize:image];
                
                // present the cropper view controller
//                FXImageCropController *imgCropperVC = [[FXImageCropController alloc] initWithImage:image cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
//                imgCropperVC.delegate = self;
//                [self presentViewController:imgCropperVC animated:YES completion:nil];
                
                PECropViewController *controller = [[PECropViewController alloc] init];
                controller.delegate = self;
                controller.image = image;
                controller.cropRect = CGRectMake(0, 100.0f, DEVICE_WIDTH, DEVICE_WIDTH);
                
                UIImage *image1 = image;
                CGFloat width = image1.size.width;
                CGFloat height = image1.size.height;
                CGFloat length = MIN(width, height);
                controller.imageCropRect = CGRectMake((width - length) / 2,
                                                      (height - length) / 2,
                                                      length,
                                                      length);
                
                
                
                
                [self presentViewController:controller animated:YES completion:NULL];
            }
            
        }
    }];
}

-(void)openCameraInFronrMode:(BOOL)isFrontMode{
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
//    CALayer *viewLayer = self.cameraView.layer;
//    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = CGRectMake(self.cameraView.frame.origin.x, self.cameraView.frame.origin.y, DEVICE_WIDTH, self.cameraView.frame.size.height);
    [self.cameraView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *selectedDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (selectedDevice)
    {
        
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (isFrontMode) {
                if ([device position] == AVCaptureDevicePositionFront) {
                    selectedDevice = device;
                }
            }else{
                if ([device position] == AVCaptureDevicePositionBack) {
                    selectedDevice = device;
                }
            }
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:selectedDevice error:&error];
        
        if (!input) {
            // Handle the error appropriately.
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        
        if ([self.session canAddInput:input])
            [self.session addInput:input];
        else
            NSLog(@"Couldn't add video input");

        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        
        if ([self.session canAddOutput:output])
            [self.session addOutput:output];
        else
            NSLog(@"Couldn't add video output");
        
        // Configure your output.
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        
        // Specify the pixel format
        output.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        self.session.sessionPreset = AVCaptureSessionPresetMedium;
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.session addOutput:self.stillImageOutput];
        
        if (self.isVideoMode) {
            //ADD MOVIE FILE OUTPUT
            NSLog(@"Adding movie file output");
            self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
            
            Float64 TotalSeconds = 60;			//Total seconds
            int32_t preferredTimeScale = 30;	//Frames per second
            CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
            self.movieFileOutput.maxRecordedDuration = maxDuration;
            
            self.movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
            
            if ([self.session canAddOutput:self.movieFileOutput])
                [self.session addOutput:self.movieFileOutput];
            
            //ADD AUDIO INPUT
            NSLog(@"Adding audio input");
            AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            NSError *error = nil;
            AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
            if (audioInput)
            {
                [self.session addInput:audioInput];
            }
            
            [self CameraSetOutputProperties];
        }
        
        [self.session startRunning];
    }
    else
    {
        NSLog(@"Couldn't create video capture device");
    }
}


- (IBAction)onClickCapture:(UIButton*)sender {
    
    [self performSelector:@selector(setCapturedImage) withObject:nil afterDelay:1.0];
}
-(void)setCapturedImage{
    
    UIImage *imageToSet =self.bufferCaptureImage;
    
    if ((self.isFromProfile || self.isFromEditPost) && !self.isVideoMode) {
        
        [self captureNow];
        
    }else{
        if (self.isVideoMode) {
            if (WeAreRecording) {
                
                self.capturedImageView.image = imageToSet;
                [self stopRecording];
            }else{
                self.nextButton.enabled = NO;
                [self.captureButton setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
                WeAreRecording=YES;
                //----- START RECORDING -----
                NSLog(@"START RECORDING");
                WeAreRecording = YES;
                
                //Create temporary URL to record to
                NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
                NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:outputPath])
                {
                    NSError *error;
                    if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
                    {
                        //Error - handle if requried
                    }
                }
                
                //Start recording
                [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
                self.videoProgressView.hidden = NO;
                self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];
            }
            
        }else{
            [self captureNow];
        }
    }
}
-(void)stopRecording{

    self.nextButton.enabled = YES;
    self.capturedImageView.hidden = NO;
    videoLength = videoCounter;
    videoCounter=0;
    WeAreRecording=NO;
    self.videoProgressView.progress=0.f;
    NSLog(@"STOP RECORDING");
    WeAreRecording = NO;
    [self.myTimer invalidate];
    self.myTimer = nil;
    [self.movieFileOutput stopRecording];
    self.captureButton.enabled = YES;
    [self.captureButton setImage:[UIImage imageNamed:@"take"] forState:UIControlStateNormal];
}
-(void)dismisView{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapPress:(UITapGestureRecognizer*)gesture {

    if (WeAreRecording)
        return;
    
    if (outputVideoPath) {
        [self playVideoWithURL:outputVideoPath];
    }
}

- (IBAction)onClickCameraMode:(UIButton*)sender {
    [self stopRecording];
    
    sender.selected = !sender.selected;
//    [self openCameraInFronrMode:sender.selected];
    self.cameraModeButton.enabled = NO;
    if (!self.session) return;
    
    [self.session beginConfiguration];
    
    AVCaptureDeviceInput *currentCameraInput;
    
    // Remove current (video) input
    for (AVCaptureDeviceInput *input in self.session.inputs) {
        if ([input.device hasMediaType:AVMediaTypeVideo]) {
            [self.session removeInput:input];
            
            currentCameraInput = input;
            break;
        }
    }
    
    if (!currentCameraInput) return;
    
    // Switch device position
    AVCaptureDevicePosition captureDevicePosition = AVCaptureDevicePositionUnspecified;
    
    if (sender.selected) {
        captureDevicePosition = AVCaptureDevicePositionFront;
    } else {
        captureDevicePosition = AVCaptureDevicePositionBack;
    }
    
    // Select new camera
    AVCaptureDevice *newCamera;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *captureDevice in devices) {
        if (captureDevice.position == captureDevicePosition) {
            newCamera = captureDevice;
        }
    }
    
    if (!newCamera) return;
    
    // Add new camera input
    NSError *error;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&error];
    if (!error && [self.session canAddInput:newVideoInput]) {
        [self.session addInput:newVideoInput];
    }
    
    [self.session commitConfiguration];
    
    self.cameraModeButton.enabled = YES;
}
- (IBAction)onClickCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickNext:(id)sender {
    
    if (videoLength<VIDEO_MINIMUM_LENGTH){
//        showAlertWithTitleWithoutAction(ALERT_VIEW_TITLE, @"Please record video with minimum length of 5 seconds.", ALERT_BUTTON_TITLE_OK);
        return;
    }
    
    UIImage *imageToSet = self.bufferCaptureImage;
    if (self.isFromEditPost) {
        if (self.isVideoMode && outputVideoPath){
            if (imageToSet!=nil){
                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          imageToSet, API_KEY_PROFILEIMAGE, outputVideoPath, @"outputVideoPath", nil];//[NSDictionary dictionaryWithObject:imageToSet forKey:API_KEY_PROFILEIMAGE];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatePostPhoto object:nil userInfo:infoDict];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }else{
//        
//        AddPostController *addPostController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ADDPOST];
//        addPostController.media = imageToSet;
//        addPostController.delegate = self;
//        addPostController.videoUrl = outputVideoPath;
//        [self.navigationController pushViewController:addPostController animated:YES];

    }
    
}

// Delegate routine that is called when a sample buffer was written
#pragma mark - Delegate routine that is called when a sample buffer was written

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    self.bufferCaptureImage = [self imageFromSampleBuffer:sampleBuffer];
    
//    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
//    self.bufferCaptureImage = [[UIImage alloc] initWithData:imageData];

}
//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    self.nextButton.enabled = YES;
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        //----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     
                 }else{
                     
//                     NSDictionary *settings = @{AVVideoCodecKey:AVVideoCodecH264,
//                                                AVVideoWidthKey:@(DEVICE_WIDTH),
//                                                AVVideoHeightKey:@(DEVICE_WIDTH),
//                                                AVVideoCompressionPropertiesKey:
//                                                    @{AVVideoAverageBitRateKey:@(1048576),
//                                                      AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31, /* Or whatever profile & level you wish to use */
//                                                      AVVideoMaxKeyFrameIntervalKey:@(1)}};
//                     
//                     AVAssetWriterInput* writer_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
             
                     outputVideoPath = outputFileURL;
                     
                     self.bufferCaptureImage=getImageFromVideoUrl(outputFileURL);
//                     [self playVideoWithURL:outputFileURL];
                     self.capturedImageView.image = self.bufferCaptureImage;//[UIImage imageNamed:@"play"];
                 }
             }];
        }
        
    }
}

#pragma mark - Custom Methods

-(void)playVideoWithURL:(NSURL*)videoUrl{
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    [self.capturedImageView addSubview:moviePlayer.view];
    moviePlayer.fullscreen = YES;
    [moviePlayer play];
}
// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}
- (void)updateUI:(NSTimer *)timer
{
    videoCounter++;
    
    if (videoCounter <=20 && WeAreRecording)
    {
//        self.progressLabel.text = [NSString stringWithFormat:@"%d %%",count*10];
        self.videoProgressView.progress = (float)videoCounter/20.0f;
    } else
    {
        [self stopRecording];
    }
}

//********** CAMERA SET OUTPUT PROPERTIES **********
- (void) CameraSetOutputProperties
{
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *CaptureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    [CaptureConnection setVideoOrientation:orientation];
    
    //Set frame rate (if requried)
//    CMTimeShow(CaptureConnection.videoMinFrameDuration);
//    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
//    
//    if (CaptureConnection.supportsVideoMinFrameDuration)
//        CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//    if (CaptureConnection.supportsVideoMaxFrameDuration)
//        CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//    
//    CMTimeShow(CaptureConnection.videoMinFrameDuration);
//    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_IMAGE_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_IMAGE_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_IMAGE_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_IMAGE_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_IMAGE_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    //    [controller dismissViewControllerAnimated:YES completion:NULL];
    //    self.videoImageView.image = croppedImage;
    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //        [self updateEditButtonEnabled];
    //    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
//    AddPostController *addPostController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ADDPOST];
//    addPostController.media = croppedImage;
//    addPostController.delegate = self;
//    [self.navigationController pushViewController:addPostController animated:YES];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
}
@end

