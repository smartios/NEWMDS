//
//  IRTabBarController.m
//  MDS
//
//  Created by SL-167 on 1/12/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "IRTabBarController.h"

@interface IRTabBarController ()

@end

@implementation IRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    if ([[UITabBar appearance] respondsToSelector:@selector(setUnselectedItemTintColor:)]) {
        if (@available(iOS 10.0, *)) {
            [[UITabBar appearance] setUnselectedItemTintColor:[UIColor blackColor]];
        } else {
            // Fallback on earlier versions
        }
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor blackColor]}
                                               forState:UIControlStateNormal];
    }
    else
    {
        if (@available(iOS 10.0, *)) {
            self.tabBar.unselectedItemTintColor = [UIColor blackColor];
        } else {
            // Fallback on earlier versions
        }
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor colorWithRed:(192/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0]}
                                               forState:UIControlStateSelected];
    }
    
    self.tabBar.tintColor = [UIColor colorWithRed:(192/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
    
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    item.image = [UIImage imageNamed:@"viewIR"];
    item.title = @"My IR";
    item.selectedImage = [UIImage imageNamed:@"viewInactive"];
    
//    if(![[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"] isEqualToString:@"staff"])
//    {
        UITabBarItem *item1 = [self.tabBar.items objectAtIndex:1];
        item1.image = [UIImage imageNamed:@"reportIR"];
        item1.title = @"Report";
        item1.selectedImage = [UIImage imageNamed:@"reportActive"];
        
        UITabBarItem *item2 = [self.tabBar.items objectAtIndex:2];
        item2.image = [UIImage imageNamed:@"sendLogs"];
        item2.title = @"Sent Logs";
        item2.selectedImage = [UIImage imageNamed:@"sendLogsActive"];
//    }
}
@end
