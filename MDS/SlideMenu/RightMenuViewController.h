//
//  RightMenuViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImageView+AFNetworking.h"
#import "SlideNavigationContorllerAnimator.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "StaticViewController.h"
//#import "WebConnector.h"


@interface RightMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
{
    UIViewController *vc;
	
    NSInteger selectedIndex;
}
//@property (nonatomic, retain) NSIndexPath * indexNo;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *labelCell,*profileCell, *subGroupCell;
@property (nonatomic, strong) IBOutlet UIImageView *slideMenuBg;


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)refresh;

@end
