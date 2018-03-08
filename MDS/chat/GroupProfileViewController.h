//
//  GroupProfileViewController.h
//  mds
//
//  Created by SS-181 on 8/11/17.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface GroupProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate,UISearchBarDelegate,SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *exitGroupButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteGroupButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConst;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSMutableDictionary *prevDataDic;

@end
