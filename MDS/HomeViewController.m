//
//  HomeViewController.m
//  MDS
//
//  Created by SL-167 on 12/5/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "HomeViewController.h"
#import "SlideNavigationController.h"
#import "ProfileViewController.h"
#import "ContactsViewController.h"
#import "TabbarController.h"
#import "TRPasswordViewController.h"
#import "NewScureTRControllerTableViewController.h"
#import "IRTabBarController.h"
#import "ContactUsViewController.h"
#import "SecureTRController.h"
#import "MYTRViewController.h"
#import "IncidentReportListing.h"
#import "NewIRViewController.h"
#import "IncidentReportListing.h"
#import "RightMenuViewController.h"
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>


@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataLbl.text = @"What would\nyou like to do?";
    _nameLbl.text = [@"Hi! " stringByAppendingString: [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"]];
    
    RightMenuViewController *homeView = [[RightMenuViewController alloc] initWithNibName:@"RightMenuViewController" bundle:nil];
    [homeView refresh];
    
    
    //checking for location access
    
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status == kCLAuthorizationStatusDenied)
//    {
//        UIAlertController *alerting = [UIAlertController alertControllerWithTitle: @"Location Services Are Off"
//                                                                          message:@"Go to settings"
//                                                                   preferredStyle:UIAlertControllerStyleAlert];
//        [alerting addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            [[UIApplication sharedApplication]openURL:settingsURL];
//        }]];
//        [alerting addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//        
//        
//        [self presentViewController:alerting animated:YES completion:nil];
//    }
//    else
//    {
//        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Logged In"
//                                                              action:@"Active"
//                                                               label:[NSString stringWithFormat:@"Name: %@ %@ Type: %@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"], [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"last_name"], [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"]]
//                                                               value:@1] build]];
//        [tracker set:kGAIScreenName value:@"Home Screen"];
//        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//        
//    }
    // Do any additional setup after loading the view.
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) myProfile: (UIButton*) sender
{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.from = @"profile";
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction) secureChat: (UIButton*) sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
    TabbarController *vc = [story instantiateViewControllerWithIdentifier:@"TabbarController"];
    [self.navigationController pushViewController:vc animated:YES];
}

//MARK:- sidemenu method

-(IBAction) sidemenu: (UIButton*) sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

-(IBAction) secureIR: (UIButton*) sender {
    
    //    if([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"] isEqualToString:@"staff"])
    //    {
    //        IncidentReportListing  *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"IncidentReportListing"];
    //        vc1.from = @"my";
    //        IRTabBarController *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"TRTabBarController"];
    //        tab.viewControllers = [[NSArray alloc] initWithObjects:vc1, nil];
    //
    //        [self.navigationController pushViewController:tab animated:true];
    //    }
    //    else
    //    {
    IncidentReportListing *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"IncidentReportListing"];
    vc1.from = @"my";
    NewIRViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"NewIRViewController"];
    vc2.from = @"new";
    IncidentReportListing *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"IncidentReportListing"];
    vc3.from = @"sent";
    IRTabBarController *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"IRTabBarController"];
    tab.viewControllers = [[NSArray alloc] initWithObjects:vc1,vc2,vc3, nil];
    
    [self.navigationController pushViewController:tab animated:true];
    //    }
}


-(IBAction) secureTR: (UIButton*) sender
{
    if([[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"tr_permission"]] isEqualToString:@"Y"] || [[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"]] isEqualToString:@"company-admin"])
    {
        TRPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TRPasswordViewController"];
        if([[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"tr_set_pass"]] isEqualToString:@"N"])
        {
            vc.from = @"set";
        }
        else
        {
            vc.from = @"login";
        }
        [self.navigationController pushViewController:vc animated:true];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:trPermission duration:3.0];
    }
}

@end
