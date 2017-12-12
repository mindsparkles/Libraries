//
//  CommonMethods.h
//  ClickAndSend
//
//  Created by Macmini5 on 12/5/16.
//  Copyright © 2016 Macmini5. All rights reserved.
//

#ifndef CommonMethods_h
#define CommonMethods_h

#import <AVFoundation/AVFoundation.h>

inline static id sortArrayWithSortDescriptorKey(NSString * key, id arrayToSort) {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    arrayToSort = [NSMutableArray arrayWithArray:[arrayToSort sortedArrayUsingDescriptors:sortDescriptors]];
    
    return arrayToSort;
}

inline static BOOL validateEmail(NSString * candidate) {
    
    //    NSString *emailRegex = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}";
    NSString *emailRegex = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
inline static BOOL validateName(NSString * candidate) {
    
    NSString *firstnameRegex = @"[^\"?][-A-Za-z ']{0,40}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", firstnameRegex];
    return [phoneTest evaluateWithObject:candidate];
}
inline static BOOL validatePassword(NSString *candidate) {
    
    BOOL lowerCaseLetter = NO;
    BOOL upperCaseLetter = NO;
    BOOL digit = NO;
    BOOL specialCharacter = NO;
    
    if([candidate length] >= 8)
    {
        for (int i = 0; i < [candidate length]; i++)
        {
            unichar c = [candidate characterAtIndex:i];
            //NSLog(@"%c", c);
            
            if(!lowerCaseLetter) {
                lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!upperCaseLetter) {
                upperCaseLetter = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!digit) {
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
            }
            if(!specialCharacter) { //!@#$%^&*-_=+.?/><,"'`~\|[]{}‹›•¥£€
                specialCharacter = [[[NSCharacterSet alphanumericCharacterSet] invertedSet] characterIsMember:c];
            }
            
            if(specialCharacter && digit && lowerCaseLetter && upperCaseLetter) {
                return YES;
            }
        }
    } else {
        return NO;
    }
    return NO;
}

inline static void showAlertWithTitleWithoutAction(NSString *title, NSString *message, NSString *cancelButtonTitle) {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ALERT_BUTTON_TITLE_OK otherButtonTitles:nil];
//        if (message.length>0)
//            [alert show];
    });
}

inline static BOOL isObjectEmpty(id obj)
{
    if (obj == nil)
        return YES;
    if ([obj isEqual:[NSNull null]])
        return YES;
    if ([obj isEqual:@""])
        return YES;
    return NO;
}
inline static NSString* getNonNullValueFromAPI(NSString *value){
    
    if (value == nil)
        return @"";
    if ([value isEqual:[NSNull null]])
        return @"";
    if (![value isKindOfClass:[NSString class]]) {
        return @"";
    }
    return value;
}
inline static NSDictionary* nullFreeDictionary(NSDictionary *dictionary)
{
    NSMutableDictionary *tempDictionary = [dictionary mutableCopy];
    for (NSString *key in tempDictionary.allKeys) {
        NSString *value = [tempDictionary valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            if (value == (id)[NSNull null] || value == nil || value.length == 0) {
                [tempDictionary setValue:@"" forKey:key];
            }
        }
    }
    return tempDictionary;
}

inline static id getValueFromDictionary(NSDictionary *dictionary,NSString *key)
{
    if (!isObjectEmpty(dictionary))
    {
        if (!isObjectEmpty([dictionary valueForKey:key]))
        {
            return [dictionary valueForKey:key];
        }
    }
    return @"";
}

static inline NSString * applicationDocumentDirectory() {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

static inline NSString * timeStamp() {
    
    return [NSString stringWithFormat:@"%lld", [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue]];
}

inline static BOOL checkForCameraAccess()
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSLog(@"auth staus = %ld", (long)authStatus);
    if(authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    else {
        return NO;
    }
}

inline static UIImage* resizeImage(UIImage *image ,CGSize inSize)
{
    UIGraphicsBeginImageContext(inSize);
    [image drawInRect:CGRectMake(0,0,inSize.width,inSize.height)];
    UIImage* imgThumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgThumb;
    
}// resizeImage:

inline static BOOL isImagesEqual(UIImage *image1 ,UIImage *image2){
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

inline static NSString* removeWhiteSpaces(NSString* string){
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

inline static NSString* remaningTime(NSDate *startDate,NSDate*endDate)
{
    NSDateComponents *components;
    NSInteger days;
    NSInteger hour;
    NSInteger minutes;
    
    NSString *durationString;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDate = [df stringFromDate:startDate];
    
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate: startDate toDate: endDate options: 0];
    
    days = [components day];
    hour = [components hour];
    minutes = [components minute];
    
    if(days>0)
    {
        if(days==1)
            durationString=[NSString stringWithFormat:@"YESTERDAY"];
        else if(days>=2)
            durationString=[NSString stringWithFormat:@"%@",messageDate];
        
        return durationString;
    }
    if(hour>0)
    {
        if(hour>1)
            durationString=[NSString stringWithFormat:@"%d HOURS AGO",(int)hour];
        else
            durationString=[NSString stringWithFormat:@"%d HOUR AGO",(int)hour];
        return durationString;
    }
    if(minutes>0)
    {
        if(minutes>1)
            durationString = [NSString stringWithFormat:@"%d MINUTES AGO",(int)minutes];
        else
            durationString = [NSString stringWithFormat:@"%d MINUTE AGO",(int)minutes];
        
        return durationString;
    }else{
        durationString = [NSString stringWithFormat:@"JUST NOW"];
        return durationString;
    }
    return @"";
}

inline static BOOL validateUrl(NSString *candidate) {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

inline static UIImage* scaleAndRotateImage(UIImage *image)
{
    int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
inline static UIImage* getImageFromVideoUrl(NSURL *videoUrl)
{
    
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 2);
    NSError *error = NULL;
    CGImageRef refImg = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage *image=[UIImage imageWithCGImage:refImg];
    CGImageRelease(refImg);  // CGImageRef won't be released by ARC

    return image;
}

inline static NSString* convertToActualCoordinate(NSString *coordinate){
    //            640  50
    //            320 ?
    //            320*50/640 =
    
    NSArray *coordinates =[coordinate componentsSeparatedByString:@","];
    
    float xValue = [coordinates[0] floatValue];
    float yValue = [coordinates[1] floatValue];
    
    xValue = (DEVICE_WIDTH * xValue)/ORIGINAL_IMAGE_MAX_WIDTH;
    yValue = (DEVICE_WIDTH * yValue)/ORIGINAL_IMAGE_MAX_WIDTH;
    
    coordinate = [NSString stringWithFormat:@"%f,%f",xValue,yValue];
    
    return coordinate;
}

inline static NSString* convertToCommonCoordinate(NSString *coordinate){
    
    NSArray *coordinates =[coordinate componentsSeparatedByString:@","];
    
    float xValue = [coordinates[0] floatValue];
    float yValue = [coordinates[1] floatValue];
    
    xValue = (ORIGINAL_IMAGE_MAX_WIDTH * xValue)/DEVICE_WIDTH;
    yValue = (ORIGINAL_IMAGE_MAX_WIDTH * yValue)/DEVICE_WIDTH;
    
    coordinate = [NSString stringWithFormat:@"%f,%f",xValue,yValue];
    
    return coordinate;
}

#endif /* CommonMethods_h */
