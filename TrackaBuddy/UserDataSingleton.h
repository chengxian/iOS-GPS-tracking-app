//
//  UserDataSingleton.h
//  TrackaBuddy
//

#import "LocationTracker.h"
#import "MGSwipeTableCell.h"
#import "NetworkSpeedChecker.h"
#import "Reachability.h"

//NSString * g_EditTripName;
//NSString * g_Note;

@interface UserDataSingleton : NSObject<NetworkSpeedCheckerDelegate>

//Etc
@property (strong, nonatomic) NSUserDefaults *              userDefaults;
@property (strong, nonatomic) PFUser *                      currUser;

@property (assign, nonatomic) BOOL                          isNetworkAble;
@property (assign, nonatomic) NetworkStatus                 currNetworkStatus;
@property (strong, nonatomic) NSString *                    documentDirectory;
@property (strong, nonatomic) NSString *                    currAppVersion;

@property (assign, nonatomic) UIDeviceOrientation           currDeviceOrientation;
@property (assign, nonatomic) UIDeviceOrientation           orientationWhenCaptured;


//Screen Bounds
//--------------------------------------------------------------------------------

@property (assign, nonatomic) NSInteger                     screenWidth;
@property (assign, nonatomic) NSInteger                     screenHeight;

//--------------------------------------------------------------------------------


//ImagePickerView
//--------------------------------------------------------------------------------

@property (nonatomic, strong) UIImagePickerController *     appImagePicker;
@property (nonatomic, strong) NSString *                    strPhotoOptions;
@property (nonatomic, strong) NSString *                    strEditIndex;
@property (nonatomic, strong) UIImage *                     imgOriginal;
@property (nonatomic, strong) NSData *                      MediaData;
@property (nonatomic, assign) BOOL                          boolAddPhoto;
@property (nonatomic, strong) NSMutableArray *              arrImageData;
@property (nonatomic, retain) NSMutableArray *              arrAlAssistData;
@property (nonatomic, strong) NSMutableDictionary *         dictData;
@property (nonatomic, strong) NSMutableDictionary *         dictSelect;
@property (nonatomic, assign) NSInteger                     imgIndex;

//--------------------------------------------------------------------------------


//Location Tracker
//--------------------------------------------------------------------------------

@property (assign, nonatomic) GMSMapViewType                mapType;
@property (assign, nonatomic) MKCoordinateSpan              currMapSpan;
@property (nonatomic, assign) BOOL                          trackisStartable;
@property (nonatomic, assign) BOOL                          trackisEnding;
@property (strong, nonatomic) LocationTracker *             currLocationTracker;
@property (nonatomic, assign) BOOL                          trackIsStarted;
@property (strong, nonatomic) PFObject *                    currTrack;
@property (strong, nonatomic) PFObject *                    currTrackLocations;
@property (strong, nonatomic) NSMutableDictionary *         currTrackDic;
@property (strong, nonatomic) NSString *                    currTrackUUID;
@property (strong, nonatomic) NSMutableArray *              trackArray;
@property (strong, nonatomic) NSMutableArray *              currTrackGeoPointArray;
@property (strong, nonatomic) PFGeoPoint *                  currSocialGeoPoint;
@property (strong, nonatomic) CLLocation *                  currLocation;
@property (strong, nonatomic) GMSMutablePath *              currTrackPath;

@property (strong, nonatomic) NSMutableArray *              currTrackCoordinateArray;

@property (strong, nonatomic) NSMutableArray *              currPinArray;
@property (assign, nonatomic) CGFloat                       currMapZoomLevel;
@property (assign, nonatomic) BOOL                          trafficIsEnabled;
@property (strong, nonatomic) NSDate *                      currTrackStartDateTime;
@property (strong, nonatomic) NSString *                    currTrackAddress;
@property (strong, nonatomic) NSString *                    currTrackTitle;
@property (strong, nonatomic) NSString *                    noteStr;

//--------------------------------------------------------------------------------

//CoreData
@property (strong, nonatomic) NSManagedObjectContext *      sharedManagedObjectContext;


//Remember Login
//--------------------------------------------------------------------------------

@property (nonatomic, assign) BOOL                          isRemember;

//--------------------------------------------------------------------------------

//Shared Variable
//--------------------------------------------------------------------------------

+ (UserDataSingleton *)sharedSingleton;

//--------------------------------------------------------------------------------

//Alert View
//--------------------------------------------------------------------------------

- (void)AlertWithCancel_btn:(NSString*)msgString;

//--------------------------------------------------------------------------------


//Resize Image
//--------------------------------------------------------------------------------

- (UIImage *) squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

- (UIImage *) ResizeImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;

//--------------------------------------------------------------------------------


//Save Track Data
//--------------------------------------------------------------------------------
- (void)signUpUser:(NSString *)username email:(NSString *)email password:(NSString *)password profile_image:(UIImage *)profile_image completion:(void (^)(BOOL finished, NSError *error))completion;

- (void)saveProfile:(NSString *)username email:(NSString *)email password:(NSString *)password profile_image:(UIImage *)profile_image completion:(void (^)(BOOL finished, NSError *error))completion;

- (void)saveCurrentTrack:(void (^)(BOOL finished, NSError *error))completion;

- (void)saveCurrentTrackGeoPoints:(void (^)(BOOL finished, NSError *error))completion;

- (void)saveMediaData:(PFFile *)file thumbnail:(PFFile *)thumbnail media_type:(NSInteger)media_type mediaURL:(NSString *)mediaURL duration:(NSString *)duration completion:(void (^)(BOOL finished, NSError *error))completion;

- (void)saveImageData:(UIImage *)image completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion;

- (void)saveVideoData:(NSData *)video videoURL:(NSURL *)videoURL completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion;

- (void)saveAudioData:(NSData *)audio audioURL:(NSURL *)audioURL completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion;

- (void)saveNote:(NSString *)content completion:(void (^)(BOOL finished, NSError * error))completion;

- (void)syncMediaData;

- (void)getMediasByTrip:(PFObject *)trip completion:(void (^)(BOOL finished, NSArray * array, NSError * error))completion;

- (void)getTripsByUser:(PFUser *)user trip_name:(NSString *)trip_name address:(NSString *)address fromDate:(NSDate *)from_date toDate:(NSDate *)to_date completion:(void (^)(BOOL finished, NSMutableArray * trip_array,  NSError * error))completion;

- (void)getGeoPointsByTrip:(PFObject *)trip completion:(void (^)(BOOL finished, NSMutableArray * geopoint_array, NSError * error))completion;

- (void)saveCrashReport:(NSString *)error_content;

- (void)saveCurrentTrack1: (void (^)(BOOL isOnline, BOOL finished, NSString * errString))completion;

- (void)deleteTrack:(PFObject *)track completion:(void (^)(BOOL finished, NSError * error))completion;

- (void)renameTrack:(PFObject *)track name:(NSString *)replaceName completion:(void(^)(BOOL isOnline, BOOL finished, NSError * error))completion;
//--------------------------------------------------------------------------------

//Get UUID
//--------------------------------------------------------------------------------

- (NSString *)getUUIDString;

//--------------------------------------------------------------------------------


@end

//--------------------------------DEFINE VARIABLES-------------------------------//


//Google Map Credential
//--------------------------------------------------------------------------------

#define GOOGLE_MAP_API_KEY              @"AIzaSyBvPKcL6KmfzD11NUrvGN9PeUJp6qzhZ1I"
#define GOOGLE_MAP_API_KEY1             @"AIzaSyBJi4W0Ycxp0P6J2YVDAaggdEiiUbQd9dE"
#define MAP_ZOOM_LEVEL                  14
#define CENTER_LAT                      27.8912539
#define CENTER_LONG                     78.07923319999998

//--------------------------------------------------------------------------------


//Parse.com Credential
//--------------------------------------------------------------------------------

#define PARSE_APP_ID                    @"tBmsLNOT6CtvLSFYduyr3FqtAlFYtxOLohfOqm5r"
#define PARSE_CLIENT_KEY                @"UTAg6qrYQTvLo296oBHwSyS5Dn9ijcWCVdd8MM7m"

//--------------------------------------------------------------------------------


//Weather API
//--------------------------------------------------------------------------------

#define WEATHER_API_KEY                 @"7d30fe039f34d4d9"
#define WEATHER_BASE_URL                @"http://api.wunderground.com/api/"

typedef NS_ENUM(NSUInteger, ActionType) {
    ActionTypeGetWeatherCondition,
    ActionTypeGetFuelPrices
};

//--------------------------------------------------------------------------------


//Image Size
//--------------------------------------------------------------------------------

#define PHOTO_FILE_WIDTH                280
#define PHOTO_FILE_HEIGHT               280

#define THUMBNAIL_WIDTH                 120
#define THUMBNAIL_HEIGHT                120

//--------------------------------------------------------------------------------


//Local Notifications
//--------------------------------------------------------------------------------

#define START_TRIP_NOTIFICATION         @"startTrip"
#define END_TRIP_NOTIFICATION           @"endTrip"
#define NOTIFICATION_ENTER_BACKGROUND   @"enterBackgroundNotification"
#define NOTIFICATION_ENTER_FOREGROUND   @"enterForegroundNotification"


//--------------------------------------------------------------------------------


//Tags
//--------------------------------------------------------------------------------

#define TRAFFIC_ENABLE_SWITCH_TAG               101
#define MAP_TYPE_SEGMENTCONTROL_TAG             102
#define TRAFFIC_MODE_SEGMENTCONTROL_TAG         103
#define ACCURACY_SEGMENTCONTROL_TAG             104

#define COLLECTIONVIEWCELL_IMAGE_TAG            201
#define COLLECTIONVIEWCELL_LABEL_TAG            202
#define COLLECTIONVIEWCELL_VIDEO_ICON_TAG       203

//--------------------------------------------------------------------------------

//Location
//--------------------------------------------------------------------------------

#define LATITUDE                        @"latitude"
#define LONGITUDE                       @"longitude"
#define ACCURACY                        @"theAccuracy"

#define IS_OS_8_OR_LATER                ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define LOCATION_UPDATE_COUNT_INTERVAL  1
#define LOCATION_UPDATE_TIME_INTERVAL   30
#define LOCATION_UPLOAD_COUNT_INTERVAL  3

#define MAP_PADDING                     1.1
#define MINIMUM_VISIBLE_LATITUDE        0.01

#define MARKER_TYPE                     @[ @"", @"start", @"end", @"pic", @"video", @"audio", @"note" ]
#define MARKER_START                    1
#define MARKER_END                      2
#define MARKER_PIC                      3
#define MARKER_VIDEO                    4
#define MARKER_AUDIO                    5
#define MARKER_NOTE                     6

#define TRAFFIC_MODE                    @[@0, @10, @50, @150]
#define ACCURACY_MODE                   @[@0, @30, @100, @150, @2000]
#define START_POINT_INTERVAL            1
#define CONDITION_REGION_COUNT          6
//--------------------------------------------------------------------------------

#define APP_CURRENT_VERSION             @"1.0.1"

#define CELL_SWIPE_TRANSITION           @[@MGSwipeTransitionBorder, @MGSwipeTransitionStatic, @MGSwipeTransitionClipCenter, @MGSwipeTransitionDrag, @MGSwipeTransition3D]

//Parse Class Names
//--------------------------------------------------------------------------------

//#define PARSE_CLASS_TRACKLIST           @"TrackList"
#define PARSE_CLASS_TRACKLIST           @"TrackTestList"
#define PARSE_CLASS_TRACKLOCATIONS      @"TrackLocations"
#define PARSE_CLASS_MEDIAS              @"Medias"
#define PARSE_CLASS_NOTES               @"Notes"
#define PARSE_CLASS_CRASHREPORT         @"CrashReport"

//--------------------------------------------------------------------------------

//NetworkSpeed Check
//--------------------------------------------------------------------------------

//#define MIN_DOWNLOAD_QTY_PER_SEC        2000
#define MIN_DOWNLOAD_QTY_PER_SEC        100

//--------------------------------------------------------------------------------


//Error Numbers
//--------------------------------------------------------------------------------
#define ERROR_GET_CURRENTTRACK          300
#define ERROR_GET_GEOPOINTARRAY         301
//--------------------------------------------------------------------------------


//Others
//--------------------------------------------------------------------------------

#define ERROR_LOGIN  0
#define SUCCESS_LOGIN  1
#define SUCCESS_LOGOUT  6
#define SUCCESS_QUERY  7

//--------------------------------------------------------------------------------


