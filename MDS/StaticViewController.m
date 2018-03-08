//
//  StaticViewController.m
//  MDS
//
//  Created by SL-167 on 1/8/18.
//  Copyright © 2018 SL-167. All rights reserved.

#import "StaticViewController.h"

@interface StaticViewController ()

@end

@implementation StaticViewController
{
}
@synthesize from, webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSURL *targetURL = [NSURL URLWithString:@""];
    
    
    if([from isEqualToString:@"about"])
    {
        _headLbl.text = @"ABOUT US";
    }
    else if([from isEqualToString:@"faq"])
    {
        _headLbl.text = @"FREQUENTLY ASKED QUESTIONS";
    }
    else if([from isEqualToString:@"privacy"])
    {
        _headLbl.text = @"PRIVACY POLICY";
    }
    else if([from isEqualToString:@"tandc"])
    {
        _headLbl.text = @"TERMS & CONDITIONS";
    }
    
    NSString *user_id = [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"user_id"];
    targetURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@mobile/static-page/%@/%@", BaseURL, from, user_id]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    _headLbl.adjustsFontSizeToFitWidth = true;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicator setHidden:false];
    [_indicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicator setHidden:true];
    [_indicator stopAnimating];
}

-(IBAction) sidemenu: (UIButton*) sender {
    
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
@end
