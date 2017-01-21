//
//  UserDataSingleton.m
//  TimeChat
//


#import "UserDataSingleton.h"
#import <UIKit/UIKit.h>
#import "Model/GeoPoint.h"

@implementation UserDataSingleton

static UserDataSingleton *sharedSingleton = NULL;

- (id)init
{
    self = [super init];
    if (self) {
        // Work your initialising magic here as you normally would
        
    }
    return self;
}

+ (UserDataSingleton *)sharedSingleton {
    if (!sharedSingleton || sharedSingleton == NULL) {
		sharedSingleton = [UserDataSingleton new];
        sharedSingleton.currMapZoomLevel = MAP_ZOOM_LEVEL;
        sharedSingleton.trafficIsEnabled = YES;
        sharedSingleton.trackArray = [[NSMutableArray alloc] init];
        sharedSingleton.currAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        sharedSingleton.currMapSpan = MKCoordinateSpanMake(0.02, 0.02);
	}

    return sharedSingleton;
}
#pragma mark - Public Methods
//-------------------------------------------------------------------------------------------------------------------------------------------------------$ dropMarker


- (void)AlertWithCancel_btn:(NSString *)msgString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"TrackaBuddy" message:msgString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        [alertView show];
    });
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)ResizeImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height
{
    CGSize size = CGSizeMake(width, height);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

#pragma mark - Parse Related Public Methods

- (void)signUpUser:(NSString *)username email:(NSString *)email password:(NSString *)password profile_image:(UIImage *)profile_image completion:(void (^)(BOOL finished, NSError *error))completion
{
    PFUser * signUpUser = [PFUser user];
    signUpUser.username = username;
    signUpUser.email = email;
    signUpUser.password = password;

    if (!profile_image) {
        profile_image = [UIImage imageNamed:@"profile.png"];
    }
    
    PFFile * avatarFile = [PFFile fileWithName:@"avatar.jpg" data:UIImageJPEGRepresentation(profile_image, 0.6f)];
    signUpUser[@"avatar"] = avatarFile;

    [signUpUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            completion(YES, nil);
        }
        else
            completion(NO, nil);
    }];
}

- (void)saveProfile:(NSString *)username email:(NSString *)email password:(NSString *)password profile_image:(UIImage *)profile_image  completion:(void (^)(BOOL finished, NSError *error))completion
{
    PFUser * currUser = [PFUser currentUser];

    currUser.username = username;
    currUser.email = email;
    
    if (!profile_image) {
        profile_image = [UIImage imageNamed:@"profile"];
    }
    
    PFFile * avatarImg = [PFFile fileWithName:@"profile.jpg" data:UIImageJPEGRepresentation(profile_image, 0.6f)];
    currUser[@"avatar"] = avatarImg;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                completion(YES, nil);
            }
            else {
                [currUser saveEventually];
                completion(NO, nil);
            }
        }];
    }
    else
    {
        [currUser saveEventually];
        completion(NO, nil);
    }
}

- (void)getMediasByTrip:(PFObject *)trip completion:(void (^)(BOOL, NSArray *, NSError *))completion
{
    PFQuery * query = [PFQuery queryWithClassName:PARSE_CLASS_MEDIAS];
    [query whereKey:@"track" equalTo:trip];
    [query whereKey:@"media_type" lessThan:[NSNumber numberWithInteger:3]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            completion(YES, objects, nil);
        }
        else
        {
            completion(NO, nil, error);
        }
    }];
}

- (void)getTripsByUser:(PFUser *)user trip_name:(NSString *)trip_name address:(NSString *)address fromDate:(NSDate *)from_date toDate:(NSDate *)to_date completion:(void (^)(BOOL, NSMutableArray *,  NSError *))completion
{
    NSMutableArray * tripArray = [[NSMutableArray alloc] init];
    
    PFQuery * query = [PFQuery queryWithClassName:PARSE_CLASS_TRACKLIST];
    
    [query whereKey:@"user" equalTo:user];
//    [query whereKey:@"name" notContainedIn:@[[NSNull null], @""]];
    [query includeKey:@"user"];

    if ([trip_name length] > 0)
        [query whereKey:@"name" containsString:trip_name];
    if ([address length] > 0)
        [query whereKey:@"address" containsString:address];
    if (from_date != nil)
        [query whereKey:@"start_datetime" greaterThanOrEqualTo:from_date];
    if (to_date != nil)
        [query whereKey:@"start_datetime" lessThanOrEqualTo:to_date];
    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject * object in objects) {
                [tripArray addObject:object];
            }
            completion(YES, tripArray, nil);
        }
        else
        {
            NSLog(@"Error : %@ userinfo : %@", error.description, [error userInfo]);
            completion(NO, nil, nil);
        }
    }];
}

- (void)getGeoPointsByTrip:(PFObject *)trip completion:(void (^)(BOOL finished, NSMutableArray * geopoint_array, NSError * error))completion;
{
    __block NSMutableArray * geoPointArray = [[NSMutableArray alloc] init];
    
    PFQuery * query = [PFQuery queryWithClassName:PARSE_CLASS_TRACKLOCATIONS];
    
    [query whereKey:@"track" equalTo:trip];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            geoPointArray = object[@"geo_point_array"];
            
            NSLog(@"GeoPoints Count : %ld", (unsigned long)[geoPointArray count]);
            
            completion(YES, geoPointArray,nil);
        }
        else
        {
            completion(NO, nil, error);
        }
    }];
}

#pragma mark - Track Methods

- (void)saveCurrentTrack:(void (^)(BOOL finished, NSError * error))completion
{
    PFObject * currTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];
    
    if (!currTrack) {
        PFObject * errorObject = [PFObject objectWithClassName:PARSE_CLASS_CRASHREPORT];
        errorObject[@"content"] = @"Failed to get current track object";
        [errorObject saveEventually];
        NSError * error = [NSError errorWithDomain:@"TrackaBuddy" code:ERROR_GET_CURRENTTRACK userInfo:nil];
        completion(NO, error);
    }
    
//    NSMutableArray * geoPointArray = [[NSMutableArray alloc] init];
//    geoPointArray = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;
    
    if ([UserDataSingleton sharedSingleton].currTrackGeoPointArray.count < CONDITION_REGION_COUNT) {
        NSError * error = [NSError errorWithDomain:@"TrackaBuddy" code:ERROR_GET_GEOPOINTARRAY userInfo:nil];
        completion(NO, error);
    }

    NSInteger last = [[UserDataSingleton sharedSingleton].trackArray count] - 1;
    NSInteger trafficMode = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_mode"] integerValue];
    NSDate * startDateTime = [[NSDate alloc] init];
    startDateTime = [UserDataSingleton sharedSingleton].currTrackStartDateTime;
    currTrack[@"traffic_mode"] = [NSNumber numberWithInteger:trafficMode];
    currTrack[@"start_datetime"] = startDateTime;
    currTrack[@"end_datetime"] = [NSDate date];
    currTrack[@"geo_point_array"] = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;
    currTrack[@"last"] = [NSNumber numberWithInteger:last];
    currTrack[@"version"] = [UserDataSingleton sharedSingleton].currAppVersion;
    currTrack[@"user"] = [PFUser currentUser];
    
//    NSLog(@"saveCurrentTrack------------------------------------------------------------------------------");
//    NSLog(@" name : %@" ,currTrack[@"name"]);
//    NSLog(@" address : %@" ,currTrack[@"address"]);
//    NSLog(@" start_datetime : %@" ,currTrack[@"start_datetime"]);
//    NSLog(@" end_datetime : %@" ,currTrack[@"end_datetime"]);
//    NSLog(@" Geopoint count: %ld", (long)[geoPointArray count]);
//    NSLog(@" Current Track: %@", currTrack);
//    NSLog(@"saveCurrentTrack------------------------------------------------------------------------------");
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        [currTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
                completion(YES, nil);
            else
            {
                [currTrack saveEventually];
                completion(NO, nil);
            }
        }];
    }
    else
    {
        [currTrack saveEventually];
        completion(NO, nil);
    }
}

- (void)saveCurrentTrackGeoPoints:(void (^)(BOOL finished, NSError *error))completion
{
    NSLog(@"count : %ld", (unsigned long)[[UserDataSingleton sharedSingleton].currTrackGeoPointArray count]);
    
    PFObject * currTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];
    
    currTrack[@"end_datetime"] = [NSDate date];
    [[UserDataSingleton sharedSingleton] saveCurrentTrack:^(BOOL finished, NSError *error) {
        if (finished) {
            NSLog(@"current Track saved");
        }
    }];
    
    PFObject * currTrackLocations = [UserDataSingleton sharedSingleton].currTrackLocations;
    currTrackLocations[@"geo_point_array"] = [UserDataSingleton sharedSingleton].currTrackGeoPointArray;
    currTrackLocations[@"track"] = currTrack;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        [currTrackLocations saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                completion(YES, nil);
            }
            else
            {
                [currTrackLocations saveEventually];
                completion(NO, nil);
            }
        }];
    }
    else
    {
        [currTrackLocations saveEventually];
        completion(NO, nil);
    }
}


- (void)saveMediaData:(PFFile *)file thumbnail:(PFFile *)thumbnail media_type:(NSInteger)media_type mediaURL:(NSString *)mediaURL duration:(NSString *)duration completion:(void (^)(BOOL, NSError *))completion
{
    PFObject * object = [PFObject objectWithClassName:PARSE_CLASS_MEDIAS];
    NSDate * current_date_time = [NSDate date];
    if ([UserDataSingleton sharedSingleton].currSocialGeoPoint == nil) {
        completion(NO, nil);
    }
    
    PFObject * currTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];
    
    object[@"geo_point"] = [UserDataSingleton sharedSingleton].currSocialGeoPoint;
    object[@"media_type"] = [NSNumber numberWithInteger:media_type];
    object[@"post_time"] = current_date_time;
    object[@"duration"] = duration;
    object[@"track"] = currTrack;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble && [UserDataSingleton sharedSingleton].currNetworkStatus == ReachableViaWiFi) {
        object[@"media_file"] = file;
        if (thumbnail) {
            object[@"thumbnail_file"] = thumbnail;
        }
        
        NetworkSpeedChecker * checker = [[NetworkSpeedChecker alloc] init];
        
        [checker determineNetworkStatus:^(BOOL isOnline) {
            if (isOnline) {
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                        completion(YES, nil);
                    else
                    {
                        object[@"local_file_url"] = mediaURL;
                        [object saveEventually];
                        completion(NO, nil);
                    }
                }];
            }
            else
            {
                object[@"local_file_url"] = mediaURL;
                
                [object saveEventually];
                completion(NO, nil);
            }
        }];
    }
    else
    {
        object[@"local_file_url"] = mediaURL;
        
        [object saveEventually];
        completion(NO, nil);
    }
}

- (void)saveImageData:(UIImage *)image completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion
{
    int width = image.size.width;
    float scale = width / PHOTO_FILE_WIDTH;
    UIImage * newImage;
    
//    if (scale > 1) {
//        float newWidth = PHOTO_FILE_WIDTH;
//        float newHeight = image.size.height / scale;
//        
//        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//        [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//        newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    else
        newImage = image;

    UIImage *thumbnail = [[UserDataSingleton sharedSingleton] ResizeImage:newImage width:THUMBNAIL_WIDTH height:THUMBNAIL_HEIGHT];
    PFFile * picture_file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(newImage, 1)];
    PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6f)];
    
    //Save to Album(TrackPhotos)
    //--------------------------------------------------------------------------------------------Save to Album
    
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];;
    __block NSString * mediaURL;
    
    [library saveImage:newImage toAlbum:@"TrackPhotos" successBlock:^(NSURL *assetURL) {
        NSLog(@"asset URL : %@", [assetURL absoluteString]);
        mediaURL = [assetURL absoluteString];
        
        [[UserDataSingleton sharedSingleton] saveMediaData:picture_file thumbnail:thumbnail_file media_type:1 mediaURL:mediaURL duration:@"" completion:^(BOOL finished, NSError *error) {
            if (finished) {
                completion(YES, nil, mediaURL);
            }
            else
            {
                completion(NO, nil, mediaURL);
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Big Error : %@", [error description]);
        completion(NO, error, nil);
    }];
    
    //--------------------------------------------------------------------------------------------Save to Album
}

- (void)saveVideoData:(NSData *)video videoURL:(NSURL *)videoURL completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion
{
    
    PFFile * video_file = [PFFile fileWithName:@"video.mp4" data:video];
    UIImage * thumbnail = [[UserDataSingleton sharedSingleton] ResizeImage:[self generateThumbnailImage:videoURL] width:THUMBNAIL_WIDTH height:THUMBNAIL_HEIGHT];
    PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6f)];
    
    //Save to Album(TrackVideos)
    //--------------------------------------------------------------------------------------------Save to Album
    
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];;
    __block NSString * mediaURL;
    
    [library saveVideo:videoURL toAlbum:@"TrackVideos" successBlock:^(NSURL *assetURL) {
        NSLog(@"Video Assets URL : %@", [assetURL absoluteString]);
        mediaURL = [assetURL absoluteString];
        
        AVURLAsset * sourceAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        CMTime duration = sourceAsset.duration;
        NSInteger seconds = (NSInteger)CMTimeGetSeconds(duration);
        NSString * durationStr = seconds > 9 ? [NSString stringWithFormat:@"0:%ld", (long)seconds] : [NSString stringWithFormat:@"0:0%ld", (long)seconds];
        
        NSLog(@"saving start");
        
        [[UserDataSingleton sharedSingleton] saveMediaData:video_file thumbnail:thumbnail_file media_type:2 mediaURL:mediaURL duration:durationStr completion:^(BOOL finished, NSError *error) {
            if (finished) {
                completion(YES, nil, mediaURL);
            }
            else
            {
                completion(NO, nil, mediaURL);
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error : %@", [error description]);
        completion(NO, error, nil);
    }];
    
    //--------------------------------------------------------------------------------------------Save to Album
}

- (void)saveAudioData:(NSData *)audio audioURL:(NSURL *)audioURL completion:(void (^)(BOOL finished, NSError *error, NSString * mediaURL))completion
{
    PFFile * audio_file = [PFFile fileWithName:@"audio.caf" data:audio];
    UIImage * thumb_image = [UIImage imageNamed:@"mic.png"];
    PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.png" data:UIImagePNGRepresentation(thumb_image)];
    NSString * url = [audioURL absoluteString];
    
    [[UserDataSingleton sharedSingleton] saveMediaData:audio_file thumbnail:thumbnail_file media_type:3 mediaURL:url duration:@"" completion:^(BOOL finished, NSError *error) {
        if (finished) {
            completion(YES, nil, url);
        }
        else
        {
            completion(NO, nil, url);
        }
    }];
}

- (void)saveNote:(NSString *)content completion:(void (^)(BOOL, NSError *))completion
{
    PFObject * currTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];

    PFObject * object = [PFObject objectWithClassName:@"Notes"];
    object[@"content"] = content;
    object[@"geo_point"] = [UserDataSingleton sharedSingleton].currSocialGeoPoint;
    object[@"track"] = currTrack;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        
        NetworkSpeedChecker * checker = [[NetworkSpeedChecker alloc] init];
        
        [checker determineNetworkStatus:^(BOOL isOnline) {
            if (isOnline) {
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                        completion(YES, nil);
                    else
                    {
                        [object saveEventually];
                        completion(NO, nil);
                    }
                }];
            }
            else
            {
                [object saveEventually];
                completion(NO, nil);
            }
        }];
    }
    else
    {
        [object saveEventually];
        completion(NO, nil);
    }
}

- (void)syncMediaData
{
    if ([UserDataSingleton sharedSingleton].isNetworkAble && [UserDataSingleton sharedSingleton].currNetworkStatus == ReachableViaWiFi) {
        NSLog(@"Sync Media Data");
        
        PFQuery * query = [PFQuery queryWithClassName:PARSE_CLASS_MEDIAS];
        [query whereKeyExists:@"local_file_url"];
        [query whereKey:@"local_file_url" notEqualTo:@""];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"Successfully retrieved %ld rows", (unsigned long)[objects count]);
                
                for (PFObject * object in objects) {
                    
                    if ([object[@"media_type"] integerValue] == 1) {
                    
                        NSString * mediaurl = object[@"local_file_url"];
                        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                        {
                            if (myasset) {
                                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                                CGImageRef iref = [rep fullResolutionImage];
                                if (iref) {
                                    UIImage * image = [UIImage imageWithCGImage:iref];
                                    UIImage *thumbnail = [[UserDataSingleton sharedSingleton] ResizeImage:image width:THUMBNAIL_WIDTH height:THUMBNAIL_HEIGHT];
                                    PFFile * picture_file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6f)];
                                    PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6f)];
                                    
                                    object[@"media_file"] = picture_file;
                                    if (thumbnail) {
                                        object[@"thumbnail_file"] = thumbnail_file;
                                    }
                                    object[@"local_file_url"] = @"";
                                }
                                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (!succeeded) {
                                        NSLog(@"Unable to sync");
                                        return;
                                    }
                                    
                                }];
                            }
                            else
                            {
                                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (!succeeded) {
                                        [object deleteEventually];
                                    }
                                }];
                            }
                            
                        };
                        
                        //
                        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
                        {
                            NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
                        };
                        
                        if(mediaurl && [mediaurl length])
                        {
                            NSURL *asseturl = [NSURL URLWithString:mediaurl];
                            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                            [assetslibrary assetForURL:asseturl
                                           resultBlock:resultblock
                                          failureBlock:failureblock];
                        }
                    }
                    else if ([object[@"media_type"] integerValue] == 2)
                    {
                        ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc] init];
                        NSString * mediaurl = object[@"local_file_url"];
                        NSURL * url = [NSURL URLWithString:mediaurl];
                        
                        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) // substitute YOURURL with your url of video
                         {
                             if (asset) {
                                 
                             
                                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                                 Byte *buffer = (Byte*)malloc(rep.size);
                                 NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(long)rep.size error:nil];
                                 NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];       //this is NSData may be what you want
                                 
                                 UIImage * thumbnail = [[UserDataSingleton sharedSingleton] ResizeImage:[self generateThumbnailImage:url] width:THUMBNAIL_WIDTH height:THUMBNAIL_HEIGHT];
                                 PFFile * video_file = [PFFile fileWithName:@"video.mp4" data:data];
                                 PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6f)];
                                 
                                 if (sizeof(video_file) > 0) {
                                     object[@"media_file"] = video_file;
                                     object[@"thumbnail_file"] = thumbnail_file;
                                     object[@"local_file_url"] = @"";
                                     
                                     [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (!succeeded) {
                                             NSLog(@"Unable to sync");
                                             return;
                                         }
                                         
                                     }];
                                 }
                             }
                             else
                             {
                                 [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                     if (!succeeded) {
                                         [object deleteEventually];
                                     }
                                 }];
                             }
                         }
                         failureBlock:^(NSError *err) {
                             NSLog(@"Error: %@",[err localizedDescription]);
                         }];
                    }
                    else if ([object[@"media_type"] integerValue] == 3)
                    {
                        NSString * audioURL = object[@"local_file_url"];
                        NSURL * url = [NSURL URLWithString:audioURL];
                        
                        NSData *audioData = [NSData dataWithContentsOfURL:url options:0 error:NULL];
                        
                        PFFile * audio_file = [PFFile fileWithName:@"audio.caf" data:audioData];
                        UIImage * thumb_image = [UIImage imageNamed:@"mic.png"];
                        PFFile * thumbnail_file = [PFFile fileWithName:@"thumbnail.png" data:UIImagePNGRepresentation(thumb_image)];
                        
                        if (sizeof(audio_file) > 0) {
                            object[@"media_file"] = audio_file;
                            object[@"thumbnail_file"] = thumbnail_file;
                            object[@"local_file_url"] = @"";
                            
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!succeeded) {
                                    NSLog(@"Unable to sync");
                                    return;
                                }
                            }];
                        }
                    }
                }
            }
        }];
    }
    else
    {
        NSLog(@"Network Error!");
    }
}

- (void)saveCrashReport:(NSString *)error_content
{
    PFObject * object = [PFObject objectWithClassName:PARSE_CLASS_CRASHREPORT];
    object[@"content"] = error_content;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Crash Report saved!");
            }
        }];
    }
    else
    {
        [object saveEventually];
    }
}


-(UIImage *)generateThumbnailImage : (NSURL *)filepath
{
    AVAsset *asset = [AVAsset assetWithURL:filepath];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0
                                       orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    //    thumbNail = thumbnail;
    return thumbnail;
}

- (NSString *)getUUIDString
{
    return [[NSUUID UUID] UUIDString];
}

- (void)saveCurrentTrack1:(void (^)(BOOL, BOOL, NSString *))completion
{
    NSLog(@"saveCurrentTrack1");
    
    NSString * uuid = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackUUID];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    
    AppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"GeoPoint" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSPredicate * pridicate = [NSPredicate predicateWithFormat:@"uuid=%@", uuid];
    
    [request setPredicate:pridicate];
    [request setSortDescriptors:sortDescriptors];
    
    NSError * error = nil;
    
    NSMutableArray * mutableFetchResults = [[[self sharedManagedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        NSLog(@"CoreData result NO!");
        completion(NO, NO, @"Can't get track data");
        return;
    }
    
    if ([mutableFetchResults count] < 10) {
        NSLog(@"Can't save current track");
        completion(NO, NO, @"Can't save current track.");
        return;
    }
    
    NSLog(@"GeoPoint Count on Core Data %ld", (long)[mutableFetchResults count]);
    
    NSMutableArray * geoPointArray = [[NSMutableArray alloc] init];
    
    for (GeoPoint * point in mutableFetchResults) {
        NSLog(@"uuid : %@, lat : %f, long : %f", point.uuid, [point.latitude doubleValue], [point.longitude doubleValue]);
        NSMutableArray * pointItem = [[NSMutableArray alloc] initWithCapacity:2];
        [pointItem addObject:[NSNumber numberWithDouble:[point.latitude doubleValue]]];
        [pointItem addObject:[NSNumber numberWithDouble:[point.longitude doubleValue]]];
        
        [geoPointArray addObject:pointItem];
    }
    
    NSString * trackTitle = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackTitle];
    NSDate * startDateTime = [[NSDate alloc] init];
    startDateTime = [UserDataSingleton sharedSingleton].currTrackStartDateTime;
    NSInteger trafficMode = [[[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_mode"] integerValue];
    
//    PFObject * newTrack = [PFObject objectWithClassName:PARSE_CLASS_TRACKLIST];
    PFObject * newTrack = [[UserDataSingleton sharedSingleton].trackArray lastObject];
    
    newTrack[@"name"] = trackTitle;

    if ([UserDataSingleton sharedSingleton].currTrackAddress != nil) {
        NSString * trackAddress = [NSString stringWithFormat:@"%@", [UserDataSingleton sharedSingleton].currTrackAddress];
        newTrack[@"address"] = trackAddress;
    }

    newTrack[@"traffic_mode"] = [NSNumber numberWithInteger:trafficMode];
    newTrack[@"start_datetime"] = startDateTime;
    newTrack[@"end_datetime"] = [NSDate date];
    newTrack[@"geo_point_array"] = geoPointArray;
    newTrack[@"version"] = [UserDataSingleton sharedSingleton].currAppVersion;
    newTrack[@"user"] = [PFUser currentUser];
    newTrack[@"uuid"] = uuid;
    
    if ([UserDataSingleton sharedSingleton].isNetworkAble) {
        NetworkSpeedChecker * checker = [[NetworkSpeedChecker alloc] init];
        
        [checker determineNetworkStatus:^(BOOL isOnline) {
            if( isOnline )
            {
                [newTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        completion(YES, YES, nil);
                    }
                }];
            }
            else
            {
                [newTrack saveEventually];
                completion(NO, YES, nil);
            }
        }];
    }
    else
    {
        [newTrack saveEventually];
        completion(NO, YES, nil);
    }
    
    //temp
    
//    NSLog(@"Saving the Speed Data");
//    
//    for (NSMutableDictionary * dic in [UserDataSingleton sharedSingleton].speedArray) {
//        PFObject * speedObj = [PFObject objectWithClassName:@"Speed"];
//        
//        speedObj[@"speed"] = [dic objectForKey:@"speed"];
//        speedObj[@"accuracy"] = [dic objectForKey:@"accuracy"];
//        speedObj[@"uuid"] = [dic objectForKey:@"uuid"];
//        speedObj[@"time"] = [dic objectForKey:@"time"];
//        
//        if ([UserDataSingleton sharedSingleton].isNetworkAble) {
//            [speedObj saveInBackground];
//        }
//        else
//            [speedObj saveEventually];
//    }
    
    //temp
    
//    NSInteger last = [[UserDataSingleton sharedSingleton].trackArray count] - 1;
//    currTrackObject[@"last"] = [NSNumber numberWithInteger:last];
}

- (void)deleteTrack:(PFObject *)track completion:(void (^)(BOOL finished, NSError * error))completion
{
    if (track) {
        if ([UserDataSingleton sharedSingleton].isNetworkAble) {
            
            NetworkSpeedChecker * checker = [[NetworkSpeedChecker alloc] init];
            
            [checker determineNetworkStatus:^(BOOL isOnline) {
                if (isOnline) {
                    [track deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded)
                            completion(YES, nil);
                        else
                            completion(NO, error);
                    }];
                }
                else
                {
                    [track deleteEventually];
                }
            }];
        }
        else
        {
            [track deleteEventually];
        }
        completion(YES, nil);
    }
    else
    {
        NSMutableDictionary * errorDic = [NSMutableDictionary dictionary];
        [errorDic setValue:@"Can't find this track" forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:@"TrackaBuddy" code:200 userInfo:errorDic];
        completion(NO, error);
    }
}

- (void)renameTrack:(PFObject *)track name:(NSString *)replaceName completion:(void(^)(BOOL isOnline, BOOL finished, NSError * error))completion
{
    if (track) {
        track[@"name"] = replaceName;
        if ([UserDataSingleton sharedSingleton].isNetworkAble) {
            
            NetworkSpeedChecker * checker = [[NetworkSpeedChecker alloc] init];
            
            [checker determineNetworkStatus:^(BOOL isOnline) {
                if (isOnline) {
                    [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            completion(YES, YES, nil);
                        }
                        else
                            completion(YES, NO, error);
                    }];
                }
                else
                {
                    [track saveEventually];
                    completion(NO, YES, nil);
                }
            }];
        }
        else
        {
            [track saveEventually];
            completion(NO, YES, nil);
        }
    }
    else
    {
        NSMutableDictionary * errorDic = [NSMutableDictionary dictionary];
        [errorDic setValue:@"Can't find this track" forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:@"TrackaBuddy" code:200 userInfo:errorDic];
        completion(NO, NO, error);
    }
}

#pragma mark - NetworkSpeedCheckDelegate Methods

- (void)speedChecker:(NetworkSpeedChecker *)cheker didDecidedOnline:(BOOL)online
{
}

@end
