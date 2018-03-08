//
//  IncidentReportListing.m
//  MDS
//
//  Created by SS068 on 03/01/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "IncidentReportListing.h"
#import "NewIRViewController.h"
#import "CalendarView.h"

@interface IncidentReportListing ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *selectedNoOfRows;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn2;
@end

@implementation IncidentReportListing
{
    NSMutableArray *arar;
    CalendarView *calView;
    NSMutableDictionary *dataDic;
    Boolean boolSelect;
    UIRefreshControl *pullToRefresh;
}

@synthesize norecordLbl,from;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    boolSelect = false;
    _selectedNoOfRows.adjustsFontSizeToFitWidth = true;
    _filterDateConst.constant = 0;
    arar = [[NSMutableArray alloc] init];
    dataDic = [[NSMutableDictionary alloc] init];
    boolSelect = false;
    UITextField *textField = [_searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
    [dataDic setValue:@"10" forKey:@"limit"];
    pullToRefresh = [[UIRefreshControl alloc] init];
    [self.tableView addSubview: pullToRefresh];
    [pullToRefresh addTarget: self action:@selector(callWebservice) forControlEvents:UIControlEventValueChanged];
    pullToRefresh.layer.zPosition = -1;
    [self viewSelect];
    // Do any additional setup after loading the view.
}


-(void)callWebservice
{
    [dataDic setValue:@"10" forKey:@"limit"];
    [self listingWebService:true];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(([from isEqualToString:@"my"] && ([dataDic valueForKey:@"myIR"] == nil || [[dataDic valueForKey:@"myIR"] count] == 0)) || ([from isEqualToString:@"sent"] && ([dataDic valueForKey:@"sentIR"] == nil || [[dataDic valueForKey:@"sentIR"] count] == 0)))
    {
        [self listingWebService:YES];
    }
    else
    {
        [self listingWebService:false];
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

// MARK:- selected view
-(void)viewSelect{
    
    
    [_editHeaderBtn setHidden:true];
    [_exportHeaderBtn setHidden:true];
    [_delHeaderBtn setHidden:true];
    calView = [[[NSBundle mainBundle] loadNibNamed:@"Calendar" owner:self options:nil] objectAtIndex:0];
    calView.frame = CGRectMake(0, self.view.frame.size.height - calView.frame.size.height, self.view.frame.size.width, calView.frame.size.height);
    [calView.select addTarget:self action:@selector(selectCal:) forControlEvents:UIControlEventTouchUpInside];
    [calView.cancel addTarget:self action:@selector(cancelCal:) forControlEvents: UIControlEventTouchUpInside];
    calView.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:calView];
    [calView setHidden: true];
}

// MARK:- button handling


- (IBAction)fromButton:(UIButton *)senter {
    
    if(calView.isHidden == false)
    {
        return;
    }
    
    [calView setHidden: false];
    
    //NSDateFormatter *df;
    NSDateFormatter *df1;
    //df = [[NSDateFormatter alloc] init];
    //[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"dd-MM-yyyy";
    calView.datePicker.maximumDate = [NSDate date];
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
        [dataDic removeObjectForKey:@"post_time_from"];
    }
    
    if([dataDic valueForKey:@"post_time_to"] != nil)
    {
        [dataDic removeObjectForKey:@"post_time_to"];
    }
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        [dataDic removeObjectForKey:@"search_array"];
    }
    
    [_toDate setTitle:@"TO" forState:UIControlStateNormal];
    [_fromDate setTitle:@"FROM" forState:UIControlStateNormal];
    [_dateBtn setTitle:@"CHOOSE DATE" forState:UIControlStateNormal];
    [dataDic setValue:@"10" forKey:@"limit"];
    if([dataDic valueForKey:@"search_term"] != nil)
    {
        [self listingWebService:true];
        return;
    }
    [self.tableView reloadData];
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
    [_dateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",[dataDic valueForKey:@"post_time_from"], [dataDic valueForKey:@"post_time_to"]] forState:UIControlStateNormal];
    _dateBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    [dataDic setValue:@"10" forKey:@"limit"];
    //    if([from isEqualToString:@"my"])
    //    {
    //        [dataDic setValue:@"10" forKey:@"mylimit"];
    //    }
    //    else if([from isEqualToString:@"sent"])
    //    {
    //        [dataDic setValue:@"10" forKey:@"sentlimit"];
    //    }
    
    
    [self listingWebService:true];
}


- (IBAction)dateBtn:(UIButton *)sender {
    
    [_tableView setUserInteractionEnabled:false];
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
}

- (IBAction)closeIncidentBtn:(UIButton *)sender {
    
    UIAlertController * alertController2 = [UIAlertController alertControllerWithTitle: @""
                                                                              message: @"Select action to perform."
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController2 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController2 addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteIR];
    }]];
    [alertController2 addAction:[UIAlertAction actionWithTitle:@"Closure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self closureIR];
    }]];
    
    [self presentViewController:alertController2 animated:YES completion:nil];
}

-(void)closureIR
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Close IR"
                                                                              message: @"Are you sure you want to close IR?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if([[_tableView indexPathsForSelectedRows] count]>0){
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
            {
                if([from isEqualToString:@"sent"])
                {
                   [arr addObject:[[[dataDic valueForKey:@"sentIR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
                }
                else
                {
                    return;
                }
            }
            
            [self closeIncidentWebService:arr optionChoose:@"close-comment"];
        }
    }
]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)deleteIR
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Delete IR"
                                                                              message: @"Are you sure you want to delete IR?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIAlertController * alertController1 = [UIAlertController alertControllerWithTitle: @"IR Comment"
                                                                                   message: @"Please enter closing comment for IR."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        [alertController1 addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"IR Comment";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        
        [alertController1 addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alertController1 addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController1.textFields;
            UITextField * password = textfields[0];
            
            if(![[[password text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            {
                [dataDic setValue:password.text forKey:@"ir_close_comment"];
                
                if([[_tableView indexPathsForSelectedRows] count]>0){
                    
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
                    {
                        if([from isEqualToString:@"sent"])
                        {
                            [arr addObject:[[[dataDic valueForKey:@"sentIR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
                        }
                        else
                        {
                            return;
                        }
                    }
                    [self closeIncidentWebService:arr optionChoose:@"close-incident"];
                }
                
            }
        }]];
        
        [self presentViewController:alertController1 animated:YES completion:nil];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)editHeaderBtn:(UIButton *)sender {
    
    if(sender.isSelected == false)
    {
        [self editHeaderValue:false];
    }
    else
    {
        [self editHeaderValue:true];
    }
}

-(void)editHeaderValue:(Boolean)selection
{
    if(selection == false)
    {
        [_editHeaderBtn setSelected:true];
        [_editHeaderBtn setImage:[UIImage imageNamed:@"deEdit"] forState:UIControlStateNormal];
        [_filterBtnView setAlpha:0.5];
        [_searchBar setAlpha:0.5];
        [_searchBar setUserInteractionEnabled:false];
        boolSelect = true;
        [_dateBtn setEnabled:false];
        [_tableView setAllowsMultipleSelection:true];
        [_exportHeaderBtn setHidden:false];
        [_selectedNoOfRows setText:@"0 Selected"];
        
        if([from isEqualToString:@"sent"])
        {
            [_delHeaderBtn setHidden:false];
        }
    }
    else
    {
        [_editHeaderBtn setSelected:false];
        [_editHeaderBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [_filterBtnView setAlpha:1.0];
        [_searchBar setAlpha:1.0];
        [_searchBar setUserInteractionEnabled:true];
        boolSelect = false;
        
        [_selectedNoOfRows setText:@"SECURE IR"];
        [_dateBtn setEnabled:true];
        [_delHeaderBtn setHidden:true];
        [_exportHeaderBtn setHidden:true];
        [_tableView setAllowsMultipleSelection:false];
    }
}


- (IBAction)exportHeaderBtn:(id)sender
{
    if([[_tableView indexPathsForSelectedRows] count]>0){
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int i = 0;i < [_tableView indexPathsForSelectedRows].count;i++)
        {
            if([from isEqualToString:@"my"])
            {
                [arr addObject:[[[dataDic valueForKey:@"myIR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
            }
            else
            {
                [arr addObject:[[[dataDic valueForKey:@"sentIR"] objectAtIndex:[[_tableView indexPathsForSelectedRows] objectAtIndex:i].row] valueForKey:@"id"]];
            }
        }
        
        [self exportIRService:arr];
    }
}



- (IBAction)menuBtnClick:(UIButton *)sender {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
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
            [self listingWebService:true];
            return;
        }
        [dataDic setValue:@"10" forKey:@"limit"];
        [_tableView reloadData];
    }
    @catch (NSException *exception) {
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)SearchBar
{
    NSString *searchValue= SearchBar.text;
    if (![searchValue isEqualToString:@""]) {
        [dataDic setValue:searchValue forKey:@"search_term"];
        
        //        if([from isEqualToString:@"my"])
        //        {
        //            [dataDic setValue:@"10" forKey:@"mylimit"];
        //        }
        //        else if([from isEqualToString:@"sent"])
        //        {
        //            [dataDic setValue:@"10" forKey:@"sentlimit"];
        //        }
        
        [dataDic setValue:@"10" forKey:@"limit"];
        [self listingWebService:true];
    }
    
    
    [SearchBar resignFirstResponder];
}


// MARK:- table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    [self setenablingViews:true];
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        if([[dataDic valueForKey:@"search_array"] count]>0)
        {
            [self setenablingViews:false];
        }
        [_dateBtn setEnabled:true];
        [_dateBtn2 setEnabled:true];
        return [[dataDic valueForKey:@"search_array"] count];
    }
    else if([from isEqualToString:@"my"] && [dataDic valueForKey:@"myIR"] != nil)
    {
        if([[dataDic valueForKey:@"myIR"] count]>0)
        {
            [self setenablingViews:false];
        }
        
        return [[dataDic valueForKey:@"myIR"] count];
    }
    else if([from isEqualToString:@"sent"] && [dataDic valueForKey:@"sentIR"] != nil)
    {
        if([[dataDic valueForKey:@"sentIR"] count]>0)
        {
            [self setenablingViews:false];
        }
        return [[dataDic valueForKey:@"sentIR"] count];
    }
    
    return 0;
}

-(void)setenablingViews:(Boolean)show
{
    if(show)
    {
        [_editHeaderBtn setHidden:true];
        [norecordLbl setHidden:false];
        
        if([dataDic valueForKey:@"post_time_to"] == nil && [dataDic valueForKey:@"post_time_from"] == nil)
        {
            [_dateBtn setEnabled:false];
            [_dateBtn2 setEnabled:false];
        }
    }
    else
    {
        [_editHeaderBtn setHidden:false];
        [norecordLbl setHidden:true];
        [_dateBtn setEnabled:true];
        [_dateBtn2 setEnabled:true];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier:@"incidentListCell" forIndexPath:indexPath];
    UILabel *incidentID = [cell viewWithTag:1];
    UILabel *incidentText =[cell viewWithTag:2];
    UILabel *incidentReported = [cell viewWithTag:3];
    UILabel *dateLbl = [cell viewWithTag:4];
    UILabel *timeLbl = [cell viewWithTag:5];
    UIImageView *calendar = [cell viewWithTag:7];
    UIImageView *clock = [cell viewWithTag:8];
    [calendar setImage:[UIImage imageNamed:@"calendar_red"]];
    [clock setImage:[UIImage imageNamed:@"clock_red"]];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if([dataDic valueForKey:@"search_array"] != nil)
    {
        dic = [[[dataDic valueForKey:@"search_array"] objectAtIndex:indexPath.row] mutableCopy];
    }
    else if([from isEqualToString:@"my"] && [dataDic valueForKey:@"myIR"] != nil && [[dataDic valueForKey:@"myIR"] count]>0)
    {
        dic = [[[dataDic valueForKey:@"myIR"] objectAtIndex:indexPath.row] mutableCopy];
    }
    else if([from isEqualToString:@"sent"] && [dataDic valueForKey:@"sentIR"] && [[dataDic valueForKey:@"sentIR"] count]>0)
    {
        dic = [[[dataDic valueForKey:@"sentIR"] objectAtIndex:indexPath.row] mutableCopy];
    }
    
    
    if([dic count]>0)
    {
        incidentID.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"ir_id"]];
        incidentText.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"incident_title"]];
        incidentReported.text = [NSString stringWithFormat:@"%@",[[dic valueForKey:@"poster_name"] valueForKey:@"poster_name"]];
        
        NSDateFormatter *dateFormat= [[NSDateFormatter alloc]init];
        dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        df1.dateFormat = @"dd/MM/yyyy";
        dateLbl.text = [df1 stringFromDate:[dateFormat dateFromString:[NSString stringWithFormat:@"%@",[dic valueForKey:@"incident_post_time"]]]];
        df1.dateFormat = @"hh:mm a";
        timeLbl.text = [df1 stringFromDate:[dateFormat dateFromString:[NSString stringWithFormat:@"%@",[dic valueForKey:@"incident_post_time"]]]];
        
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(boolSelect)
    {
        _selectedNoOfRows.text= [NSString stringWithFormat:@"%lu  SELECTED",[_tableView indexPathsForSelectedRows].count];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *calendar = [cell viewWithTag:7];
        UIImageView *clock = [cell viewWithTag:8];
        [calendar setImage:[UIImage imageNamed:@"calendar"]];
        [clock setImage:[UIImage imageNamed:@"clock_black"]];
        //[selectarry addObject:[[[dataDic valueForKey:@"myIR"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
    }
    else
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NewIRViewController *vc = [story instantiateViewControllerWithIdentifier:@"NewIRViewController"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        if([dataDic valueForKey:@"search_array"] != nil)
        {
            dic = [[[dataDic valueForKey:@"search_array"] objectAtIndex:indexPath.row] mutableCopy];
        }
        else if([from isEqualToString:@"my"])
        {
            dic = [[[dataDic valueForKey:@"myIR"] objectAtIndex:indexPath.row] mutableCopy];
        }
        else
        {
            dic = [[[dataDic valueForKey:@"sentIR"] objectAtIndex:indexPath.row] mutableCopy];
        }
        vc.dataDic = [dic mutableCopy];
        vc.from = @"view";
        [self.navigationController pushViewController:vc animated:true];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedNoOfRows.text= [NSString stringWithFormat:@"%lu  SELECTED",[_tableView indexPathsForSelectedRows].count];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *calendar = [cell viewWithTag:7];
    UIImageView *clock = [cell viewWithTag:8];
    [calendar setImage:[UIImage imageNamed:@"calendar_red"]];
    [clock setImage:[UIImage imageNamed:@"clock_red"]];
    //  [selectarry removeObject:[[[dataDic valueForKey:@"myIR"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(boolSelect)
    {
        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    else
    {
        [[tableView cellForRowAtIndexPath:indexPath] setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return true;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger limit = 0;
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height))
    {
        if(([dataDic valueForKey:@"search_term"] != nil) || ([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil))
        {
            if([dataDic valueForKey:@"allLimit"] != nil && [[dataDic valueForKey:@"allLimit"] integerValue] <= [[dataDic valueForKey:@"search_array"] count])
            {
                return;
            }
        }
        else if([from isEqualToString:@"my"])
        {
            if([dataDic valueForKey:@"allLimit"] != nil && [[dataDic valueForKey:@"allLimit"] integerValue] <= [[dataDic valueForKey:@"myIR"] count])
            {
                return;
            }
        }
        else
        {
            if([dataDic valueForKey:@"allLimit"] != nil && [[dataDic valueForKey:@"allLimit"] integerValue] <= [[dataDic valueForKey:@"sentIR"] count])
            {
                return;
            }
        }
        
        limit = [[dataDic valueForKey:@"limit"] integerValue];
        limit = limit + 10;
        
        [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
        
        //        if([from isEqualToString:@"my"]){
        //
        //            if([dataDic valueForKey:@"mylimit"] != nil && [[dataDic valueForKey:@"mylimit"] integerValue] <= [[dataDic valueForKey:@"myIR"] count])
        //            {
        //                return;
        //            }
        //
        //            limit = [[dataDic valueForKey:@"mylimit"] integerValue];
        //            limit = limit + 10;
        //
        //            [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"mylimit"];
        //
        //        }
        //        else if ([from isEqualToString:@"sent"]) {
        //            if([dataDic valueForKey:@"sentlimit"] != nil && [[dataDic valueForKey:@"sentlimit"] integerValue] <= [[dataDic valueForKey:@"sentIR"] count])
        //            {
        //                return;
        //            }
        //            limit = [[dataDic valueForKey:@"sentlimit"] integerValue];
        //            limit = limit + 10;
        //            [dataDic setValue:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"sentlimit"];
        //        }
        
        [self listingWebService:YES];
    }
}

// MARK:- web service methods

-(void)listingWebService:(Boolean)choice
{
    [pullToRefresh endRefreshing];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD dismiss];
    if(choice)
    {
        [SVProgressHUD showWithStatus:@"Please wait."];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    
    
    if([from isEqualToString:@"my"])
    {
        [params setValue:@"my" forKey:@"action"];
        // [params setValue:[dataDic valueForKey:@"mylimit"] forKey:@"limit"];
    }
    else
    {
        [params setValue:@"sent" forKey:@"action"];
        // [params setValue:[dataDic valueForKey:@"sentlimit"] forKey:@"limit"];
    }
    
    if([dataDic valueForKey:@"search_term"] != nil)
    {
        [params setValue:[dataDic valueForKey:@"search_term"] forKey:@"search_term"];
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
    NSString *url = [NSString stringWithFormat:@"%@api/auth/incident-listing?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webconnector IRLising:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            if(([dataDic valueForKey:@"search_term"] != nil) || ([dataDic valueForKey:@"post_time_from"] != nil && [dataDic valueForKey:@"post_time_to"] != nil))
            {
                [dataDic setValue:[[responseObject valueForKey:@"data"] mutableCopy] forKey:@"search_array"];
            }
            else if([from isEqualToString:@"my"])
            {
                if([dataDic valueForKey:@"myIR"] == nil || [[dataDic valueForKey:@"myIR"] count] == 0 || [[dataDic valueForKey:@"limit"] isEqualToString:@"10"])
                {
                    [dataDic setValue:[[responseObject valueForKey:@"data"] mutableCopy] forKey:@"myIR"];
                }
                else
                {
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    arr = [[dataDic valueForKey:@"myIR"] mutableCopy];
                    
                    for(int i = 0;i< [[responseObject valueForKey:@"data"] count];i++)
                    {
                        if(![arr containsObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]])
                        {
                            [arr addObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]];
                        }
                    }
                    [dataDic setValue:arr forKey:@"myIR"];
                }
                
                // [dataDic setValue:[responseObject valueForKey:@"allListCount"] forKey:@"my_limit"];
            }
            else if ([from isEqualToString:@"sent"])
            {
                if([dataDic valueForKey:@"sentIR"] == nil || [[dataDic valueForKey:@"sentIR"] count] == 0 || [[dataDic valueForKey:@"limit"] isEqualToString:@"10"])
                {
                    [dataDic setValue:[[responseObject valueForKey:@"data"] mutableCopy] forKey:@"sentIR"];
                }
                else
                {
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    arr = [[dataDic valueForKey:@"sentIR"] mutableCopy];
                    
                    for(int i = 0;i< [[responseObject valueForKey:@"data"] count];i++)
                    {
                        if(![arr containsObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]])
                        {
                            [arr addObject:[[responseObject valueForKey:@"data"] objectAtIndex:i]];
                        }
                    }
                    [dataDic setValue:arr forKey:@"sentIR"];
                }
                
                // [dataDic setValue:[responseObject valueForKey:@"allListCount"] forKey:@"sent_limit"];
            }
            [dataDic setValue:[responseObject valueForKey:@"allListCount"] forKey:@"allLimit"];
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
                    
                    [self listingWebService:choice];
                }
            } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
            }];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [appDelegate.constant logoutFromApp];
        }
    }errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
}


-(void)exportIRService:(NSMutableArray *)selected
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    [params setValue:selected forKey:@"incident_ids"];
    
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Please wait."];
    
    WebConnector *webconnector = [[WebConnector alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/incident-export?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webconnector exportIncident:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            [_selectedNoOfRows setText:@"0 Selected"];
            [_tableView reloadData];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                 {
                     NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                     [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                     [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                     
                     [self exportIRService:selected];
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
        
    }errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
}


-(void)closeIncidentWebService:(NSMutableArray *)selected optionChoose:(NSString *)option
{
    if (![appDelegate hasConnectivity]) {
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Please wait."];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    [params setValue:selected forKey:@"incident_id"];
    
    if([option isEqualToString:@"close-incident"])
    {
        [params setValue:[dataDic valueForKey:@"ir_close_comment"] forKey:@"ir_close_comment"];
    }
    else
    {
        [params setValue:@"Y" forKey:@"ir_close_comment_status"];
    }
    
    WebConnector *webconnector = [[WebConnector alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/%@?token=%@",BaseURL,option,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    
    [webconnector closeIncident:params url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            //            NSMutableArray *arr = [[NSMutableArray alloc] init];
            //            arr = [dataDic valueForKey:@"sentIR"];
            //
            //            for(int j = 0; j<[selected count]; j++)
            //            {
            //                for(int i =0; i< [arr count];i++)
            //                {
            //                    if([[NSString stringWithFormat:@"%@", [selected objectAtIndex:j]] isEqualToString:[NSString stringWithFormat:@"%@", [[arr objectAtIndex:i] valueForKey:@"id"]]])
            //                    {
            //                        [arr removeObjectAtIndex:i];
            //                    }
            //                }
            //            }
            //
            //            [dataDic setValue:arr forKey:@"sentIR"];
            if([dataDic valueForKey:@"search_array"] != nil)
            {
                [dataDic removeObjectForKey:@"search_array"];
            }
            else if([dataDic valueForKey:@"sentIR"] != nil)
            {
                [dataDic removeObjectForKey:@"sentIR"];
            }
            [dataDic setValue:@"10" forKey:@"limit"];
            boolSelect = false;
            [SVProgressHUD showErrorWithStatus:@"Incident Closed Successfully."];
            _selectedNoOfRows.text = @"INCIDENT REPORT";
            
            [self editHeaderValue:true];
            [self listingWebService:true];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            [webconnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                {
                    NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                    [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                    [self closeIncidentWebService:selected optionChoose:option];
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
        
    }errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Please try again."];
    }];
}

@end
