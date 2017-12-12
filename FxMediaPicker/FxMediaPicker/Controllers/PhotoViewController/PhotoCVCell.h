//
//  PhotoCVCell.h
//  SafeworkID
//
//  Created by Macmini5 on 4/1/17.
//  Copyright © 2016 Fxbytes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCVCell : UICollectionViewCell

//UIX
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

//Data

//Methods
-(void)initData:(NSMutableDictionary*)photoDetail;

@end
