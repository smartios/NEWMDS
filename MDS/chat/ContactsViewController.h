//
//  ContactsViewController.h
//  mds
//
//  Created by SS-181 on 6/27/17.
//
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *norecord;
@property (strong, nonatomic)  NSArray *tempKeyArr;;

-(void) getContactsList:(BOOL)showHud;
@end
