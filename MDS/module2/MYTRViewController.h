//
//  MYTRViewController.h
//  MDS
//
//  Created by SS068 on 03/01/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYTRViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *recordLbl;
@property (strong, nonatomic) IBOutlet UILabel *headLbl;
@property (strong, nonatomic) IBOutlet UIView *filterBtnView;
@property (nonatomic, strong) NSString *from;
@property (weak, nonatomic) IBOutlet UIButton *fromDate;
@property (weak, nonatomic) IBOutlet UIButton *resetDate;
@property (weak, nonatomic) IBOutlet UIButton *dateButton2;
@property (weak, nonatomic) IBOutlet UIButton *toDate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *calOkBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *filterDateConst;
@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *headerExportBtn;
@property (nonatomic, strong) NSMutableDictionary *dataDic;

@end
