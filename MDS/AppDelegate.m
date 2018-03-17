//
//  AppDelegate.m
//  MDS
//
//  Created by SL-167 on 12/1/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "AppDelegate.h"
#import "RightMenuViewController.h"
#import "SlideNavigationController.h"
#import "TabbarController.h"
#import "NewIRViewController.h"
#import "MYTRViewController.h"
#import "TRTabBarController.h"
#import "IRTabBarController.h"
#import <Google/Analytics.h>
@import GooglePlaces;
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GoogleMaps/GoogleMaps.h>
#import "TRPasswordViewController.h"
#import "IncidentReportListing.h"

@interface AppDelegate ()
{
    Reachability* internetReachable;
}
@end

@implementation AppDelegate
@synthesize cryptoLib,navigationController, generalFunction,downlaodArray,onlineUsersDictionary,socketManager,locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
    
    locationManager =[[CLLocationManager alloc]init];
    // Ask for Authorisation from the User.
    [locationManager requestAlwaysAuthorization];
    
    // For use in foreground
    [self.locationManager requestWhenInUseAuthorization];
    
    
    
    if(locationManager.locationServicesEnabled)
    {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        locationManager.distanceFilter = 500;
    }
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyDOCZEZBTWsVW_t2PHMcd3bBNbuVEfjx5w"];
    [GMSServices provideAPIKey:@"AIzaSyDOCZEZBTWsVW_t2PHMcd3bBNbuVEfjx5w"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    /////////////////////////Socket/////////////////////////
    socketManager = [[SocketIOManger alloc] init];
    
    
    /////////DATABASE////////////////
    [self copyDB];
    
    
    
    ///////////encryption///////////
    cryptoLib = [[CryptLib alloc] init];
    
    
    //Code for push notification feature
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert  | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    
    //////DOWNLOAD/////
    downlaodArray = [[NSMutableArray alloc] init];
    onlineUsersDictionary = [[NSMutableDictionary alloc] init];
    
    
    //[NSThread sleepForTimeInterval:2.0];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [UIViewController alloc];
    SlideNavigationController *navController = [SlideNavigationController alloc];
    
    //checking the flow.....
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] == nil)
    {
        vc = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
    }
    else
    {
        vc = [storyBoard instantiateViewControllerWithIdentifier: @"HomeViewController"];
    }
    
    [navController initWithRootViewController:vc];
    RightMenuViewController *homeView = [[RightMenuViewController alloc] initWithNibName:@"RightMenuViewController" bundle:nil];
    [SlideNavigationController sharedInstance].leftMenu = homeView;
    [navController setNavigationBarHidden:YES animated:NO];
    self.window.rootViewController = navController;
    self.constant = [[Constant alloc] init];
    
    
    [Fabric with:@[[Crashlytics class]]];
    
    generalFunction = [[GeneralFunction alloc] init];
    [generalFunction openDB];
    [appDelegate.constant getExpireMessage];
    
   
    return YES;
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    CLLocationCoordinate2D loc = manager.location.coordinate;
//
//    if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
//    {
//
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
//        [params setValue:[NSString stringWithFormat:@"%f", loc.latitude]  forKey:@"latitude"];
//        [params setValue:[NSString stringWithFormat:@"%f", loc.longitude]  forKey:@"longitude"];
//
//        [self locationWebservice:params];
//    }
    [self locationWebserviceManagement];
}

-(BOOL)hasConnectivity
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [socketManager closeConnection];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
    {
        [self checkUserStatus];
        [self locationWebserviceManagement];
    }
    [socketManager establishConnection];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)locationWebserviceManagement
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
    {
        CLLocationCoordinate2D loc = locationManager.location.coordinate;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
        [params setValue:[NSString stringWithFormat:@"%f", loc.latitude]  forKey:@"latitude"];
        [params setValue:[NSString stringWithFormat:@"%f", loc.longitude]  forKey:@"longitude"];
        
        [self locationWebservice:params];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Apple Push Notification registering Delegate methods

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication* )application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"accessToken: %@", devToken);
    if (devToken != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:devToken forKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 didFailToRegisterForRemoteNotificationsWithError function
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"The error while getting device token is: %@",error.localizedDescription);
}


/**
 didReceiveRemoteNotification function
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey: @"aps"] isKindOfClass: [NSDictionary class]] && [userInfo objectForKey: @"aps"] != nil)
    {
        NSDictionary *payload = [[userInfo objectForKey: @"aps"] objectForKey:@"data"];
        if([[payload objectForKey:@"alert"] isEqualToString: @"new-message"])
        {
            if (application.applicationState == UIApplicationStateActive)
            {
                return;
            }
            
            if ([[[UIApplication sharedApplication] .keyWindow rootViewController] isKindOfClass: [SlideNavigationController class]])
            {
                NSArray *arrVC = [[SlideNavigationController sharedInstance] viewControllers];
                UITabBarController *vc = [[UITabBarController alloc] init];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
                
                for (vc in arrVC)
                {
                    if ([vc isKindOfClass: [UITabBarController class]])
                    {
                        vc.selectedIndex = 1;
                        
                        [[self navigationController] popViewControllerAnimated: YES];
                        
                    }
                    else if ([vc isKindOfClass: [TabbarController class]])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName: @"refresh_Chat_List" object: nil];
                        vc.selectedIndex = 1;
                    }
                    else
                    {
                        storyboard = [UIStoryboard storyboardWithName: @"Main2" bundle: nil];
                        UITabBarController *vc = [storyboard instantiateViewControllerWithIdentifier: @"TabbarController"];
                        vc.selectedIndex = 1;
                        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withCompletion:nil];
                    }
                }
            }
        }
        else if([[payload objectForKey:@"alert"] isEqualToString: @"staff-permission-change"])
        {
            [self checkUserStatus];
        }
        else if([[payload objectForKey:@"alert"] isEqualToString: @"user-delete"])
        {
            [appDelegate.constant logoutFromApp];
        }
        else if([[payload objectForKey:@"alert"] isEqualToString: @"ir-comment"])
        {
            if([[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[NewIRViewController class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newComment" object:nil];
            }
        }
        else if([[payload objectForKey:@"alert"] isEqualToString: @"new-tr"])
        {
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive &&
               [[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[TRTabBarController class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newTR" object:nil];
            }
            else
            {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                TRPasswordViewController *vc = [story instantiateViewControllerWithIdentifier:@"TRPasswordViewController"];
                vc.from = @"login";
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController: vc withCompletion:nil];
            }
        }
        else if([[payload objectForKey:@"alert"] isEqualToString: @"new-ir"])
        {
            if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && [[[SlideNavigationController sharedInstance] topViewController] isKindOfClass:[IRTabBarController class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newIR" object:nil];
            }
            else
            {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                IncidentReportListing *vc1 = [story instantiateViewControllerWithIdentifier:@"IncidentReportListing"];
                vc1.from = @"my";
                NewIRViewController *vc2 = [story instantiateViewControllerWithIdentifier:@"NewIRViewController"];
                vc2.from = @"new";
                IncidentReportListing *vc3 = [story instantiateViewControllerWithIdentifier:@"IncidentReportListing"];
                vc3.from = @"sent";
                IRTabBarController *tab = [story instantiateViewControllerWithIdentifier:@"IRTabBarController"];
                tab.viewControllers = [[NSArray alloc] initWithObjects:vc1,vc2,vc3, nil];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:tab withCompletion:nil];
                
            }
        }
    }
}



//MARK:- DropBox

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    }
    
    return NO;
}

//MARK:- Check internet

//get default data
-(void)checkUserStatus
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/status?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    WebConnector *webConnector = [[WebConnector alloc] init];
   
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic = [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] mutableCopy];
    
    [webConnector defaultData:dic url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([[responseObject valueForKey:@"response"]  isEqualToString:@"success"])
        {
            [dic setValue:[[responseObject valueForKey:@"data"] valueForKey:@"staff_permission"] forKey:@"staff_permission"];
            [dic setValue:[[responseObject valueForKey:@"data"] valueForKey:@"tr_permission"] forKey:@"tr_permission"];
            
            NSMutableDictionary *temp = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
            [temp setValue:dic forKey:@"users_details"];
            [[NSUserDefaults standardUserDefaults] setValue:temp forKey:@"userData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_user_List" object:nil];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    
                    [self checkUserStatus];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
        
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            break;
        }
        case ReachableViaWiFi:
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] isEqualToString: @"yes"])
            {
                if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
                {
                    [self checkUserStatus];
                }
                
                [socketManager checkSocketStatus];
            }
            NSLog(@"The internet is working via WIFI.");
            break;
        }
        case ReachableViaWWAN:
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] isEqualToString: @"yes"])
            {
                if([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
                {
                    [self checkUserStatus];
                }
                [socketManager checkSocketStatus];
            }
            NSLog(@"The internet is working via WWAN.");
            break;
        }
    }
}

//MARK:- DATABASE

// Function to copy db to phone if not exists
-(void) copyDB
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *databasePath = [NSString stringWithFormat:@"%@/mds.db",documentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if(![fileManager fileExistsAtPath:databasePath])
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"mds" ofType:@"db"];
        [fileManager copyItemAtPath:path toPath:databasePath error:&error];
    }
}

-(void)locationWebservice:(NSMutableDictionary *)params
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector locationWebservice: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
        {
            [SVProgressHUD dismiss];
           
            
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
        else
        {
           // [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
        }
        
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[SVProgressHUD showErrorWithStatus: @"Please try again."];
        
    }];
}
@end
