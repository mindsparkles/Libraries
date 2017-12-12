//
//  DisplayViewController.m
//  FxMediaPicker
//
//  Created by Samkit Shah on 1/10/17.
//  Copyright © 2017 Macmini5. All rights reserved.
//

#import "DisplayViewController.h"
#import "MediaViewController.h"
#import "PhotoCVCell.h"
#import "NMRangeSlider.h"

@interface DisplayViewController ()
//UIX

@property (weak, nonatomic) IBOutlet NMRangeSlider *standardSlider;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *videoTrimView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;

//Data
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong, nonatomic) NSMutableArray *videoImages;

@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoImages = [[NSMutableArray alloc] init];
    
    if (self.selectedImage) {
        [self.imageView setImage:self.selectedImage];
    }
    if (self.selectedVideoURL) {
        self.collectionView.hidden = NO;
        self.playButton.hidden = NO;
        [self playVideoWithURL:self.selectedVideoURL];
        [self generateThumbImage:self.selectedVideoURL];
    }else{
        self.collectionView.hidden = YES;
        self.playButton.hidden = YES;
    }
    
//    [self.standardSlider setLowerHandleImageNormal:[UIImage imageNamed:@""]];
//    [self.standardSlider setUpperHandleImageNormal:[UIImage imageNamed:@""]];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [self.avPlayer pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Methods
- (IBAction)onClickDone:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickPlay:(UIButton*)sender {
    
    [self.playButton setImage:[UIImage imageNamed:@"take"] forState:UIControlStateSelected];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    self.playButton.selected = !sender.selected;
    
    if (self.playButton.selected) {
        
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.videoSlider setValue:0.0f animated:YES];
        //    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [self.avPlayer play];
    }else{
        [self.avPlayer pause];
    }
}

- (void)updateTime:(NSTimer *)timer {
    
    CMTime currentTime = self.avPlayer.currentTime;
    float duration = CMTimeGetSeconds(currentTime);
    self.videoSlider.value = duration;
}

-(void)playVideoWithURL:(NSURL*)videoUrl{
    
    if(videoUrl){
        
        self.avPlayer=[[AVPlayer alloc] initWithURL:videoUrl];
        
        self.avPlayerLayer = [AVPlayerLayer layer];
        [self.avPlayerLayer setPlayer:self.avPlayer];
        [self.avPlayerLayer setFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
        [self.avPlayerLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        
//        [self.avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.imageView.layer addSublayer:self.avPlayerLayer];
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
      
//        [self.avPlayer play];
    }
}
#pragma mark - Slider Events
- (IBAction)sliderValueChanged:(id)sender {
    
    CMTime playerDuration = self.avPlayer.currentItem.asset.duration;
    double duration = CMTimeGetSeconds(playerDuration);

    CMTime newTime = CMTimeMakeWithSeconds(self.videoSlider.value * duration , self.avPlayer.currentTime.timescale);

    [self.avPlayer seekToTime:newTime];
    [self.avPlayer pause];
}
- (IBAction)trimmerValueChanged:(NMRangeSlider*)sender {
    
    NSLog(@"sender.lowerValue-->%f",sender.lowerValue);
    NSLog(@"sender.upperValue-->%f",sender.upperValue);
}


#pragma mark - Collection View Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"trimCell";
    
    PhotoCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImage *imageToShow = [self.videoImages objectAtIndex:indexPath.row];
    
    if (imageToShow) {
        cell.photoImageView.image = imageToShow;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIImage *imageToShow = [self.videoImages objectAtIndex:indexPath.row];
    
    if (imageToShow) {
        self.imageView.image = imageToShow;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

-(void)generateThumbImage : (NSURL *)filepath
{
    AVAsset *asset = [AVAsset assetWithURL:filepath];
    self.imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    Float64 duration = CMTimeGetSeconds([asset duration]);
    for(Float64 i = 0.0; i<duration; i=i+0.2)
    {
        CGImageRef imgRef = [self.imageGenerator copyCGImageAtTime:CMTimeMake(i, duration) actualTime:NULL error:nil];
        UIImage* thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
        [self.videoImages addObject:thumbnail];
        CGImageRelease(imgRef);

        if (self.videoImages.count == duration) {
            [self.collectionView reloadData];
            return;
        }
    }
}

-(void)generateImageArrayFromVideo:(NSURL*)videoURL{

    if (self.videoImages.count>0) [self.videoImages removeAllObjects];
    
    AVAsset *myAsset = [AVAsset assetWithURL:videoURL];
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    
    Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
    int totalDuration = (int)durationSeconds;
    int skipValue = durationSeconds/20;
    
    //    NSMutableArray *timesFixed;
    if (totalDuration > 20) {
        for (int i=1; i<=20; i++) {
            if (skipValue == i/skipValue) {
                
            }
        }
    }
    
    CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds/3.0, 600);
    CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, 600);
    CMTime threeThird = CMTimeMakeWithSeconds(durationSeconds*3.0/3.0, 600);
    CMTime fourthThird = CMTimeMakeWithSeconds(durationSeconds*4.0/3.0, 600);
    CMTime fifthThird = CMTimeMakeWithSeconds(durationSeconds*5.0/3.0, 600);
    CMTime sixthThird = CMTimeMakeWithSeconds(durationSeconds*6.0/3.0, 600);
    CMTime end = CMTimeMakeWithSeconds(durationSeconds, 600);
    
    NSArray *times = @[[NSValue valueWithCMTime:kCMTimeZero],[NSValue valueWithCMTime:firstThird], [NSValue valueWithCMTime:secondThird],[NSValue valueWithCMTime:threeThird],[NSValue valueWithCMTime:fourthThird],[NSValue valueWithCMTime:fifthThird],[NSValue valueWithCMTime:sixthThird],[NSValue valueWithCMTime:end]];
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                             AVAssetImageGeneratorResult result, NSError *error) {
                                             
                                             NSString *requestedTimeString = (NSString *)
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
                                             NSString *actualTimeString = (NSString *)
                                             CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                                             NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
                                             
                                             if (result == AVAssetImageGeneratorSucceeded) {
                                                 // Do something interesting with the image.
                                                 UIImage *imageToAdd=[UIImage imageWithCGImage:image];
//                                                 CGImageRelease(image);
                                                 
                                                 [self.videoImages addObject:imageToAdd];
                                                 
                                                 if (self.videoImages.count == 6) {
                                                     [self.collectionView reloadData];
                                                 }
                                             }
                                             
                                             if (result == AVAssetImageGeneratorFailed) {
                                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                                             }
                                             if (result == AVAssetImageGeneratorCancelled) {
                                                 NSLog(@"Canceled");
                                             }
                                         }];
    
    if (self.videoImages.count>0) [self.collectionView reloadData];
    
}

- (void) configureStandardSlider
{
    self.standardSlider.lowerValue = 0.23;
    self.standardSlider.upperValue = 0.53;
}

@end
