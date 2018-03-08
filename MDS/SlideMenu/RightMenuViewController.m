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
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "ContactUsViewController.h"
#import "StaticViewController.h"
#import "ContactUsViewController.h"


@implementation RightMenuViewController
{
    //WebConnector *webConnector;
    NSMutableArray *titleArray;
    NSMutableArray *ImageArray;
    CGRect screenRect;
    CGFloat screenHeight;
}
@synthesize slideMenuBg, tableView;

#pragma mark - UIViewController Methods 



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    titleArray = [[NSMutableArray alloc]initWithObjects:@"", @"Dashboard",@"About Us",@"Contact Us",@"Privacy Policy", @"T&C", @"FAQ", @"Logout", nil];
    
    self.tableView.opaque = NO;
    
    //Code to get height of the device
    screenRect = [[UIScreen mainScreen] bounds];
    screenHeight = screenRect.size.height;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(refresh) name: @"refreshSide" object: nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
    if (indexPath.row == 0)
    {
        return 130;
    }
    else
    {
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
        userImg.layer.cornerRadius = userImg.frame.size.width/2;
        
        if([[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"profile_picture"] != nil && [[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"profile_picture"] isKindOfClass: [NSString class]])
        {
            NSString *url = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL, [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"profile_picture"]];
            [userImg setImageWithURL:[NSURL URLWithString: url] placeholderImage:[UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            [userImg setImage:[UIImage imageNamed:@"default_profile"]];
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] != nil)
        {
            userName.text = [NSString stringWithFormat:@"%@ %@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"], [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"last_name"]];
            userName.adjustsFontSizeToFitWidth = true;
            
            email.text = [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"email"];
            email.adjustsFontSizeToFitWidth = true;
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
        
        UILabel* optionLabel = (UILabel *)[cell viewWithTag:1];
        optionLabel.attributedText = [appDelegate.constant addCharacterSpacing: [titleArray objectAtIndex:indexPath.row] space:0.5f];
        optionLabel.text = [titleArray objectAtIndex:indexPath.row];
        [optionLabel setTextColor:[UIColor blackColor]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //indexNo = indexPath;
    [self.tableView reloadData];
    id <SlideNavigationContorllerAnimator> revealAnimator;
    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^
     {
         [SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
     }];
    
    if(indexPath.row == 0)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProfileViewController *vc = [story instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.from = @"profile";
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:true];
        
    }
    else  if(indexPath.row == 1)
    {
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[self.storyboard instantiateViewControllerWithIdentifier: @"HomeViewController"] withCompletion:nil];
        
    }
    else if([[NSUserDefaults standardUserDefaults] valueForKey: @"userData"] != nil && indexPath.row == titleArray.count-1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MDS"
                                                        message: @"Are you sure you want to logout?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles: @"Yes", nil];
        [alert show];
    }
    else if (indexPath.row == 3)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ContactUsViewController *vc = [story instantiateViewControllerWithIdentifier:@"ContactUsViewController"];
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:true];
    }
    else
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StaticViewController *vc = [story instantiateViewControllerWithIdentifier:@"StaticViewController"];
        
        if(indexPath.row == 2)
        {
            vc.from = @"about";
        }
        else if(indexPath.row == 4)
        {
            vc.from = @"privacy";
        }
        else if(indexPath.row == 5)
        {
            vc.from = @"tandc";
        }
        else if(indexPath.row == 6)
        {
            vc.from = @"faq";
        }
        [[SlideNavigationController sharedInstance] pushViewController:vc animated:true];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
    }
    else
    {
        [appDelegate.constant logoutFromApp];
    }
}
@end
