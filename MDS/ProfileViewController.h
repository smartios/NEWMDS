//
//  ProfileViewController.h
//  MDS
//
//  Created by SL-167 on 12/7/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *header;
@property (nonatomic, strong) IBOutlet UIButton *menuBtn;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSMutableDictionary *dataDic;
@end
