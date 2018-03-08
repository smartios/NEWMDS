//
//  IncidentReportListing.h
//  MDS
//
//  Created by SS068 on 03/01/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncidentReportListing : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *delHeaderBtn;
@property (weak, nonatomic) IBOutlet UIButton *exportHeaderBtn;
@property (weak, nonatomic) IBOutlet UIButton *editHeaderBtn;
@property (weak, nonatomic) IBOutlet UIView *filterBtnView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *norecordLbl;
@property (weak, nonatomic) IBOutlet UIButton *resetDate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *filterDateConst;
@property (weak, nonatomic) IBOutlet UIButton *fromDate;
@property (weak, nonatomic) IBOutlet UIButton *toDate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *calOkBtn;
@property (nonatomic, strong) NSString *from;
@end
