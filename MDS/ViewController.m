//
//  ViewController.m
//  MDS
//
//  Created by SL-167 on 12/1/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "ViewController.h"
#import "RightMenuViewController.h"
#import "HomeViewController.h"
#import <Google/Analytics.h>

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableDictionary *dataDic;
    UITapGestureRecognizer *tap;
    //NSString *_from;
}

@synthesize num;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_from == nil)
    {
        _from = @"";
        num = 4;
    }
    else if([_from isEqualToString:@"reset"])
    {
        num = 5;
    }
    else if([_from isEqualToString:@"forgot"])
    {
        num = 3;
    }
    
    dataDic = [[NSMutableDictionary alloc] init];
    
    //Code to handle keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    // Do any additional setup after loading the view, typically _from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:@"ViewDidLoad" value:@"LoginViewDidLoad"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

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
    
    [self.tblView setContentInset:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    
    [self.tblView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    
    //Add tap gesture when keyboard will show
}


/**
 *  Keyboard did hide
 *
 *  @param notification NSNotification
 */

-(void) keyboardDidHide:(NSNotification *) notification
{
    [self.tblView setContentInset:UIEdgeInsetsZero];
    [self.tblView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

-(void)dismissKeyboard {
    [self.view endEditing:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//MARK:- tableview handling
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height;
    
    if(indexPath.row == 0)
    {
        height = 180.0;
    }
    else
    {
        height = 80;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    }
    else if(indexPath.row == num-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        UIButton *signIn = [cell viewWithTag:1];
        UIButton *forgot = [cell viewWithTag:2];
        signIn.layer.cornerRadius = 19;
        
        if([_from isEqualToString: @""])
        {
            [signIn setTitle:@"SIGN IN" forState:UIControlStateNormal];
            [forgot setTitle:@"Forgot Password?" forState:UIControlStateNormal];
        }
        else
        {
            [signIn setTitle:@"SUBMIT" forState:UIControlStateNormal];
            [forgot setTitle:@"Back" forState:UIControlStateNormal];
        }
    }
    else if(![_from isEqualToString:@"reset"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextField *textfld = [cell viewWithTag:2];
        UIButton *show = [cell viewWithTag:3];
        
        if(indexPath.row == 1)
        {
            headLbl.text = @"EMAIL";
            
            for(NSLayoutConstraint *i in show.constraints)
            {
                if([i.identifier isEqualToString:@"width"])
                {
                    i.constant = 0;
                }
            }
            
            if([dataDic valueForKey:@"email"] != nil)
            {
                textfld.text = [dataDic valueForKey:@"email"];
            }
            else
            {
                textfld.text = @"";
            }
        }
        else if(indexPath.row == 2)
        {
            for(NSLayoutConstraint *i in show.constraints)
            {
                if([i.identifier isEqualToString:@"width"])
                {
                    i.constant = 36;
                }
            }
            
            headLbl.text = @"PASSWORD";
            if([dataDic valueForKey:@"password"] != nil && [[dataDic valueForKey:@"password"] isEqualToString:@""])
            {
                [show setHidden:false];
                textfld.text = [dataDic valueForKey:@"password"];
            }
            else
            {
                [show setHidden:true];
            }
        }
    }
    else if([_from isEqualToString:@"reset"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextField *textfld = [cell viewWithTag:2];
        UIButton *show = [cell viewWithTag:3];
        
        for(NSLayoutConstraint *i in show.constraints)
        {
            if([i.identifier isEqualToString:@"width"])
            {
                i.constant = 0;
            }
        }
        
        if(indexPath.row == 1)
        {
            headLbl.text = @"OLD PASSWORD";
            if([dataDic valueForKey:@"old_password"] != nil)
            {
                textfld.text = [dataDic valueForKey:@"old_password"];
            }
        }
        else if(indexPath.row == 2)
        {
            headLbl.text = @"NEW PASSWORD";
            if([dataDic valueForKey:@"password"] != nil)
            {
                textfld.text = [dataDic valueForKey:@"password"];
            }
        }
        else if(indexPath.row == 3)
        {
            headLbl.text = @"CONFIRM NEW PASSWORD";
            if([dataDic valueForKey:@"confirm_password"] != nil)
            {
                textfld.text = [dataDic valueForKey:@"confirm_password"];
            }
        }
    }
    
    _tblView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}


//MARK:- textfield functions

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tblView addGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    
     if([_from isEqualToString: @""] && indexPath.row == 1)
     {
         textField.keyboardType = UIKeyboardTypeEmailAddress;
     }
    
    if(indexPath.row == num-2)
    {
        textField.returnKeyType = UIReturnKeyDone;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyNext;
    }

    
    if((indexPath.row == 2 && [_from isEqualToString:@""]) || [_from isEqualToString:@"reset"])
    {
        textField.secureTextEntry = YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tblView removeGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:hitPoint];
    
    
    if(![_from isEqualToString:@"reset"])
    {
        if(indexPath.row == 1)
        {
            [dataDic setValue:textField.text forKey:@"email"];
        }
        else if(indexPath.row == 2)
        {
            [dataDic setValue:textField.text forKey:@"password"];
        }
    }
    else
    {
        if(indexPath.row == 1)
        {
            [dataDic setValue:textField.text forKey:@"old_password"];
        }
        else if(indexPath.row == 2)
        {
            [dataDic setValue:textField.text forKey:@"password"];
        }
        else if(indexPath.row == 3)
        {
            [dataDic setValue:textField.text forKey:@"confirm_password"];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    

    if(indexPath.row == num-2)
    {
           [self.view endEditing:YES];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        UITableViewCell *cell = [_tblView cellForRowAtIndexPath: indexPath];
        UITextField *txt = [cell viewWithTag:2];
        [textField resignFirstResponder];
        [txt becomeFirstResponder];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    
    
    if(indexPath.row == 2 && [_from isEqualToString:@""])
    {
        UITableViewCell *cell = [_tblView cellForRowAtIndexPath:indexPath];
        UIButton *button = [cell viewWithTag:3];
        
        if([textField.text length] == 1 && [string length] == 0)
        {
            [button setHidden:true];
        }
        else
        {
            [button setHidden:false];
        }
    }
    
    if(indexPath.row != 0 && indexPath.row != 1)
    {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 20;
    }
    
    
    return YES;
}

//MARK:- button handling
-(IBAction) signIn: (UIButton*) sender {
    [self.view endEditing:true];
    
    if (![_from isEqualToString:@"reset"])
    {
        if([dataDic valueForKey: @"email"] == nil || [[dataDic valueForKey:@"email"] isEqualToString: @""])
        {
            [SVProgressHUD showErrorWithStatus:emptyEmail];
            return;
        }
        else if([appDelegate.constant emailValidation:[dataDic valueForKey:@"email"]] == false)
        {
            [SVProgressHUD showErrorWithStatus:validEmail];
            return;
        }
        else if(([dataDic valueForKey:@"password"] == nil || [[dataDic valueForKey:@"password"] isEqualToString: @""])  && [_from isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus:Emptypassword];
            return;
        }
        else if(([[dataDic valueForKey:@"password"] length] < 8 || [[dataDic valueForKey:@"password"] length] > 20) && [_from isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus:validPassword];
            return;
        }
    }
    else
    {
        if([dataDic valueForKey:@"old_password"] == nil || [[dataDic valueForKey:@"old_password"] isEqualToString: @""])
        {
            [SVProgressHUD showErrorWithStatus:currentEmptyPass];
            return;
        }
        else if([dataDic valueForKey:@"password"] == nil || [[dataDic valueForKey:@"password"] isEqualToString: @""])
        {
            [SVProgressHUD showErrorWithStatus:Emptypassword];
            return;
        }
        else if([appDelegate.constant passwordValidation:[dataDic valueForKey:@"password"]] == false)
        {
            [SVProgressHUD showErrorWithStatus:validPassword];
            return;
        }
        else if([dataDic valueForKey:@"confirm_password"] == nil || [[dataDic valueForKey:@"confirm_password"] isEqualToString: @""])
        {
            [SVProgressHUD showErrorWithStatus: confirmEmptyPass];
            return;
        }
        else if(!([[dataDic valueForKey:@"password"] isEqualToString:[dataDic valueForKey:@"confirm_password"]]))
        {
            [SVProgressHUD showErrorWithStatus:matchPassword];
            return;
        }
    }
  
    
    
    [self webservices];
}


-(void)webservices
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [SVProgressHUD showWithStatus:@"Please Wait"];
    if([_from isEqualToString: @""])
    {
        [dataDic setValue: @"ios" forKey:@"device_type"];
        [dataDic setValue: [[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"device_id"];
        
        if([[NSUserDefaults standardUserDefaults] valueForKey: @"device_token"] != nil)
        {
            [dataDic setValue: [[NSUserDefaults standardUserDefaults] valueForKey: @"device_token"] forKey:@"device_token"];
        }
        else
        {
            [dataDic setValue: @"bwdbfjewbfjlw" forKey:@"device_token"];
        }
        
        NSString *str = [NSString stringWithFormat:@"%@api/auth/login",BaseURL];
        [webConnector Login:dataDic url:str completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [appDelegate.generalFunction Delete_All_Records_From:@"mds_users"];
                [appDelegate.generalFunction Delete_All_Records_From:@"mds_messages"];
                NSMutableDictionary *temp = [[responseObject objectForKey: @"result"] mutableCopy];
                NSMutableDictionary *user = [[temp valueForKey:@"users_details"] mutableCopy];
                
                //remove null values
                for(NSString *i in [user allKeys])
                {
                    if ([[user valueForKey: i] isEqual: [NSNull null]])
                    {
                        [user setValue:@"" forKey:i];
                    }
                }
                
                
                [user setValue:[user valueForKey:@"id"] forKey:@"user_id"];
              
                if([user valueForKey:@"tr_set_pass"] == nil || [[user valueForKey:@"tr_set_pass"] isKindOfClass:[NSNull class]])
                {
                    [user setValue:@"N" forKey:@"tr_set_pass"];
                }
                 [temp setValue:user forKey:@"users_details"];
                [[NSUserDefaults standardUserDefaults] setValue:temp forKey:@"userData"];
                [[NSUserDefaults standardUserDefaults] setValue:[user valueForKey:@"id"] forKey:@"user_id"];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@", [user valueForKey:@"first_name"], [user valueForKey:@"last_name"]] forKey:@"name"];
                
                [appDelegate locationWebserviceManagement];
                HomeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
                [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController: vc withCompletion:nil];
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
    else if([_from isEqualToString: @"forgot"])
    {
        NSString *str = [NSString stringWithFormat:@"%@api/auth/forgot-password",BaseURL];
        
        [webConnector Login:dataDic url:str completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    [self.navigationController popViewControllerAnimated:true];
                });
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
    else if([_from isEqualToString: @"reset"])    {
        
        NSString *str = [NSString stringWithFormat:@"%@api/auth/change-password?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
        
        [webConnector Login:dataDic url:str completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    [self.navigationController popViewControllerAnimated:true];
                });
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
}


-(IBAction) showPass: (UIButton*) sender {
    
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    UITableViewCell *cell = [self.tblView cellForRowAtIndexPath:indexPath];
    UITextField *txt = [cell viewWithTag:2];
    
    if(sender.isSelected == true)
    {
        txt.secureTextEntry = true;
        sender.selected = false;
    }
    else
    {
        txt.secureTextEntry = false;
        sender.selected = true;
    }
}

-(IBAction) forgotPass: (UIButton*) sender {
    
    if([_from isEqualToString:@""])
    {
        ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        vc.from = @"forgot";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end



