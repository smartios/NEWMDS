//
//  TRPasswordViewController.m
//  MDS
//
//  Created by SL-167 on 1/1/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "TRPasswordViewController.h"
#import "MYTRViewController.h"
#import "NewScureTRControllerTableViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <AudioToolbox/AudioServices.h>

#import "SecureTRController.h"

#import "TRTabBarController.h"


@interface TRPasswordViewController ()
{
    NSMutableDictionary *dataDic;
    UITapGestureRecognizer *tap;
    int num;
    __weak IBOutlet UILabel *TRPasswordTitle;
   
}

@end

@implementation TRPasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([_from isEqualToString:@"set"])
    {
        TRPasswordTitle.text = @"Set TR Password";
        num = 4;
        [_sidemenu setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    }
    else if ([_from isEqualToString:@"login"]){
        TRPasswordTitle.text = @"TR Login";
         num = 4;
        [self fingerPrintDetection];
        [_sidemenu setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    }
    else if ([_from isEqualToString:@"reset"])
    {
        TRPasswordTitle.text = @"Reset TR Password";
        [_sidemenu setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        num = 5;
    }
    
    
    dataDic = [[NSMutableDictionary alloc] init];
    //Code to handle keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    // Do any additional setup after loading the view.
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)viewWillAppear:(BOOL)animated{
}

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

// MARK:- fingerPrint authentication Method
-(void)fingerPrintDetection
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Use your fingerprint to login in TR.";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        [self settingTabBar];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                    });
                                }
                            }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
         
        });
    }
}

- (IBAction)thumbClick:(UIButton *)sender {
    [self fingerPrintDetection];
}


//MARK:- table view functions

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 215;
    }
    else if (indexPath.row == num-1 && [_from isEqualToString:@"login"]){
        return 180;
    }
    else if (indexPath.row == num-2 && [_from isEqualToString:@"login"]){
        return 90;
    }
    else if (indexPath.row == num-1 && [_from isEqualToString:@"reset"]){
        return 90;
    }
    else
    {
        return 75;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];


    if (indexPath.row==0)
    {
        cell = [_tblView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    }
    else if((indexPath.row == num-2 && [_from isEqualToString:@"login"]) || (indexPath.row == num-1 && ![_from isEqualToString:@"login"]))
    {
        cell = [_tblView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        UIButton *smtbtn = [[UIButton alloc] init];
        UIButton *reset = [cell viewWithTag:2];
        UIButton *forgetPassWordBtn = [cell viewWithTag:3];
        [forgetPassWordBtn addTarget:self action:@selector(forgotPassword:)  forControlEvents:UIControlEventTouchUpInside];
        [reset setHidden:true];
        [forgetPassWordBtn setHidden:true];
        reset.titleLabel.adjustsFontSizeToFitWidth = true;
        forgetPassWordBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        
        if([_from isEqualToString:@"login"])
        {
            [reset setHidden:false];
            [forgetPassWordBtn setHidden:false];
            
        }
        
        
        smtbtn = [cell viewWithTag:1];
        smtbtn.layer.cornerRadius = 19;
    }
    else if(indexPath.row == num-1 && [_from isEqualToString:@"login"]){
        cell = [_tblView dequeueReusableCellWithIdentifier:@"fingerPrintCell" forIndexPath:indexPath];
    }
    else
    {
        cell = [_tblView dequeueReusableCellWithIdentifier:@"fieldCell" forIndexPath:indexPath];
        UILabel *lblText = [cell viewWithTag:1];
        UITextField *textField = [cell viewWithTag:2];
        textField.secureTextEntry = YES;
        //[textField setSecureTextEntry:true];
        if ([_from isEqualToString:@"set"]) {
            
            if(indexPath.row == 1)
            {
                lblText.text = @"New Password";
                textField.text = [dataDic valueForKey:@"password"];
            }
            else if(indexPath.row == 2)
            {
                lblText.text = @"Confirm Password";
                textField.text = [dataDic valueForKey:@"confirm_password"];
            }
        }
        else if ([_from isEqualToString:@"login"])
        {
            if(indexPath.row == 1)
            {
                lblText.text = @"Password";
                textField.text = [dataDic valueForKey:@"tr_password"];
            }
        }
        else if ([_from isEqualToString:@"reset"])
        {
            if(indexPath.row == 1)
            {
                lblText.text = @"Old Password";
                textField.text = [dataDic valueForKey:@"old_password"];
            }
            else if(indexPath.row == 2)
            {
                lblText.text = @"New Password";
                textField.text = [dataDic valueForKey:@"password"];
            }
            else if(indexPath.row == 3)
            {
                lblText.text = @"Confirm Password";
                textField.text = [dataDic valueForKey:@"confirm_password"];
            }
        }
    }
    return cell;
}

//MARK:- textfield functions
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.tblView addGestureRecognizer:tap];
    
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.secureTextEntry = YES;
    
    if(indexPath.row == num-2){
        textField.returnKeyType = UIReturnKeyDone;
    }else{
        textField.returnKeyType = UIReturnKeyNext;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self.tblView removeGestureRecognizer:tap];
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:hitPoint];
    
    if ([_from isEqualToString:@"set"]) {
        if(indexPath.row == 1)
        {
            [dataDic setValue:textField.text forKey:@"password"];
        }
        else if(indexPath.row == 2)
        {
           [dataDic setValue:textField.text forKey:@"confirm_password"];
        }
    }
        else if ([_from isEqualToString:@"login"])
        {
            if(indexPath.row == 1)
            {
                [dataDic setValue:textField.text forKey:@"tr_password"];
            }
        }
        else if ([_from isEqualToString:@"reset"])
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:hitPoint];
    
    if(indexPath.row == num-2)
    {
        [self.view endEditing:true];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        UITableViewCell *cell = [_tblView cellForRowAtIndexPath: indexPath];
        UITextField *txt = [cell viewWithTag:2];
        [textField resignFirstResponder];
        [txt becomeFirstResponder];
    }
    
    return true;
}

//MARK:- button handling

-(void)forgotPasswordWebservice
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Please wait."];
    WebConnector *webconnector = [[WebConnector alloc] init];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"email"] forKey:@"email"];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/tr-forgot-password?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webconnector trPassword:dic url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
            
            //[SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
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


- (IBAction)forgotPassword:(UIButton *)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Forgot TR"
                                                                              message: @"Click on send button to receive forgot password email."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self forgotPasswordWebservice];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)sidemenu:(UIButton *)sender {
    
    if ([_from isEqualToString:@"reset"])
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }
    
}

- (IBAction)reset:(UIButton *)sender {
    
    TRPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TRPasswordViewController"];
    vc.from = @"reset";
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)submitTRPassword:(UIButton *)sender {
    
//    [self settingTabBar];
//    return;
    
    [self.view endEditing:true];
    if ([_from isEqualToString:@"set"]) {
            if ([dataDic valueForKey:@"password"] == nil || [[dataDic  valueForKey:@"password"] isEqualToString:@""]) {
                [SVProgressHUD showErrorWithStatus:Emptypassword];
                return;
            }
            else if([appDelegate.constant passwordValidation:[dataDic valueForKey:@"password"]] == false)
            {
                [SVProgressHUD showErrorWithStatus:validPassword];
                return;
            }
            else if ([dataDic valueForKey:@"confirm_password"]==nil || [[dataDic valueForKey:@"confirm_password"] isEqualToString:@""]){
                [SVProgressHUD showErrorWithStatus:confirmEmptyPass];
                return;
            }
            else if(!([[dataDic valueForKey:@"password"] isEqualToString:[dataDic valueForKey:@"confirm_password"]]))
            {
                [SVProgressHUD showErrorWithStatus:matchPassword];
                return;
            }
    }
   else if ([_from isEqualToString:@"reset"]) {
            if ([dataDic valueForKey:@"old_password"] == nil || [[dataDic  valueForKey:@"old_password"] isEqualToString:@""]) {
                [SVProgressHUD showErrorWithStatus:currentEmptyPass];
                return;
            }
           else if ([dataDic valueForKey:@"password"] == nil || [[dataDic  valueForKey:@"password"] isEqualToString:@""]) {
                [SVProgressHUD showErrorWithStatus:Emptypassword];
                return;
            }
           else if([appDelegate.constant passwordValidation:[dataDic valueForKey:@"password"]] == false)
           {
               [SVProgressHUD showErrorWithStatus:validPassword];
               return;
           }
            else if ([dataDic valueForKey:@"confirm_password"]==nil || [[dataDic valueForKey:@"confirm_password"] isEqualToString:@""]){
                [SVProgressHUD showErrorWithStatus:confirmEmptyPass];
                return;
            }
       
            else if(!([[dataDic valueForKey:@"password"] isEqualToString:[dataDic valueForKey:@"confirm_password"]]))
            {
                [SVProgressHUD showErrorWithStatus:matchPassword];
                return;
            }
    }
  else if ([_from isEqualToString:@"login"]) {
        if ([dataDic valueForKey:@"tr_password"] == nil || [[dataDic  valueForKey:@"tr_password"] isEqualToString:@""]) {
            
            [SVProgressHUD showErrorWithStatus:PasswordEmpty];
            return;
        }
    }
    
    [self webService];
}

-(void)webService
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Please wait."];
    WebConnector *webconnector = [[WebConnector alloc] init];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    
    if([_from isEqualToString:@"set"] || [_from isEqualToString:@"reset"])
    {
        NSString *url = [NSString stringWithFormat:@"%@api/auth/set_reset_tr_password?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
        
        [webconnector trPassword:dataDic url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
            {
                NSMutableDictionary *dic = [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] mutableCopy];
                NSMutableDictionary *user = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                
                [dic setValue:@"Y" forKey:@"tr_set_pass"];
                
                [user setValue:dic forKey:@"users_details"];
                [[NSUserDefaults standardUserDefaults] setValue:user forKey:@"userData"];
                TRPasswordViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TRPasswordViewController"];
                vc.from = @"login";
                [self.navigationController pushViewController:vc animated:true];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self webService];
                    }
                } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
                }];
                
                //[SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
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
    else if([_from isEqualToString:@"login"] )
    {
        NSString *url = [NSString stringWithFormat:@"%@api/auth/tr_login?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
        
        [dataDic setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
        
        [webconnector Login_TR:dataDic url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
            {

//                 SecureTRController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecureTRController"];
                
//                MYTRViewController *vc = [self.self.storyboard instantiateViewControllerWithIdentifier:@"MYTRViewController"];
                
//   NewScureTRControllerTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewScureTRControllerTableViewController"];
                
//                [self.navigationController pushViewController:vc animated:true];

                [self settingTabBar];

            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self webService];
                    }
                } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
                }];
                
                //[SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
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
}


-(void)settingTabBar
{
    if([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"] isEqualToString:@"staff"])
    {
        MYTRViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"MYTRViewController"];
        vc1.from = @"receive";
        TRTabBarController *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"TRTabBarController"];
        tab.viewControllers = [[NSArray alloc] initWithObjects:vc1, nil];
        
        [self.navigationController pushViewController:tab animated:true];
    }
    else
    {
        MYTRViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"MYTRViewController"];
        vc1.from = @"receive";
        NewScureTRControllerTableViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"NewScureTRControllerTableViewController"];
        MYTRViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"MYTRViewController"];
        vc3.from = @"sent";
        MYTRViewController *vc4 = [self.storyboard instantiateViewControllerWithIdentifier:@"MYTRViewController"];
        vc4.from = @"draft";
        
        TRTabBarController *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"TRTabBarController"];
        tab.viewControllers = [[NSArray alloc] initWithObjects:vc1,vc2,vc3,vc4, nil];
        
        [self.navigationController pushViewController:tab animated:true];
    }
}
@end
