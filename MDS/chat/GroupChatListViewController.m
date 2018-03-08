//
//  GroupChatListViewController.m
//  mds
//
//  Created by SS-181 on 9/5/17.
//
//

#import "GroupChatListViewController.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "WebConnector.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "ChatViewController.h"
#import "SWTableViewCell.h"
#import "GroupMemberViewController.h"
#import "favouriteViewController.h"

@interface GroupChatListViewController ()
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

@implementation GroupChatListViewController

@synthesize chatTableView,deleteIndexPath,chatListArray,blackTranView,titleLabel,searchBar,ChatButton,favButton,GroupButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"Groups";
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    titleLabel.text = @"GROUPS";
    searchBar.placeholder = @"Search";
    [ChatButton setTitle:@"New Chat" forState:UIControlStateNormal];
  //  [favButton setTitle:[appDel getString:@"View Favourite"] forState:UIControlStateNormal];
    [GroupButton setTitle:@"New Group" forState:UIControlStateNormal];
    
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
    
    //chatListArray = [appDelegate.generalFunction getGroupChatList];
    
    
    //[self getChatList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [[self view] sendSubviewToBack:blackTranView];
    [chatListArray removeAllObjects];
    chatListArray = [appDelegate.generalFunction getGroupChatList];
    [chatTableView reloadData];
    [[appDelegate socketManager] checkSocketStatus];
    
}

-(void) refresh
{
    offset = @"0";
    [pullToRefresh endRefreshing];
    [[appDelegate socketManager] getChatList];
  //  [self getChatList];
}


-(void) refreshList
{
    
    //chatListArray = [[appDelegate.generalFunction getValuesInTable:@"mds_chat_list" forKeys:tempKeyArr] mutableCopy];
    offset = @"0";
    [chatListArray removeAllObjects];
    chatListArray = [appDelegate.generalFunction getGroupChatList];
    
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
    
    //cell.leftUtilityButtons = [self leftButtons:indexPath];
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
        if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_image"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_image"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
        
        
        if ([[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_name"] != nil && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_name"] isKindOfClass:[NSNull class]] && ![[[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_name"] isEqualToString:@""])
        {
            nameLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
        }
        else
        {
            nameLabel.text = [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"name"];
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
-(void) getChatList
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
        [params setObject: @"English" forKey: @"language"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
      //  [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: offset forKey: @"offset"];
        [params setObject: @"10" forKey: @"limit"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        
        if (![appDelegate hasConnectivity]) {
            
            [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
            return;
        }
        
        [webConnector chatlist: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"status"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                [chatListArray removeAllObjects];
                if ([responseObject objectForKey: @"data"] != nil && [[responseObject objectForKey: @"data"] isKindOfClass: [NSDictionary class]])
                {
                    if([[responseObject objectForKey: @"data"] objectForKey:@"data"] != nil && [[[responseObject objectForKey: @"data"] objectForKey:@"data"] isKindOfClass: [NSArray class]])
                    {
                        //  [chatListArray addObjectsFromArray:[[responseObject objectForKey: @"data"] objectForKey:@"data"]];
                        
                        
                        //                        "group_id" = 1;
                        //                        "group_name" = "test ";
                        //                        "last_message" = qweqwwswewere;
                        //                        "last_message_time" = "2017-07-11 19:20:38";
                        //                        name = "<null>";
                        //                        "send_by" = other;
                        //                        "sender_id" = 130;
                        //                        "sender_name" = Cerian;
                        //                        unread = 17;
                        //                        "user_id" = "<null>";
                        //                        "user_image" = "<null>";
                        //                        "user_image1" = "";
                        //                        "user_image_thumb" = "";
                        
                        //NSArray *dataArray = [[NSArray alloc] initWithArray:[[responseObject objectForKey: @"data"] objectForKey:@"data"]];
                        
                        NSArray *tempSourceArray = [[NSArray alloc] initWithArray:[[responseObject objectForKey: @"data"] objectForKey:@"data"]];
                        //[tempSourceArray arrayByAddingObjectsFromArray:[[responseObject objectForKey: @"data"] objectForKey:@"data"]];
                        
                        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                        
                        for(int i = 0; i < tempSourceArray.count; i ++)
                        {
                            NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] init];
                            
                            [valueDic setValue:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"user_id"];
                            
                            
                            if(![[[tempSourceArray objectAtIndex:i] valueForKey:@"user_id"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"connected_user_id"];
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"connected_user_id"];
                            }
                            
                            if(![[[tempSourceArray objectAtIndex:i] valueForKey:@"group_id"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"group_id"] forKey:@"group_id"];
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"group_id"];
                            }
                            
                            if(![[[tempSourceArray objectAtIndex:i] valueForKey:@"last_message_time"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"last_message_time"] forKey:@"last_message_time"];
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"last_message_time"];
                            }
                            
                            if([[tempSourceArray objectAtIndex:i] valueForKey:@"favorite"] != nil && ![[[tempSourceArray objectAtIndex:i] valueForKey:@"favorite"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"favorite"] forKey:@"favorite"];
                                
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"favorite"];
                            }
                            
                            if([[tempSourceArray objectAtIndex:i] valueForKey:@"most_priority"] != nil && ![[[tempSourceArray objectAtIndex:i] valueForKey:@"most_priority"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"most_priority"] forKey:@"most_priority"];
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"most_priority"];
                            }
                            
                            if([[tempSourceArray objectAtIndex:i] valueForKey:@"last_message"] != nil && ![[[tempSourceArray objectAtIndex:i] valueForKey:@"last_message"] isKindOfClass:[NSNull class]])
                            {
                                [valueDic setValue:[[tempSourceArray objectAtIndex:i] valueForKey:@"last_message"] forKey:@"last_message"];
                            }
                            else
                            {
                                [valueDic setValue:@"" forKey:@"last_message"];
                            }
                            
                            [dataArray addObject:valueDic];
                        }
                        
                        
                        
                        for(int i = 0; i<dataArray.count;i++)
                        {
                            NSMutableArray *tempGroupChatArr = [[NSMutableArray alloc] init];
                            NSMutableArray *tempOneChatArr = [[NSMutableArray alloc] init];
                            
                            NSArray *tempValuesArr = [[NSArray alloc] initWithObjects:[dataArray objectAtIndex:i], nil];
                            
                            if ([[dataArray objectAtIndex:i] valueForKey:@"group_id"] != nil && ![[[dataArray objectAtIndex:i] valueForKey:@"group_id"] isKindOfClass:[NSNull class]] && ![[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:i] valueForKey:@"group_id"]] isEqualToString:@""])
                            {
                                
                                tempGroupChatArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_chat_list" forKeys:tempKeyArr andWhere:[NSString stringWithFormat:@"group_id = '%@'",[[dataArray objectAtIndex:i] valueForKey:@"group_id"]]] mutableCopy];
                            }
                            else
                            {
                                tempOneChatArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_chat_list" forKeys:tempKeyArr andWhere:[NSString stringWithFormat:@"user_id = '%@' AND connected_user_id = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[dataArray objectAtIndex:i] valueForKey:@"connected_user_id"]]] mutableCopy];
                                
                            }
                            
                            if([tempOneChatArr count] > 0 || [tempGroupChatArr count] > 0)
                            {
                                [appDelegate.generalFunction updateTable:@"mds_chat_list" forKeys:tempKeyArr setValue:tempValuesArr andWhere:[NSString stringWithFormat:@"user_id = '%@' AND connected_user_id = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[dataArray objectAtIndex:i] valueForKey:@"connected_user_id"]]];
                            }
                            else
                            {
                                
                                [appDelegate.generalFunction insertDataIntoTable:@"mds_chat_list" forKeys:tempKeyArr Values:tempValuesArr];
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
                    if([[responseObject objectForKey: @"data"] objectForKey:@"next_offset"] != nil && [[[responseObject objectForKey: @"data"] objectForKey:@"next_offset"] isKindOfClass: [NSArray class]])
                    {
                        offset = [NSString stringWithFormat:@"%@",[[responseObject objectForKey: @"data"] objectForKey:@"next_offset"]];
                    }
                    
                }
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
                        
                        [self getChatList];
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
            
            if (![[[NSUserDefaults standardUserDefaults] objectForKey: @"isFailed"] boolValue])
            {
                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"isFailed"];
                //[self getChatList];
            }
            else
            {
                //[SVProgressHUD showErrorWithStatus: @"Please try again."]
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            }
            
        }];
    }
}

-(void) setFavChat:(NSIndexPath *)indexPath
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {}
//    {
//        [SVProgressHUD showWithStatus: @"Please wait"];
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        webConnector = [[WebConnector alloc] init];
//        //        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
//        [params setObject: @"English" forKey: @"language"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
//
//
//        [params setObject: [[chatListArray objectAtIndex:indexPath.row] valueForKey:@"id"] forKey: @"chat_id"];
//
//        [webConnector setFavChat: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//            if ([responseObject objectForKey: @"status"] != nil && ![[responseObject objectForKey: @"status"] isKindOfClass:[NSNull class]] &&[[responseObject objectForKey: @"status"] isEqualToString: @"success"])
//            {
//                [SVProgressHUD dismiss];
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
//                    [dic setObject:@"Y" forKey:@"favorite"];
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
//                [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
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
//                [SVProgressHUD showWithStatus: @"Please try again."];
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
        [params setObject: @"English" forKey: @"language"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        
        [params setObject: [[chatListArray objectAtIndex:deleteIndexPath.row] valueForKey:@"id"] forKey: @"chat_id"];
        
        [webConnector deleteChatFromChatList: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"status"] isEqualToString: @"success"])
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
            
            if (![[[NSUserDefaults standardUserDefaults] objectForKey: @"isFailed"] boolValue])
            {
                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"isFailed"];
                //[self getChatList];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            }
            
        }];
    }
}


@end
