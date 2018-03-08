//
//  ViewController.h
//  MDS
//
//  Created by SL-167 on 12/1/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SVProgressHUD.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic, strong) NSString *from;
@property (nonatomic) int num;
@end

