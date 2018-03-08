//
//  StaticViewController.h
//  MDS
//
//  Created by SL-167 on 1/8/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, strong) IBOutlet UILabel *headLbl;
@property (nonatomic, strong) NSString *from;
@end
