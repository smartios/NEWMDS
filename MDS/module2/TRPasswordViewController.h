//
//  TRPasswordViewController.h
//  MDS
//
//  Created by SL-167 on 1/1/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRPasswordViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIButton *sidemenu;
@property (nonatomic, strong) NSString *from;
@property (nonatomic) int num;
@end
