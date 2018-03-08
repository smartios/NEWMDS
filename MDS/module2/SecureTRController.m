//
//  SecureTRController.m
//  MDS
//
//  Created by SS068 on 21/12/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "SecureTRController.h"
#import "UIImageView+AFNetworking.h"
#import "MediaViewController.h"
//#import "SecureTRViewCell.h"

@interface SecureTRController ()
{
    NSInteger num;
    __weak IBOutlet UILabel *TRIDLabel;
    UIPageControl *pageControl ;
    __weak IBOutlet UITableView *tableView;
}
@end

@implementation SecureTRController
@synthesize dataDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    pageControl = [[UIPageControl alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(downloadProgress:) name: @"downloadProggressUpdate" object: nil];
    // Do any additional setup after loading the view.
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        return 110;
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
        return UITableViewAutomaticDimension;
    }
    else if(indexPath.row == 3 && [[dataDic valueForKey:@"images"] count] != 0) {
        return 200;
    }
    else if ((indexPath.row == 4 && [[dataDic valueForKey:@"files"] count] != 0) || (indexPath.row == 3 && [[dataDic valueForKey:@"files"] count] != 0 && [[dataDic valueForKey:@"images"] count] == 0))
    {
        return 140;
    }
    else if (indexPath.row == num-1 && [[dataDic valueForKey:@"action"] isEqualToString:@"my"])
    {
        return 40;
    }
    else if(indexPath.row == num-1)
    {
        return 80;
    }
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    num = 4;
    
    if([[dataDic valueForKey:@"destroy_time"] isEqualToString:@"never"])
    {
        num = num - 1;
    }
    
    if([[dataDic valueForKey:@"files"] count] > 0)
    {
        num = num + 1;
    }
    
    if([[dataDic valueForKey:@"images"] count] > 0)
    {
        num = num + 1;
    }
    
    if([[dataDic valueForKey:@"action"] isEqualToString:@"draft"])
    {
        num = num + 1;
    }
    
    return num;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    TRIDLabel.text = [dataDic valueForKey:@"tr_id"];
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRTitleCell" forIndexPath:indexPath];
        
        UILabel *abbrevNameLbl = [cell viewWithTag:1];
        UILabel *name = [cell viewWithTag:2];
        UILabel * dateLbl = [cell viewWithTag:3];
        UILabel *timeLbl = [cell viewWithTag:4];
        UIView *viewLabel = [cell viewWithTag:5];
        viewLabel.layer.cornerRadius = (viewLabel.frame.size.width)/2;
        viewLabel.clipsToBounds=YES;
        
        if ([dataDic count] > 0) {
            
            TRIDLabel.text = [dataDic valueForKey:@"TR0008"];
            name.text = [[dataDic valueForKey:@"poster_name"] valueForKey:@"poster_name"];
            abbrevNameLbl.text = [NSString stringWithFormat:@"%c", [[[[dataDic valueForKey:@"poster_name"] valueForKey:@"poster_name"] uppercaseString] characterAtIndex:0]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            
            df1.dateFormat = @"dd/MM/yyyy";
            dateLbl.text = [df1 stringFromDate:[df dateFromString:[NSString stringWithFormat:@"%@", [dataDic valueForKey:@"tr_post_time"]]]];
            
            df1.dateFormat = @"HH:mm";
            timeLbl.text = [df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"tr_post_time"]]];
        }
    }
    else if(indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRMsgCell" forIndexPath:indexPath];
        
        UILabel *messageLbl = [cell viewWithTag:2];
        UILabel *titleLbl = [cell viewWithTag:1];
        titleLbl.text = @"TITLE";
        messageLbl.text = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"tr_title"]];
    }
    else if(indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRMsgCell" forIndexPath:indexPath];
        
        UILabel *messageLbl = [cell viewWithTag:2];
        UILabel *titleLbl = [cell viewWithTag:1];
        NSString *rawString = [dataDic valueForKey:@"tr_message"];
        titleLbl.text = @"MESSAGE";
        
        NSArray *messageArr = [appDelegate.constant getMessageAndIV:rawString];
        
        NSString *decryptedString = [[appDelegate cryptoLib] decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
        
        if(decryptedString != nil && ![decryptedString isEqualToString:@""])
        {
            messageLbl.text = [appDelegate.constant UTF8Message:decryptedString];
        }
        else
        {
            messageLbl.text = @"";
        }
    }
    else if(indexPath.row == 3 && [[dataDic valueForKey:@"images"] count] != 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRImageCell" forIndexPath:indexPath];
        pageControl = [cell viewWithTag:2];
        pageControl.numberOfPages = [[dataDic valueForKey:@"images"] count];
        UICollectionView *coll = [cell viewWithTag:1];
        coll.delegate = self;
        coll.dataSource = self;
        coll.restorationIdentifier = @"image";
        [coll reloadData];
    }
    else if((indexPath.row == 4 && [[dataDic valueForKey:@"files"] count] != 0) || (indexPath.row == 3 && [[dataDic valueForKey:@"files"] count] != 0 && [[dataDic valueForKey:@"images"] count] == 0)){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRFileCell" forIndexPath:indexPath];
        UICollectionView *coll = [cell viewWithTag:2];
        coll.delegate = self;
        coll.dataSource = self;
        coll.restorationIdentifier = @"file";
        [coll reloadData];
    }
    else if(indexPath.row == num-1 && [dataDic valueForKey:@"action"] != nil && [[dataDic valueForKey:@"action"] isEqualToString:@"draft"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
        UIButton *btn = [cell viewWithTag:1];
        btn.layer.cornerRadius = 19;
    }
    else if(indexPath.row == num-1 && ![[dataDic valueForKey:@"destroy_time"] isEqualToString:@"never"] && [[dataDic valueForKey:@"action"] isEqualToString:@"my"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecureTRDistroyMsgCell" forIndexPath:indexPath];
        UILabel *lbl = [cell viewWithTag:1];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitSecond fromDate:[df dateFromString:[dataDic valueForKey:@"tr_read_time"]]];
        NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[dataDic valueForKey:@"destroy_time"] componentsSeparatedByString:@":"]];
        
        components.minute = [components minute] + [[tempArr2 objectAtIndex:2] integerValue];
        components.day = [components day] + [[tempArr2 objectAtIndex:0] integerValue];
        components.hour = [components hour] + [[tempArr2 objectAtIndex:1] integerValue];
        
        NSCalendar *cal = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *newDate = [cal dateFromComponents:components];
        NSLog(@"%@", newDate);
        
        
        NSDateComponents *newComponents = [cal components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitSecond fromDate: [NSDate date] toDate:newDate  options: 0];
        
        lbl.text = [NSString stringWithFormat:@"TR will be destroyed after %ld Day(s) %ld Hour(s) %ld Min(s).", (long)newComponents.day, (long)newComponents.hour,(long) (long)newComponents.minute];
        lbl.adjustsFontSizeToFitWidth = true;
    }
    return cell;
}


//MARK:- Collection view for images and files

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if ([collectionView.restorationIdentifier isEqualToString:@"image"]) {
        return [[dataDic valueForKey:@"images"] count];
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"file"]){
        return [[dataDic valueForKey:@"files"] count];
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *collCell =[[UICollectionViewCell alloc] init];
    
    if ([collectionView.restorationIdentifier isEqualToString:@"image"]) {
        collCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scrollCell" forIndexPath:indexPath];
        
        UIImageView *imageView = [collCell viewWithTag:3];
        UILabel *imagelbl = [collCell viewWithTag:4];
        UIButton *downBtn = [collCell viewWithTag:5];
        UIActivityIndicatorView *activity = [collCell viewWithTag:6];
        [activity setHidden:true];
        [downBtn setHidden:true];
        
        
        [imageView setAlpha:1.0];
        imagelbl.text = [[[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"files"] componentsSeparatedByString:@"_mds_"][1];
        
        NSString *url = [[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"file_thumb"];
        [imageView setImageWithURL:[NSURL URLWithString: url] placeholderImage:[UIImage imageNamed: @"image_default"]];
        imageView.backgroundColor = [UIColor clearColor];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"files"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath])
        {
            [downBtn setHidden:true];
        }
        else
        {
            imageView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.4];;
            [downBtn setHidden:false];
            [downBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        }
        
        if([[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] != 1)
        {
            [downBtn setHidden:true];
            [activity setHidden:false];
            [activity startAnimating];
        }
        
    }
    else if ([collectionView.restorationIdentifier isEqualToString:@"file"]){
        collCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCell" forIndexPath:indexPath];
        UIImageView *fileImageView = [collCell viewWithTag:3];
        UIButton *downBtn = [collCell viewWithTag:5];
        UIActivityIndicatorView *activity = [collCell viewWithTag:6];
        UILabel *fileNameLbl = [collCell viewWithTag:7];
        
        
        [activity setHidden:true];
        fileImageView.backgroundColor = [UIColor clearColor];
        NSString *url = [[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] valueForKey: @"file_thumb"];
        
        [fileImageView setImageWithURL:[NSURL URLWithString: url] placeholderImage:[UIImage imageNamed: @"image_default"]];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] valueForKey:@"files"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
        fileNameLbl.text = [fileName componentsSeparatedByString:@"_mds_"][1];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath])
        {
            [downBtn setHidden:true];
        }
        else
        {
            fileImageView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.4];
            [downBtn setHidden:false];
            [downBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        }
        
        if([[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] != 1)
        {
            [downBtn setHidden:true];
            [activity setHidden:false];
            [activity startAnimating];
        }
        
    }
    return collCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([collectionView.restorationIdentifier isEqualToString:@"image"]) {
        //        return CGSizeMake(275,150);
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }
    return CGSizeMake(100, 120);
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    pageControl.numberOfPages = [[dataDic valueForKey:@"images"] count];
    pageControl.currentPage = indexPath.row;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if([collectionView.restorationIdentifier isEqualToString:@"image"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] valueForKey:@"files"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath])
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
            MediaViewController *infoVC = [story instantiateViewControllerWithIdentifier:@"MediaViewController"];
            infoVC.filePath = filePath;
            infoVC.data = nil;
            infoVC.from = @"image";
            [[self navigationController] pushViewController:infoVC animated:YES];
        }
        else
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [[dataDic valueForKey:@"images"] mutableCopy];
            NSMutableDictionary *dic = [[[dataDic valueForKey:@"images"] objectAtIndex:indexPath.row] mutableCopy];
            [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
            [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
            [dic setValue:[dic valueForKey:@"files"] forKey:@"file"];
            [arr replaceObjectAtIndex:indexPath.row withObject:dic];
            [dataDic setValue:arr forKey:@"images"];
            
            [tableView reloadData];
            [appDelegate.downlaodArray addObject:dic];
            [appDelegate.constant downloadWithNsurlconnection];
        }
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] valueForKey:@"files"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath])
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
            MediaViewController *infoVC = [story instantiateViewControllerWithIdentifier:@"MediaViewController"];
            infoVC.filePath = filePath;
            infoVC.data = nil;
            infoVC.from = @"document";
            [[self navigationController] pushViewController:infoVC animated:YES];
        }
        else
        {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            arr = [[dataDic valueForKey:@"files"] mutableCopy];
            NSMutableDictionary *dic = [[[dataDic valueForKey:@"files"] objectAtIndex:indexPath.row] mutableCopy];
            [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
            [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
            [dic setValue:[dic valueForKey:@"files"] forKey:@"file"];
            [arr replaceObjectAtIndex:indexPath.row withObject:dic];
            [dataDic setValue:arr forKey:@"files"];
            
            [tableView reloadData];
            [appDelegate.downlaodArray addObject:dic];
            [appDelegate.constant downloadWithNsurlconnection];
        }
    }
}

//MARK:- downlaod progress
-(void)downloadProgress:(NSNotification *)info
{
    
    NSDictionary *data = [[NSDictionary alloc] initWithDictionary:[info object]];
    
    if([[data valueForKey:@"file_type"] isEqualToString:@"file"])
    {
        for(int i = 0;i< [[dataDic valueForKey:@"files"] count]; i++)
        {
            if([[[dataDic valueForKey:@"files"] objectAtIndex:i] valueForKey:@"files"] == [data valueForKey:@"files"])
            {
                NSMutableDictionary *mut = [[[dataDic valueForKey:@"files"] objectAtIndex:i] mutableCopy];
                [mut setValue:[data objectForKey:@"receivedData"] forKey:@"receivedData"];
                [mut setValue:[data objectForKey:@"expectedBytes"] forKey:@"expectedBytes"];
                
                [mut setValue:[data objectForKey:@"progressive"] forKey:@"progressive"];
                NSMutableArray *arr = [[dataDic valueForKey:@"files"] mutableCopy];
                [arr replaceObjectAtIndex:i withObject:mut];
                [dataDic setValue:arr forKey:@"files"];
            }
        }
    }
    else if([[data valueForKey:@"file_type"] isEqualToString:@"images"])
    {
        for(int i = 0;i< [[dataDic valueForKey:@"images"] count]; i++)
        {
            if([[[dataDic valueForKey:@"images"] objectAtIndex:i] valueForKey:@"files"] == [data valueForKey:@"files"])
            {
                NSMutableDictionary *mut = [[[dataDic valueForKey:@"images"] objectAtIndex:i] mutableCopy];
                [mut setValue:[data objectForKey:@"receivedData"] forKey:@"receivedData"];
                [mut setValue:[data objectForKey:@"expectedBytes"] forKey:@"expectedBytes"];
                
                [mut setValue:[data objectForKey:@"progressive"] forKey:@"progressive"];
                NSMutableArray *arr = [[dataDic valueForKey:@"images"] mutableCopy];
                [arr replaceObjectAtIndex:i withObject:mut];
                [dataDic setValue:arr forKey:@"images"];
            }
        }
    }
    
    [tableView reloadData];
}

- (IBAction)sendBtn:(id)sender
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@api/auth/trSend?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"token"]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] forKey:@"user_id"];
    [dic setValue:[dataDic valueForKey:@"id"] forKey:@"tr_id"];
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"Please wait"];
    WebConnector *webConnector = [[WebConnector alloc] init];
    
    [webConnector TRRead:dic url:url completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD showSuccessWithStatus:@"TR has been sent."];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"draftSent" object:nil];
            [self.navigationController popViewControllerAnimated:true];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            
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

- (IBAction)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
