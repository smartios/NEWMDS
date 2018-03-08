//
//  TRTabBarController.m
//  MDS
//
//  Created by SL-167 on 1/5/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "TRTabBarController.h"

@interface TRTabBarController ()

@end

@implementation TRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
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
    
    self.tabBar.tintColor = [UIColor colorWithRed:(192/255.0) green:(0) blue:(0) alpha:1.0];
    
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    item.image = [UIImage imageNamed:@"myTR"];
    item.title = @"My TR";
    item.selectedImage = [UIImage imageNamed:@"myTR_Active"];
    
    if(![[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"] isEqualToString:@"staff"])
    {
        UITabBarItem *item1 = [self.tabBar.items objectAtIndex:1];
        item1.image = [UIImage imageNamed:@"newTR"];
        item1.title = @"New TR";
        item1.selectedImage = [UIImage imageNamed:@"newTR_active"];
        
        UITabBarItem *item2 = [self.tabBar.items objectAtIndex:2];
        item2.image = [UIImage imageNamed:@"sendLogs"];
        item2.title = @"Sent Logs";
        item2.selectedImage = [UIImage imageNamed:@"sendLogsActive"];
        
        UITabBarItem *item3 = [self.tabBar.items objectAtIndex:3];
        item3.image = [UIImage imageNamed:@"draft"];
        item3.title = @"Draft";
        item3.selectedImage = [UIImage imageNamed:@"draft_Active"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
