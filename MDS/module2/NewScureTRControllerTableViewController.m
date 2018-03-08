//
//  NewScureTRControllerTableViewController.m
//  MDS
//
//  Created by SS068 on 25/12/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "NewScureTRControllerTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CalendarView.h"
#import "GroupMemberViewController.h"

@interface NewScureTRControllerTableViewController () 
{
    CalendarView *calView;
    NSMutableArray *pickerArray;
    UITapGestureRecognizer *tap;
}

@end
@implementation NewScureTRControllerTableViewController
@synthesize dataDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 200;
    pickerArray = [[NSMutableArray alloc] init];
    dataDic = [[NSMutableDictionary alloc] init];
    [self settingViews];
    [_pickerV setHidden:true];
    
    //Code to handle keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
}

-(void)settingViews
{
    //calendar view
    calView = [[[NSBundle mainBundle] loadNibNamed:@"Calendar" owner:self options:nil] objectAtIndex:0];
    calView.frame = CGRectMake(0, self.view.frame.size.height - calView.frame.size.height, self.view.frame.size.width, calView.frame.size.height);
    [calView.select addTarget:self action:@selector(selectCal:) forControlEvents:UIControlEventTouchUpInside];
    [calView.cancel addTarget:self action:@selector(cancelCal:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:calView];
    [calView setHidden: true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


/**
 *  Keyboard did show fuction
 *
 *  @param notification NSNotification
 */
-(void) keyboardDidShow:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    
    //Add tap gesture when keyboard will show
}


/**
 *  Keyboard did hide
 *
 *  @param notification NSNotification
 */

-(void) keyboardDidHide:(NSNotification *) notification
{
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

-(void)dismissKeyboard {
    [self.view endEditing:true];
}


//MARK:- tableview function

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80;
    
    if(indexPath.row == 6 ||indexPath.row == 1)
    {
        height = 90;
    }
    else if(indexPath.row == 3)
    {
        height = 160;
    }
    else if(indexPath.row == 4 || indexPath.row == 5 )
    {
        height = 150;
    }
    else if(indexPath.row == 2)
    {
        height = UITableViewAutomaticDimension;
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
        UILabel *dateLbl = [cell viewWithTag:1];
        UILabel *timeLbl = [cell viewWithTag:2];
        UIButton *dateBtn = [cell viewWithTag:3];
        UIButton *timeBtn = [cell viewWithTag:4];
        
        dateLbl.text = @"DATE";
        timeLbl.text = @"TIME";
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        NSString *date = [[NSString alloc] init];
        
        if([dataDic valueForKey:@"date"] != nil && ![[dataDic valueForKey:@"date"] isEqualToString:@""])
        {
            [dateBtn setTitle:[dataDic valueForKey:@"date"] forState:UIControlStateNormal];
        }
        else
        {
            df.dateFormat = @"dd/MM/yyyy";
            date = [df stringFromDate:[NSDate date]];
            [dataDic setValue:date forKey:@"date"];
            [dateBtn setTitle:date forState:UIControlStateNormal];
        }
        
        if([dataDic valueForKey:@"time"] != nil && ![[dataDic valueForKey:@"time"] isEqualToString:@""])
        {
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            [df1 setDateFormat:@"dd/MM/yyyy HH:mm"];
            
            df.dateFormat = @"HH:mm";
            [timeBtn setTitle:[df stringFromDate:[df1 dateFromString:[dataDic valueForKey:@"time"]]] forState:UIControlStateNormal];
        }
        else
        {
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            [df1 setDateFormat:@"dd/MM/yyyy HH:mm"];
            
            df.dateFormat = @"HH:mm";
            date = [df1 stringFromDate:[NSDate date]];
            [dataDic setValue:date forKey:@"time"];
            
            [timeBtn setTitle:[df stringFromDate:[df1 dateFromString:[dataDic valueForKey:@"time"]]] forState:UIControlStateNormal];
        }
    }
    else if (indexPath.row == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textViewCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextView *txtfld = [cell viewWithTag:2];
        UILabel *lbl = [cell viewWithTag:3];
        headLbl.text = @"MESSAGE";
        
        if([dataDic valueForKey:@"tr_message"] != nil && ![[dataDic valueForKey:@"tr_message"] isEqualToString:@""])
        {
            [lbl setHidden: true];
            txtfld.text = [dataDic valueForKey:@"tr_message"];
        }
        else
        {
            [lbl setHidden: false];
            txtfld.text = @"";
        }
    }
    else if(indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"labelCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UILabel *txtfld = [cell viewWithTag:2];
        [txtfld  setEnabled:true];
        headLbl.text = @"TO";
        
        if([dataDic valueForKey:@"users_list"] != nil && [[dataDic valueForKey:@"users_list"] count] > 0)
        {
            NSString *str = [[NSString alloc] init];
            str = @"";
            for(int i=0; i<[[dataDic valueForKey:@"users_list"] count]; i++)
            {
                if(i==0)
                {
                    str = [NSString stringWithFormat:@"%@",[[[dataDic valueForKey:@"users_list"] objectAtIndex:i] objectForKey:@"email"]];
                }
                else
                {
                    str = [NSString stringWithFormat:@"%@, %@",str,[[[dataDic valueForKey:@"users_list"] objectAtIndex:i] objectForKey:@"email"]];
                }
            }
            
            txtfld.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
            txtfld.text = str;
        }
        else
        {
            txtfld.text = @"Search User";
            txtfld.font = [UIFont fontWithName:@"Roboto-Light" size:14];
        }
    }
    else if(indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextField *txtfld = [cell viewWithTag:2];
        [txtfld  setSecureTextEntry:true];
        txtfld.text = @"";
        txtfld.placeholder = @"";
        
        if(indexPath.row == 7)
        {
            headLbl.text = @"SET ENCRYPTION PASSWORD";
            if([dataDic valueForKey:@"password"] != nil && ![[dataDic valueForKey:@"password"] isEqualToString:@""])
            {
                txtfld.text = [dataDic valueForKey:@"password"];
            }

        }
        else if(indexPath.row == 8)
        {
            headLbl.text = @"CONFIRM ENCRYPTION PASSWORD";
            if([dataDic valueForKey:@"confirm_password"] != nil && ![[dataDic valueForKey:@"confirm_password"] isEqualToString:@""])
            {
                txtfld.text = [dataDic valueForKey:@"confirm_password"];
            }
        }
        
        else if(indexPath.row == 1)
        {
            headLbl.text = @"TITLE";
            [txtfld  setSecureTextEntry:false];
//            txtfld.text
            if([dataDic valueForKey:@"tr_title"] != nil && ![[dataDic valueForKey:@"tr_title"] isEqualToString:@""])
            {
                txtfld.text = [dataDic valueForKey:@"tr_title"];
            }
            else
            {
                
                txtfld.placeholder = @"Enter title";

            }
        }
    }
    else if(indexPath.row == 4 || indexPath.row == 5)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UICollectionView *collection = [cell viewWithTag:2];
        collection.delegate = self;
        collection.dataSource = self;
        
        if(indexPath.row == 4)
        {
            headLbl.text = @"ADD IMAGE";
            collection.restorationIdentifier = @"tr_images";
        }
        else if(indexPath.row == 5)
        {
            headLbl.text = @"ADD FILES";
            collection.restorationIdentifier = @"tr_file";
        }
        
        [collection reloadData];
    }
    else if(indexPath.row == 6)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"destroyCell"];
        UILabel *headlbl = [cell viewWithTag:1];
        UIButton *dd = [cell viewWithTag:2];
        UIButton *hh = [cell viewWithTag:3];
        UIButton *mm = [cell viewWithTag:4];
        UIButton *never = [cell viewWithTag:5];
        
        headlbl.text = @"";
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"*SELF DESTROY AFTER "];
        NSMutableAttributedString * string1 = [[NSMutableAttributedString alloc] initWithString:@"(TR destroyed DD:HH:MM after read)"];
        UIFont *boldFont = [UIFont fontWithName:@"Roboto-Regular" size:16.0];
        NSRange range = [@"*SELF DESTROY AFTER " rangeOfString:@"*SELF DESTROY AFTER "];
        [string setAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                        NSFontAttributeName:boldFont} range:range];
        
        UIFont *boldFont2 = [UIFont fontWithName:@"Roboto-Italic" size:14.0];
        NSRange range2 = [@"(TR destroyed DD:HH:MM after read)" rangeOfString:@"(TR destroyed DD:HH:MM after read)"];
        [string1 setAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                NSFontAttributeName:boldFont2} range:range2];
        
        
        
        if([dataDic valueForKey:@"never"] != nil)
        {
            [never setSelected:true];
        }
        else
        {
            [never setSelected:false];
            
            if([dataDic valueForKey:@"dd"] != nil)
            {
                [dd setTitle:[dataDic valueForKey:@"dd"] forState:UIControlStateNormal];
            }
            else
            {
                [dd setTitle:@"DD" forState:UIControlStateNormal];
            }
            
            if([dataDic valueForKey:@"hh"] != nil)
            {
                [hh setTitle:[dataDic valueForKey:@"hh"] forState:UIControlStateNormal];
            }
            else
            {
                [hh setTitle:@"HH" forState:UIControlStateNormal];
            }
            
            if([dataDic valueForKey:@"mm"] != nil)
            {
                [mm setTitle:[dataDic valueForKey:@"mm"] forState:UIControlStateNormal];
            }
            else
            {
                [mm setTitle:@"MM" forState:UIControlStateNormal];
            }
        }
        
        [string appendAttributedString:string1];
        [headlbl setAttributedText:string];
         //headlbl.attributedText = string;
        headlbl.adjustsFontSizeToFitWidth = true;
        
    }
    else if(indexPath.row == 9)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        UIButton *submit = [cell viewWithTag:1];
        UIButton *draft = [cell viewWithTag:2];
        submit.layer.cornerRadius = 19;
        draft.layer.cornerRadius = 19;
        draft.layer.borderColor = [UIColor colorWithRed:134/255 green:134/255 blue:134/255 alpha:1].CGColor;
        draft.layer.borderWidth = 1;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
        
        GroupMemberViewController *vc = [story instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
        vc.from = @"tr_list";
        
        if([dataDic valueForKey:@"users_list" ] != nil)
        {
            vc.selectedDataArray = [dataDic valueForKey:@"users_list"];
        //    [vc.prevDataDic setValue:[dataDic valueForKey:@"users_list"] forKey:@"users_list"];
        }
        
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:true];
    }
}

//MARK:- collection view

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if([collectionView.restorationIdentifier isEqualToString:@"tr_images"] && [dataDic valueForKey:@"images"] != nil &&  [[dataDic valueForKey:@"images"] count] > 0)
    {
        return [[dataDic valueForKey:@"images"] count]+1;
    }
    else if([collectionView.restorationIdentifier isEqualToString:@"tr_file"] && [dataDic valueForKey:@"file"] != nil && [[dataDic valueForKey:@"file"] count] > 0)
    {
        return [[dataDic valueForKey:@"file"] count]+1;
    }
    
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    UIImageView *image = [cell viewWithTag:3];
    UILabel *lbl = [cell viewWithTag:4];
    UIImageView *img = [cell viewWithTag:5];
    [img setHidden:true];
    
    if([collectionView.restorationIdentifier isEqualToString:@"tr_images"])
    {
        lbl.text = @"";
        
        if([dataDic valueForKey:@"images"] == nil || (indexPath.row == [[dataDic valueForKey:@"images"] count]))
        {
            [image setImage: [UIImage imageNamed: @"addImage"]];
            lbl.text = @"";
        }
        else
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            NSString *yearString = [formatter stringFromDate:[NSDate date]];
            
            [image setImage:[UIImage imageWithData:[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row]]];
            lbl.text = [NSString stringWithFormat:@"TR%ld_%@.jpg", indexPath.row + 1, yearString];
            
            if([[NSString stringWithFormat:@"%@", [[dataDic valueForKey:@"tr_images_selected"] objectAtIndex:indexPath.row]] isEqualToString:@"1"])
            {
                [img setHidden:false];
            }
            else
            {
                [img setHidden:true];
            }
        }
        
    }
    else if([collectionView.restorationIdentifier isEqualToString:@"tr_file"])
    {
        lbl.text = @"";
        
        if([dataDic valueForKey:@"file"] == nil || indexPath.row == [[dataDic valueForKey:@"file"] count])
        {
            [image setImage: [UIImage imageNamed: @"addFile"]];
        }
        else
        {
            NSString *name = [NSString stringWithFormat:@"%@", [[dataDic valueForKey:@"file_name"] objectAtIndex:indexPath.row]];
            
            if([name containsString:@"pdf"])
            {
                [image setImage:[UIImage imageNamed:@"pdf"]];
            }
            else
            {
                [image setImage:[UIImage imageNamed:@"file_default"]];
            }
            
            if([[NSString stringWithFormat:@"%@", [[dataDic valueForKey:@"tr_files_selected"] objectAtIndex:indexPath.row]] isEqualToString:@"1"])
            {
                [img setHidden:false];
            }
            else
            {
                [img setHidden:true];
            }
            
            lbl.text = name;
        }
    }
    
    lbl.adjustsFontSizeToFitWidth = true;
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([collectionView.restorationIdentifier isEqualToString:@"tr_images"])
    {
        if([dataDic valueForKey:@"images"] == nil || (indexPath.row == [[dataDic valueForKey:@"images"] count]))
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *photo = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
                                        clickImg.delegate = self;
                                        clickImg.allowsEditing = NO;
                                        clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
                                        [self presentViewController: clickImg animated:YES completion:nil];
                                    }];
            
            UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
                                         clickImg.delegate = self;
                                         clickImg.allowsEditing = NO;
                                         clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
                                         clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
                                         [self presentViewController: clickImg animated:YES completion:nil];
                                     }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [alert addAction:photo];
            [alert addAction:camera];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            NSMutableArray *arr = [dataDic valueForKey:@"tr_images_selected"];
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *img = [cell viewWithTag:5];
            
            if([[arr objectAtIndex:indexPath.row] isEqualToString:@"1"])
            {
                [arr replaceObjectAtIndex:indexPath.row withObject:@"0"];
                [img setHidden:true];
            }
            else
            {
                [img setHidden:false];
                [arr replaceObjectAtIndex:indexPath.row withObject:@"1"];
            }
            
            [dataDic setValue:arr forKey:@"tr_images_selected"];
        }
    }
    else if([collectionView.restorationIdentifier isEqualToString:@"tr_file"])
    {
        if([dataDic valueForKey:@"file"] == nil || (indexPath.row == [[dataDic valueForKey:@"file"] count]))
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cloud = [UIAlertAction actionWithTitle:@"iCloud" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.composite-content"]//@"public.content"
                                                                                                                                                inMode:UIDocumentPickerModeImport];
                                        documentPicker.delegate = self;
                                        
                                        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
                                        [self presentViewController:documentPicker animated:YES completion:nil];
                                    }];
            
            UIAlertAction *dropbox = [UIAlertAction actionWithTitle:@"Dropbox" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                      {
                                          
                                          [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypePreview
                                                                          fromViewController:self completion:^(NSArray *results)
                                           {
                                               if ([results count]) {
                                                   
                                                   DBChooserResult *result = results[0];
                                                   
                                                   // Process results from Chooser
                                                   
                                                   NSData * data = [[NSData alloc] initWithContentsOfURL: result.link];
                                                   if ( data != nil )
                                                   {
                                                       
                                                       if ([data length] > 5000000)
                                                       {
                                                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"File cannot be greater than 5Mb." preferredStyle:UIAlertControllerStyleAlert];
                                                           UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                                                           [alert addAction:ok];
                                                           return;
                                                       }
                                                       
                                                   }
                                                   else
                                                   {
                                                    //   NSLog(@"INVALID URL!!!");
                                                   }
                                                   
                                                   
                                               } else {
                                                   // User canceled the action
                                               }
                                           }];
                                          
                                          
                                          
                                      }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [alert addAction:cloud];
            [alert addAction:dropbox];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIImageView *img = [cell viewWithTag:5];
            NSMutableArray *arr = [dataDic valueForKey:@"tr_files_selected"];
            
            if([[NSString stringWithFormat:@"%@", [arr objectAtIndex:indexPath.row]] isEqualToString:@"1"])
            {
                [img setHidden:true];
                [arr replaceObjectAtIndex:indexPath.row withObject:@"0"];
            }
            else
            {
                [img setHidden:false];
                [arr replaceObjectAtIndex:indexPath.row withObject:@"1"];
            }
            [dataDic setValue:arr forKey:@"tr_files_selected"];
        }
    }
}

//MARK:- textfield functions

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView addGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    [textField setSecureTextEntry:false];
    
    if(indexPath.row == 1)
    {
         textField.returnKeyType = UIReturnKeyDone;
    }
    else
    if(indexPath.row == 7 || indexPath.row == 8)
    {
        
        [textField setSecureTextEntry:true];
        textField.returnKeyType = UIReturnKeyNext;
        
        if(indexPath.row == 8)
        {
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView removeGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    if(indexPath.row == 7)
    {
        [dataDic setValue:textField.text forKey:@"password"];
    }
    else if(indexPath.row == 8)
    {
        [dataDic setValue:textField.text forKey:@"confirm_password"];
    }
    else if(indexPath.row == 1)
    {
        [dataDic setValue:textField.text forKey:@"tr_title"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    if(indexPath.row == 7)
    {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath: indexPath];
        UITextField *txt = [cell viewWithTag:2];
        [textField resignFirstResponder];
        [txt becomeFirstResponder];
    }else
    {
        [self.view endEditing:true];
    }
    
    return true;
}

//MARK:- textview functions

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.tableView addGestureRecognizer:tap];
    CGPoint hitPoint = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = [cell viewWithTag:3];
    [lbl setHidden:true];
    
    textView.keyboardType = UIKeyboardTypeASCIICapable;
    textView.returnKeyType = UIReturnKeyDone;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.tableView removeGestureRecognizer:tap];
    [dataDic setValue:[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"tr_message"];
}

- (void) textViewDidChange:(UITextView *)textView
{
    CGPoint hitPoint = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *lbl = [cell viewWithTag:3];
    
    if(![textView hasText]) {
        [lbl setHidden:false];
    }
    else
    {
        [lbl setHidden:true];
    }
}


//#pragma mark- UIActionSheetDelegate
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
//    clickImg.delegate = self;
//    clickImg.allowsEditing = YES;
//    if (buttonIndex == 0)
//    {
//        clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
//        [self presentViewController: clickImg animated:YES completion:nil];
//    }
//    else if (buttonIndex == 1)
//    {
//        clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
//        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
//        [self presentViewController: clickImg animated:YES completion:nil];
//    }
//}

//MARK:- picker view functions

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;  // Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
    return [pickerArray count];//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerArray objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

#pragma mark - iCloud files
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport)
    {
        NSData * data = [[NSData alloc] initWithContentsOfURL: url];
        if ( data != nil )
        {
            if ([data length] > 5000000)
            {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"File cannot be greater than 5Mb." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:ok];
                return;
            }
            NSString *name = [NSString stringWithFormat:@"%@", [url lastPathComponent]];
            NSString *type = [[NSString stringWithFormat:@"%@",[url lastPathComponent]] componentsSeparatedByString:@"."][1];
            
            if([dataDic valueForKey:@"file_name"] != nil && [[dataDic valueForKey:@"file_name"] count] > 0)
            {
                NSMutableArray *arr = [[dataDic valueForKey:@"file_name"] mutableCopy];
                [arr addObject:name];
                [dataDic setValue:arr forKey:@"file_name"];
                
                NSMutableArray *file = [[dataDic valueForKey:@"file"] mutableCopy];
                [file addObject: data];
                [dataDic setValue:file forKey:@"file"];
                
                NSMutableArray *arr1 = [[dataDic valueForKey:@"tr_files_selected"] mutableCopy];
                [arr1 addObject:@"1"];
                [dataDic setValue:arr1 forKey:@"tr_files_selected"];
            }
            else
            {
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                [arr addObject:name];
                [dataDic setValue:arr forKey:@"file_name"];
                
                NSMutableArray *arr1 = [[NSMutableArray alloc] init];
                [arr1 addObject:data];
                [dataDic setValue:arr1 forKey:@"file"];
                
                NSMutableArray *arr2 = [[NSMutableArray alloc] init];
                [arr2 addObject:@"1"];
                [dataDic setValue:arr2 forKey:@"tr_files_selected"];
            }
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:4 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
            //      [self uploadDocument:data withThumbnailImage:nil withFileName:[url lastPathComponent] forType:[NSString stringWithFormat:@"application/%@",type] withDuration:@""];
        }
        else
        {
       //     NSLog(@"INVALID URL!!!");
        }
    }
}


#pragma mark- UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *profilePic = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *profile = UIImageJPEGRepresentation(profilePic, 0.6);
    NSData *thumb = UIImageJPEGRepresentation(profilePic, 0.3);
    
    if ([thumb length] > 5000000)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if([dataDic valueForKey:@"images"] != nil && [[dataDic valueForKey:@"images"] count] > 0)
    {
        NSMutableArray *arr = [[dataDic valueForKey:@"images"] mutableCopy];
        [arr addObject:profile];
        [dataDic setValue:arr forKey:@"images"];
        
        NSMutableArray *arr1 = [[dataDic valueForKey:@"tr_images_selected"] mutableCopy];
        [arr1 addObject:@"1"];
        [dataDic setValue:arr1 forKey:@"tr_images_selected"];
        
        NSMutableArray *arr2 = [[dataDic valueForKey:@"tr_images_thumb"] mutableCopy];
        [arr2 addObject:thumb];
        [dataDic setValue:arr2 forKey:@"tr_images_thumb"];
    }
    else
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:profile];
        [dataDic setValue:arr forKey:@"images"];
        
        NSMutableArray *arr1 = [[NSMutableArray alloc] init];
        [arr1 addObject:@"1"];
        [dataDic setValue:arr1 forKey:@"tr_images_selected"];
        
        NSMutableArray *arr2 = [[NSMutableArray alloc] init];
        [arr2 addObject:thumb];
        [dataDic setValue:arr2 forKey:@"tr_images_thumb"];
    }
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
}

//MARK:- button actions

-(IBAction) sidemenu: (UIButton*) sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

-(IBAction) send: (UIButton*) sender
{
    [self.view endEditing:true];
    if([dataDic valueForKey:@"date"] == nil)
    {
        [SVProgressHUD showErrorWithStatus:emptyDate];
        return;
    }
    else if([dataDic valueForKey:@"time"] == nil)
    {
        [SVProgressHUD showErrorWithStatus:emptyTime];
        return;
    }
    else if([dataDic valueForKey:@"tr_title"] == nil || [[dataDic valueForKey:@"tr_title"] isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:emptyTitle];
        return;
    }
    else if([dataDic valueForKey:@"users_list"] == nil || [[dataDic valueForKey:@"users_list"] count] == 0)
    {
        [SVProgressHUD showErrorWithStatus:emptyUsers];
        return;
    }
    else if([dataDic valueForKey:@"tr_message"] == nil)
    {
        [SVProgressHUD showErrorWithStatus:emptyMessage];
        return;
    }
    else if([dataDic valueForKey:@"dd"] == nil && [dataDic valueForKey:@"mm"] == nil && [dataDic valueForKey:@"hh"] == nil && [dataDic valueForKey:@"never"] == nil)
    {
        [SVProgressHUD showErrorWithStatus:emptyDestroy];
        return;
    }
    else if([dataDic valueForKey:@"password"] == nil || [[dataDic valueForKey:@"password"] isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:emptypassword];
        return;
    }
    else if([appDelegate.constant passwordValidation:[dataDic valueForKey:@"password"]] == false)
    {
        [SVProgressHUD showErrorWithStatus:validPassword];
        return;
    }
    else if([dataDic valueForKey:@"confirm_password"] == nil || [[dataDic valueForKey:@"confirm_password"] isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:emptyCPassword];
        return;
    }
    else if(![[dataDic valueForKey:@"confirm_password"] isEqualToString:[dataDic valueForKey:@"password"]])
    {
        [SVProgressHUD showErrorWithStatus:matchTRPassword];
        return;
    }
    
    
    
    NSMutableDictionary *params= [[NSMutableDictionary alloc] init];
    [params setValue:[dataDic valueForKey:@"confirm_password"] forKey:@"confirm_password"];
    [params setValue:[dataDic valueForKey:@"tr_title"] forKey:@"tr_title"];
    [params setValue:[dataDic valueForKey:@"password"] forKey:@"password"];
    [params setValue:[appDelegate.constant generateMessage:[dataDic valueForKey:@"tr_message"]] forKey:@"tr_message"];
    [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    
    //to send as draft or not
    if(sender.tag == 1)
    {
        [params setValue:@"0" forKey:@"draft"];
    }
    else
    {
        [params setValue:@"1" forKey:@"draft"];
    }
    
    
    //tr_post_date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    [df2 setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    NSDateFormatter *df3 = [[NSDateFormatter alloc] init];
    [df3 setDateFormat:@"HH:mm"];
    
    [params setValue:[NSString stringWithFormat:@"%@ %@", [df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"date"]]], [df3 stringFromDate:[df2 dateFromString:[dataDic valueForKey:@"time"]]]] forKey:@"tr_post_time"];
    
    //user id
    NSMutableArray *user = [[NSMutableArray alloc] init];
    for(int i = 0;i<[[dataDic valueForKey:@"users_list"] count]; i++)
    {
        [user addObject:[NSString stringWithFormat:@"%@", [[[dataDic valueForKey:@"users_list"] objectAtIndex:i] valueForKey:@"id"]]];
    }
    [params setValue:user forKey:@"recieptent"];
    
    //destroy time
    if([dataDic valueForKey:@"never"] != nil)
    {
        
        [params setValue:@"never" forKey:@"destroy_time"];
//        if([dataDic valueForKey:@"destroy_time"] != nil)
//        {
//            [dataDic removeObjectForKey:@"destroy_time"];
//        }
    }
    else
    {
        NSString *str = [[NSString alloc] init];

        if([dataDic valueForKey:@"dd"] != nil)
        {
            str = [NSString stringWithFormat:@"%@", [dataDic valueForKey:@"dd"]];
        }
        else
        {
            str = @"00";
        }
        
        if([dataDic valueForKey:@"hh"] != nil)
        {
            str = [NSString stringWithFormat:@"%@:%@",str, [dataDic valueForKey:@"hh"]];
        }
        else
        {
            str = [NSString stringWithFormat:@"%@:%@",str, @"00"];
        }
        
        if([dataDic valueForKey:@"mm"] != nil)
        {
            str = [NSString stringWithFormat:@"%@:%@",str, [dataDic valueForKey:@"mm"]];
        }
        else
        {
            str = [NSString stringWithFormat:@"%@:%@",str, @"00"];
        }
       
        [params setValue:str forKey:@"destroy_time"];
    }
    
    //image clear
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSMutableArray *thumb = [[NSMutableArray alloc] init];
    for(int i=0;i< [[dataDic valueForKey:@"tr_images_selected"] count];i++)
    {
        if([[[dataDic valueForKey:@"tr_images_selected"] objectAtIndex:i] isEqualToString:@"1"])
        {
            [images addObject:[[dataDic valueForKey:@"images"] objectAtIndex:i]];
            [thumb addObject:[[dataDic valueForKey:@"tr_images_thumb"] objectAtIndex:i]];
        }
    }
    [params setObject:images forKey:@"tr_images"];
    [params setObject:thumb forKey:@"tr_images_thumb"];
    
    
    //file clear
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSMutableArray *name = [[NSMutableArray alloc] init];
    for(int i=0;i< [[dataDic valueForKey:@"tr_files_selected"] count];i++)
    {
        if([[[dataDic valueForKey:@"tr_files_selected"] objectAtIndex:i] isEqualToString:@"1"])
        {
            [files addObject:[[dataDic valueForKey:@"file"] objectAtIndex:i]];
            [name addObject:[[dataDic valueForKey:@"file_name"] objectAtIndex:i]];
        }
    }
    [params setObject:files forKey:@"tr_file"];
    [params setObject:name forKey:@"file_name_"];
    
    
    [self webservice:params];
}

-(IBAction) neverBtn: (UIButton*) sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    if(sender.isSelected == YES)
    {
        [dataDic removeObjectForKey:@"never"];
        [sender setSelected:false];
    }
    else
    {
     //   UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        //        UIButton *dd = [cell viewWithTag:2];
        //        UIButton *hh = [cell viewWithTag:3];
        //        UIButton *mm = [cell viewWithTag:4];
        
        [sender setSelected:true];
        [dataDic setValue:@"Y" forKey:@"never"];
        
        if([dataDic valueForKey:@"dd"] != nil)
        {
            [dataDic removeObjectForKey:@"dd"];
        }
        
        if([dataDic valueForKey:@"mm"] != nil)
        {
            [dataDic removeObjectForKey:@"mm"];
        }
        
        if([dataDic valueForKey:@"hh"] != nil)
        {
            [dataDic removeObjectForKey:@"hh"];
        }
    }
    
    [self.tableView reloadData];
}


//calendar button
-(IBAction) dayPicker: (UIButton*) sender
{
    [pickerArray removeAllObjects];
    if(sender.tag == 2)
    {
        for (int i = 1; i <= 31; i++)
        {
            [pickerArray addObject: [NSString stringWithFormat:@"%d", i]];
        }
        _pickerView.tag = 2;
    }
    else if(sender.tag == 3)
    {
        for (int i = 1; i <= 24; i++)
        {
            [pickerArray addObject: [NSString stringWithFormat:@"%d", i]];
        }
        _pickerView.tag = 3;
    }
    else if(sender.tag == 4)
    {
        for (int i = 1; i <= 60; i++)
        {
            [pickerArray addObject: [NSString stringWithFormat:@"%d", i]];
        }
        _pickerView.tag = 4;
    }
    
    [self.tableView setUserInteractionEnabled:false];
    [_pickerView reloadAllComponents];
    [_pickerV setHidden:false];
    [_pickerView selectRow:0 inComponent:0 animated:NO];
}

-(IBAction) calSelection: (UIButton*) sender
{
    [calView setHidden:false];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    if(sender.tag == 3)
    {
        calView.datePicker.datePickerMode = UIDatePickerModeDate;
        calView.datePicker.minimumDate = [NSDate date];

        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [calView.datePicker setLocale:locale];
        if([dataDic valueForKey:@"date"] == nil)
        {
            calView.datePicker.date = [NSDate date];
        }
        else
        {
            [df setDateFormat:@"dd/mm/yyyy"];
            calView.datePicker.date = [df dateFromString:[dataDic valueForKey:@"date"]];
        }
        
        calView.tag = 3;
    }
    else
    {
        calView.datePicker.datePickerMode = UIDatePickerModeTime;
        calView.datePicker.minimumDate = [NSDate date];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        [calView.datePicker setLocale:locale];
        
        if([dataDic valueForKey:@"time"] == nil)
        {
            calView.datePicker.date = [NSDate date];
        }
        else
        {
            [df setDateFormat:@"dd/MM/yyyy HH:mm"];
            calView.datePicker.date = [df dateFromString:[dataDic valueForKey:@"time"]];
        }
        
        calView.tag = 4;
    }
}

-(IBAction)cancelPicker: (UIButton*) sender
{
    [self.tableView setUserInteractionEnabled:true];
    [_pickerV setHidden:true];
}

-(IBAction)selectPicker: (UIButton*) sender
{
    NSInteger row;
    row = [_pickerView selectedRowInComponent:0];
    
    if([dataDic valueForKey:@"never"] != nil)
    {
        [dataDic removeObjectForKey:@"never"];
    }
    
    if(_pickerView.tag == 2)
    {
        [dataDic setValue:[pickerArray objectAtIndex:row] forKey:@"dd"];
    }
    else if(_pickerView.tag == 3)
    {
        [dataDic setValue:[pickerArray objectAtIndex:row] forKey:@"hh"];
    }
    else if(_pickerView.tag == 4)
    {
        [dataDic setValue:[pickerArray objectAtIndex:row] forKey:@"mm"];
    }
    
    [self.tableView setUserInteractionEnabled:true];
    [_pickerV setHidden:true];
    [self.tableView reloadData];
}

-(IBAction)cancelCal: (UIButton*) sender
{
    [calView setHidden:true];
}

-(IBAction)selectCal: (UIButton*) sender
{
    [calView setHidden:true];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* TimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:TimeZone];
    
    if(calView.tag == 3)
    {
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dat = [dateFormatter stringFromDate: calView.datePicker.date];
        [dataDic setValue:dat forKey:@"date"];
    }
    else if(calView.tag == 4)
    {
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
//        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//        [calView.datePicker setLocale:locale];
        NSString *dat = [dateFormatter stringFromDate: calView.datePicker.date];
        [dataDic setValue:dat forKey:@"time"];
    }
    
    [self.tableView reloadData];
}

//MARK:- protocol
-(void)getUserList:(NSMutableArray *)arr;
{
    [dataDic setValue:arr forKey:@"users_list"];
    [self.tableView reloadData];
}

-(void)webservice:(NSMutableDictionary *)params
{
    [SVProgressHUD dismiss];
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please Wait"];
    
    WebConnector *webconnector = [[WebConnector alloc] init];
    [webconnector create_TR:params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            [dataDic removeAllObjects];
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [self.tabBarController setSelectedIndex:0];
            });
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    
                    [self webservice:params];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
        }
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
}

@end
