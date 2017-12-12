//
//  CommonMacros.h
//  FXCommon
//
//  Created by Macmini5 on 12/5/16.
//  Copyright © 2016 Macmini5. All rights reserved.
//

#ifndef CommonMacros_h
#define CommonMacros_h


#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

//FXMediaPicker

#define VIEWCONTROLLER_HOME             @"HomeViewController"
#define VIEWCONTROLLER_MEDIAPICKER          @"MediaViewController"
#define VIEWCONTROLLER_DISPLAY          @"DisplayViewController"

//FXMediaPicker

typedef enum
{
    kHorseDetailTypeOwner = 0,
    kHorseDetailTypeVideo,
    kHorseDetailTypeTrackWork,
    kHorseDetailTypePhoto,
    kHorseDetailTypeCurrentVet,
    kHorseDetailTypeNutritions,
    kHorseDetailTypeVetHistory,
    kHorseDetailTypeWater,
    kHorseDetailTypeCurrentFarrier,
    kHorseDetailTypeStrapper,
    kHorseDetailTypeFarrierHistory,
    kHorseDetailTypeRaceHistory,
    kHorseDetailTypePool,
    kHorseDetailTypeSpecialRequirements,
    kHorseDetailTypeWeight,
    kHorseDetailTypeDailyRoutine,
    kHorseDetailTypeNominations,
    kHorseDetailTypeRaceDay,
    kHorseDetailTypeAcceptances,
    kHorseDetailTypeGear
    
} Weekday;

typedef enum
{
    STABLE_ADMIN   =   1,
    TRAINER        =   2,
    OWNER          =   3,
    STABLEHAND     =   4,
    STRAPPER       =   5,
    OTHER          =   6
    
}UserType;

static NSString *kNotificationUpdatePostPhoto                       = @"kNotificationUpdatePostPhoto";
static NSString *kNotificationUpdateHorseData                       = @"kNotificationUpdateHorseData";
static NSString *kNotificationUpdateTagData                       = @"kNotificationUpdateTagData";

static NSString *kMediaTypeImage                       = @"image";
static NSString *kMediaTypeVideo                       = @"video";

#define MAIN_STORYBOARD         [UIStoryboard storyboardWithName:@"Main" bundle: nil]

#define MAX_IAMGE_SIZE 1000
#define ORIGINAL_IMAGE_MAX_WIDTH 640.0f

#define QUALITY_IMAGE 0.7
#define MAX_IAMGE_THUMB_SIZE 100
#define TIMEOUTSECONDS 90

#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CELL_HEIGHT 66.0f

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define COLOR_WITH_rgba(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define ROBOTO_REGULAR  @"Roboto-Regular"
#define ROBOTO_MEDIUM   @"Roboto-Medium"
#define ROBOTO_LIGHT    @"Roboto-Light"
#define ROBOTO_ITALIC   @"Roboto-MediumItalic"

#define LIGHT_FONT_WITH_SIZE(x)     [UIFont fontWithName:ROBOTO_LIGHT size:x]
#define REGULAR_FONT_WITH_SIZE(x)   [UIFont fontWithName:ROBOTO_REGULAR size:x]
#define MEDIUM_FONT_WITH_SIZE(x)    [UIFont fontWithName:ROBOTO_MEDIUM size:x]
#define ITALIC_FONT_WITH_SIZE(x)    [UIFont fontWithName:ROBOTO_ITALIC size:x]

#define ICON_DOWN_ARROW     @"down_arrow"
#define ICON_RIGHT_ARROW    @"right_arrow"

#define MENU_HORSE_SELECTED     @"menu_horse_selected"
#define MENU_STAFF_SELECTED     @"menu_staff_selected"
#define MENU_ACCOUNT_SELECTED   @"menu_account_selected"
#define MENU_OWNERS_SELECTED    @"menu_owner_selected"
#define MENU_PROFILE_SELECTED    @"menu_profile_selected"

#define MENU_NEUTRITION_SELECTED    @"menu_neutrition_selected"
#define MENU_VETERINARY_SELECTED    @"menu_veterinary_selected"
#define MENU_TRAINERS_SELECTED      @"menu_trainers_selected"
#define MENU_HOME_SELECTED          @"menu_home_selected"
#define DATE_FORMATE @"dd/MM/yyyy"
#define DATE_TIME_FORMATE @"YYYY-MM-dd HH:mm:ss"//yyyy-MM-dd HH:mm:ss

#define KEY_MESSAGE @"msg"

#define KEY_IMAGE_PATH @"image_path"
#define KEY_STATUS @"status"

#define IS_IPAD  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define ALERT_BUTTON_TITLE_YES    @"YES"
#define ALERT_BUTTON_TITLE_NO    @"NO"
#define ALERT_BUTTON_TITLE_OK    @"OK"
#define ALERT_VIEW_TITLE         @"Alert"

#define APP_VERSION_STRING        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define IS_IOS10 ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
#define APPDELEGATE             ((AppDelegate *)[[UIApplication sharedApplication] delegate])


#define VIEWCONTROLLER_HOME             @"HomeViewController"
#define VIEWCONTROLLER_LOGIN            @"LoginController"
#define VIEWCONTROLLER_CHANGEPASSWORD   @"ChangePasswordController"
#define VIEWCONTROLLER_STAFFLIST        @"StaffListController"
#define VIEWCONTROLLER_HORSESLIST       @"HorsesListController"
#define VIEWCONTROLLER_ACCOUNTLIST      @"AccountsListController"
#define VIEWCONTROLLER_INVOICEDETAIL    @"InvoiceDetailController"
#define VIEWCONTROLLER_OWNERSLIST       @"OwnersListController"
#define VIEWCONTROLLER_OWNERDETAIL      @"OwnerDetailController"
#define VIEWCONTROLLER_HORSE_SUBDETAIL  @"HorseSubDetailController"
#define VIEWCONTROLLER_PROFILELIST      @"ProfileListController"
#define VIEWCONTROLLER_PROFILEDETAIL    @"ProfileDetailController"


#define VIEWCONTROLLER_GENERALPOST      @"GeneralPostController"
#define VIEWCONTROLLER_ADDPOST          @"AddPostController"


#define VIEWCONTROLLER_CAMERAVIEW          @"PhotoViewController"
#define VIEWCONTROLLER_LIBRARYVIEW          @"LibraryViewController"

#define VIEWCONTROLLER_TAGHORSESVIEW          @"TagHorsesController"


#define VIEWCONTROLLER_HORSEDETAIL      @"HorseDetailController"
#define VIEWCONTROLLER_HORSEITEMDETAIL  @"HorseItemDetailController"
#define VIEWCONTROLLER_GEARLIST         @"GearListController"
#define VIEWCONTROLLER_FARRIER          @"FarrierController"
#define VIEWCONTROLLER_PHOTO            @"PhotoController"


//-----Common Strings-------------------------

#define POST_TYPE_GENERAL @1

//-----API Macros-------------------------

#define API_KEY_STATUS      @"status"
#define API_KEY_MESSAGE     @"message"
#define API_KEY_USER_DATA   @"userData"
#define API_KEY_HORSE_DATA  @"horseData"
#define API_KEY_HORSE_DETAIL  @"horseDetails"
#define API_KEY_STAFF_DATA  @"staffData"
#define API_KEY_POST_DATA  @"postData"
#define API_KEY_ID  @"id"
#define API_KEY_POST_DATE  @"createdDate"


#define API_KEY_GENERAL_SERVER_ERROR                    @"NSLocalizedDescription"


#define API_KEY_NAME        @"name"
#define API_KEY_FIRSTNAME   @"firstname"
#define API_KEY_LASTNAME    @"lastname"
#define API_KEY_IMAGE       @"image"
#define API_KEY_USER_EMAIL              @"email"
#define API_KEY_MOBILENUMBER              @"mobileNumber"
#define API_KEY_PROFILEIMAGE              @"profileImage"


#define API_KEY_USER_PASSWORD           @"password"
#define API_KEY_USER_CURRENT_PASSWORD   @"current_password"
#define API_KEY_USER_NEW_PASSWORD       @"new_password"

#define API_KEY_POST_COMMENT    @"comment"
#define API_KEY_POST_TYPE       @"postType"
#define API_KEY_MEDIA       @"media"
#define API_KEY_HORSEID       @"horseId"
#define API_KEY_LOCATION       @"location"
#define API_KEY_MEDIATYPE       @"mediaType"
#define API_KEY_TAGDATA       @"tagData"
#define API_KEY_TAGID       @"tagId"
#define API_KEY_ISDELETE       @"isDelete"
#define API_KEY_XYCOORDINATE       @"xyCoordinate"


#define BASE_IMAGE_URL @"http://fxbytes.com/Client/cas/"

#define USERTYPE    @"userType"
#define USERID      @"userId"
#define POSTID      @"postId"

#define EMAIL       @"email"
#define PASSWORD    @"password"

#endif /* CommonMacros_h */
