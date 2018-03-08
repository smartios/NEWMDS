//
//  GroupMemberViewController.h
//  
//
//  Created by SS-181 on 7/5/17.
//
//

#import <UIKit/UIKit.h>
@protocol usersList <NSObject>
-(void)getUserList:(NSMutableArray *)arr;
@end

@interface GroupMemberViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *colectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;

@property (strong, nonatomic) NSString *from;
@property (nonatomic, strong) id delegate;
@property (strong, nonatomic) NSMutableDictionary *prevDataDic;
@property (strong, nonatomic) NSMutableArray *selectedDataArray;
@end

