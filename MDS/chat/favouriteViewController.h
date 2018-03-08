//
//  favouriteViewController.h
//  UMA
//
//  Created by SS-181 on 7/20/17.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface favouriteViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UITextViewDelegate,SWTableViewCellDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConst;
@property (strong, nonatomic) IBOutlet UIButton *BroadcastButton;

@property (nonatomic,strong) NSMutableArray* dataListArray;
@property (nonatomic,strong) NSMutableDictionary* prevDataDic;
@property (strong, nonatomic) NSString *from;


@end
