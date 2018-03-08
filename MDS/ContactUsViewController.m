//
//  ContactUsViewController.m
//  MDS
//
//  Created by SL-167 on 12/8/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "ContactUsViewController.h"
#import "RightMenuViewController.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController
{
    NSMutableDictionary *dataDic;
    UITapGestureRecognizer *tap;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    dataDic = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


//MARK:- tableview functions

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == 2)
    {
        return 180;
    }
    else
    {
        return  75;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
    }
    else if (indexPath.row == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
        UIButton *btn = [cell viewWithTag:1];
        btn.layer.cornerRadius = 19;
    }
    else if(indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextView *textView = [cell viewWithTag:2];
        headLbl.text = @"MESSAGE";
        
        if([dataDic valueForKey:@"message"] != nil)
        {
            textView.text = [dataDic valueForKey:@"message"];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
        UILabel *headLbl = [cell viewWithTag:1];
        UITextField *textfld = [cell viewWithTag:2];
        textfld.text = @"";
        [textfld setEnabled:false];
        
        headLbl.text = @"EMAIL";
        
        if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"email"] != nil)
        {
            textfld.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"email"];
        }
    }
    
    return cell;
}


//MARK:- textview functions
-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self.tblView addGestureRecognizer:tap];
    CGPoint hitPoint = [textView convertPoint:CGPointZero toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
    textView.keyboardType = UIKeyboardTypeASCIICapable;
//    textView.returnKeyType = UIReturnKeyNext;
    
    
}
-(void)textViewDidChange:(UITextView *)textView{}


-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.tblView removeGestureRecognizer:tap];
    [dataDic setValue:textView.text forKey:@"message"];
}


//MARK:- textfield functions

//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    [self.tblView addGestureRecognizer:tap];
//    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
//    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
//    textField.keyboardType = UIKeyboardTypeASCIICapable;
//    textField.returnKeyType = UIReturnKeyNext;
//
//
//}

//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [self.tblView removeGestureRecognizer:tap];
//    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
//    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:hitPoint];
//
//    if(indexPath.row == 1)
//    {
//        [dataDic setValue:textField.text forKey:@"email"];
//    }
//    else
//    {
//        [dataDic setValue:textField.text forKey:@"message"];
//    }
//}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
//    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
//
//    if(indexPath.row == 1)
//    {
//        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
//        UITableViewCell *cell = [_tblView cellForRowAtIndexPath: indexPath];
//        UITextField *txt = [cell viewWithTag:2];
//        [textField resignFirstResponder];
//        [txt becomeFirstResponder];
//    }
//    else
//    {
//        [self.view endEditing:YES];
//    }
//
//    return YES;
//}
//
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    CGPoint hitPoint = [textField convertPoint:CGPointZero toView:self.tblView];
//    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint: hitPoint];
//
//    if(indexPath.row == 2)
//    {
//        if(range.length + range.location > textField.text.length)
//        {
//            return NO;
//        }
//        NSUInteger newLength = [textField.text length] + [string length] - range.length;
//        return newLength <= 20;
//    }
//    return YES;
//}

//MARK:- button handling
-(IBAction) submit: (UIButton*) sender
{
  [self.view endEditing:true];
    
//    if([dataDic valueForKey: @"email"] == nil || [[dataDic valueForKey:@"email"] isEqualToString: @""])
//    {
//        [SVProgressHUD showErrorWithStatus:emptyEmail];
//        return;
//    }
//    else if([appDelegate.constant emailValidation:[dataDic valueForKey:@"email"]] == false)
//    {
//        [SVProgressHUD showErrorWithStatus:validEmail];
//        return;
//    }
   if([dataDic valueForKey:@"message"] == nil || [[dataDic valueForKey:@"message"] isEqualToString: @""])
    {
        [SVProgressHUD showErrorWithStatus:Emptymessage];
        return;
    }
    
     [dataDic setValue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"email"] forKey:@"email" ];
    [dataDic setValue:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id" ];
    //webservice for contact us
    WebConnector *webConnector = [[WebConnector alloc] init];
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Please Wait"];
    NSString *str = [NSString stringWithFormat:@"%@api/auth/contact-us?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webConnector Login:dataDic url:str completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
        {
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[self.storyboard instantiateViewControllerWithIdentifier: @"HomeViewController"] withCompletion:nil];
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

-(IBAction) sidemenu: (UIButton*) sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}
@end
