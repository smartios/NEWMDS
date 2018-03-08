//
//  ProfileViewController.m
//  MDS
//
//  Created by SL-167 on 12/7/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "ProfileViewController.h"
#import "ViewController.h"
#import "UIImageView+AFNetworking.h"
///AFNetworking/

@interface ProfileViewController ()
<UIImagePickerControllerDelegate, UIActionSheetDelegate>
@end

@implementation ProfileViewController
{
    NSData *profile;
    UITapGestureRecognizer *tap;
    UIRefreshControl *pullToRefresh;
}
@synthesize dataDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if([_from isEqualToString:@"editprofile"])
    {
        [_menuBtn setImage: [UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _header.text = @"EDIT PROFILE";
    }
    else if([_from isEqualToString:@"otherUserProfile"])
    {
        [_menuBtn setImage: [UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _header.text = @"PROFILE";
    }
    else
    {
        pullToRefresh = [[UIRefreshControl alloc] init];
        [self.tableView addSubview: pullToRefresh];
        [pullToRefresh addTarget: self action:@selector(myprofileWebservice) forControlEvents:UIControlEventValueChanged];
         pullToRefresh.layer.zPosition = -1;
        [_menuBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        _header.text = @"MY PROFILE";
    }
    
    //Code to handle keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
}

-(void) viewWillAppear:(BOOL)animated
{
    if([_from isEqualToString:@"profile"])
    {
        [self myprofileWebservice];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//MARK:- tableview functions

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_from isEqualToString:@"otherUserProfile"])
    {
        return 5;
    }
    else
    {
        return 6;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0 && ([_from isEqualToString:@"editprofile"] || ([_from isEqualToString:@"otherUserProfile"])))
    {
        return 150;
    }
    else if(indexPath.row == 0)
    {
        return 100;
    }
    else
    {
        return 70;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.row == 0 && [_from isEqualToString:@"profile"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        UIImageView *userImg = [cell viewWithTag:1];
        UITextField *name = [cell viewWithTag:2];
        [name setEnabled:false];
        // UIButton *editP = [cell viewWithTag:3];
        userImg.layer.cornerRadius = userImg.frame.size.width/2;
        
        if([dataDic valueForKey:@"first_name"] != nil && [dataDic valueForKey:@"last_name"] != nil)
        {
            name.text = [NSString stringWithFormat:@"%@ %@",[dataDic valueForKey:@"first_name"], [dataDic valueForKey:@"last_name"]];
        }
        
        if([dataDic valueForKey:@"profile_picture"] != nil && [[dataDic valueForKey:@"profile_picture"] isKindOfClass: [NSString class]])
        {
            //[dataDic objectForKey: @"profile_picture"]
            NSString *url = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL, [dataDic valueForKey:@"profile_picture"]];
            [userImg setImageWithURL:[NSURL URLWithString: url] placeholderImage:[UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            [userImg setImage:[UIImage imageNamed:@"default_profile"]];
        }
    }
    else if(indexPath.row == 0 && ([_from isEqualToString:@"editprofile"] || ([_from isEqualToString:@"otherUserProfile"])))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"editImage"];
        UIImageView *userImg = [cell viewWithTag:1];
        UIButton *camera = [cell viewWithTag:2];
        camera.layer.cornerRadius = camera.frame.size.width/2;
        userImg.layer.cornerRadius = userImg.frame.size.width/2;
        
        if([_from isEqualToString:@"otherUserProfile"])
        {
            [camera setHidden:true];
        }
        else
        {
            [camera setHidden:false];
        }
        
        if(![profile isKindOfClass:[NSNull class]] && profile != nil)
        {
            userImg.image = [UIImage imageWithData:profile];
        }
        else if([dataDic valueForKey:@"profile_picture"] != nil && [[dataDic valueForKey:@"profile_picture"] isKindOfClass: [NSString class]])
        {
            NSString *url = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL, [dataDic valueForKey:@"profile_picture"]];
            [userImg setImageWithURL:[NSURL URLWithString: url] placeholderImage:[UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            [userImg setImage:[UIImage imageNamed:@"default_profile"]];
        }
    }
    else if(indexPath.row == 5)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"resetCell"];
        UIButton *reset = [cell viewWithTag:1];
        reset.layer.cornerRadius = 19;
        
        if([_from isEqualToString:@"profile"])
        {
            [reset setTitle:@"RESET PASSWORD" forState: UIControlStateNormal];
            [reset setTitleColor: [UIColor colorWithRed:0.75 green:0.00 blue:0.00 alpha:1.0] forState: UIControlStateNormal];
            reset.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [reset setTitle:@"SUBMIT" forState: UIControlStateNormal];
            reset.backgroundColor = [UIColor colorWithRed:0.75 green:0.00 blue:0.00 alpha:1.0];
            [reset setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
        UILabel *head = [cell viewWithTag:1];
        UITextField *name = [cell viewWithTag:2];
        [name setEnabled:true];
        if([_from isEqualToString:@"profile"] || ([_from isEqualToString:@"otherUserProfile"]))
        {
            [name setEnabled:false];
        }
        else
        {
            [name setEnabled:true];
        }
        
        if(indexPath.row == 1)
        {
            head.text = @"FIRST NAME";
            name.text = @"";
            if([dataDic valueForKey:@"first_name"] != nil && ![[dataDic valueForKey:@"first_name"] isEqual:[NSNull null]])
            {
                name.text = [dataDic valueForKey:@"first_name"];
            }
        }
        else if(indexPath.row == 2)
        {
            head.text = @"LAST NAME";
            name.text = @"";
            if([dataDic valueForKey:@"last_name"] != nil && ![[dataDic valueForKey:@"last_name"] isEqual:[NSNull null]])
            {
                name.text = [dataDic valueForKey:@"last_name"];
            }
        }
        else if(indexPath.row == 3)
        {
            [name setEnabled:false];
            head.text = @"EMAIL";
            name.text = @"";
            if([dataDic valueForKey:@"email"] != nil && ![[dataDic valueForKey:@"email"] isEqual:[NSNull null]])
            {
                name.text = [dataDic valueForKey:@"email"];
            }
        }
        else if(indexPath.row == 4)
        {
            head.text = @"MOBILE NUMBER";
            name.text = @"";
            if([dataDic valueForKey:@"phone"] != nil && ![[dataDic valueForKey:@"phone"] isEqual:[NSNull null]])
            {
                name.text = [dataDic valueForKey:@"phone"];
            }
        }
        
        name.adjustsFontSizeToFitWidth = true;
    }
    
    return cell;
}

//MARK:- textfield functions

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    [self.tableView addGestureRecognizer:tap];
    
    
    if(indexPath.row == 1|| indexPath.row == 2)
    {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    
    if(indexPath.row == 4)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.returnKeyType = UIReturnKeyDone;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyNext;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView removeGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    if(indexPath.row == 1)
    {
        [dataDic setValue:textField.text forKey:@"first_name"];
    }
    else if(indexPath.row == 2)
    {
        [dataDic setValue:textField.text forKey:@"last_name"];
    }
    else if(indexPath.row == 3)
    {
        [dataDic setValue:textField.text forKey:@"email"];
    }
    else if(indexPath.row == 4)
    {
        [dataDic setValue:textField.text forKey:@"phone"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    if(indexPath.row == 4)
    {
        [self.view endEditing:YES];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath: indexPath];
        UITextField *txt = [cell viewWithTag:2];
        [textField resignFirstResponder];
        [txt becomeFirstResponder];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    
    if(indexPath.row == 4)
    {
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:textField.text];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
        
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength <= 11 && stringIsValid);
    }
    else if(indexPath.row == 1 || indexPath.row == 2)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 15;
    }
    return YES;
}



//MARK:_ button handling
-(IBAction) editProfile: (UIButton*) sender
{
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.from = @"editprofile";
    vc.dataDic = [dataDic mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction) reset: (UIButton*) sender
{
    if([_from isEqualToString:@"profile"])
    {
        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.from = @"reset";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self submit];
    }
    
}

-(IBAction) camera: (UIButton*) sender
{
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Use Photo Gallery" otherButtonTitles:@"Use Camera", nil];
    [option showInView:self.view];
}

-(IBAction) sidemenu: (UIButton*) sender {
    
    if([_from isEqualToString:@"editprofile"] || ([_from isEqualToString:@"otherUserProfile"]))
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }
    
}


#pragma mark- UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
    clickImg.delegate = self;
    clickImg.allowsEditing = YES;
    if (buttonIndex == 0)
    {
        clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController: clickImg animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController: clickImg animated:YES completion:nil];
    }
}


#pragma mark- UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *profilePic = [info valueForKey:UIImagePickerControllerEditedImage];
    //    profileImgData = UIImagePNGRepresentation(profileImg.image);
    profile = UIImageJPEGRepresentation(profilePic, 0.6);
    [self.tableView reloadData];
}


-(void)submit
{
    [self.view endEditing:true];
    if([dataDic valueForKey: @"first_name"] == nil || [[dataDic valueForKey:@"first_name"] isEqualToString: @""])
    {
        [SVProgressHUD showErrorWithStatus: emptyFName];
        return;
    }
    else if([dataDic valueForKey: @"last_name"] == nil || [[dataDic valueForKey:@"last_name"] isEqualToString: @""])
    {
        [SVProgressHUD showErrorWithStatus: emptyLName];
        return;
    }
    else if([dataDic valueForKey: @"phone"] == nil || [[dataDic valueForKey:@"phone"] isEqualToString: @""])
    {
        [SVProgressHUD showErrorWithStatus: emptyPhone];
        return;
    }
    else if((![profile isKindOfClass:[NSNull class]] && profile == nil) && ([dataDic valueForKey: @"profile_picture"] == nil || [[dataDic valueForKey: @"profile_picture"] isKindOfClass:[NSNull class]]))
    {
        [SVProgressHUD showErrorWithStatus: emptyProfile];
        return;
    }
    
    [self myprofileWebservice];
}

-(void)myprofileWebservice
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    
    [pullToRefresh endRefreshing];
    [SVProgressHUD showWithStatus:@"Please Wait"];
    WebConnector *webConnector = [[WebConnector alloc] init];
    if([_from isEqualToString:@"profile"])
    {
        [_tableView setHidden:true];
        NSString *url = [NSString stringWithFormat:@"%@api/auth/myprofile?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
        
        [webConnector profile:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [_tableView setHidden:false];
            if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
            {
                [SVProgressHUD dismiss];
                //[SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
                dataDic = [[responseObject valueForKey: @"data"] mutableCopy];
                NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                
                //remove null values
                for(NSString *i in [dataDic allKeys])
                {
                    if ([[dataDic valueForKey: i] isEqual: [NSNull null]] || [[NSString stringWithFormat:@"%@",[dataDic valueForKey: i]] isEqualToString:@"<null>"])
                    {
                        [dataDic setValue:@"" forKey:i];
                    }
                }
                
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@", [dataDic valueForKey:@"first_name"], [dataDic valueForKey:@"last_name"]] forKey:@"name"];
                [[NSUserDefaults standardUserDefaults] setValue:[dataDic valueForKey:@"id"] forKey:@"user_id"];
                
                [dataDic setValue:[dataDic valueForKey:@"id"] forKey:@"user_id"];
                [dic setValue:dataDic forKey:@"users_details"];
                [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                [_tableView reloadData];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self myprofileWebservice];
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
                [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            }
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"Please try again."];
        }];
    }
    else
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params = [dataDic mutableCopy];
        [params removeObjectForKey:@"profile_picture"];
        [webConnector editProfile:params profilePhoto:profile completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
            {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    [self.navigationController popViewControllerAnimated:true];
                });
                
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self myprofileWebservice];
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
                [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            }
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"Please try again."];
        }];
    }
}

@end
