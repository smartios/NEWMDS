//
//  GroupMemberViewController.m
//  
//
//  Created by SS-181 on 7/5/17.
//
//

#import "GroupMemberViewController.h"
#import "AppDelegate.h"
#import "WebConnector.h"
#import "UIImageView+AFNetworking.h"
#import "GroupProfileViewController.h"
#import "AppDelegate.h"
//#import "NewScureTRControllerTableViewController.h"

@interface GroupMemberViewController ()
{
    WebConnector *webConnector;
    NSMutableArray *dataArray;
    //   NSMutableArray *selectedDataArray;
    NSMutableArray *searchCode;
    
    BOOL searchActive;
}
@end

@implementation GroupMemberViewController

@synthesize tableView,colectionView,collectionHeight,from,titleLabel,nextButton,prevDataDic,searchBar, selectedDataArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    searchBar.placeholder = @"Search";
    
    webConnector = [[WebConnector alloc] init];
    if(selectedDataArray == nil)
    {
        selectedDataArray = [[NSMutableArray alloc] init];
    }
    
    dataArray = [[NSMutableArray alloc] init];
    searchCode = [[NSMutableArray alloc] init];
    searchActive = false;
    
    if([from isEqualToString:@"tr_list"])
    {
        titleLabel.text = @"SELECT USERS";
        [nextButton setTitle:@"DONE" forState:UIControlStateNormal];
        dataArray = [appDelegate.generalFunction getContactList];
    }
    else if([from isEqualToString:@"new"])
    {
        titleLabel.text = @"CREATE A GROUP";
        [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
        dataArray = [appDelegate.generalFunction getContactList];
    }
    else if([from isEqualToString:@"broadcast"])
    {
        titleLabel.text = @"CREATE BROADCAST";
        [nextButton setTitle:@"NEXT" forState:UIControlStateNormal];
        dataArray = [appDelegate.generalFunction getContactList];
    }
    else
    {
        titleLabel.text = @"ADD MEMBERS";
        [nextButton setTitle:@"Add" forState:UIControlStateNormal];
        dataArray = [appDelegate.generalFunction getGroupRemainingContactList:[prevDataDic valueForKey:@"group_id"]];
    }
    
    //colectionView.frame = CGRectMake(0, 108, self.view.frame.size.width, 106);
    collectionHeight.constant = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(selectedDataArray != nil && [selectedDataArray count] > 0)
    {
        collectionHeight.constant = 106;
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
- (IBAction)removeContactButtonClicked:(UIButton *)sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:colectionView];
    NSIndexPath *indexPath = [colectionView indexPathForItemAtPoint:hitPoint];
    
    [selectedDataArray removeObjectAtIndex:indexPath.row];
    
    [colectionView reloadData];
    
    if([selectedDataArray count] == 0)
    {
        collectionHeight.constant = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }
    [tableView reloadData];
}
- (IBAction)checkBtn:(UIButton *)sender {
}
- (IBAction)backBtn:(UIButton *)sender
{
    [[self navigationController] popViewControllerAnimated: YES];
}

- (IBAction)nextBtn:(UIButton *)sender
{
    
    if([selectedDataArray count] == 0)
    {
        [SVProgressHUD showErrorWithStatus: @"Select at least one member."];
        return;
    }
    
    
    if([from isEqualToString:@"tr_list"])
    {
        [_delegate getUserList:selectedDataArray];
        [self.navigationController popViewControllerAnimated:true];
    }
    else if([from isEqualToString:@"new"] || [from isEqualToString:@"broadcast"])
    {
        GroupProfileViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupProfileViewController"];
        
        if([from isEqualToString:@"new"])
        {
            infoVC.from = @"create";
        }
        else if([from isEqualToString:@"broadcast"])
        {
            infoVC.from = @"broadcast";
        }
        
        //NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"name",@"user_name",@"mobile",@"user_image",@"last_login_time", nil];
        
        //[selectedDataArray insertObject:[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:keys andWhere:[NSString stringWithFormat:@"user_id = %@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]][0] atIndex:0];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:selectedDataArray forKey:@"members"];
        
        infoVC.prevDataDic = dic;
        
        [[self navigationController] pushViewController:infoVC animated:YES];
    }
    else
    {
        [self addNewGroupMembers];
    }
    
}

//MARK:- SearchBar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [searchCode removeAllObjects];
    
    NSPredicate *searchPreicate = [[NSPredicate alloc] init];
    
    searchPreicate = [NSPredicate predicateWithFormat:@"first_name contains[cd] %@ OR last_name contains[cd] %@",searchText,searchText];
    
    NSArray *tempSearchCategory = [[NSArray alloc] initWithArray:[dataArray filteredArrayUsingPredicate:searchPreicate]];
    
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


#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell"  forIndexPath: indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *nameLabel = [cell viewWithTag:2];
    UILabel *numberLabel = [cell viewWithTag:3];
    UIButton *button = [cell viewWithTag:4];
    
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    
    NSMutableDictionary *tempDataDic = [[NSMutableDictionary alloc] init];
    
    if(searchActive)
    {
        tempDataDic = [searchCode objectAtIndex:indexPath.row];
    }
    else
    {
        tempDataDic = [dataArray objectAtIndex:indexPath.row];
    }
    
    
    
    if ([tempDataDic valueForKey:@"profile_picture"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
    {
        [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[tempDataDic valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        
    }
    else
    {
        imageView.image = [UIImage imageNamed: @"default_profile"];
    }
    
    
    
    if (([tempDataDic valueForKey:@"first_name"] != nil && ![[tempDataDic valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"first_name"] isEqualToString:@""]) && ([tempDataDic valueForKey:@"last_name"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"last_name"] isEqualToString:@""]))
    {
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", [tempDataDic valueForKey:@"first_name"],[[dataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
    }
    else
    {
        nameLabel.text = [tempDataDic valueForKey:@"email"];
    }
    
    if ([tempDataDic valueForKey:@"email"] != nil && ![[tempDataDic valueForKey:@"email"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"email"] isEqualToString:@""])
    {
        numberLabel.text = [tempDataDic valueForKey:@"email"];
    }
    else
    {
        numberLabel.text = [tempDataDic valueForKey:@"email"];
    }
    
    //    if ([tempDataDic valueForKey:@"mobile"] != nil && ![[tempDataDic valueForKey:@"mobile"] isKindOfClass:[NSNull class]] && ![[tempDataDic valueForKey:@"mobile"] isEqualToString:@""])
    //    {
    //        numberLabel.text = [tempDataDic valueForKey:@"mobile"];
    //    }
    //    else
    //    {
    //        numberLabel.text = @"N/A";
    //    }
    
    if([selectedDataArray containsObject:tempDataDic])
    {
        [button setSelected:true];
    }
    else if([from isEqualToString:@"tr_list"] && [[prevDataDic valueForKey:@"users_list"] containsObject:tempDataDic])
    {
        [button setSelected:true];
    }
    else
    {
        [button setSelected:false];
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchActive)
    {
        return [searchCode count];
        
    }
    else
    {
        return [dataArray count];
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
        tempDataDic = [dataArray objectAtIndex:indexPath.row];
    }
    
    
    if([selectedDataArray containsObject:tempDataDic])
    {
        [selectedDataArray removeObject:tempDataDic];
        
        [colectionView.collectionViewLayout invalidateLayout];
        [colectionView reloadData];
        
        if([selectedDataArray count] == 0)
        {
            collectionHeight.constant = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            }];
            
        }
    }
    else
    {
        [selectedDataArray addObject:tempDataDic];
        
        [colectionView.collectionViewLayout invalidateLayout];
        [colectionView reloadData];
        
        if([selectedDataArray count] > 0 && collectionHeight.constant == 0)
        {
            collectionHeight.constant = 106;
            [UIView animateWithDuration:0.2 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
    }
    
    [tableView reloadData];
    
}

#pragma mark- UICollectionViewDelegate & UICollectionViewDataSinvalidateLayoutource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [selectedDataArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    
    cell = [self.colectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *nameLabel = [cell viewWithTag:2];
    
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    
    if ([[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
    {
        [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] ]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
    }
    else
    {
        imageView.image = [UIImage imageNamed: @"default_profile"];
    }
    
    if ([[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] != nil && ![[[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"] isEqualToString:@""])
    {
        nameLabel.text = [[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"first_name"];
    }
    else
    {
        nameLabel.text = [[selectedDataArray objectAtIndex:indexPath.row] valueForKey:@"last_name"];
    }
    
    
    return cell;
}



//MARK:- Webservice
-(void) addNewGroupMembers
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
        
        // [params setObject: @"English" forKey: @"language"];
        
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        //  [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: [prevDataDic valueForKey:@"group_id"] forKey: @"group_id"];
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        for(int i=0;i<[selectedDataArray count];i++)
        {
            [arr addObject:[[selectedDataArray objectAtIndex:i] valueForKey:@"user_id"]];
            
            // [params setObject:[[selectedDataArray objectAtIndex:i] valueForKey:@"user_id"] forKey:[NSString stringWithFormat:@"members[%i]",i]];
        }
        
        [params setObject:arr forKey:@"members_id"];
        //
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector addNewMembers: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                NSString *msgString = @"";
                
                //Sending Messages
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                
                [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                [tempDic setObject:@"" forKey:@"mid"];
                
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                
                [tempDic setObject: [prevDataDic valueForKey:@"group_id"] forKey:@"group_id"];
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
                
                
                
                //Adding group members
                NSArray *keysForGroupMembers = [[NSArray alloc] initWithObjects:@"group_id",@"user_id",@"is_admin",@"created_at",@"created_by", nil];
                NSMutableArray *membersArr = [[NSMutableArray alloc] init];
                
                for(int i = 0; i < [selectedDataArray count]; i++)
                {
                    //Cretating message string
                    if(i == 0 )
                    {
                        msgString = [[selectedDataArray objectAtIndex:i] valueForKey:@"first_name"];
                    }
                    else if(i == [selectedDataArray count] - 1)
                    {
                        msgString = [NSString stringWithFormat:@"%@ and %@",msgString,[[selectedDataArray objectAtIndex:i] valueForKey:@"first_name"]];
                    }
                    else
                    {
                        msgString = [NSString stringWithFormat:@"%@, %@",msgString,[[selectedDataArray objectAtIndex:i] valueForKey:@"first_name"]];
                    }
                    //Adding member Data
                    NSMutableDictionary *InfoDic = [[NSMutableDictionary alloc] init];
                    
                    [InfoDic setObject:[prevDataDic valueForKey:@"group_id"] forKey:@"group_id"];
                    [InfoDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"created_by"];
                    
                    [InfoDic setObject:[[selectedDataArray objectAtIndex:i] valueForKey:@"user_id"] forKey:@"user_id"];
                    [InfoDic setObject:@"0" forKey:@"is_admin"];
                    
                    [membersArr addObject:InfoDic];
                }
                
                msgString = [NSString stringWithFormat:@"%@ was added by %@",msgString,[[NSUserDefaults standardUserDefaults] objectForKey: @"name"]];
                
                [tempDic setObject:msgString forKey:@"message"];
                [[appDelegate socketManager] sendMessage:tempDic];
                
                [appDelegate.generalFunction insertDataIntoTable:@"mds_group_members" forKeys:keysForGroupMembers Values:membersArr];
                [[appDelegate socketManager] chatGroupUpdate:[prevDataDic valueForKey:@"group_id"]];
                
                [[self navigationController] popViewControllerAnimated:true];
                
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self addNewGroupMembers];
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
                [self addNewGroupMembers];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            }
            
        }];
    }
}

@end
