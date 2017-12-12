//
//  DataViewController.m
//  FxMediaPicker
//
//  Created by Macmini5 on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "LibraryViewController.h"
#import "PhotoCVCell.h"
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PECropViewController.h"
#import "DisplayViewController.h"

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width

@interface LibraryViewController ()<PECropViewControllerDelegate>
{
    BOOL showDurationLabel;
}
//UIX
@property (weak, nonatomic) IBOutlet UIImageView *selectedPhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

//Data
//@property (strong, nonatomic) NSMutableArray* photoItems;
@property (strong, nonatomic) NSMutableArray* originalPhotoItems;
@property (strong, nonatomic) NSURL *selectedVideoUrl;
@property (strong, nonatomic) NSDate *maxPhotoDate;
@property (strong, nonatomic) NSDate *minPhotoDate;
@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    showDurationLabel = YES;
    
    self.avPlayer = [AVPlayer new];
    
    // Do any additional setup after loading the view, typically from a nib.
    float cellWidth = DEVICE_WIDTH/4;
    self.collectionViewHeight.constant =(cellWidth*2);
    
//    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"dd.MM.yyyy"];
//    _maxPhotoDate = [formatter stringFromDate:_maxPhotoDate];
    
    if (self.index ==0)
        [self loadLibrary];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];

    if (self.avPlayer != nil && [self.avPlayer observationInfo]) {
        [self.avPlayer removeObserver:self forKeyPath:@"status"];
    }
    [self stopPlayer];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self playVideoWithURL:self.selectedVideoUrl];
}

#pragma mark -
#pragma mark - CollectionView delegate
#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.originalPhotoItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float cellWidth = DEVICE_WIDTH/4;
//    float cellHeight = cellWidth-(cellWidth*7)/100;
    
    return CGSizeMake(cellWidth,cellWidth);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
    
        PhotoCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCVCell" forIndexPath:indexPath];
        PHAsset *asset = [self.originalPhotoItems objectAtIndex:indexPath.row];
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            cell.playImageView.hidden = NO;
            
        }else{
            cell.playImageView.hidden = YES;
        }
        CGSize imageSize = CGSizeMake(210.0f, 210.0f); //PHImageManagerMaximumSize;
        
        if(SCREEN_MAX_LENGTH == 568.0){
            imageSize = CGSizeMake(140.0f, 140.0f);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.photoImageView.image = nil;
            
            [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                
                if (result!=nil)
                    cell.photoImageView.image = result;
            }];
        });
        
        cell.layer.borderWidth =0.3;
        cell.layer.borderColor =[[UIColor colorWithWhite:0.95 alpha:1] CGColor];
        
        return cell;        
    }@catch (NSException* exception) {
        NSLog(@"Uncaught exception-cell init %@", exception);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    }
}

//#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        PHAsset *asset = [self.originalPhotoItems objectAtIndex:indexPath.row];
        
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    NSURL *URL = [(AVURLAsset *)asset URL];
                    
                    if (showDurationLabel) {
                        float videoDurationSeconds = CMTimeGetSeconds(asset.duration);
                        
                        NSDate* date = [NSDate dateWithTimeIntervalSince1970:videoDurationSeconds];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                        [dateFormatter setDateFormat:@"HH:mm:ss"];  //you can vary the date string. Ex: "mm:ss"
                        NSString* result = [dateFormatter stringFromDate:date];
                        self.videoDurationLabel.text = result;
                        self.videoDurationLabel.hidden = NO;
                    }
                    self.selectedVideoUrl = URL;
                    [self playVideoWithURL:URL];
                    self.selectedPhotoImageView.image = getImageFromVideoUrl(URL);
                }
            }];
        }else{
            self.videoDurationLabel.hidden = YES;
            self.selectedVideoUrl=nil;
            [self stopPlayer];
            self.videoImageView.hidden = YES;
            self.selectedPhotoImageView.hidden = NO;
        }
        [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            
            self.selectedPhotoImageView.image = result;
            
        }];        
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception %@", exception);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    }
}
-(void)stopPlayer{
    
    [self.avPlayer pause];
//    if (self.avPlayer != nil && [self.avPlayer observationInfo]) {
//    }
//    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    [self.avPlayerLayer removeFromSuperlayer];
    self.playButton.hidden = YES;
    
}

-(void)loadLibrary{
    if(!_minPhotoDate){
        _minPhotoDate = [NSDate date];
    }
    _maxPhotoDate = [_minPhotoDate dateByAddingTimeInterval:-15*24*60*60];
    
    NSLog(@"max photo date = %@", _maxPhotoDate);
    
    if(!self.originalPhotoItems){
        self.originalPhotoItems =[NSMutableArray array];
    }
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];  //we are gathering data in the sort of creating date.
//    allPhotosOptions.fetchLimit = 250;
    
    if (self.isFromProfile)
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    else{
        if (self.isVideoMode && self.isFromEditPost) {
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
        }else if (!self.isVideoMode && self.isFromEditPost) {
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        }else{
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d OR mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
        }
    }
    
//    allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@ AND creationDate < %@",_maxPhotoDate,_minPhotoDate];
    
//    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];  //only Photos
    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithOptions:allPhotosOptions];  //only Photos
    PHAsset *asset;
    
    if (allPhotosResult != nil) {
        [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            
            [self.originalPhotoItems addObject:asset];
        }];
    }
    
    if (self.originalPhotoItems.count>0){
        if(self.videoImageView.image == nil){
            
            asset = [self.originalPhotoItems objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                    self.selectedPhotoImageView.image = result;
                    if (asset.mediaType == PHAssetMediaTypeVideo)
                    {
                        self.selectedPhotoImageView.hidden = YES;
                        self.videoImageView.hidden = NO;
                        self.playButton.hidden = NO;
                        
                        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                        options.version = PHVideoRequestOptionsVersionOriginal;
                        options.networkAccessAllowed = YES;
                        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                if (showDurationLabel) {
                                    
                                    float videoDurationSeconds = CMTimeGetSeconds(asset.duration);
                                    
                                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:videoDurationSeconds];
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                                    [dateFormatter setDateFormat:@"HH:mm:ss"];  //you can vary the date string. Ex: "mm:ss"
                                    NSString* result = [dateFormatter stringFromDate:date];
                                    self.videoDurationLabel.text = result;
                                    self.videoDurationLabel.hidden = NO;
                                }

                                NSURL *URL = [(AVURLAsset *)asset URL];
                                self.selectedVideoUrl = URL;
                                [self playVideoWithURL:URL];
                                self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
                                self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
                                self.selectedPhotoImageView.hidden = NO;
                                self.selectedPhotoImageView.image = getImageFromVideoUrl(URL);
                                self.videoImageView.image = getImageFromVideoUrl(URL);
                            }
                        }];
                    }
                }];
            });
        }
    }
    

//    CGSize imageSize = CGSizeMake(40.0f, 40.0f);//PHImageManagerMaximumSize
    
    
//    for (PHAsset *asset in self.originalPhotoItems) {
////        [self getImageForAsset:asset andTargetSize:PHImageManagerMaximumSize andSuccessBlock:^(UIImage *photoObj) {
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [self.photoItems addObject:photoObj];
////            });
////        }];
//        
////        if (self.photoItems.count == 125) {
////            NSLog(@"Limit cross - %ld",self.photoItems.count);
////            break;
////        }
//        NSLog(@"self.originalPhotoItems photos - %ld",self.originalPhotoItems.count);
//        NSLog(@"self.photoItems photos - %ld",self.photoItems.count);
//        
//        
//    }
    _minPhotoDate = [_maxPhotoDate copy];
    
    
    [_collectionView reloadData];
    
}

-(void) getImageForAsset: (PHAsset *) asset andTargetSize: (CGSize) targetSize andSuccessBlock:(void (^)(UIImage * photoObj))successBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *requestOptions;
        
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        requestOptions.synchronous = true;
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset
                           targetSize:targetSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            @autoreleasepool {
                                
                                if(image!=nil){
                                    successBlock(image);
                                }
                            }
                        }];
    });
}

#pragma mark - UIButton methods

- (IBAction)onClickImageMode:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.selectedPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }else{
        self.selectedPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
}
- (IBAction)onClickCancel:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dismisView{

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickDone:(id)sender {
    [self stopPlayer];

    UIImage *imageToSet=self.selectedPhotoImageView.image;
    
    if (self.isFromProfile){
        
//        [APPDELEGATE startLoading];
        [self performSelector:@selector(dismisView) withObject:self afterDelay:2.0];
        
    }else if (self.isFromEditPost) {
        
        NSDictionary* infoDict;
        if (self.selectedVideoUrl) {
            infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        imageToSet, API_KEY_PROFILEIMAGE, self.selectedVideoUrl, @"outputVideoPath", nil];
        }else{
            infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        imageToSet, API_KEY_PROFILEIMAGE, nil];
        }//[NSDictionary dictionaryWithObject:imageToSet forKey:API_KEY_PROFILEIMAGE];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatePostPhoto object:nil userInfo:infoDict];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else{
        
        if (self.selectedVideoUrl) {
            
            DisplayViewController *displayController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:VIEWCONTROLLER_DISPLAY];
            displayController.selectedVideoURL = self.selectedVideoUrl;
            [self presentViewController:displayController animated:YES completion:nil];

            //Navigate to display
        }else{
//            imageToSet  = [self imageByScalingToMaxSize:imageToSet];
            
            // present the cropper view controller
//            FXImageCropController *imgCropperVC = [[FXImageCropController alloc] initWithImage:imageToSet cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
//            imgCropperVC.delegate = self;
//            [self presentViewController:imgCropperVC animated:YES completion:nil];
            
            PECropViewController *controller = [[PECropViewController alloc] init];
            controller.delegate = self;
            controller.image = imageToSet;
            controller.cropRect = CGRectMake(0, 100.0f, DEVICE_WIDTH, DEVICE_WIDTH);
            
            UIImage *image = imageToSet;
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            CGFloat length = MIN(width, height);
            controller.imageCropRect = CGRectMake((width - length) / 2,
                                                  (height - length) / 2,
                                                  length,
                                                  length);

            
           
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
    
    
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

-(void)playVideoWithURL:(NSURL*)videoUrl{
    
    if(videoUrl){
        self.selectedPhotoImageView.hidden = NO;
        self.videoImageView.image = nil;
        self.videoImageView.hidden = NO;
        self.playButton.hidden = NO;
        
//        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.

        [self stopPlayer];

        self.avPlayer=[self.avPlayer initWithURL:videoUrl];
        
        self.avPlayerLayer = [AVPlayerLayer layer];
        [self.avPlayerLayer setPlayer:self.avPlayer];
        [self.avPlayerLayer setFrame:CGRectMake(self.videoImageView.frame.origin.x, self.videoImageView.frame.origin.y, self.videoImageView.frame.size.width, self.videoImageView.frame.size.height)];
        [self.avPlayerLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [self.videoImageView setBackgroundColor:[UIColor clearColor]];
//        [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoImageView.layer addSublayer:self.avPlayerLayer];
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        [self.avPlayer play];

    }
}

- (IBAction)onClickPlayButton:(id)sender {

    self.selectedPhotoImageView.hidden = YES;
    self.playButton.hidden = YES;
    [self.avPlayer play];
    self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

#pragma mark - Custom Methods

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    self.playButton.hidden = NO;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    NSLog(@"self.avPlayer.status %ld",self.avPlayer.status);
    
    if (object == self.avPlayer && [keyPath isEqualToString:@"status"]) {
        
        if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
            self.playButton.hidden = NO;
            
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        } else if (self.avPlayer.status == AVPlayerStatusFailed) {
            self.playButton.hidden = YES;
            
            // something went wrong. player.error should contain some information
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }
}


//-(NSString*)getDurationFromAsset:(PHAsset*)asset{
//    
//    float videoDurationSeconds = CMTimeGetSeconds(asset.duration);
//    
//    NSDate* date = [NSDate dateWithTimeIntervalSince1970:videoDurationSeconds];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [dateFormatter setDateFormat:@"HH:mm:ss"];  //you can vary the date string. Ex: "mm:ss"
//    NSString* result = [dateFormatter stringFromDate:date];
//    return result;
////    NSLog(@"asset.duration - %@",result);
//}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
//    [controller dismissViewControllerAnimated:YES completion:NULL];
//    self.videoImageView.image = croppedImage;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [self updateEditButtonEnabled];
//    }
    
    //Navigate to display view.
    
//    [controller dismissViewControllerAnimated:YES completion:nil];
//    AddPostController *addPostController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:VIEWCONTROLLER_ADDPOST];
//    addPostController.media = croppedImage;
//    addPostController.delegate = self;
//    addPostController.videoUrl = self.selectedVideoUrl;
//    [self.navigationController pushViewController:addPostController animated:YES];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    
}
@end

