//
//  GroupChatListViewController.h
//  mds
//
//  Created by SS-181 on 9/5/17.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface GroupChatListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextViewDelegate,SWTableViewCellDelegate,UISearchBarDelegate>


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *ChatButton;
@property (strong, nonatomic) IBOutlet UIButton *favButton;
@property (strong, nonatomic) IBOutlet UIButton *GroupButton;

@property (nonatomic,strong) NSMutableArray* chatListArray;
@property (nonatomic,strong) NSIndexPath* deleteIndexPath;

@property (strong, nonatomic) IBOutlet UITableView *chatTableView;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *blackTranView;
@end
