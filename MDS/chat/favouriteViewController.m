//
//  favouriteViewController.m
//  UMA
//
//  Created by SS-181 on 7/20/17.
//
//

#import "favouriteViewController.h"
#import "WebConnector.h"
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "SWTableViewCell.h"
#import "GroupMemberViewController.h"

@interface favouriteViewController ()
{
    WebConnector *webConnector;
    NSMutableArray *searchCode;
    NSMutableArray *searchMessageArray;
    BOOL searchActive;
}
@end

@implementation favouriteViewController

@synthesize tableView,titleLabel,dataListArray,prevDataDic,from,searchBarHeightConst,searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];

    searchBar.placeholder = @"Search";
    webConnector = [[WebConnector alloc] init];
    dataListArray = [[NSMutableArray alloc] init];
    searchMessageArray = [[NSMutableArray alloc] init];
    searchCode = [[NSMutableArray alloc] init];
    searchActive = false;
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.BroadcastButton.hidden = true;

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(from != nil && [from isEqualToString:@"forwardMessage"])
    {
        titleLabel.text = @"SELECT CONTACT";
        dataListArray = [appDelegate.generalFunction getContactList];
    }
    else if(from != nil && [from isEqualToString:@"broadcast"])
    {
        titleLabel.text = @"BROADCASTS";
        dataListArray = [appDelegate.generalFunction getAllBroadcastGroups];
        self.BroadcastButton.hidden = false;
        searchBarHeightConst.constant = 0;
    }
    else if(from != nil && [from isEqualToString:@"search"])
    {
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = [prevDataDic valueForKey:@"searchText"];
        dataListArray = [appDelegate.generalFunction getSearchedContact:[prevDataDic valueForKey:@"searchText"]];
        searchMessageArray = [appDelegate.generalFunction getSearchedMessage:[prevDataDic valueForKey:@"searchText"]];
        searchBarHeightConst.constant = 0;
    }
    else
    {
        from = @"";
    }
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK:- Buttons
-(IBAction)backButtonTapped:(UIButton *)sender
{
    [[self navigationController]popViewControllerAnimated:true];
}

-(IBAction)newBroadcastButtonTapped:(UIButton *)sender
{
    GroupMemberViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupMemberViewController"];
    infoVC.from = @"broadcast";
    [[self navigationController] pushViewController:infoVC animated:YES];
}
#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   SWTableViewCell *cell = [[SWTableViewCell alloc] init];
    
     cell = [self.tableView dequeueReusableCellWithIdentifier:@"chatCell"  forIndexPath: indexPath];
    
    if ([from isEqualToString:@"favourites"])
    {
   // cell.leftUtilityButtons = [self leftButtons:indexPath];
    //cell.rightUtilityButtons = [self rightButtons];
    //cell.delegate = self;
    }
    
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
    
    NSMutableDictionary *tempDataDic = [[NSMutableDictionary alloc] init];
    
    if(searchActive)
    {
        tempDataDic = [searchCode objectAtIndex:indexPath.row];
    }
    else
    {
        if(indexPath.section == 0)
        {
          tempDataDic = [dataListArray objectAtIndex:indexPath.row];
        }
        else
        {
           tempDataDic = [searchMessageArray objectAtIndex:indexPath.row];
        }
    }
    
    
    if([tempDataDic valueForKey:@"group_id"] != nil && ![[tempDataDic valueForKey:@"group_id"] isEqualToString:@""])
    {
        if ([tempDataDic valueForKey:@"group_icon"] != nil && ![[tempDataDic valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/group_icon/%@",imageBaseURL,[tempDataDic valueForKey:@"group_icon"] ]] placeholderImage: [UIImage imageNamed: @"groupDefault"]];
        }
        
        if ([tempDataDic valueForKey:@"group_name"] != nil && ![[tempDataDic valueForKey:@"group_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"group_name"] isEqualToString:@""])
        {
            nameLabel.text = [tempDataDic valueForKey:@"group_name"];
        }
    }
    else
    {
        if ([tempDataDic valueForKey:@"profile_picture"] != nil && ![[tempDataDic valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[tempDataDic valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
         
        
        if (([tempDataDic valueForKey:@"first_name"] != nil && ![[tempDataDic valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"first_name"] isEqualToString:@""]) && ([tempDataDic valueForKey:@"last_name"] != nil && ![[tempDataDic valueForKey:@"last_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"last_name"] isEqualToString:@""]))
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@", [tempDataDic valueForKey:@"first_name"],[tempDataDic valueForKey:@"last_name"]];
        }
        else
        {
            nameLabel.text = [tempDataDic valueForKey:@"email"];
        }
        
        
    }
    
//    if (indexPath.section == 1 && [tempDataDic valueForKey:@"group_id"] != nil && ![[tempDataDic valueForKey:@"group_id"] isEqualToString:@""])
//    {
//         nameLabel.text = [tempDataDic valueForKey:@"group_name"];
//    }
//    else if ([tempDataDic valueForKey:@"name"] != nil && ![[tempDataDic valueForKey:@"name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"name"] isEqualToString:@""])
//    {
//        nameLabel.text = [tempDataDic valueForKey:@"name"];
//    }
//    else
//    {
//        nameLabel.text = [tempDataDic valueForKey:@"user_name"];
//    }
    
    
    
    if ([from isEqualToString:@"favourites"] || [from isEqualToString:@"search"])
        {
            if ([tempDataDic valueForKey:@"last_message"] != nil && ![[tempDataDic valueForKey:@"last_message"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"last_message"] isEqualToString:@""] && [[tempDataDic valueForKey:@"attachment_type"] isEqualToString:@""])
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
                textLabel.text = [tempDataDic valueForKey:@"last_message"];
            }
            else if (![[tempDataDic valueForKey:@"attachment_type"] isEqualToString:@""])
            {
                if([[[NSString stringWithFormat:@"%@",[tempDataDic valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"image"])
                {
                    textLabel.text = @"Image";
                }
                else if ([[[NSString stringWithFormat:@"%@",[tempDataDic valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"])
                {
                    textLabel.text = @"Video";
                }
                else if ([[[NSString stringWithFormat:@"%@",[tempDataDic valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"Audio"] || [[[NSString stringWithFormat:@"%@",[tempDataDic valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"audio"])
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
        
    }
    else if ([from isEqualToString:@"forwardMessage"])
    {
        if ([tempDataDic valueForKey:@"user_name"] != nil && ![[tempDataDic valueForKey:@"user_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"user_name"] isEqualToString:@""])
        {
            textLabel.text = [tempDataDic valueForKey:@"user_name"];
        }
        else
        {
            textLabel.text = [tempDataDic valueForKey:@"name"];
        }
        //textLabel.text = [tempDataDic valueForKey:@"mobile"];
    }
    else
    {
        textLabel.text = @"";
    }
    
  
    
    if (([from isEqualToString:@"favourites"] || indexPath.section == 1) && [tempDataDic valueForKey:@"last_message_time"] != nil && ![[tempDataDic valueForKey:@"last_message_time"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"last_message_time"] isEqualToString:@""])
    {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
            [dateFormatter setTimeZone:TimeZone];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *tempDate = [dateFormatter dateFromString:[tempDataDic valueForKey:@"last_message_time"]];
            
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
            timeLabel.text = @"";
        }

    
    if ([tempDataDic valueForKey:@"unread_no"] != nil && ![[tempDataDic valueForKey:@"unread_no"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"unread_no"] isEqualToString:@""] && ![[tempDataDic valueForKey:@"unread_no"] isEqualToString:@"0"])
    {
        badgeLabel.text = [tempDataDic valueForKey:@"unread_no"];
    }
    else
    {
        badgeLabel.hidden = true;
        badgeLabel.text = @"";
    }
    
    
    //badgeLabel.sizeToFit;
    badgeLabel.layer.cornerRadius = badgeLabel.frame.size.width/2;
    
    if ([tempDataDic valueForKey:@"favorite"] != nil &&[[tempDataDic valueForKey:@"favorite"] isEqualToString:@"Y"])
    {
        favImageView.hidden = false;
    }
    else
    {
        favImageView.hidden = true;
    }
    
    
    if ([from isEqualToString:@"search"])
    {
        if(indexPath.section == 0)
        {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nameLabel.text];
            
            NSRange range = [[nameLabel.text lowercaseString] rangeOfString:[titleLabel.text lowercaseString]];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0] range:range];
            
            nameLabel.attributedText = attString;
        }
        else
        {
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textLabel.text];
            
            NSRange range = [[textLabel.text lowercaseString] rangeOfString:[titleLabel.text lowercaseString]];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(101/255.0) green:(145/255.0) blue:(234/255.0) alpha:1.0] range:range];
            
            textLabel.attributedText = attString;
        }
        
    }

    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([from isEqualToString:@"search"])
    {
        return 2;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchActive)
    {
        return [searchCode count];
    }
    else
    {
        if(section == 0)
        {
           return [dataListArray count];
        }
        return [searchMessageArray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *tempDataDic = [[NSMutableDictionary alloc] init];
    
    if(searchActive)
    {
        tempDataDic = [searchCode objectAtIndex:indexPath.row];
    }
    else
    {
        if(indexPath.section == 0)
        {
           tempDataDic = [dataListArray objectAtIndex:indexPath.row];
        }
        else
        {
            tempDataDic = [searchMessageArray objectAtIndex:indexPath.row];
        }
        
    }
    
   if([from isEqualToString:@"forwardMessage"])
   {
       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
       NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
       
       NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
       
       tempDic = prevDataDic;
       
       [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
       [tempDic setObject:@"" forKey:@"mid"];
       
       [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
       [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
       [tempDic setObject:[tempDataDic objectForKey: @"user_id"] forKey:@"receiver_id"];
       [tempDic setObject: [NSNull null] forKey:@"group_id"];
       [tempDic setObject: @"unread" forKey:@"read_status"];
       [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
       [tempDic setObject: @"" forKey:@"deleted_at"];
       [tempDic setObject: @"" forKey:@"read_at"];
       [tempDic setObject: @"" forKey:@"delivery_time"];
       
       
       NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
       [dateFormatter setTimeZone:localTimeZone];
       [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
       [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
       
       
       [appDelegate.socketManager sendMessage:tempDic];
       
       [[self navigationController]popViewControllerAnimated:true];
       
   }
   else if([from isEqualToString:@"broadcast"] || [from isEqualToString:@"search"] )
   {
       ChatViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier: @"ChatViewController"];
       
       infoVC.prevDataDic = tempDataDic;
       
       [[self navigationController] pushViewController: infoVC animated:YES];
   }
    
}

-(CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    if([from isEqualToString:@"search"] && ((section == 0 && dataListArray.count > 0) || (section == 1 && searchMessageArray.count > 0)))
    {
        return 30;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 29, self.view.frame.size.width, 1)];
    
    topImageView.backgroundColor = [UIColor lightGrayColor];
    bottomImageView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 15, 30)];
    
    bgView.clipsToBounds = true;
    bgView.backgroundColor = [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:1.0];
    
    label.backgroundColor = [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:1.0];
    label.font = [UIFont fontWithName:@"Roboto-Regular" size:14.0];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:(111/255.0) green:(113/255.0) blue:(121/255.0) alpha:1.0];
    
    if(section == 0)
    {
        label.text = @"Contacts";
    }
    else
    {
         label.text = @"Messages";
    }
   
    [bgView addSubview:label];
    [bgView addSubview:topImageView];
    [bgView addSubview:bottomImageView];
    
    return bgView;
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
    
    if([[[[self dataListArray] objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"Y"])
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
    
    //[self setFavChat: [tableView indexPathForCell:cell]];
    
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
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    
    //deleteIndexPath = indexPath;
//    if (index == 0) {
//        //Delete
//        
//        [[self view] bringSubviewToFront:blackTranView];
//        
//    }
    
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

//MARK:- Search bar
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [searchCode removeAllObjects];
    
    NSPredicate *searchPreicate = [[NSPredicate alloc] init];
    
    if ([from isEqualToString:@"broadcast"])
    {
        searchPreicate = [NSPredicate predicateWithFormat:@"group_name contains[cd] %@",searchText];
    }
    else
    {
        searchPreicate = [NSPredicate predicateWithFormat:@"first_name contains[cd] %@ OR last_name contains[cd] %@",searchText,searchText];
    }
    
    NSArray *tempSearchCategory = [[NSArray alloc] initWithArray:[dataListArray filteredArrayUsingPredicate:searchPreicate]];
    
    [searchCode addObjectsFromArray:tempSearchCategory];
    
    if([searchCode count] == 0)
    {
        if([searchText isEqualToString:@""])
        {
            searchActive = false;
        }
        else
        {
            searchActive = true;
        }
        
    }
    else
    {
        searchActive = true;
    }
    
    [self.tableView reloadData];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = true;
    searchActive = true;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
    searchActive = false;
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchActive = false;
    searchBar.text = @"";
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}



//MARK:- Webservice
//-(void) setFavChat:(NSIndexPath *)indexPath
//{
//    if (![appDel hasConnectivity]) {
//
//        [appDel showInfoWithStatus: [appDel getString: @"connectioError"]];
//    }
//    else
//    {
//        [appDel showWithStatus: [appDel getString: @"loading"]];
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        webConnector = [[WebConnector alloc] init];
//        //        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
//        [params setObject: @"English" forKey: @"language"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
//        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
//
//
//        [params setObject: [[dataListArray objectAtIndex:indexPath.row] valueForKey:@"id"] forKey: @"chat_id"];
//
//        [webConnector setFavChat: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//            if ([[responseObject objectForKey: @"status"] isEqualToString: @"success"])
//            {
//                [appDel dismiss];
//
//
//                NSArray *tempKey = [[NSArray alloc] initWithObjects:@"favorite", nil];
//                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//
//                if([[[dataListArray objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"Y"])
//                {
//                    [[dataListArray objectAtIndex:indexPath.row] setValue:@"N" forKey:@"favorite"];
//                    [dic setObject:@"N" forKey:@"favorite"];
//                }
//                else
//                {
//                    [[dataListArray objectAtIndex:indexPath.row] setValue:@"Y" forKey:@"favorite"];
//                    [dic setObject:@"Y" forKey:@"favorite"];
//                }
//
//                NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
//
//
//                [[appDel generalFunction] updateTable:@"uma_chat_list" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"id = '%@'",[[dataListArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
//
//                if([[[dataListArray objectAtIndex:indexPath.row] valueForKey:@"favorite"] isEqualToString:@"N"])
//                {
//                    [dataListArray removeObject:[dataListArray objectAtIndex:indexPath.row]];
//                }
//
//                [[self tableView] reloadData];
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
//}


@end
