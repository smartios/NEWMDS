//
//  ContactUsViewController.h
//  MDS
//
//  Created by SL-167 on 12/8/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIButton *sideMenu;
@property (strong, nonatomic) IBOutlet UIButton *submit;
@end
