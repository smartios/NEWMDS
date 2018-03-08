//
//  MYTRViewController.m
//  MDS
//
//  Created by SS068 on 03/01/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "MYTRViewController.h"
#import "SecureTRController.h"
#import "CalendarView.h"
#import "ContactsViewController.h"

@interface MYTRViewController ()
@end

@implementation MYTRViewController
{
    CalendarView *calView;
    //NSInteger limit;
    NSMutableDictionary *dataDic;
    Boolean selection;
    UIRefreshControl *pullToRefresh;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    selection = false;
    dataDic = [[NSMutableDictionary alloc] init];
    
    if([_from isEqualToString:@"receive"])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(NewTRcallWebservice) name: @"newTR" object: nil];
    }
    else if([_from isEqualToString:@"draft"])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(callWebservice) name: @"draftSent" object: nil];
    }
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
    ContactsViewController *vc = [story instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    vc.tempKeyArr = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time",@"user_color",@"branch_id",@"company_id",@"hq_id",@"user_type", nil];
    [vc getContactsList:true];
    UITextField *textField = [_searchText valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
    pullToRefresh = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: pullToRefresh];
    [pullToRefresh addTarget: self action:@selector(callWebservice) forControlEvents:UIControlEventValueChanged];
    pullToRefresh.layer.zPosition = -1;
    [self settingViews];
    // [self webservice];
}


-(void)NewTRcallWebservice
{
    [self webservice:false];
}


-(void)callWebservice
{
     [dataDic setValue:@"10" forKey:@"limit"];
    [self webservice:true];
}

-(void)settingViews
{
    //    if([_from isEqualToString:@"receive"])
    //    {
    //        [dataDic setValue:@"10" forKey:@"receiveLimit"];
    //    }
    //    else if([_from isEqualToString:@"sent"])
    //    {
    //        [dataDic setValue:@"10" forKey:@"sentLimit"];
    //    }
    //    else if([_from isEqualToString:@"draft"])
    //    {
    //        [dataDic setValue:@"10" forKey:@"draftLimit"];
    //    }
    [dataDic setValue:@"10" forKey:@"limit"];
    [_headerEditBtn setHidden:true];
    [_headerExportBtn setHidden:true];
    
    _filterDateConst.constant = 0;
    _calOkBtn.layer.cornerRadius = 8;
    _cancelButton.layer.borderColor=[UIColor redColor].CGColor;
    calView = [[[NSBundle mainBundle] loadNibNamed:@"Calendar" owner:self options:nil] objectAtIndex:0];
    calView.frame = CGRectMake(0, self.view.frame.size.height - calView.frame.size.height, self.view.frame.size.width, calView.frame.size.height);
    [calView.select addTarget:self action:@selector(selectCal:) forControlEvents:UIControlEventTouchUpInside];
    [calView.cancel addTarget:self action:@selector(cancelCal:) forControlEvents: UIControlEventTouchUpInside];
    calView.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:calView];
    [calView setHidden: true];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(([_from isEqualToString:@"receive"] && ([dataDic valueForKey:@"receiveTR"] == nil || [[dataDic valueForKey:@"receiveTR"] count] == 0)) || ([_from isEqualToString:@"sent"] && ([dataDic valueForKey:@"sentTR"] == nil || [[dataDic valueForKey:@"sentTR"] count] == 0)) || ([_from isEqualToString:@"draft"] && ([dataDic valueForKey:@"draftTR"] == nil || [[dataDic valueForKey:@"draftTR"] count] == 0)))
    {
        [self webservice:YES];
    }
    else
    {
        [self webservice:false];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


//MARK:- tableview functions

-(void)setenablingViews:(Boolean)show
{
    if(show)
    {
        [_recordLbl setHidden:false];
        [_headerEditBtn setHidden:true];
        [_dateButton setEnabled:false];
        [_dateButton2 setEnabled:false];
    }
    else
    {
        [_recordLbl setHidden:true];
        [_headerEditBtn setHidden:false];
        [_dateButton setEnabled:true];
        [_dateButton2 setEnabled:true];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self setenablingViews:true];
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        if([[dataDic valueForKey:@"search_array"] count]>0)
        {
            [self setenablingViews:false];
        }
        
        [_dateButton setEnabled:true];
        [_dateButton2 setEnabled:true];
        return [[dataDic valueForKey:@"search_array"] count];
    }
    else if([_from isEqualToString:@"receive"] && [dataDic valueForKey:@"receiveTR"] != nil)
    {
        if([[dataDic valueForKey:@"receiveTR"] count]>0)
        {
            [self setenablingViews:false];
        }
        
        return [[dataDic valueForKey:@"receiveTR"] count];
    }
    else if([_from isEqualToString:@"sent"] && [dataDic valueForKey:@"sentTR"] != nil)
    {
        if([[dataDic valueForKey:@"sentTR"] count]>0)
        {
            [self setenablingViews:false];
        }
        return [[dataDic valueForKey:@"sentTR"] count];
    }
    else if([_from isEqualToString:@"draft"] && [dataDic valueForKey:@"draftTR"] != nil)
    {
        if([[dataDic valueForKey:@"draftTR"] count]>0)
        {
            [self setenablingViews:false];
        }
        return [[dataDic valueForKey:@"draftTR"] count];
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [_tableView dequeueReusableCellWithIdentifier:@"myTRCell" forIndexPath:indexPath];
    UILabel *titleLabel = [cell viewWithTag:1];
    UILabel *TRIDLabel = [cell viewWithTag:2];
    UILabel *nameLabel = [cell viewWithTag:3];
    UILabel *dateLabel = [cell viewWithTag:4];
    UILabel *timeLabel = [cell viewWithTag:5];
    UIView *tipView = [cell viewWithTag:6];
    UIImageView *calendar = [cell viewWithTag:7];
    UIImageView *clock = [cell viewWithTag:8];
    UILabel *titleNameLabel = [cell viewWithTag:9];

    [calendar setImage:[UIImage imageNamed:@"calendar_red"]];
    [clock setImage:[UIImage imageNamed:@"clock_red"]];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        dic = [[[dataDic valueForKey:@"search_array"] objectAtIndex:indexPath.row] mutableCopy];
    }
    else if([_from isEqualToString:@"receive"] && [dataDic valueForKey:@"receiveTR"] != nil)
    {
        dic = [[[dataDic valueForKey:@"receiveTR"] objectAtIndex:indexPath.row] mutableCopy];
    }
    else if([_from isEqualToString:@"sent"] && [dataDic valueForKey:@"sentTR"] != nil)
    {
        dic = [[[dataDic valueForKey:@"sentTR"] objectAtIndex:indexPath.row] mutableCopy];
    }
    else if([_from isEqualToString:@"draft"] && [dataDic valueForKey:@"draftTR"] != nil)
    {
        dic = [[[dataDic valueForKey:@"draftTR"] objectAtIndex:indexPath.row] mutableCopy];
    }
    
    
    if([dic count] >0)
    {
        
        TRIDLabel.text = [dic valueForKey:@"tr_id"];
       
        titleNameLabel.text =  [NSString stringWithFormat:@"%@", [dic valueForKey:@"tr_title"]];;

        titleLabel.text = [NSString stringWithFormat:@"%c", [[[[dic valueForKey:@"poster_name"] valueForKey:@"poster_name"] uppercaseString] characterAtIndex:0]];
        nameLabel.text = [[dic valueForKey:@"poster_name"] valueForKey:@"poster_name"];
        
        //        nameLabel.text = [[dic valueForKey:@"poster_name"] valueForKey:@"poster_name"];
        //
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        df1.dateFormat = @"dd/MM/yyyy";
        
        dateLabel.text = [df1 stringFromDate:[df dateFromString:[NSString stringWithFormat:@"%@", [dic valueForKey:@"tr_post_time"]]]];
        
        df1.dateFormat = @"HH:mm";
        timeLabel.text = [df1 stringFromDate:[df dateFromString:[NSString stringWithFormat:@"%@", [dic valueForKey:@"tr_post_time"]]]];
    }
    tipView.layer.cornerRadius= (tipView.frame.size.width)/2;
    tipView.clipsToBounds=YES;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  130;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(selection == false)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *name = [[NSString alloc] init];
        name = _from;
        if([dataDic valueForKey:@"search_array"] != nil)
        {
            name = @"search";
            dic = [[[dataDic valueForKey:@"search_array"] objectAtIndex:indexPath.row] mutableCopy];
        }
        else if([_from isEqualToString:@"receive"] && [dataDic valueForKey:@"receiveTR"] != nil && [[dataDic valueForKey:@"receiveTR"] count] > 0)
        {
            dic = [[[dataDic valueForKey:@"receiveTR"] objectAtIndex:indexPath.row] mutableCopy];
            
        }
        else if([_from isEqualToString:@"sent"] && [dataDic valueForKey:@"sentTR"] != nil && [[dataDic valueForKey:@"sentTR"] count] > 0)
        {
            dic = [[[dataDic valueForKey:@"sentTR"] objectAtIndex:indexPath.row] mutableCopy];
        }
        else if([_from isEqualToString:@"draft"] && [dataDic valueForKey:@"draftTR"] != nil && [[dataDic valueForKey:@"draftTR"] count] > 0)
        {
            dic = [[[dataDic valueForKey:@"draftTR"] objectAtIndex:indexPath.row] mutableCopy];
            
        }
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"TR Password"
                                                                                  message: @"Enter TR password to view TR."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"TR Password";
            textField.textColor = [UIColor blackColor];
            textField.secureTextEntry = true;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.secureTextEntry = YES;
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField * password = textfields[0];
            
            if(![[[password text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            {
                [self TRWebservice:dic ArrayOFData:_from IndexTobeChanged:indexPath text:[[password text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        _headLbl.text = [NSString stringWithFormat:@"%lu  SELECTED",[_tableView indexPathsForSelectedRows].count];
    
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *calendar = [cell viewWithTag:7];
        UIImageView *clock = [cell viewWithTag:8];
        [calendar setImage:[UIImage imageNamed:@"calendar"]];
        [clock setImage:[UIImage imageNamed:@"clock_black"]];
        
    }
}


-(void)selectedTR:(NSDictionary *)dic ArrayOFData:(NSString *)str IndexTobeChanged:(NSIndexPath *)index
{
    
    if([dic valueForKey:@"tr_read_time"] != nil && [[NSString stringWithFormat:@"%@", [dic valueForKey:@"tr_read_time"]] isEqualToString:@"0000-00-00 00:00:00"] && [[dic valueForKey:@"action"] isEqualToString:@"my"] && ![[NSString stringWithFormat:@"%@", [dic valueForKey:@"destroy_time"]] isEqualToString:@"never"])
    {
        if (![appDelegate hasConnectivity]) {
            
            [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
            return;
        }
        
        [self readWebservice:dic ArrayOFData:_from IndexTobeChanged:index];
        return;
    }
    else if(![[NSString stringWithFormat:@"%@", [dic valueForKey:@"destroy_time"]] isEqualToString:@"never"] && [[dic valueForKey:@"action"] isEqualToString:@"my"])
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitSecond fromDate:[df dateFromString:[dic valueForKey:@"tr_read_time"]]];
        NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[dic valueForKey:@"destroy_time"] componentsSeparatedByString:@":"]];
        
        components.minute = [components minute] + [[tempArr2 objectAtIndex:2] integerValue];
        components.day = [components day] + [[tempArr2 objectAtIndex:0] integerValue];
        components.hour = [components hour] + [[tempArr2 objectAtIndex:1] integerValue];
        
        NSCalendar *cal = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *newDate = [cal dateFromComponents:components];
        NSLog(@"%@", newDate);
        
        
        NSDateComponents *newComponents = [cal components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitSecond fromDate: [NSDate date] toDate:newDate  options: 0];
        
        if([newComponents minute] <= 0)
        {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"TR has expired at %@",[df stringFromDate:newDate]]];
            return;
        }
        
        
    }
    
    SecureTRController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecureTRController"];
    vc.dataDic = [dic mutableCopy];
    [self.navigationController pushViewController:vc animated:true];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _headLbl.text = [NSString stringWithFormat:@"%lu  SELECTED",[_tableView indexPathsForSelectedRows].count];
   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *calendar = [cell viewWithTag:7];
    UIImageView *clock = [cell viewWithTag:8];
    [calendar setImage:[UIImage imageNamed:@"calendar_red"]];
    [clock setImage:[UIImage imageNamed:@"clock_red"]];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selection)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    else
    {
        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return true;
}


//MARK:- end of tableview
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger limit = 0;
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height))
    {
        if(([dataDic valueForKey:@"search_term"] != nil) || ([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil))
        {
            if([dataDic valueForKey:@"limit"] != nil && [[dataDic valueForKey:@"limit"] integerValue] <= [[dataDic valueForKey:@"search_array"] count])
            {
                return;
            }
        }
        else if([_from isEqualToString:@"receive"]){
            
            if([dataDic valueForKey:@"limit"] != nil && [[dataDic valueForKey:@"limit"] integerValue] <= [[dataDic valueForKey:@"receiveTR"] count])
            {
                return;
            }
        }
        else if ([_from isEqualToString:@"sent"]) {
            if([dataDic valueForKey:@"limit"] != nil && [[dataDic valueForKey:@"limit"] integerValue] <= [[dataDic valueForKey:@"sentTR"] count])
            {
                return;
            }
            //            limit = [[dataDic valueForKey:@"sentLimit"] integerValue];
            //            limit = limit + 10;
            //            [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"sentLimit"];
        }
        else if([_from isEqualToString:@"draft"]){
            
            if([dataDic valueForKey:@"limit"] != nil && [[dataDic valueForKey:@"limit"] integerValue] <= [[dataDic valueForKey:@"draftTR"] count])
            {
                return;
            }
            //            limit = [[dataDic valueForKey:@"draftLimit"] integerValue];
            //            limit = limit + 10;
            //            [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"draftLimit"];
        }
        limit = [[dataDic valueForKey:@"limit"] integerValue];
        limit = limit + 10;
        
        [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
        [self webservice:true];
    }
}
//MARK:- web service methods

-(void)readWebservice:(NSDictionary *)dic ArrayOFData:(NSString *)str IndexTobeChanged:(NSIndexPath *)index
{
    [SVProgressHUD dismiss];
    
    [SVProgressHUD showWithStatus:@"Please wait"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] forKey:@"user_id"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [params setValue:[dic valueForKey:@"id"] forKey:@"tr_id"];
    [params setValue:[df stringFromDate:[NSDate date]] forKey:@"tr_read_time"];
    [dic setValue:[df stringFromDate:[NSDate date]] forKey:@"tr_read_time"];
    WebConnector *webconnector = [[WebConnector alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/tr-read-time?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    [webconnector TRRead:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            if([str isEqualToString:@"search"])
            {
                arr = [[dataDic valueForKey:@"search_array"] mutableCopy];
                [arr replaceObjectAtIndex:index.row withObject:dic];
                [dataDic setValue:arr forKey:@"search_array"];
            }
            else if([str isEqualToString:@"receive"])
            {
                arr = [[dataDic valueForKey:@"receiveTR"] mutableCopy];
                [arr replaceObjectAtIndex:index.row withObject:dic];
                [dataDic setValue:arr forKey:@"receiveTR"];
            }
            else if([str isEqualToString:@"draft"])
            {
                arr = [[dataDic valueForKey:@"draftTR"] mutableCopy];
                [arr replaceObjectAtIndex:index.row withObject:dic];
                [dataDic setValue:arr forKey:@"draftTR"];
            }
            else if([str isEqualToString:@"sent"])
            {
                arr = [[dataDic valueForKey:@"sentTR"] mutableCopy];
                [arr replaceObjectAtIndex:index.row withObject:dic];
                [dataDic setValue:arr forKey:@"sentTR"];
            }
            [self.tableView reloadData];
            [self selectedTR:dic ArrayOFData:str IndexTobeChanged:index];
            
//            SecureTRController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecureTRController"];
//            vc.dataDic = [dic mutableCopy];
//            [self.navigationController pushViewController:vc animated:true];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    
                    [self readWebservice:dic ArrayOFData:str IndexTobeChanged:index];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
        
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
    
}

-(void)TRWebservice:(NSDictionary *)dic ArrayOFData:(NSString *)str IndexTobeChanged:(NSIndexPath *)index text:(NSString *)passText
{
    [SVProgressHUD dismiss];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    // [params setValue:[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] forKey:@"user_id"];
    [params setValue:[dic valueForKey:@"id"] forKey:@"tr_id"];
    [params setValue:passText forKey:@"tr_password"];
    
    WebConnector *webconnector = [[WebConnector alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/trLogin?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webconnector TRRead:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [self selectedTR:dic ArrayOFData:_from IndexTobeChanged:index];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    
                    [self TRWebservice:dic ArrayOFData:str IndexTobeChanged:index text:passText];
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
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
        }
        
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
}

-(void)webservice:(Boolean )show
{
    [pullToRefresh endRefreshing];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD dismiss];
    if(show)
    {
        [SVProgressHUD showWithStatus:@"Please wait"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] forKey:@"user_id"];
    
    if([dataDic valueForKey:@"search_term"] != nil)
    {
        [params setValue:[dataDic valueForKey:@"search_term"] forKey:@"search_term"];
    }
    
    if([_from isEqualToString:@"receive"])
    {
        //  [params setValue:[dataDic valueForKey:@"receiveLimit"] forKey:@"limit"];
        [params setValue:@"my" forKey:@"action"];
    }
    else  if([_from isEqualToString:@"sent"])
    {
        //[params setValue:[dataDic valueForKey:@"sentLimit"] forKey:@"limit"];
        [params setValue:@"sent" forKey:@"action"];
    }
    else  if([_from isEqualToString:@"draft"])
    {
        //[params setValue:[dataDic valueForKey:@"draftLimit"] forKey:@"limit"];
        [params setValue:@"draft" forKey:@"action"];
    }
    
    [params setValue:[dataDic valueForKey:@"limit"] forKey:@"limit"];
    
    if([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd-MM-yyyy";
        df1.dateFormat = @"yyyy-MM-dd";
        [params setValue:[df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"post_time_from"]]] forKey:@"post_time_from"];
        [params setValue:[df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"post_time_to"]]] forKey:@"post_time_to"];
    }
    
    WebConnector *webconnector = [[WebConnector alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/tr-listing?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    
    [webconnector TRListing:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            //            NSString *str = [[NSString alloc] init];
            //            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            //            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //
            //            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            //            [df1 setDateFormat:@"dd/MM/yyyy"];
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            if(([dataDic valueForKey:@"search_term"] != nil) || ([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil))
            {
                [dataDic setValue:[[responseObject valueForKey:@"data"] mutableCopy] forKey:@"search_array"];
                [dataDic setValue:[responseObject valueForKey:@"allListCount"] forKey:@"limit"];
                [self.tableView reloadData];
                return;
            }
            else if([_from isEqualToString:@"receive"])
            {
                
                if([dataDic valueForKey:@"receiveTR"] == nil || [[NSString stringWithFormat:@"%@", [dataDic valueForKey:@"limit"]] isEqualToString:@"10"])
                {
                    arr = [[responseObject valueForKey:@"data"] mutableCopy];
                }
                else if([[responseObject valueForKey:@"data"] count] > 0)
                {
                    arr = [[dataDic valueForKey:@"receiveTR"] mutableCopy];
                    
                    for(int i = 0 ;i < [[responseObject valueForKey:@"data"] count];i++)
                    {
                        if(![arr containsObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]])
                        {
                            [arr addObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]];
                        }
                    }
                }
                
                [dataDic setValue:arr forKey:@"receiveTR"];
            }
            else  if([_from isEqualToString:@"sent"])
            {
                if([dataDic valueForKey:@"sentTR"] == nil || [[NSString stringWithFormat:@"%@", [dataDic valueForKey:@"limit"]] isEqualToString:@"10"])
                {
                    arr = [[responseObject valueForKey:@"data"] mutableCopy];
                }
                else if([[responseObject valueForKey:@"data"] count] > 0)
                {
                    arr = [[dataDic valueForKey:@"sentTR"] mutableCopy];
                    for(int i = 0 ;i < [[responseObject valueForKey:@"data"] count];i++)
                    {
                        if(![arr containsObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]])
                        {
                            [arr addObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]];
                        }
                    }
                }
                
                [dataDic setValue:arr forKey:@"sentTR"];
            }
            else if([_from isEqualToString:@"draft"])
            {
                if([dataDic valueForKey:@"draftTR"] == nil || [[NSString stringWithFormat:@"%@", [dataDic valueForKey:@"limit"]] isEqualToString:@"10"])
                {
                    arr = [[responseObject valueForKey:@"data"] mutableCopy];
                }
                else if([[responseObject valueForKey:@"data"] count] > 0)
                {
                    arr = [[dataDic valueForKey:@"draftTR"] mutableCopy];
                    for(int i = 0 ;i < [[responseObject valueForKey:@"data"] count];i++)
                    {
                        if(![arr containsObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]])
                        {
                            [arr addObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]];
                        }
                    }
                }
                
                [dataDic setValue:arr forKey:@"draftTR"];
            }
            
            [dataDic setValue:[responseObject valueForKey:@"allListCount"] forKey:@"limit"];
            [_tableView reloadData];
            
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    
                    [self webservice:show];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
        
    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
    
}

-(IBAction) sidemenu: (UIButton*) senter {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}


// MARK:- searching methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)SearchBar
{
    SearchBar.showsCancelButton=YES;
    SearchBar.returnKeyType = UIReturnKeySearch;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar
{
    @try
    {
        SearchBar.showsCancelButton=NO;
        [SearchBar resignFirstResponder];
        SearchBar.text = @"";
        
        if([dataDic valueForKey:@"search_array"] != nil)
        {
            [dataDic removeObjectForKey:@"search_array"];
            [dataDic removeObjectForKey:@"search_term"];
        }
        
        if([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil)
        {
            [self webservice:true];
            return;
        }
        
        [_tableView reloadData];
    }
    @catch (NSException *exception) {
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)SearchBar
{
    NSString *searchValue= _searchText.text;
    if (![searchValue isEqualToString:@""]) {
        [dataDic setValue:searchValue forKey:@"search_term"];
        
        //        if([_from isEqualToString:@"receive"])
        //        {
        //            [dataDic setValue:@"10" forKey:@"receiveLimit"];
        //        }
        //        else if([_from isEqualToString:@"sent"])
        //        {
        //            [dataDic setValue:@"10" forKey:@"sentLimit"];
        //        }
        //        else if([_from isEqualToString:@"draft"])
        //        {
        //            [dataDic setValue:@"10" forKey:@"draftLimit"];
        //        }
        [dataDic setValue:@"10" forKey:@"limit"];
        [self webservice:true];
    }
    
    
    [SearchBar resignFirstResponder];
}

//MARK:- header buttons

- (IBAction)headerExportBtn:(UIButton *)sender {
    [self exportWebservice];
}

- (IBAction)headerEditBtn:(UIButton *)sender {
    
    if(sender.isSelected == false)
    {
        [_headerEditBtn setImage:[UIImage imageNamed:@"deEdit"] forState:UIControlStateNormal];
        [_filterBtnView setAlpha:0.5];
        [_searchText setAlpha:0.5];
        [_dateButton setEnabled:false];
        [_searchText setUserInteractionEnabled:false];
        [sender setSelected:true];
        [_tableView setAllowsMultipleSelection:true];
        selection = true;
        
        if([_from isEqualToString:@"sent"] || [_from isEqualToString:@"draft"])
        {
            [_headerExportBtn setHidden:false];
        }
        else if([_from isEqualToString:@"receive"])
        {
            [_headerExportBtn setHidden:false];
        }
        [_headLbl setText:@"0 Selected"];
    }
    else
    {
        [_headerEditBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [_filterBtnView setAlpha:1.0];
        [_searchText setAlpha:1.0];
        [_searchText setUserInteractionEnabled:true];
        selection = false;
        [sender setSelected:false];
        [_headerExportBtn setHidden:true];
        [_headLbl setText:@"SECURE TR"];
        [_dateButton setEnabled:true];
        [_tableView setAllowsMultipleSelection:false];
    }
    
    [self.tableView reloadData];
}

-(void)exportWebservice
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    if([[_tableView indexPathsForSelectedRows] count] == 0)
    {
        return;
    }
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Please wait"];
    if([_from isEqualToString:@"receive"])
    {
        for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
        {
            [arr addObject:[[[dataDic valueForKey:@"receiveTR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
        }
        
    }
    else if([_from isEqualToString:@"sent"])
    {
        for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
        {
            [arr addObject:[[[dataDic valueForKey:@"sentTR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
        }
    }
    else if([_from isEqualToString:@"draft"])
    {
        for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
        {
            [arr addObject:[[[dataDic valueForKey:@"draftTR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
        }
    }
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/exporttrList?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    [params setValue:arr forKey:@"IDs"];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector exportTR:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            [_headLbl setText:@"0 Selected"];
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
                    
                    [self exportWebservice];
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

//MARK:- Date Picker Methods

- (IBAction)resetBtn:(UIButton *)senter {
    
    [UIView animateWithDuration:0.3 animations:^{
        _filterDateConst.constant = 0;
    }];
    [_tableView setUserInteractionEnabled:true];
    
    if([dataDic valueForKey:@"post_from"] != nil)
    {
        [dataDic removeObjectForKey:@"post_from"];
    }
    
    if([dataDic valueForKey:@"post_to"] != nil)
    {
        [dataDic removeObjectForKey:@"post_to"];
    }
    
    
    if([dataDic valueForKey:@"post_time_from"] != nil)
    {
        [_fromDate setTitle:@"FROM" forState:UIControlStateNormal];
        [dataDic removeObjectForKey:@"post_time_from"];
    }
    
    if([dataDic valueForKey:@"post_time_to"] != nil)
    {
        [_toDate setTitle:@"TO" forState:UIControlStateNormal];
        [dataDic removeObjectForKey:@"post_time_to"];
    }
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        [dataDic removeObjectForKey:@"search_array"];
    }
    
    [_dateButton setTitle:@"CHOOSE DATE" forState:UIControlStateNormal];
    
    if([dataDic valueForKey:@"search_term"] != nil)
    {
        [self webservice:true];
        return;
    }
    [self.tableView reloadData];
}

- (IBAction)fromButton:(UIButton *)senter {
    
    if(calView.isHidden == false)
    {
        return;
    }
    
    [calView setHidden: false];
    calView.datePicker.maximumDate = [NSDate date];
    //    NSDateFormatter *df;
    
    NSDateFormatter *df1;
    //    df = [[NSDateFormatter alloc] init];
    //    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"dd-MM-yyyy";
    
    //    if([_from isEqualToString:@"receive"]){
    //        calView.datePicker.minimumDate = [df dateFromString:[dataDic valueForKey:@"my_maxDate"]];
    //        calView.datePicker.maximumDate = [df dateFromString:[dataDic valueForKey:@"my_minDate"]];
    //        //   calView.datePicker.date = [df dateFromString:[dataDic valueForKey:@"my_minDate"]];
    //
    //    }
    //    else if([_from isEqualToString:@"sent"])
    //    {
    //        calView.datePicker.minimumDate = [df dateFromString:[dataDic valueForKey:@"sent_maxDate"]];
    //        calView.datePicker.maximumDate =[df dateFromString:[dataDic valueForKey:@"sent_minDate"]];
    //        //   calView.datePicker.date = [df dateFromString:[dataDic valueForKey:@"sent_minDate"]];
    //    }
    //    else if ([_from isEqualToString:@"draft"]){
    //        calView.datePicker.minimumDate= [df dateFromString:[dataDic valueForKey:@"draft_maxDate"]];
    //        calView.datePicker.maximumDate=[df dateFromString:[dataDic valueForKey:@"draft_minDate"]];
    //        //    calView.datePicker.date = [df dateFromString:[dataDic valueForKey:@"draft_minDate"]];
    //
    // }
    
    if(senter.tag == 1)
    {
        if([dataDic valueForKey:@"post_time_from"] != nil)
        {
            calView.datePicker.date = [df1 dateFromString:[dataDic valueForKey:@"post_time_from"]];
        }
        else if([dataDic valueForKey:@"post_from"] != nil)
        {
            calView.datePicker.date = [df1 dateFromString:[dataDic valueForKey:@"post_from"]];
        }
        else
        {
            calView.datePicker.date = [NSDate date];
        }
        calView.datePicker.tag = 1;
    }
    else
    {
        if([dataDic valueForKey:@"post_time_to"] != nil)
        {
            calView.datePicker.date = [df1 dateFromString:[dataDic valueForKey:@"post_time_to"]];
        }
        else if([dataDic valueForKey:@"post_to"] != nil)
        {
            calView.datePicker.date = [df1 dateFromString:[dataDic valueForKey:@"post_to"]];
        }
        else
        {
            calView.datePicker.date = [NSDate date];
        }
        calView.datePicker.tag = 2;
    }
}

- (IBAction)cancelButton:(UIButton *)senter
{
    [UIView animateWithDuration:0.3 animations:^{
        _filterDateConst.constant = 0;
    }];
    [_tableView setUserInteractionEnabled:true];
    
    if([dataDic valueForKey:@"post_from"] != nil)
    {
        [dataDic removeObjectForKey:@"post_from"];
    }
    
    if([dataDic valueForKey:@"post_to"] != nil)
    {
        [dataDic removeObjectForKey:@"post_to"];
    }
}

- (IBAction)okButton:(UIButton *)senter
{
    NSDateFormatter *df1;
    df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"dd-MM-yyyy";
    
    if([dataDic valueForKey:@"post_from"] == nil && [dataDic valueForKey:@"post_time_from"] == nil)
    {
        [SVProgressHUD showErrorWithStatus: emptyFromDate];
        return;
    }
    else if([dataDic valueForKey:@"post_to"] == nil && [dataDic valueForKey:@"post_time_to"] == nil)
    {
        
        [SVProgressHUD showErrorWithStatus: emptyToDate];
        return;
    }
    else if([[df1 dateFromString:[dataDic valueForKey:@"post_to"]] compare:[df1 dateFromString:[dataDic valueForKey:@"post_from"]]] == NSOrderedAscending ){
        
        [SVProgressHUD showErrorWithStatus: checkDate];
        return;
    }
    
    [dataDic setValue:[dataDic valueForKey:@"post_from"] forKey:@"post_time_from"];
    [dataDic setValue:[dataDic valueForKey:@"post_to"] forKey:@"post_time_to"];
    
    [UIView animateWithDuration:0.3 animations:^{
        _filterDateConst.constant = 0;
    }];
    [_tableView setUserInteractionEnabled:true];
    
    [_dateButton setTitle:[NSString stringWithFormat:@"%@ - %@",[dataDic valueForKey:@"post_time_from"], [dataDic valueForKey:@"post_time_to"]] forState:UIControlStateNormal];
    _dateButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [dataDic setValue:@"10" forKey:@"limit"];
    [self webservice:true];
}


- (IBAction)dataPickerClick:(UIButton *)senter {
    
    [UIView animateWithDuration:0.3 animations:^{
        _filterDateConst.constant = 100;
    }];
    
    if([dataDic valueForKey:@"post_time_from"] != nil)
    {
        [_fromDate setTitle:[dataDic valueForKey:@"post_time_from"] forState:UIControlStateNormal];
    }
    else if([dataDic valueForKey:@"post_from"] != nil)
    {
        [_fromDate setTitle:[dataDic valueForKey:@"post_from"] forState:UIControlStateNormal];
    }
    else
    {
        [_fromDate setTitle:@"FROM" forState:UIControlStateNormal];
    }
    
    if([dataDic valueForKey:@"post_time_to"] != nil)
    {
        [_toDate setTitle:[dataDic valueForKey:@"post_time_to"] forState:UIControlStateNormal];
    }
    else if([dataDic valueForKey:@"post_to"] != nil)
    {
        [_toDate setTitle:[dataDic valueForKey:@"post_to"] forState:UIControlStateNormal];
    }
    else
    {
        [_toDate setTitle:@"TO" forState:UIControlStateNormal];
    }
    
    [_tableView setUserInteractionEnabled:false];
}
-(IBAction)cancelCal: (UIButton*) senter
{
    [calView setHidden:true];
}

-(IBAction)selectCal: (UIButton*) senter
{
    //NSString *str = [[NSString alloc]init];
    NSDateFormatter *df;
    NSDateFormatter *df1;
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"dd-MM-yyyy";
    [calView setHidden:true];
    
    if(calView.datePicker.tag == 1)
    {
        [dataDic setValue:[df1 stringFromDate:[calView.datePicker date]] forKey:@"post_from"];
        [_fromDate setTitle:[df1 stringFromDate:[calView.datePicker date]]forState:UIControlStateNormal];
    }
    else
    {
        [dataDic setValue:[df1 stringFromDate:[calView.datePicker date]] forKey:@"post_to" ];
        [_toDate setTitle:[df1 stringFromDate:[calView.datePicker date]]forState:UIControlStateNormal];
    }
}

@end

