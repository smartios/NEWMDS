//
//  NewScureTRControllerTableViewController.h
//  MDS
//
//  Created by SS068 on 25/12/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupMemberViewController.h"

@interface NewScureTRControllerTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate, UIPickerViewDataSource, UIPickerViewDelegate,usersList>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *cancel;
@property (nonatomic, strong) IBOutlet UIButton *select;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIView *pickerV;
@property (nonatomic, strong) NSMutableDictionary *dataDic;



@end

