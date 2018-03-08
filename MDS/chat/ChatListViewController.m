//
//  ChatListViewController.m
//  mds
//
//  Created by SS-181 on 7/10/17.
//
//

#import "ChatListViewController.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "WebConnector.h"
//AFNetworking/
#import "UIImageView+AFNetworking.h"
#import "ChatViewController.h"
#import "SWTableViewCell.h"
#import "GroupMemberViewController.h"
#import "favouriteViewController.h"

@interface ChatListViewController ()
{
    UITapGestureRecognizer *tapGesture;
       
    WebConnector *webConnector;
    UIRefreshControl *pullToRefresh;
    NSString *offset;
    NSString *serverTimeZone;
    
    NSArray *tempKeyArr;
    
}
@property (nonatomic) BOOL useCustomCells;
@end

@implementation ChatListViewController

@synthesize chatTableView,deleteIndexPath,chatListArray,blackTranView,titleLabel,searchBar,ChatButton,favButton,GroupButton,deleteChatLabel,yesButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"Chats";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    titleLabel.text = @"CHAT";
    deleteChatLabel.text = @"Are you sure, you want to delete chat?";
    searchBar.placeholder = @"Search";
    [ChatButton setTitle:@"New Chat" forState:UIControlStateNormal];
   // [favButton setTitle:[appDel getString:@"View Favourite"] forState:UIControlStateNormal];
    [GroupButton setTitle:@"New Group" forState:UIControlStateNormal];
    [yesButton setTitle:@"Yes" forState:UIControlStateNormal];
    
    chatListArray = [[NSMutableArray alloc] init];
    offset = @"0";
    pullToRefresh = [[UIRefreshControl alloc] init];
    [self.chatTableView addSubview: pullToRefresh];
    [pullToRefresh addTarget: self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    pullToRefresh.layer.zPosition = -1;
    webConnector = [[WebConnector alloc] init];
    
   // [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(getNewsFeeds) name: @"newMsg" object: nil]
    
//   self.tabBarItem.selectedImage = [UIImage imageName:@"unselected"];
//    
//    tabBarItem.selectedImage = UIImage(named: "stories2")!.imageWithRenderingMode(.AlwaysOriginal)
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(refreshList) name: @"refresh_Chat_List" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userTyping:) name: @"typing" object: nil];
    
    
    tempKeyArr = [[NSArray alloc] initWithObjects:@"user_id",@"connected_user_id",@"group_id",@"last_message_time",@"favorite",@"most_priority", nil];
    
//    chatListArray = [[appDelegate.generalFunction getValuesInTable:@"mds_chat_list" forKeys:tempKeyArr] mutableCopy];
    
   // chatListArray = [appDelegate.generalFunction getChatList];
    
    
    //[self getChatList];
    
    if([[appDelegate.generalFunction getContactList] count] == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_user_List" object:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [[self view] sendSubviewToBack:blackTranView];
    [chatListArray removeAllObjects];
    chatListArray = [appDelegate.generalFunction getChatList];
    [chatTableView reloadData];
    [[appDelegate socketManager] checkSocketStatus];
    
    
}

-(void) refresh
{
    offset = @"0";
    [pullToRefresh endRefreshing];
    [[appDelegate socketManager] getChatList];
    //[self getChatList];
}


-(void) refreshList
{

    //chatListArray = [[appDelegate.generalFunction getValuesInTable:@"mds_chat_list" forKeys:tempKeyArr] mutableCopy];
    offset = @"0";
    [chatListArray removeAllObjects];
    chatListArray = [appDelegate.generalFunction getChatList];
    
    [[self chatTableView] reloadData];
}

- (void)userTyping:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
}



//MARK:- Buttons
- (IBAction)menuBtnClicked:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"notification"
     object:nil];
    
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)homeButtonClicked:(UIButton *)sender
{
    [[self navigationController] popViewControllerAnimated:true];
}

- (IBAction)favouriteButtonClicked:(UIButton *)sender
{
    favouriteViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"favouriteViewController"];
    infoVC.from = @"broadcast";
    [[self navigationController] pushViewController:infoVC animated:YES];
}

- (IBAction)newChateButtonClicked:(UIButton *)sender
{
    self.tabBarController.selectedIndex = 0;
}

-(IBAction)newGroupButtonClicked:(UIButton *)sender
{
    GroupMemberViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
    infoVC.from = @"new";
    [[self navigationController] pushViewController:infoVC animated:YES];

}

- (IBAction)yesDeleteButtonClicked:(UIButton *)sender
{
   [[self view] sendSubviewToBack:blackTranView];
    [self deleteChatFromChatList];
}

- (IBAction)hideDeleteAlertButtonClicked:(UIButton *)sender
{
    [[self view] sendSubviewToBack:blackTranView];
}


#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell *cell;
    
    static NSString *CellIdentifier;
    
    CellIdentifier = @"chatCell";
    
    cell= (SWTableViewCell *)[chatTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
   // cell.leftUtilityButtons = [self leftButtons:indexPath];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *nameLabel = [cell viewWithTag:2];
    UILabel *textLabel = [cell viewWithTag:3];
    UILabel *timeLabel = [cell viewWithTag:4];
    UILabel *badgeLabel = [cell viewWithTag:5];
    UILabel *favImageView = [cell viewWithTag:6];
    
    badgeLabel.clipsToBounds = true;
    badgeLabel.hidden = false;
    
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    
     if([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_id"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_id"] isEqualToString:@""])
    {
        if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_icon"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/group_icon/%@",imageBaseURL,[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_icon"] ]] placeholderImage: [UIImage imageNamed: @"groupDefault"]];
        }
        
        if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_name"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_name"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_name"] isEqualToString:@""])
        {
             nameLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"group_name"];
        }
    }
    else
    {
        if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
        
        
        if (([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isEqualToString:@""]) && ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] isEqualToString:@""]))
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@", [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"first_name"],[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
        }
        else
        {
            nameLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"email"];
        }

    }
   
       
    
    if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message"] isEqualToString:@""] && [[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
    {
//        NSString *rawString = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message"];
//        
//        NSArray *messageArr = [appDel getMessageAndIV:rawString];
//        
//        NSString *decryptedString = [[appDel cryptoLib] decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
//        
//        if(decryptedString != nil && ![decryptedString isEqualToString:@""])
//        {
//            textLabel.text = [appDel UTF8Message:decryptedString];
//        }
//        else
//        {
//            textLabel.text = @"";
//        }
//        
        textLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message"];
    }
    else if (![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
    {
        if([[[NSString stringWithFormat:@"%@",[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"image"])
        {
            textLabel.text = @"Image";
        }
        else if ([[[NSString stringWithFormat:@"%@",[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"])
        {
            textLabel.text = @"Video";
        }
        else if ([[[NSString stringWithFormat:@"%@",[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"Audio"] || [[[NSString stringWithFormat:@"%@",[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"audio"])
        {
            textLabel.text = @"Audio";
        }
        else
        {
            textLabel.text = @"Document";
        }
    }
    else
    {
        textLabel.text = @"";
    }

    
    if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message_time"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message_time"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message_time"] isEqualToString:@""])
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *tempDate = [dateFormatter dateFromString:[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"last_message_time"]];
        
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        
        if([[NSCalendar currentCalendar] isDateInToday:tempDate])
        {
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        else if([[NSCalendar currentCalendar] isDateInYesterday:tempDate])
        {
           timeLabel.text = @"YESTERDAY";
        }
        else
        {
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
       
    }
    else
    {
        timeLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@""];
    }
    
    if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"unread_no"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"unread_no"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"unread_no"] isEqualToString:@""] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"unread_no"] isEqualToString:@"0"])
    {
        badgeLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"unread_no"];
    }
    else
    {
        badgeLabel.hidden = true;
        badgeLabel.text = @"";
    }
    
    
    //badgeLabel.sizeToFit;
    badgeLabel.layer.cornerRadius = badgeLabel.frame.size.width/2;
    
    if ([[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"Y"])
    {
        favImageView.hidden = false;
    }
    else
    {
        favImageView.hidden = true;
    }
    
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatListArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ChatViewController *infoVC = [[UIStoryboard storyboardWithName:@"Main2" bundle: nil] instantiateViewControllerWithIdentifier: @"ChatViewController"];
    
     infoVC.prevDataDic = [[chatListArray objectAtIndex:indexPath.row] mutableCopy];
    
    [[self navigationController] pushViewController: infoVC animated:YES];

}
#pragma mark - UIScrollViewDelegate


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] title:@""];
    
    [[rightUtilityButtons objectAtIndex:0] setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons:(NSIndexPath *)indexPath
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];

//    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0] title:@""];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0] icon:[UIImage imageNamed:@""]];
    
       if([[[[self chatListArray] objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"Y"])
        {
            [[leftUtilityButtons objectAtIndex:0] setImage:[UIImage imageNamed:@"unfavourite"] forState:UIControlStateNormal];
            
           // [[leftUtilityButtons objectAtIndex:0] setBackgroundImage:[UIImage imageNamed:@"unfavourite"] forState:UIControlStateNormal];
            
           // [[leftUtilityButtons objectAtIndex:0] setBackgroundColor:[UIColor lightGrayColor]];
            
            
        }
        else
        {
            //[[leftUtilityButtons objectAtIndex:0] setBackgroundImage:[UIImage imageNamed:@"favourite"] forState:UIControlStateNormal];
            
            [[leftUtilityButtons objectAtIndex:0] setImage:[UIImage imageNamed:@"favourite"] forState:UIControlStateNormal];
            
           // [[leftUtilityButtons objectAtIndex:0] setBackgroundColor:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0]];
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
    
    [self setFavChat: [chatTableView indexPathForCell:cell]];
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
    NSIndexPath *indexPath = [chatTableView indexPathForCell:cell];
    
    deleteIndexPath = indexPath;
    if (index == 0) {
        //Delete
        
        [[self view] bringSubviewToFront:blackTranView];
        
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

//MARK:- Searchbar
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = true;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
    
    if(![[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        favouriteViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"favouriteViewController"];
        infoVC.from = @"search";
        infoVC.prevDataDic = [[NSMutableDictionary alloc] init];
        [infoVC.prevDataDic setValue:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"searchText"];
        [[self navigationController] pushViewController:infoVC animated:YES];
    }
    
   
}

//MARK:- Webservice

-(void) setFavChat:(NSIndexPath *)indexPath
{
//    if (![appDelegate hasConnectivity]) {
//
//        [SVProgressHUD showWithStatus: [appDel getString: @"connectioError"]];
//    }
//    else
//    {
//        [SVProgressHUD showWithStatus: @"Please wait"];
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        webConnector = [[WebConnector alloc] init];
//        //        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
//
//
//        [params setObject: [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"id"] forKey: @"chat_id"];
//        WebConnector *webConnector = [[WebConnector alloc] init];
//        [webConnector setFavChat: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//            if ([responseObject objectForKey: @"status"] != nil && ![[responseObject objectForKey: @"status"] isKindOfClass:[NSNull class]] &&[[responseObject objectForKey: @"status"] isEqualToString: @"success"])
//            {
//                [appDel dismiss];
//
//
//                NSArray *tempKey = [[NSArray alloc] initWithObjects:@"favorite", nil];
//                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//
//                if([[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"Y"])
//                {
//                    [[chatListArray objectAtIndex:indexPath.row] setValue:@"N" forKey:@"favorite"];
//                    [dic setObject:@"N" forKey:@"favorite"];
//                }
//                else
//                {
//                    [[chatListArray objectAtIndex:indexPath.row] setValue:@"Y" forKey:@"favorite"];
//                  [dic setObject:@"Y" forKey:@"favorite"];
//                }
//
//                NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
//
//
//                [appDelegate.generalFunction updateTable:@"mds_chat_list" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"id = '%@'",[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
//
//                [[self chatTableView] reloadData];
//            }
//            else
//            {
//                [appDel showErrorWithStatus: [responseObject objectForKey: @"message"]];
//            }
//            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
//
//        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
//
//            if (![[[NSUserDefaults standardUserDefaults] objectForKey: @"isFailed"] boolValue])
//            {
//                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"isFailed"];
//                //[self getChatList];
//            }
//            else
//            {
//                [appDel showInfoWithStatus: [appDel getString: @"requestFail"]];
//            }
//
//        }];
//    }
}

-(void) deleteChatFromChatList
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        //        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        //[params setObject: @"English" forKey: @"language"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
       // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];

        [params setObject: [[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"id"] forKey: @"chat_id"];
        [params setObject:@"N"  forKey: @"only_message"];
        WebConnector *webConnector = [[WebConnector alloc] init];
        if (![appDelegate hasConnectivity]) {
            
            [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
            return;
        }
        
        [webConnector deleteChatFromChatList: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                
                [appDelegate.generalFunction Delete_Record_From:@"mds_chat_list" where:[NSString stringWithFormat:@"id = \"%@\"",[[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"id"]]];
                
                [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"(`receiver_id` = '%@' OR `sender_id` = '%@') AND (`receiver_id` = '%@' OR `sender_id` = '%@')",[[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"receiver_id"],[[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"receiver_id"],[[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"sender_id"],[[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"sender_id"]]];
                
                [[self chatListArray] removeObjectAtIndex:deleteIndexPath.row];
                [chatTableView reloadData];
    
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self deleteChatFromChatList];
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


@end
