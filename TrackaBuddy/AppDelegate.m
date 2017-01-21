//
//  AppDelegate.m
//  TrackaBuddy
//
//  Created by Alexander on 10/07/15.
//  Copyright (c) 2015 Shirong Huang. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <MoPub/MoPub.h>
#import "LocationCount.h"
#import "TrackList.h"

#import "NetworkSpeedChecker.h"

static NSString * const kRecipesStoreName = @"DB.sqlite";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)testHowToSaveAndGetArrayToCoreData
{
    NSMutableArray * geoPointArray = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 4000; i++) {
        NSMutableArray * geoPoint = [[NSMutableArray alloc] initWithCapacity:2];
        [geoPoint addObject:[NSNumber numberWithDouble:i * 10]];
        [geoPoint addObject:[NSNumber numberWithDouble:i * 10 + 1]];
        
        [geoPointArray addObject:geoPoint];
    }
    

    TrackList * trackList = [TrackList MR_createEntity];

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        TrackList * localTrackList = [TrackList MR_createEntityInContext:localContext];
        localTrackList.uuid = @"2-2-2-3";
        localTrackList.geoPointArray = geoPointArray;
    } completion:^(BOOL contextDidSave, NSError *error) {
       if(contextDidSave)
       {
           NSLog(@"contextDidSave");
           
           NSArray * trackLists = [TrackList MR_findAll];
           NSLog(@"count : %ld", [trackLists count]);
       }
        
        if (error != nil) {
            NSLog(@"Error : %@", error.description);
        }
    }];

    
    TrackList * trackList1 = [TrackList MR_findFirstByAttribute:@"uuid" withValue:@"2-2-2-10"];

    if (trackList1) {
        NSMutableArray * geoPointArray1 = trackList1.geoPointArray;
        
        NSLog(@"geoPointArray1 count : %ld", [geoPointArray1 count]);
        for (int j = 0; j < [geoPointArray1 count]; j ++) {
            NSMutableArray * geoPoint = [geoPointArray1 objectAtIndex:j];
            NSLog(@"index : %d, Lat : %f , Long : %f", j, [geoPoint[0] doubleValue], [geoPoint[1] doubleValue]);
        }
    }
}

- (void) copyDefaultStoreIfNecessary;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:kRecipesStoreName];
    
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]])
    {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[kRecipesStoreName stringByDeletingPathExtension] ofType:[kRecipesStoreName pathExtension]];
        
        if (defaultStorePath)
        {
            NSError *error;
            BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                NSLog(@"Failed to install default recipe store");
            }
        }
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //crash report setting
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    [self copyDefaultStoreIfNecessary];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:kRecipesStoreName];
    
    [self performSelector:@selector(testHowToSaveAndGetArrayToCoreData) withObject:nil afterDelay:1.0f];
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    //crash report setting end
    
    UIAlertView * alert;
    
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    [Parse enableLocalDatastore];

    [self initializeSDKs];
    
    [self initializeShareVariables];
    
    [self initializeNetworkReachabilities];
    
    [self initializeCrashlytics];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    //temp code
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    [UserDataSingleton sharedSingleton].documentDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:[UserDataSingleton sharedSingleton].documentDirectory  error:nil];
    
    NSLog(@"document Directory : %@", [UserDataSingleton sharedSingleton].documentDirectory);
    NSLog(@"files array %@", filePathsArray);
    
    
//    [self saveEventuallyTest];
    
    [self showLocationCounts];
    
    //temp code
    return YES;
}

//temp code

- (void)showLocationCounts
{
//    NSFetchRequest * request = [[NSFetchRequest alloc] init];
//    NSEntityDescription * entity = [NSEntityDescription entityForName:@"GeoPoint" inManagedObjectContext:_managedObjectContext];
//    [request setEntity:entity];
//    
//    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES];
//    NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    
//    [request setSortDescriptors:sortDescriptors];
//    
//    NSError * error = nil;
//    
//    NSMutableArray * mutableFetchResults = [[[self managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
//    if (mutableFetchResults == nil) {
//        NSLog(@"CoreData result NO!");
//    }
//    
//    for (LocationCount * count in mutableFetchResults) {
//        NSLog(@"uuid : %@, start_date : %@, count : %ld", count.uuid, count.start_date, (long)[count.count integerValue]);
//    }
}

- (void)saveEventuallyTest
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < 1000; i++) {
        [array addObject:[NSNumber numberWithInt:i]];
    }
    
    PFObject * object = [PFObject objectWithClassName:@"SaveEventuallyTest"];
    object[@"value"] = array;
    
    [object saveEventually];
    NSLog(@"saveEventuallyTest Log");
}

//temp code
void HandleException(NSException * exception)
{
    NSString * content = [NSString stringWithFormat:@"%@", exception];
    [[UserDataSingleton sharedSingleton] saveCrashReport:content];
}

void HandleSignal(int signal)
{
    NSString * content = [NSString stringWithFormat:@"signal : %d", signal];
    [[UserDataSingleton sharedSingleton] saveCrashReport:content];
}


- (void) initializeShareVariables
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    
    [UserDataSingleton sharedSingleton].screenWidth = screenBound.size.width;
    [UserDataSingleton sharedSingleton].screenHeight = screenBound.size.height;
    
    [UserDataSingleton sharedSingleton].userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_enable"]) {
        [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"traffic_enable"];
    }
    
    if (![[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"map_type"]) {
        [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"map_type"];
    }
    
    if (![[UserDataSingleton sharedSingleton].userDefaults objectForKey:@"traffic_mode"]) {
        [[UserDataSingleton sharedSingleton].userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"traffic_mode"];
    }    
}

- (void) initializeSDKs
{
    // Google Map initialization
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    //    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY1];
    
    // ****************************************************************************
    // Parse initialization
    [Parse enableLocalDatastore];
    [ParseCrashReporting enable];
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    // ****************************************************************************
}

- (void)initializeNetworkReachabilities
{
    NSString *remoteHostName = @"www.apple.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)initializeCrashlytics
{
    [Fabric with:@[CrashlyticsKit]];
    
#ifdef DEBUG
    [[Crashlytics sharedInstance] setDebugMode:NO];
#else
    [[Crashlytics sharedInstance] setDebugMode:YES];
#endif

}


- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    [UserDataSingleton sharedSingleton].currNetworkStatus = netStatus;
    
    if (netStatus == NotReachable )
        [UserDataSingleton sharedSingleton].isNetworkAble = NO;
    else if(netStatus == ReachableViaWiFi)
    {
        [UserDataSingleton sharedSingleton].isNetworkAble = YES;
        [self performSelector:@selector(syncMediaData) withObject:nil afterDelay:180];
    }
    else if(netStatus == ReachableViaWWAN)
    {
        [UserDataSingleton sharedSingleton].isNetworkAble = YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTER_BACKGROUND object:nil];
    return;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTER_BACKGROUND object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self performSelector:@selector(syncMediaData) withObject:nil afterDelay:180];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

- (void)syncMediaData
{
    [[UserDataSingleton sharedSingleton] syncMediaData];
}

#pragma mark - Core Data stack

//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.app.frank.TrackaBuddy" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//- (NSManagedObjectModel *)managedObjectModel {
//    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TrackaBuddy" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    // Create the coordinator and store
//    
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TrackaBuddy.sqlite"];
//    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        // Report any error we got.
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//        dict[NSUnderlyingErrorKey] = error;
//        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//        // Replace this with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//
//- (NSManagedObjectContext *)managedObjectContext {
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] init];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    
//    [UserDataSingleton sharedSingleton].sharedManagedObjectContext = [[NSManagedObjectContext alloc] init];
//    [[UserDataSingleton sharedSingleton].sharedManagedObjectContext setPersistentStoreCoordinator:coordinator];
//    
//    return _managedObjectContext;
//}
//
//#pragma mark - Core Data Saving support
//
//- (void)saveContext {
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        NSError *error = nil;
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

#pragma mark - Orientation change

- (void)orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    
    [UserDataSingleton sharedSingleton].currDeviceOrientation = device.orientation;
}

@end
