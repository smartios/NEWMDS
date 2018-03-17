//
//  MediaViewController.h
//  mds
//
//  Created by SS-181 on 7/19/17.
//
//

#import <UIKit/UIKit.h>


@interface MediaViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
