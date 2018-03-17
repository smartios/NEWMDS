//
//  MediaViewController.m
//  mds
//
//  Created by SS-181 on 7/19/17.
//
//

#import "MediaViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "UIImageView+AFNetworking.h"

@interface MediaViewController ()
{
    AVPlayer *avPlayer;
}
@end

@implementation MediaViewController

@synthesize from,filePath,titleLabel,webView,imageView, data;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webView.delegate = self;
    
    if([from isEqualToString:@"image"])
    {
        if(filePath != nil)
        {
            if([filePath containsString:@"http"])
            {
                [imageView setImageWithURL:[NSURL URLWithString:filePath] placeholderImage:[UIImage imageNamed:@"image_default"]];
            }
            else
            {
                imageView.image = [UIImage imageWithContentsOfFile:filePath];

            }
        }
        else if(data != nil)
        {
            imageView.image = [UIImage imageWithData:data];
        }
        
        webView.hidden = true;
    }
    else if([from isEqualToString:@"document"])
    {
        if(filePath != nil && [filePath containsString:@"http"])
        {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
        }
        
        else if(data == nil)
        {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
        }
        else
        {
            [webView loadData:data MIMEType:[NSString stringWithFormat:@"application/%@",[filePath componentsSeparatedByString:@"."][1]] textEncodingName:@"utf-8" baseURL:nil];
        }
       
    }
    else
    {
        imageView.hidden = true;
        webView.hidden = true;
        
        if(filePath != nil)
        {
            NSURL *url;
            if([filePath containsString:@"http"] || [filePath containsString:@"file://"])
            {
            url = [NSURL URLWithString:filePath];
            }
            else{
              url = [NSURL fileURLWithPath:filePath];
            }
            avPlayer = [[AVPlayer alloc] initWithURL:url];
            AVPlayerViewController *AVVC = [[AVPlayerViewController alloc]init];
            AVVC.player = avPlayer;
            AVVC.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
            [self addChildViewController:AVVC];
            [self.view addSubview:AVVC.view];
            [AVVC.player play];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonTapped:(UIButton *)sender
{
    [[self navigationController]popViewControllerAnimated:true];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"Please Wait"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

@end
