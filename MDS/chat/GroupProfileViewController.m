//
//  GroupProfileViewController.m
//  mds
//
//  Created by SS-181 on 8/11/17.
//
//

#import "GroupProfileViewController.h"
#import "AppDelegate.h"
#import "WebConnector.h"
#import "UIImageView+AFNetworking.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GroupMemberViewController.h"

@interface GroupProfileViewController ()
{
    WebConnector *webConnector;
    BOOL isAdminBool;
}
@end

@implementation GroupProfileViewController
@synthesize createButton,titleLabel,tableView,bottomViewConst,from,prevDataDic,deleteGroupButton,exitGroupButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
    [deleteGroupButton setTitle:@"Delete Group" forState:UIControlStateNormal];
    [exitGroupButton setTitle:@"Exit Group" forState:UIControlStateNormal];
    
    webConnector = [[WebConnector alloc] init];
    isAdminBool = false;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateGroupinfo) name: @"updateGroup" object: nil];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateGroupinfo];
    [[appDelegate socketManager] checkSocketStatus];
}

-(void)updateGroupinfo
{
    if([from isEqualToString:@"create"])
    {
        titleLabel.text = @"Create group";
        bottomViewConst.constant = 0;
    }
    else if([from isEqualToString:@"broadcast"])
    {
        titleLabel.text = @"Broadcast group";
        bottomViewConst.constant = 0;
    }
    else
    {
        
        NSArray *groupInfoArr = [[NSArray alloc] initWithArray:[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_groups" forKeys:[[NSArray alloc] initWithObjects:@"group_name",@"group_icon",@"group_type", nil] andWhere:[NSString stringWithFormat:@"id = '%@'",[prevDataDic valueForKey:@"group_id"]]]];
        
        if([groupInfoArr count] > 0)
        {
            [prevDataDic setValue:[[groupInfoArr objectAtIndex:0] valueForKey:@"group_name"]  forKey:@"group_name"];
            [prevDataDic setValue:[[groupInfoArr objectAtIndex:0] valueForKey:@"group_icon"]  forKey:@"group_icon"];
            [prevDataDic setValue:[[groupInfoArr objectAtIndex:0] valueForKey:@"group_type"]  forKey:@"group_type"];
        }
        
        titleLabel.text = [prevDataDic valueForKey:@"group_name"];
        deleteGroupButton.hidden = true;
        
        [createButton setTitle:@"Update" forState:UIControlStateNormal];
        
        NSMutableArray *tempArr = [[appDelegate.generalFunction getAllGroupMembers:[prevDataDic valueForKey:@"group_id"]] mutableCopy];
        
        [prevDataDic setObject:tempArr forKey:@"members"];
        
        for(int i=0;i<[[prevDataDic objectForKey:@"members"] count];i++)
        {
            if([[NSString stringWithFormat:@"%@",[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] valueForKey:@"user_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]] && [[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] valueForKey:@"is_admin"] isEqualToString:@"1"])
            {
                isAdminBool = true;
                //createButton.hidden = false;
                bottomViewConst.constant = 40;
                deleteGroupButton.hidden = false;
                break;
            }
        }
        
        [tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK:- Buttons
- (IBAction)backBtn:(UIButton *)sender
{
    [[self navigationController] popViewControllerAnimated: YES];
}

- (IBAction)createButtonClicked:(UIButton *)sender
{
    [self.view endEditing:true];
    
    if([prevDataDic valueForKey:@"group_name"] == nil || [[prevDataDic valueForKey:@"group_name"] isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus: @"Enter Group Name"];
        return;
    }
    
    //    if([prevDataDic valueForKey:@"userfile"] == nil && [prevDataDic valueForKey:@"group_icon"] == nil)
    //    {
    //        [appDel showInfoWithStatus: @"Select Group Image"];
    //        return;
    //    }
    
    if([from isEqualToString:@"create"] || [from isEqualToString:@"broadcast"])
    {
        [self createGroup];
    }
    else
    {
        [self updateGroup];
    }
    
}


-(IBAction)groupImageButtonClicked:(UIButton *)sender
{
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Gallery" otherButtonTitles:@"Camera", nil];
    [option showInView:self.view];
}

-(IBAction)exitGroupButtonClicked:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mds"
                                                    message: @"Are you sure, you want to exit?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles: @"Yes", nil];
    alert.tag = 1;
    [alert show];
}

-(IBAction)deleteGroupButtonClicked:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"mds"
                                                    message: @"Are you sure, you want to delete this group?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 2;
    [alert show];
}

-(void)addMembersButtonClicked:(UIButton *)sender
{
    GroupMemberViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
    infoVC.from = @"profile";
    infoVC.prevDataDic = prevDataDic;
    [[self navigationController] pushViewController:infoVC animated:YES];
}

//MARK:- Action Sheet
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


#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    SWTableViewCell *cell;
    
    if(indexPath.section == 0)
    {
        cell= (SWTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"groupProfileCell"];
        //cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupProfileCell"  forIndexPath: indexPath];
        
        UIImageView *imageView = [cell viewWithTag:1];
        UITextField *titleTextField = [cell viewWithTag:2];
        UIButton *editImageButton = [cell viewWithTag:3];
        
        
        titleTextField.placeholder = @"Enter Group Name";
        
        imageView.clipsToBounds = true;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        imageView.layer.borderWidth = 1.0;
        imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        editImageButton.clipsToBounds = true;
        editImageButton.layer.cornerRadius = editImageButton.frame.size.width/2;
        
        //        if([from isEqualToString:@"create"])
        //        {
        //            editImageButton.hidden = false;
        //            titleTextField.userInteractionEnabled = true;
        //        }
        //        else
        //        {
        //            if(isAdminBool != true)
        //            {
        //                editImageButton.hidden = true;
        //                titleTextField.userInteractionEnabled = false;
        //            }
        //            else
        //            {
        //                editImageButton.hidden = false;
        //                titleTextField.userInteractionEnabled = true;
        //            }
        //        }
        
        if([prevDataDic valueForKey:@"group_name"] != nil)
        {
            titleTextField.text = [prevDataDic valueForKey:@"group_name"];
        }
        
        
        
        if([prevDataDic valueForKey:@"userfile"] != nil && [[prevDataDic valueForKey:@"userfile"] isKindOfClass:[NSData class]])
        {
            imageView.image = [UIImage imageWithData:[prevDataDic valueForKey:@"userfile"]];
        }
        else
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/group_icon/%@",imageBaseURL,[prevDataDic valueForKey:@"group_icon"] ]] placeholderImage: [UIImage imageNamed: @"groupDefault"]];
        }
        
        
    }
    else
    {
        
        cell= (SWTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        
        if(![[prevDataDic valueForKey:@"group_type"] isEqualToString:@"broadcast"])
        {
          cell.leftUtilityButtons = [self leftButtons:indexPath];
        }
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        
        
        // cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell"  forIndexPath: indexPath];
        
        UIImageView *imageView = [cell viewWithTag:1];
        UILabel *nameLabel = [cell viewWithTag:2];
        UILabel *numberLabel = [cell viewWithTag:3];
        UIButton *adminButton = [cell viewWithTag:4];
        
        imageView.clipsToBounds = true;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        
        adminButton.layer.cornerRadius = 5.0;
        adminButton.layer.borderColor = [[UIColor greenColor] CGColor];
        adminButton.layer.borderWidth = 1.0;
        
        [adminButton setTitle: @"Group Admin" forState:UIControlStateNormal];
        
        NSMutableArray *dataArray = [self.prevDataDic objectForKey:@"members"];
        
        if ([[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            imageView.image = [UIImage imageNamed: @"default_profile"];
        }
        
        
        
        if (([[dataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isEqualToString:@""]) && ([[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] isKindOfClass:[NSNull class]] && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] isEqualToString:@""]))
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@", [[dataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"],[[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
        }
        else
        {
            nameLabel.text = [[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
        
        if ([[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"] isKindOfClass:[NSNull class]] && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"] isEqualToString:@""])
        {
            numberLabel.text = [[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
        else
        {
            numberLabel.text = [[dataArray objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
        
        if([[dataArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"] != nil && [[[dataArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"] isEqualToString:@"1"])
        {
            adminButton.hidden = false;
        }
        else
        {
            adminButton.hidden = true;
        }
    }
    
    
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    return [[prevDataDic objectForKey:@"members"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 172;
    }
    else
    {
        return 80;
    }
}

-(CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 0;
    }
    return 30.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 15, 30)];
    
    bgView.clipsToBounds = true;
    bgView.backgroundColor = [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:1.0];
    
    label.backgroundColor = [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:1.0];
    label.font = [UIFont fontWithName:@"Roboto-Regular" size:14.0];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:(111/255.0) green:(113/255.0) blue:(121/255.0) alpha:1.0];
    
    label.text = [NSString stringWithFormat:@"Members in this group (%lu)",[[prevDataDic objectForKey:@"members"] count]];
    
    [bgView addSubview:label];
    
    if(![from isEqualToString:@"create"] && isAdminBool == true)
    {
        UIButton *addMembersButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 30, 0, 30, 30)];
        addMembersButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:16.0];
        [addMembersButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addMembersButton setTitle:@"+" forState:UIControlStateNormal];
        [addMembersButton addTarget:self action:@selector(addMembersButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:addMembersButton];
    }
    
    return bgView;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.section == 1 && isAdminBool == true)
//    {
//        return true;
//    }
//    return false;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self exitGroup:[[[self.prevDataDic objectForKey:@"members"] objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
//}

#pragma mark - UIScrollViewDelegate


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    if(isAdminBool == true)
    {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@"Delete"];
    }
    //[[rightUtilityButtons objectAtIndex:0] setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons:(NSIndexPath *)indexPath
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    

    if(isAdminBool == true && ![[[[self.prevDataDic objectForKey:@"members"] objectAtIndex:indexPath.row] valueForKey:@"is_admin"] isEqualToString:@"1"])
    {
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0] title:@"Assign Admin"];
    }
    
    return leftUtilityButtons;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}


#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if(![[[[self.prevDataDic objectForKey:@"members"] objectAtIndex:indexPath.row] valueForKey:@"is_admin"] isEqualToString:@"1"])
    {
        [self makeGroupAdmin:[[[self.prevDataDic objectForKey:@"members"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus: @"This member is already admin."];
    }
    //[self setFavChat: [chatTableView indexPathForCell:cell]];
    /* switch (index) {
     case 0:
     //NSLog(@"left button 0 was pressed");
     [self setFavChat:index];
     break;
     default:
     break;
     }*/
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (index == 0) {
        //Delete
        
        [self exitGroup:[[[self.prevDataDic objectForKey:@"members"] objectAtIndex:indexPath.row] valueForKey:@"user_id"]];;
        
    }
    
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}



#pragma mark- UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    [[self prevDataDic] setObject:imageData forKey:@"userfile"];
    
    [self.tableView reloadData];
    
}

//MARK:- textField
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [[self prevDataDic] setValue:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"group_name"];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIalertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        //
    }
    else
    {
        if(alertView.tag == 1)
        {
            [self exitGroup:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
        }
        else if(alertView.tag == 2)
        {
            [self deleteGroup];
        }
    }
}

//MARK:- Webservice
-(void) createGroup
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        // params = [prevDataDic mutableCopy];
        
        NSData *data = [[prevDataDic objectForKey:@"group_name"] dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *UTF8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if([UTF8String length] > 100)
        {
            [SVProgressHUD showErrorWithStatus: @"Group name cannot to too large."];
            return;
        }
        
        [params setObject: UTF8String forKey: @"group_name"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
      //  [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        for(int i=0;i<[[prevDataDic objectForKey:@"members"] count];i++)
        {
            [params setObject:[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] valueForKey:@"user_id"] forKey:[NSString stringWithFormat:@"group_members[%i]",i]];
        }
        
        if([from isEqualToString:@"create"])
        {
            [params setObject: @"normal" forKey: @"group_type"];
        }
        else
        {
           [params setObject: @"broadcast" forKey: @"group_type"];
        }
        
        [webConnector createGroup:params withImage:[prevDataDic objectForKey:@"userfile"] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             [SVProgressHUD dismiss];
             
             if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
             {
                 
                 //Sending Messages
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                 NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                 
                 NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                 
                 [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                 [tempDic setObject:@"" forKey:@"mid"];
                 
                 if([from isEqualToString:@"create"])
                 {
                    [tempDic setObject:@"You were added." forKey:@"message"];
                 }
                 else
                 {
                     [tempDic setObject:@"Broadcast created." forKey:@"message"];
                 }
                 
                 [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                 [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                 
                 [tempDic setObject: [responseObject objectForKey: @"group_id"] forKey:@"group_id"];
                 [tempDic setObject: @"Normal" forKey:@"group_type"];
                 [tempDic setObject: [[self prevDataDic] objectForKey: @"group_name"] forKey:@"group_name"];
                 [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
                 [tempDic setObject: @"action" forKey:@"message_type"];
                 [tempDic setObject: @"unread" forKey:@"read_status"];
                 [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
                 [tempDic setObject: @"" forKey:@"deleted_at"];
                 [tempDic setObject: @"" forKey:@"delete_after"];
                 [tempDic setObject: @"" forKey:@"filesize"];
                 
                 
                 NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                 [dateFormatter setTimeZone:localTimeZone];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
                 
                 
              
                 [[appDelegate socketManager] sendMessage:tempDic];
                    [[appDelegate socketManager] getChatList];
                 [[appDelegate socketManager] chatGroupUpdate:[responseObject objectForKey:@"group_id"]];
                 
                 //Getting chat list
//                 dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
//                 dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
                     [[appDelegate socketManager] getChatList];
                 //});
                 
                 for(UIViewController *vc in self.navigationController.viewControllers)
                 {
                     if([vc isKindOfClass:[UITabBarController class]])
                     {
                         [self.navigationController popToViewController:vc animated:true];
                     }
                 }
             }
             else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
             {
                 [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                     {
                         NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                         [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                         [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                         
                         [self createGroup];
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
                 [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"error"]];
             }
            
             
         } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus: @"Please try again."];
         }];
    }
}

-(void) updateGroup
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        // params = [prevDataDic mutableCopy];
        NSData *data = [[prevDataDic objectForKey:@"group_name"] dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *UTF8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if([UTF8String length] > 100)
        {
            [SVProgressHUD showErrorWithStatus: @"Group name cannot to too large."];
            return;
        }
        
        [params setObject: UTF8String forKey: @"group_name"];
        [params setObject: [prevDataDic objectForKey:@"group_id"] forKey: @"group_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector updateGroup:params withImage:[prevDataDic objectForKey:@"userfile"] completionHandler:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             [SVProgressHUD dismiss];
             
             if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
             {
                 [SVProgressHUD showSuccessWithStatus:[responseObject objectForKey: @"message"]];
                 //updating Group
                 NSArray *keys = [[NSArray alloc] initWithObjects:@"group_name",@"group_icon",@"updated_at", nil];
                 
                 
                 NSMutableDictionary *groupInfoDic = [[NSMutableDictionary alloc] init];
                 
                 self.titleLabel.text = [prevDataDic valueForKey:@"group_name"];
                 
                 // groupInfoDic = [[responseObject objectForKey: @"data"] objectForKey:@"" mutableCopy];
                 [[self prevDataDic] setObject:[[responseObject objectForKey: @"data"] objectForKey:@"group_icon" ] forKey:@"group_icon"];
                 [groupInfoDic setObject:[[responseObject objectForKey: @"data"] objectForKey:@"group_icon" ]  forKey:@"group_icon"];
                 [groupInfoDic setObject:[prevDataDic objectForKey:@"group_name"]  forKey:@"group_name"];
                 //[groupInfoDic setObject:[[[responseObject objectForKey: @"data"] objectForKey:@"new_group" ] objectForKey:@"updated_at" ]   forKey:@"updated_at"];
                 [groupInfoDic setObject:[prevDataDic objectForKey:@"group_id"] forKey:@"id"];
                 
                 [appDelegate.generalFunction updateTable:@"mds_groups" forKeys:keys setValue:[[NSArray alloc] initWithObjects:groupInfoDic, nil] andWhere:[NSString stringWithFormat:@"id = '%@'",[groupInfoDic objectForKey: @"id"]]];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"update_group_profile" object:prevDataDic];
                 
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                 NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                 
                 NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                 
                 [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                 [tempDic setObject:@"" forKey:@"mid"];
                 
                 if(![[[[responseObject objectForKey: @"data"] objectForKey:@"old_group" ] objectForKey:@"group_name"] isEqualToString:[[[responseObject objectForKey: @"data"] objectForKey:@"new_group" ] objectForKey:@"group_name"]] && [prevDataDic objectForKey:@"userfile"] != nil)
                 {
                     [tempDic setObject:[NSString stringWithFormat:@"Group icon and group title was changed by %@",[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                 }
                 else if([prevDataDic objectForKey:@"userfile"] != nil)
                 {
                     [tempDic setObject:[NSString stringWithFormat:@"Group icon was changed by %@.",[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                 }
                 else if(![[[[responseObject objectForKey: @"data"] objectForKey:@"old_group" ] objectForKey:@"group_name"] isEqualToString:[[[responseObject objectForKey: @"data"] objectForKey:@"new_group" ] objectForKey:@"group_name"]])
                 {
                     [tempDic setObject:[NSString stringWithFormat:@"Group title was changed by %@.",[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                 }
                 else
                 {
                     [tempDic setObject:[NSString stringWithFormat:@"Group profile was updated by %@.",[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                 }
                 
                 
                 [tempDic setObject: @"Normal" forKey:@"group_type"];
                 [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                 [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                 
                 [tempDic setObject: [prevDataDic objectForKey:@"group_id"] forKey:@"group_id"];
                 [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
                 [tempDic setObject: @"action" forKey:@"message_type"];
                 [tempDic setObject: @"unread" forKey:@"read_status"];
                 [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
                 [tempDic setObject: @"" forKey:@"deleted_at"];
                 [tempDic setObject: @"" forKey:@"delete_after"];
                 [tempDic setObject: @"" forKey:@"filesize"];
                 
                 
                 NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                 [dateFormatter setTimeZone:localTimeZone];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
                 
                 
                 [[appDelegate socketManager] sendMessage:tempDic];
                 [[appDelegate socketManager] chatGroupUpdate:[prevDataDic objectForKey:@"group_id"]];
             }
             else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
             {
                 [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                     {
                         NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                         [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                         [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                         
                         [self updateGroup];
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
                 [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
             }
             
             [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
             
         } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {

               [SVProgressHUD dismiss];
               [SVProgressHUD showErrorWithStatus: @"Please try again."];
             
         }];
    }
}

-(void) exitGroup:(NSString *)forID
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        
        [SVProgressHUD showWithStatus: @"Please wait"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        
        // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
        //[params setObject: @"English" forKey: @"language"];
        
        [params setObject: forID forKey: @"members_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: [prevDataDic valueForKey:@"group_id"] forKey: @"group_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"action_user_id"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector exitGroup: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                //[dataArray removeAllObjects];
                //                if ([responseObject objectForKey: @"data"] != nil && [[responseObject objectForKey: @"data"] isKindOfClass: [NSDictionary class]])
                //                {
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                
                [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                [tempDic setObject:@"" forKey:@"mid"];
                
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                
                [tempDic setObject: [prevDataDic objectForKey:@"group_id"] forKey:@"group_id"];
                [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
                [tempDic setObject: @"action" forKey:@"message_type"];
                [tempDic setObject: @"unread" forKey:@"read_status"];
                [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
                [tempDic setObject: @"" forKey:@"deleted_at"];
                [tempDic setObject: @"" forKey:@"delete_after"];
                [tempDic setObject: @"" forKey:@"filesize"];
                
                
                NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:localTimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
                
                if([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]] isEqualToString:forID])
                {
                    [tempDic setObject:[NSString stringWithFormat:@"%@ left.",[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                    
                    [appDelegate.generalFunction Delete_Record_From:@"mds_groups" where:[NSString stringWithFormat:@"id = %@",[prevDataDic valueForKey:@"group_id"]]];
                    [appDelegate.generalFunction Delete_Record_From:@"mds_group_members" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                    [appDelegate.generalFunction Delete_Record_From:@"mds_chat_list" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                    [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                    
                    [[self navigationController] popToRootViewControllerAnimated:true];
                }
                else
                {
                    
                    
                    [appDelegate.generalFunction Delete_Record_From:@"mds_group_members" where:[NSString stringWithFormat:@"group_id = %@ AND user_id = %@",[prevDataDic valueForKey:@"group_id"],forID]];
                    
                    for(int i = 0;i<[[prevDataDic objectForKey:@"members"] count];i++)
                    {
                        if([[NSString stringWithFormat:@"%@",[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] objectForKey:@"user_id"]] isEqualToString:forID])
                        {
                            [tempDic setObject:[NSString stringWithFormat:@"%@ was removed by %@.",[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] objectForKey:@"first_name"],[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                            
                            NSMutableArray *arr = [[NSMutableArray alloc] init];
                            arr = [[prevDataDic objectForKey:@"members"] mutableCopy];
                            
                            [arr removeObjectAtIndex:i];
                            [prevDataDic setObject:arr forKey:@"members"];
                            [tableView reloadData];
                            break;
                        }
                    }
                    
                    
                }
                
                [[appDelegate socketManager] sendMessage:tempDic];
                [[appDelegate socketManager] chatGroupUpdate:[prevDataDic objectForKey:@"group_id"]];
                [[appDelegate socketManager] chatGroupDeleteUpdate:forID forGroupID:[prevDataDic objectForKey:@"group_id"]];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self exitGroup:forID];
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
                [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
            }
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            
        }];
    }
}

-(void) deleteGroup
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        
        [SVProgressHUD showWithStatus: @"Please wait"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        
        // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
        //[params setObject: @"English" forKey: @"language"];
        
        //[params setObject: forID forKey: @"user_id"];
       // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: [prevDataDic valueForKey:@"group_id"] forKey: @"group_id"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        
        [webConnector deleteGroup: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                //[dataArray removeAllObjects];
                
                [appDelegate.generalFunction Delete_Record_From:@"mds_groups" where:[NSString stringWithFormat:@"id = %@",[prevDataDic valueForKey:@"group_id"]]];
                [appDelegate.generalFunction Delete_Record_From:@"mds_group_members" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                [appDelegate.generalFunction Delete_Record_From:@"mds_chat_list" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"group_id = %@",[prevDataDic valueForKey:@"group_id"]]];
                
                [[appDelegate socketManager] chatGroupUpdate:[prevDataDic objectForKey:@"group_id"]];
                
                for(UIViewController *vc in self.navigationController.viewControllers)
                {
                    if([vc isKindOfClass:[UITabBarController class]])
                    {
                        [self.navigationController popToViewController:vc animated:true];
                    }
                }
                
                
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self deleteGroup];
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
                [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
            }
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
               [SVProgressHUD showErrorWithStatus: @"Please try again."];
            
        }];
    }
}

-(void) makeGroupAdmin:(NSString *)forID
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        
        [SVProgressHUD showWithStatus: @"Please wait"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        
        // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
      //  [params setObject: @"English" forKey: @"language"];
        
        //[params setObject: forID forKey: @"user_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: [prevDataDic valueForKey:@"group_id"] forKey: @"group_id"];
        [params setObject: forID forKey: @"members_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"action_user_id"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector makeAdmin: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                //[dataArray removeAllObjects];
                //                if ([responseObject objectForKey: @"data"] != nil && [[responseObject objectForKey: @"data"] isKindOfClass: [NSDictionary class]])
                //                {
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                
                [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                [tempDic setObject:@"" forKey:@"mid"];
                
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                
                [tempDic setObject: [prevDataDic objectForKey:@"group_id"] forKey:@"group_id"];
                [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
                [tempDic setObject: @"action" forKey:@"message_type"];
                [tempDic setObject: @"unread" forKey:@"read_status"];
                [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
                [tempDic setObject: @"" forKey:@"deleted_at"];
                [tempDic setObject: @"" forKey:@"delete_after"];
                [tempDic setObject: @"" forKey:@"filesize"];
                
                
                NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:localTimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
                
                [appDelegate.generalFunction updateTable:@"mds_group_members" forKeys:[[NSArray alloc] initWithObjects:@"is_admin", nil] setValue:[[NSArray alloc] initWithObjects: [[NSDictionary alloc] initWithObjectsAndKeys:@"is_admin",@"1", nil], nil] andWhere:[NSString stringWithFormat:@"group_id = %@ AND user_id = %@",[prevDataDic valueForKey:@"group_id"],forID]];
                
                for(int i = 0;i<[[prevDataDic objectForKey:@"members"] count];i++)
                {
                    if([[NSString stringWithFormat:@"%@",[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] objectForKey:@"user_id"]] isEqualToString:forID])
                    {
                        [tempDic setObject:[NSString stringWithFormat:@"%@ was assigned admin by %@.",[[[prevDataDic objectForKey:@"members"] objectAtIndex:i] objectForKey:@"first_name"],[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                        
                        NSMutableArray *arr = [[NSMutableArray alloc] init];
                        arr = [[prevDataDic objectForKey:@"members"] mutableCopy];
                        
                        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                        tempDic = [[arr objectAtIndex:i] mutableCopy];
                        [tempDic setValue:@"1" forKey:@"is_admin"];
                        [arr replaceObjectAtIndex:i withObject:tempDic];
                        [prevDataDic setObject:arr forKey:@"members"];
                        [tableView reloadData];
                        break;
                    }
                }
                
                
                // [tempDic setObject:[NSString stringWithFormat:@"%@ was assigned admin by %@.",[[userDic objectForKey:@"name"] objectForKey:@"name"],[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]] forKey:@"message"];
                
                [[appDelegate socketManager] sendMessage:tempDic];
                [[appDelegate socketManager] chatGroupUpdate:[prevDataDic objectForKey:@"group_id"]];
                
                [self.tableView reloadData];
                //}
                
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self makeGroupAdmin:forID];
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
                [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
            }
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            
        }];
    }
}


@end
