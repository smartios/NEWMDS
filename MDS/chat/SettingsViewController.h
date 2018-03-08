//
//  SettingsViewController.h
//  mds
//
//  Created by SS-181 on 8/14/17.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
