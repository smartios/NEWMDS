//
//  TabbarController.m
//  mds
//
//  Created by SS-181 on 6/29/17.
//
//

#import "TabbarController.h"
#import "AppDelegate.h"

@interface TabbarController ()

@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
   UITabBarItem *item = [[UITabBarItem alloc] init];
    
    
    [self.tabBar.items objectAtIndex:1].badgeColor = [UIColor colorWithRed:(255/255.0) green:(132/255.0) blue:(0/255.0) alpha:1.0];
    [self.tabBar.items objectAtIndex:2].badgeColor = [UIColor colorWithRed:(255/255.0) green:(132/255.0) blue:(0/255.0) alpha:1.0];
    
    if ([[UITabBar appearance] respondsToSelector:@selector(setUnselectedItemTintColor:)]) {
        [[UITabBar appearance] setUnselectedItemTintColor:[UIColor blackColor]];
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor blackColor]}
                                               forState:UIControlStateNormal];
    }
    else
    {
       self.tabBar.unselectedItemTintColor = [UIColor blackColor];
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor colorWithRed:(192/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0]}
                                               forState:UIControlStateSelected];
    }
    
    for(item in self.tabBar.items)
    {
        item.image = [[item image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[item selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkBannerCount) name: @"refresh_Chat_List" object: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self checkBannerCount];
    
}

-(void)checkBannerCount
{
    NSMutableArray *chatListArray = [[NSMutableArray alloc] init];
    chatListArray = [appDelegate.generalFunction getChatList];
    
    [[appDelegate socketManager] checkSocketStatus];
    
    int unreadCount = 0;
    int unreadGroupCount = 0;
    
    for(NSDictionary *dic in chatListArray)
    {
        if ([dic valueForKey:@"unread_no"] != nil && ![[dic valueForKey:@"unread_no"] isKindOfClass:[NSNull class]] && ![[dic valueForKey:@"unread_no"] isEqualToString:@""] && ![[dic valueForKey:@"unread_no"] isEqualToString:@"0"])
        {
            unreadCount = unreadCount + [[dic valueForKey:@"unread_no"] intValue];
        }
        
        if ([dic valueForKey:@"group_id"] != nil && ![[dic valueForKey:@"group_id"] isEqualToString:@""] && [dic valueForKey:@"unread_no"] != nil && ![[dic valueForKey:@"unread_no"] isKindOfClass:[NSNull class]] && ![[dic valueForKey:@"unread_no"] isEqualToString:@""] && ![[dic valueForKey:@"unread_no"] isEqualToString:@"0"])
        {
            unreadGroupCount = unreadGroupCount + [[dic valueForKey:@"unread_no"] intValue];
        }
    }
    if(unreadCount > 0)
    {
        [[self.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%i",unreadCount]];
    }
    else
    {
        [[self.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
    
    if(unreadGroupCount > 0)
    {
        [[self.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%i",unreadGroupCount]];
    }
    else
    {
        [[self.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    }
   
}
@end
