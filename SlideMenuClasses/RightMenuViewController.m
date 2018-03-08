//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "RightMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "LandingVC.h"
#import "ContactUsVC.h"
#import "HomeVC.h"
#import "AppDelegate.h"
#import "NewsFeedsVC.h"
#import "MyProfileVC.h"
#import "StaticContentVC.h"
#import "LangSettingVC.h"
#import "AboutAppVC.h"

@implementation RightMenuViewController
{
	WebConnector *webConnector;
	NSMutableArray *titleArray;
	NSMutableArray *ImageArray;
	CGRect screenRect;
	CGFloat screenHeight;
}
@synthesize slideMenuBg, indexNo, tableView;

#pragma mark - UIViewController Methods 

-(void)viewWillAppear:(BOOL)animated
{
    //Code here
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
   titleArray = [[NSMutableArray alloc]initWithObjects:@"", @"dashboard",@"newsfeed",@"myProfile", @"faq", @"setting", @"aboutUs", @"contactUs", @"privacyStatement", @"termsOfUse", @"about",  @"logout", nil];
	
   ImageArray = [[NSMutableArray alloc]initWithObjects:@"", @"dashboard",@"newsfeedicon", @"profileicon", @"faqicon", @"langIcon", @"abouticon",@"contacticon", @"privacyicon", @"termsicon", @"abouticon", @"logouticon", nil];
	
    self.tableView.opaque = NO;
	
	//Code to get height of the device
	screenRect = [[UIScreen mainScreen] bounds];
	screenHeight = screenRect.size.height;
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(update) name: @"notification" object:nil];
}

-(void)update
{
	[self.tableView reloadData ];
}

-(void)refresh
{
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate & Datasrouce

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"user_type"] isEqualToString: @"staff"])
		{
			return 100;
		}
		return 140;
	}else{
		return 45;
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"menuCell" owner:self options:nil];
	
	UITableViewCell *cell = [[UITableViewCell alloc] init];
	
	if (indexPath.row == 0)
	{
		cell = [self.tableView dequeueReusableCellWithIdentifier:@"profileCell"];
		
		if(cell == nil)
		{
			cell = self.profileCell;
			self.profileCell = nil;
		}
		
		UIImageView *userImg = (UIImageView *)[cell viewWithTag: 10];
		UILabel *userName = (UILabel *)[cell viewWithTag: 11];
		UILabel *email = (UILabel *)[cell viewWithTag: 12];
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"user_type"] isEqualToString: @"staff"])
		{
			userImg.hidden = YES;
			email.text = @"";
			userName.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"username"];
		}
		else
		{
			userImg.hidden = NO;
			[userImg setImageWithURL:[NSURL URLWithString: [[NSUserDefaults standardUserDefaults]objectForKey: @"profile_pic"]] placeholderImage: [UIImage imageNamed: @"defaultUser"]];
			userName.text = [[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] capitalizedString];
			email.text = [[NSUserDefaults standardUserDefaults] objectForKey: @"email"];
			userImg.layer.cornerRadius = userImg.frame.size.height / 2;
			userImg.layer.borderWidth = 3.0;
			userImg.layer.borderColor = [[UIColor whiteColor] CGColor];
		}
	}
	else
	{
		cell = [self.tableView dequeueReusableCellWithIdentifier:@"labelCell"];
		
		if(cell == nil)
		{
			cell = self.labelCell;
			self.labelCell = nil;
		}
		
		UIImageView* image = (UIImageView *)[cell viewWithTag:-6];
		UILabel* optionLabel = (UILabel *)[cell viewWithTag:1];
		
		[image setImage:[UIImage imageNamed:[ImageArray objectAtIndex:indexPath.row]]];
		optionLabel.attributedText = [appDel addCharacterSpacing:[appDel getString:[titleArray objectAtIndex:indexPath.row]] space:0.5f];
		[optionLabel setTextColor:[UIColor blackColor]];

    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexNo = indexPath;
     [self.tableView reloadData];
     id <SlideNavigationContorllerAnimator> revealAnimator;
    
    if(indexPath.row == 0)
    {
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"MyProfileVC"] withCompletion:nil];
    }
    else if(indexPath.row == 1)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"HomeVC"] withCompletion:nil];
    }
	else if(indexPath.row == 2)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"NewsFeedsVC"] withCompletion:nil];
	}
    else if(indexPath.row == 3)
    {
//		if ([[[NSUserDefaults standardUserDefaults] objectForKey: @"user_type"] isEqualToString: @"staff"])
//		{
//			//Do Nothing
//		}
//		else
//		{
			UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
			[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"MyProfileVC"] withCompletion:nil];
//		}
    }
	else if(indexPath.row == 4)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		StaticContentVC *VC = [mainStoryboard instantiateViewControllerWithIdentifier:@"StaticContentVC"];
		VC.baseURL = @"FAQ";
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:VC withCompletion:nil];
	}
    else if (indexPath.row == 5)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"LangSettingVC"] withCompletion:nil];
		
    }
    else if(indexPath.row == 6)
    {
		//Code here
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		StaticContentVC *VC = [mainStoryboard instantiateViewControllerWithIdentifier:@"StaticContentVC"];
		VC.baseURL = @"about_us";
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:VC withCompletion:nil];
		
    }
	else if(indexPath.row == 7)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"ContactUsVC"] withCompletion:nil];
	}
	else if(indexPath.row == 8)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		StaticContentVC *VC = [mainStoryboard instantiateViewControllerWithIdentifier:@"StaticContentVC"];
		VC.baseURL = @"privacyPolicy";
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:VC withCompletion:nil];
	}
	else if(indexPath.row == 9)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		StaticContentVC *VC = [mainStoryboard instantiateViewControllerWithIdentifier:@"StaticContentVC"];
		VC.baseURL = @"terms_condition";
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:VC withCompletion:nil];
	}
	else if (indexPath.row == 10)
	{
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"AboutAppVC"] withCompletion:nil];
	}
	else if(indexPath.row == 11)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UMA"
														message: [appDel getString: @"logoutmsg"]
													   delegate:self
											  cancelButtonTitle:[appDel getString: @"no"]
											  otherButtonTitles: [appDel getString: @"yes"], nil];
		[alert show];
	}
	
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^
         {
     		[SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
     	}];
}

#pragma mark - IBAction Method
-(IBAction)logoutBtnClicked:(id)sender
{
    [self.view endEditing:YES];
    
    //Post the notification for the logout
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
    
}

#pragma mark - UIalertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
		//s
    }
	else
	{
		[self logoutDone];
	}
}


-(void)logoutDone
{
	webConnector = [[WebConnector alloc]init];
	if (![appDel hasConnectivity]) {
		
		[appDel showInfoWithStatus: [appDel getString: @"connectioError"]];
	}
	else
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"device_token"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] isKindOfClass:[NSNull class]] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] length]!=0)
        {
            [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"device_token"] forKey: @"device_token"];
        }
        else
        {
            [params setObject: @"123456" forKey: @"device_token"];
        }
		
		[appDel showWithStatus: [appDel getString: @"loading"]];
		webConnector = [[WebConnector alloc] init];
		[webConnector logout:params  completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
			
			if ([[responseObject objectForKey: @"status"] isEqualToString: @"success"])
			{
				[appDel dismiss];
                
                [[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"userData"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"name"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"email"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"user_id"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"profile_pic"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"user_type"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey:@"isLogin"];
				[[NSUserDefaults standardUserDefaults] setValue: @"" forKey: @"fromLogin"];
				[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"sessionStart"];
				[[NSUserDefaults standardUserDefaults] setObject:@""  forKey:@"check_capability_domain"];
				[[NSUserDefaults standardUserDefaults] setObject:@""  forKey:@"check_capability_app_key"];
				[[NSUserDefaults standardUserDefaults] setObject:@""  forKey:@"authorize_device_domain"];
				[[NSUserDefaults standardUserDefaults] setObject:@""  forKey:@"authorize_device_app_key"];
				[[NSUserDefaults standardUserDefaults] setObject:@""  forKey:@"location_id"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
				[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[mainStoryboard instantiateViewControllerWithIdentifier: @"LandingVC"] withCompletion:nil];
			}
			else
			{
				[appDel showErrorWithStatus: [responseObject objectForKey: @"message"]];
			}
			[[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
			
		} errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
			
			if (![[[NSUserDefaults standardUserDefaults] objectForKey: @"isFailed"] boolValue])
			{
				[[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"isFailed"];
				[self logoutDone];
			}
			else
			{
				[appDel showInfoWithStatus: [appDel getString: @"requestFail"]];
			}
		}];
	}
}

@end
