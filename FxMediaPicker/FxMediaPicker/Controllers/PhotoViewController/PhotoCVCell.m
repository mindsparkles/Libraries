//
//  PhotoCVCell.m
//  SafeworkID
//
//  Created by Macmini5 on 4/1/17.
//  Copyright © 2016 Fxbytes. All rights reserved.
//

#import "PhotoCVCell.h"
@interface PhotoCVCell()
{
    NSMutableDictionary *photoDetailDictionary;
}

//Data

@end

@implementation PhotoCVCell

- (IBAction)onClickPhotoButton:(id)sender {
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)initData:(NSMutableDictionary*)photoDetail{
    photoDetailDictionary = photoDetail;
    
//    NSURL *imageURL = [NSURL URLWithString:[photoDetail valueForKey:API_KEY_CATEGORY_ICON]];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    UIImage *image = [UIImage imageWithData:imageData];

//    if (image != nil) self.imageView.image=image;
//    if (imageURL != nil) self.imageView.imageURL=imageURL;
    
//    self.imageTitle.text = [photoDetail valueForKey:API_KEY_CATEGORY_TITLE];
    
}

@end
