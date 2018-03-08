//
//  ContactsViewController.m
//  mds
//
//  Created by SS-181 on 6/27/17.
//
//

#import "ChatViewController.h"
#import "ContactsViewController.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "WebConnector.h"
#import "UIImageView+AFNetworking.h"
//AFNetworking/
@interface ContactsViewController ()
{
    WebConnector *webConnector;
    NSMutableArray *dataArray;
    UIRefreshControl *pullToRefresh;
   
    NSMutableArray *searchCode;
    Boolean *searchActive;
}
@end

@implementation ContactsViewController

@synthesize tableView,titleLabel,searchBar,tempKeyArr;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"Contacts";
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchActive = false;
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    searchCode = [[NSMutableArray alloc] init];
    titleLabel.text = @"CONTACTS";
    searchBar.placeholder = @"Search";
    
    pullToRefresh = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: pullToRefresh];
    [pullToRefresh addTarget: self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [[appDelegate socketManager] addUserMethod];
    pullToRefresh.layer.zPosition = -1;
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(refreshList) name: @"refresh_user_List" object: nil];
    
    tempKeyArr = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time",@"user_color",@"branch_id",@"company_id",@"hq_id",@"user_type", nil];
    
    if([dataArray count] == 0)
    {
        [self getContactsList:true];
    }
    else
    {
        [self getContactsList:false];
    }
    //[[NSArray alloc] initWithObjects:@"id",@"user_id",@"name",@"user_name",@"mobile",@"user_image",@"last_login_time",@"user_color",@"location_id", nil]
    
    //dataArray = [appDelegate.generalFunction getc
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [[appDelegate socketManager] checkSocketStatus];
}

-(void) refresh
{
    [pullToRefresh endRefreshing];
    [self getContactsList:true];
}

-(void) refreshList
{
    [dataArray removeAllObjects];
    dataArray = [appDelegate.generalFunction getContactList];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell"  forIndexPath: indexPath];
    
    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *nameLabel = [cell viewWithTag:2];
    UILabel *numberLabel = [cell viewWithTag:3];
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    
    if([dataArray count] != 0 && searchActive == false)
    {
        if ([[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            [imageView setImage:[UIImage imageNamed: @"default_profile"]];
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
    }
    else if([searchCode count] != 0 && searchActive == true)
    {
        if ([[searchCode objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
        {
            [imageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[searchCode objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]]] placeholderImage: [UIImage imageNamed: @"default_profile"]];
        }
        else
        {
            [imageView setImage:[UIImage imageNamed: @"default_profile"]];
        }
        
        
        
        if (([[searchCode objectAtIndex:indexPath.row] valueForKey:@"first_name"] != nil && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"first_name"] isKindOfClass:[NSNull class]] && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"first_name"] isEqualToString:@""]) && ([[searchCode objectAtIndex:indexPath.row] valueForKey:@"last_name"] != nil && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"last_name"] isKindOfClass:[NSNull class]] && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"last_name"] isEqualToString:@""]))
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@", [[searchCode objectAtIndex:indexPath.row] valueForKey:@"first_name"],[[searchCode objectAtIndex:indexPath.row] valueForKey:@"last_name"]];
        }
        else
        {
            nameLabel.text = [[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
        
        if ([[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"] != nil && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"] isKindOfClass:[NSNull class]] && ![[[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"] isEqualToString:@""])
        {
            numberLabel.text = [[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
        else
        {
            numberLabel.text = [[searchCode objectAtIndex:indexPath.row] valueForKey:@"email"];
        }
    }
    
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchActive == false && [dataArray count] != 0)
    {
        [self.norecord setHidden:true];
        return [dataArray count];
    }
    else if(searchActive == true && [searchCode count] != 0)
    {
        [self.norecord setHidden:true];
        return [searchCode count];
    }
    
    [self.norecord setHidden:false];
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier: @"ChatViewController"];
    
    if(searchActive == false)
    {
        infoVC.prevDataDic = [[dataArray objectAtIndex:indexPath.row] mutableCopy];
    }
    else
    {
        infoVC.prevDataDic = [[searchCode objectAtIndex:indexPath.row] mutableCopy];
    }
    [[self navigationController] pushViewController: infoVC animated:YES];
}


//MARK:- SearchBar

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [[self view] endEditing:true];
    return true;
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    [searchCode removeAllObjects];
    
    NSPredicate *searchPreicate = [[NSPredicate alloc] init];
    searchPreicate = [NSPredicate predicateWithFormat:@"first_name contains[cd] %@ OR last_name contains[cd] %@ OR email contains[cd] %@",searchText,searchText,searchText];
    
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
    
    //        if(![[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    //        {
    //            favouriteViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"favouriteViewController"];
    //            infoVC.from = @"search";
    //            infoVC.prevDataDic = [[NSMutableDictionary alloc] init];
    //            [infoVC.prevDataDic setValue:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"searchText"];
    //            [[self navigationController] pushViewController:infoVC animated:YES];
    //        }
}


//MARK:- Webservice
-(void) getContactsList:(BOOL)showHud
{
    if (![appDelegate hasConnectivity]) {
        [SVProgressHUD showErrorWithStatus:@"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        WebConnector *webConnector = [[WebConnector alloc] init];
        
        if (![appDelegate hasConnectivity]) {
            
            [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
            return;
        }
        
        
        [webConnector contactslist: nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                //[dataArray removeAllObjects];
                
                if ([responseObject valueForKey:@"data"] != nil && [[responseObject valueForKey:@"data"] isKindOfClass: [NSArray class]])
                {
                    
                    //[dataArray addObjectsFromArray:[responseObject objectForKey: @"data"]];
                    
                    NSMutableArray *dataArray1 = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey: @"data"]];
                    
                    NSArray *colorArray = [[NSArray alloc] initWithObjects:@"FFEBEE",@"FFCDD2",@"EF9A9A",@"E57373", @"EF5350",@"F44336",@"E53935",@"D32F2F",@"C62828",@"B71C1C",@"FF8A80",@"FF5252",@"FF1744", @"D50000",@"FCE4EC",@"F8BBD0",@"F48FB1",@"F06292",@"EC407A",@"E91E63",@"D81B60",                         @"C2185B",@"AD1457",@"880E4F",@"FF80AB",@"FF4081",@"F50057",@"C51162",
                                           @"F3E5F5",@"E1BEE7",@"CE93D8",@"BA68C8",@"AB47BC",@"9C27B0",@"8E24AA",
                                           @"7B1FA2",@"6A1B9A",@"4A148C",@"EA80FC",@"E040FB",@"D500F9",@"AA00FF",
                                           @"EDE7F6",@"D1C4E9",@"B39DDB",@"9575CD",@"7E57C2",@"673AB7",@"5E35B1",
                                           @"512DA8",@"4527A0",@"311B92",@"B388FF",@"7C4DFF",@"651FFF",@"6200EA",
                                           @"E8EAF6",@"C5CAE9",@"9FA8DA",@"7986CB",@"5C6BC0",@"3F51B5",@"3949AB",
                                           @"303F9F",@"283593",@"1A237E",@"8C9EFF",@"536DFE",@"3D5AFE",@"304FFE",
                                           @"E3F2FD",@"BBDEFB",@"90CAF9",@"64B5F6",@"42A5F5",@"2196F3",@"1E88E5",
                                           @"1976D2",@"1565C0",@"0D47A1",@"82B1FF",@"448AFF",@"2979FF",@"2962FF",
                                           @"E1F5FE",@"B3E5FC",@"81D4fA",@"4fC3F7",@"29B6FC",@"03A9F4",@"039BE5",                         @"0288D1",@"0277BD",@"01579B",@"80D8FF",@"40C4FF",@"00B0FF",@"0091EA",
                                           @"E0F7FA",@"B2EBF2",@"80DEEA",@"4DD0E1",@"26C6DA",@"00BCD4",@"00ACC1",
                                           @"0097A7",@"00838F",@"006064",@"84FFFF",@"18FFFF",@"00E5FF",@"00B8D4",
                                           @"E0F2F1",@"B2DFDB",@"80CBC4",@"4DB6AC",@"26A69A",@"009688",@"00897B",
                                           @"00796B",@"00695C",@"004D40",@"A7FFEB",@"64FFDA",@"1DE9B6",@"00BFA5",
                                           @"E8F5E9",@"C8E6C9",@"A5D6A7",@"81C784",@"66BB6A",@"4CAF50",@"43A047",
                                           @"388E3C",@"2E7D32",@"1B5E20",@"B9F6CA",@"69F0AE",@"00E676",@"00C853",
                                           @"F1F8E9",@"DCEDC8",@"C5E1A5",@"AED581",@"9CCC65",@"8BC34A",@"7CB342",
                                           @"689F38",@"558B2F",@"33691E",@"CCFF90",@"B2FF59",@"76FF03",@"64DD17",
                                           @"F9FBE7",@"F0F4C3",@"E6EE9C",@"DCE775",@"D4E157",@"CDDC39",@"C0CA33",
                                           @"A4B42B",@"9E9D24",@"827717",@"F4FF81",@"EEFF41",@"C6FF00",@"AEEA00",
                                           @"FFFDE7",@"FFF9C4",@"FFF590",@"FFF176",@"FFEE58",@"FFEB3B",@"FDD835",
                                           @"FBC02D",@"F9A825",@"F57F17",@"FFFF82",@"FFFF00",@"FFEA00",@"FFD600",
                                           @"FFF8E1",@"FFECB3", nil];
                    
                    for(int i = 0; i<dataArray1.count;i++)
                    {
                        NSMutableArray *DBValueArr = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *tempContactDic = [[NSMutableDictionary alloc] init];
                        tempContactDic = [[dataArray1 objectAtIndex:i] mutableCopy];
                        
                        [tempContactDic setValue:colorArray[arc4random_uniform(184)] forKey:@"user_color"];
                        
                        if([tempContactDic valueForKey:@"first_name"] != nil)
                        {
                            [tempContactDic setValue: [NSString stringWithFormat:@"%@ %@", [tempContactDic valueForKey:@"first_name"], [tempContactDic valueForKey:@"last_name"]] forKey:@"user_name"];
                            [tempContactDic setValue: [NSString stringWithFormat:@"%@ %@", [tempContactDic valueForKey:@"first_name"], [tempContactDic valueForKey:@"last_name"]] forKey:@"name"];
                            [tempContactDic setValue:[[dataArray1 objectAtIndex:i] valueForKey:@"user_id"] forKey:@"id"];
                        }
                        
                        DBValueArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:tempKeyArr andWhere:[NSString stringWithFormat:@"user_id = '%@'",[[dataArray1 objectAtIndex:i] valueForKey:@"user_id"]]] mutableCopy];
                        
                        if([DBValueArr count] > 0)
                        {
                            [appDelegate.generalFunction updateTable:@"mds_users" forKeys:tempKeyArr setValue:[[NSArray alloc] initWithObjects:tempContactDic, nil] andWhere:[NSString stringWithFormat:@"user_id = '%@'",[[dataArray1 objectAtIndex:i] valueForKey:@"user_id"]]];
                        }
                        else
                        {
                            [appDelegate.generalFunction insertDataIntoTable:@"mds_users" forKeys:tempKeyArr Values:[[NSArray alloc] initWithObjects:tempContactDic, nil]];
                        }
                    }
                }
                
                [tableView reloadData];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self getContactsList:showHud];
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
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus: [responseObject objectForKey: @"message"]];
            }
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD dismiss];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey: @"isFailed"] boolValue])
            {
                [SVProgressHUD dismiss];
                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"isFailed"];
                [self getContactsList:false];
            }
            else
            {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus: @"Please try again."];
            }
            
        }];
    }
}

@end
