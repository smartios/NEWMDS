//
//  AppDelegate.h
//  MDS
//
//  Created by SL-167 on 12/1/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"
#import "SlideNavigationController.h"
#import "GeneralFunction.h"
#import "CryptLib.h"
#import "SocketIOManger.h"
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

//@property (strong, nonatomic)SlideNavigationController  *navController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SocketIOManger *socketManager;
@property (strong, nonatomic) Constant *constant;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (strong, nonatomic) GeneralFunction *generalFunction;
@property (strong, nonatomic) CryptLib *cryptoLib;
@property(nonatomic)CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *downlaodArray;
@property (strong, nonatomic) NSMutableDictionary *onlineUsersDictionary;
-(BOOL)hasConnectivity;
-(void)locationWebserviceManagement;
@end

