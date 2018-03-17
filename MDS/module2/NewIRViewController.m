//
//  NewIRViewController.m
//  MDS
//
//  Created by SL-167 on 1/6/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import "NewIRViewController.h"
#import "AudioViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MediaViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GoogleMaps/GoogleMaps.h>

@interface NewIRViewController ()

@end

@implementation NewIRViewController
{
    UITapGestureRecognizer *tap;
    UIView *optionView;
    NSIndexPath *selectedIndexPath;
    NSMutableDictionary *playingDict;
}
@synthesize iconConst,tableView,textView, dataDic,textfield, iconViewConst, dataArray, audioPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    optionView.hidden = true;
    selectedIndexPath = [[NSIndexPath alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    playingDict = [[NSMutableDictionary alloc] init];
    
    //Code to handle keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    [self defaultValues];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(downloadProgress:) name: @"downloadProggressUpdate" object: nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if([_from isEqualToString:@"new"])
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
        df1.dateFormat = @"dd/MM/yyyy";
        [dataDic setValue:[df stringFromDate:[NSDate date]] forKey:@"date"];
        [_dateBTN setTitle:[df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"date"]]] forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [audioPlayer stop];
}


-(void)defaultValues
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    df1.dateFormat = @"dd/MM/yyyy";
    
    if([_from isEqualToString:@"new"])
    {
        dataDic = [[NSMutableDictionary alloc] init];
        
        [dataDic setValue:[df stringFromDate:[NSDate date]] forKey:@"date"];
        [_dateBTN setTitle:[df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"date"]]] forState:UIControlStateNormal];
        [_dateBTN setEnabled:true];
        textView.text = @"Say something...";
        _titleLbl.text = @"REPORT TITLE";
        _titleLbl.font = [UIFont fontWithName:_titleLbl.font.fontName size:13];
        [textfield setEnabled:true];
        _sendBtn.layer.cornerRadius = 18;
        _headLbl.text = @"NEW INCIDENT REPORT";
        [_menuBtn setImage: [UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        _IRLbl.text =@"INC";
        _sendBTnCons.constant = 48;
        _showIconBtnConst.constant = 46;
        iconViewConst.constant = 88;
        [_sendChatBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(callWebService) name: @"newComment" object: nil];
        
        if(![[dataDic valueForKey:@"incident_post_time"] isKindOfClass:[NSNull class]] && ![[dataDic valueForKey:@"incident_post_time"] isEqualToString:@"<null>"])
        {
            [_dateBTN setTitle:[df1 stringFromDate:[df dateFromString:[dataDic valueForKey:@"incident_post_time"]]] forState:UIControlStateNormal];
        }
        
        [_dateBTN setEnabled:false];
        _titleLbl.font = [UIFont fontWithName:_titleLbl.font.fontName size:16];
        _titleLbl.text = [dataDic valueForKey:@"incident_title"];
        textfield.text = [NSString stringWithFormat:@"Reported By: %@", [[dataDic valueForKey:@"poster_name"] valueForKey:@"poster_name"]];
        [textfield setEnabled:false];
        textfield.adjustsFontSizeToFitWidth = true;
        _titleLbl.adjustsFontSizeToFitWidth = true;
        textView.text = @"Enter your comment";
        dataArray = [[dataDic valueForKey:@"incident_files"] mutableCopy];
        
//        if([dataDic valueForKey: @"location"] != nil && ![[dataDic valueForKey: @"location"] isKindOfClass:[NSNull class]] && ![[dataDic valueForKey: @"location"] isEqualToString:@""] )
//        {
//            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//            [dic setValue:@"text" forKey:@"type"];
//            [dic setValue:[dataDic valueForKey: @"location"] forKey:@"message"];
//            [dataArray insertObject:dic atIndex:0];
//        }
        
        [dataDic removeObjectForKey:@"incident_files"];
        [self.tableView reloadData];
        
        if([[[dataDic valueForKey:@"ir_close_comment_status"] uppercaseString] isEqualToString:@"N"])
        {
            iconViewConst.constant = 40;
        }
        else
        {
            iconViewConst.constant = 0;
        }
        
        _sendBTnCons.constant = 0;
        _showIconBtnConst.constant = 0;
        _headLbl.text = @"INCIDENT REPORT";
        [_menuBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _IRLbl.text = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"ir_id"]];
        [_sendChatBtn setImage:[UIImage imageNamed:@"send_msg"] forState:UIControlStateNormal];
        [self getCommentWebservice:true];
    }
    textView.textColor = [UIColor darkTextColor];
    iconConst.constant = 0;
}

-(void)callWebService
{
   
    [self getCommentWebservice:false];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/**
 *  Keyboard did show fuction
 *
 *  @param notification NSNotification
 */
-(void) keyboardWillShow:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if([_from isEqualToString:@"new"])
    {
        _bottomConst.constant = -keyBoardSize.height+40;
    }
    else
    {
        _bottomConst.constant = -keyBoardSize.height;
    }
    
    //    [self.tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    //    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0, 0.0, keyBoardSize.height, 0.0)];
    //Add tap gesture when keyboard will show
}


/**
 *  Keyboard did hide
 *
 *  @param notification NSNotification
 */

-(void) keyboardWillHide:(NSNotification *) notification
{
    _bottomConst.constant = 0;
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

-(void)dismissKeyboard {
    [self.view endEditing:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK:- tableview functions
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_from isEqualToString:@"view"] && [dataDic valueForKey:@"commentArray"] != nil && [[dataDic valueForKey:@"commentArray"] count] > 0)
    {
        return 2;
    }
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_from isEqualToString:@"view"] && [dataDic valueForKey:@"commentArray"] != nil && [[dataDic valueForKey:@"commentArray"] count] > 0 && section == 1)
    {
        return [[dataDic valueForKey:@"commentArray"] count]+1;
    }
    
//    if([[[dataDic valueForKey:@"ir_close_comment_status"] uppercaseString] isEqualToString:@"Y"] && [[dataDic valueForKey:@"close_comment_reason"] count] > 0)
//    {
//        return [dataArray count] + 1;
//    }
    return [dataArray count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
    if([[[dataDic valueForKey:@"ir_close_comment_status"] uppercaseString] isEqualToString:@"Y"] && [dataDic valueForKey:@"close_comment_reason"] != nil && ![[dataDic valueForKey:@"close_comment_reason"] isKindOfClass:[NSNull class]] && ![[dataDic valueForKey:@"close_comment_reason"] isEqualToString:@"<null>"] && [[dataDic valueForKey:@"close_comment_reason"] length] > 0)
    {
    }
    else
    {
        return 0;
    }
    }
    return UITableViewAutomaticDimension;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell setHidden:NO];

    if([dataArray count] > 0 && indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"  forIndexPath: indexPath];

            UILabel *charLbl = [cell viewWithTag:1];
            UILabel *nameLbl = [cell viewWithTag:2];
            UILabel *timeLbl = [cell viewWithTag:3];
            UILabel *messageLbl = [cell viewWithTag:4];
            charLbl.layer.cornerRadius = charLbl.frame.size.width/2;
            charLbl.text = [NSString stringWithFormat:@"%c", [[[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"first_name"] uppercaseString] characterAtIndex:0]];                nameLbl.text = [NSString stringWithFormat:@"Closing Comment"];

            [timeLbl setHidden:YES];
            
            
            
            if([[[dataDic valueForKey:@"ir_close_comment_status"] uppercaseString] isEqualToString:@"Y"] && [dataDic valueForKey:@"close_comment_reason"] != nil && ![[dataDic valueForKey:@"close_comment_reason"] isKindOfClass:[NSNull class]] && ![[dataDic valueForKey:@"close_comment_reason"] isEqualToString:@"<null>"] &&  [[dataDic valueForKey:@"close_comment_reason"] length] > 0)
            {
                messageLbl.text = [dataDic valueForKey:@"close_comment_reason"];

                [cell setHidden:NO];
            }
            else
            {
                [cell setHidden:YES];
            }
            
            return cell;
        }
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        
        if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"text"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderCell"  forIndexPath: indexPath];
            UIView *bgView = [cell viewWithTag:1];
            UILabel *textLabel = [cell viewWithTag:2];
            UIImageView *statusImageView = [cell viewWithTag:3];
            UILabel *timeLabel = [cell viewWithTag:4];
            [statusImageView setHidden:true];
            if([_from isEqualToString:@"new"])
            {
                [bgView addGestureRecognizer:longGesture];
                bgView.layer.cornerRadius = 10;
                bgView.clipsToBounds = true;
                bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
                
                textLabel.text = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"message"];
                [textLabel sizeToFit];
                statusImageView.backgroundColor = [UIColor clearColor];
            }
            else
            {
                NSString *rawString = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"message"];
                
                NSArray *messageArr = [appDelegate.constant getMessageAndIV:rawString];
                
                NSString *decryptedString = [[appDelegate cryptoLib] decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
                
                if(decryptedString != nil && ![decryptedString isEqualToString:@""])
                {
                    textLabel.text = [appDelegate.constant UTF8Message:decryptedString];
                }
                else
                {
                    textLabel.text = @"";
                }
            }
            
            if([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"] != nil)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
            }
            else
            {
                timeLabel.text = @"";
            }
        }
        else if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"audio"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderAudioCell"  forIndexPath: indexPath];
            UIView *bgView = [cell viewWithTag:1];
            UIButton *playBtn = [cell viewWithTag:2];
            UIProgressView *progressView = [cell viewWithTag:3];
            UILabel *counterLabel = [cell viewWithTag:4];
            UIButton *mediaButton = [cell viewWithTag:5];
            UIImageView *statusImageView = [cell viewWithTag:6];
            UILabel *timeLabel = [cell viewWithTag:7];
            UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
            
            [statusImageView setHidden:true];
            [ActivityIndicator setColor:[UIColor whiteColor]];
            bgView.layer.cornerRadius = 10;
            bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
            counterLabel.clipsToBounds = true;
            counterLabel.layer.cornerRadius = 10;
            [mediaButton setHidden: true];
            [playBtn setHidden: false];
            [playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
            [progressView setProgress:0.0];
            [ActivityIndicator setHidden:true];
            [playBtn addTarget:self action:@selector(audioMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            if([_from isEqualToString:@"new"])
            {
                [bgView addGestureRecognizer:longGesture];
                
                if([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] != nil && [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] integerValue] < 1 && [[dataArray objectAtIndex:indexPath.row - 1] objectForKey:@"generated_at"] == [playingDict objectForKey:@"generated_at"])
                {
                    [progressView setProgress:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] floatValue]];
                    [playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                }
                else
                {
                    [progressView setProgress:0.0];
                    [playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                }
            }
            else
            {
                //                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                //                NSString *documentPath = [paths objectAtIndex:0];
                //
                //                NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"] componentsSeparatedByString:@"/"]];
                //                NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
                //
                //                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                //                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] != nil && [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] integerValue] != 1)
                {
                    [playBtn setHidden:true];
                    [ActivityIndicator setHidden:false];
                    [ActivityIndicator startAnimating];
                }
                else if([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] != nil && [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] integerValue] < 1 && [[dataArray objectAtIndex:indexPath.row - 1] objectForKey:@"id"] == [playingDict objectForKey:@"id"])
                {
                    [progressView setProgress:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressivePlaying"] floatValue]];
                    [playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                }
                else
                {
                    [progressView setProgress:0.0];
                    [playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                }
            }
            
            int totalSec = [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"duration"] intValue];
            int minutes = totalSec/60;
            int sec = totalSec % 60;
            counterLabel.text = [NSString stringWithFormat:@"%d:%d",minutes,sec];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *tempDate = [dateFormatter dateFromString:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        else if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"image"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderMediaCell"  forIndexPath: indexPath];
            
            UIView *bgView = [cell viewWithTag:1];
            UIImageView *imageView = [cell viewWithTag:2];
            UIImageView *statusImageView = [cell viewWithTag:3];
            [statusImageView setHidden:true];
            UILabel *timeLabel = [cell viewWithTag:4];
            UIButton *mediaButton = [cell viewWithTag:5];
            UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
            
            
            bgView.layer.cornerRadius = 10;
            imageView.clipsToBounds = true;
            statusImageView.hidden = true;
            ActivityIndicator.hidden = true;
            [ActivityIndicator stopAnimating];
            mediaButton.enabled = true;
            bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
            [mediaButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
            if([_from isEqualToString:@"new"])
            {
                
                [bgView addGestureRecognizer:longGesture];
                if ([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video"])
                {
                    [imageView setImage:[UIImage imageWithData:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"thumb"]]];
                    [mediaButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                    [mediaButton setHidden:false];
                }
                else
                {
                    [imageView setImage:[UIImage imageWithData:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"]]];
                }
                [mediaButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
            }
            else
            {
                [mediaButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2f]];
                [mediaButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                [mediaButton setEnabled:true];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [mediaButton setTitle:@"" forState:UIControlStateNormal];
                //
                //[NSString stringWithFormat:@"%@uploads/ir_images/%@",imageBaseURL, fileName]
                
                if ([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video"])
                {
                    [imageView setImageWithURL:[NSURL URLWithString: [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"thumb_name"]] placeholderImage:[UIImage imageNamed:@"image_default"]];
                    
                }
                else
                {
                    [imageView setImageWithURL:[NSURL URLWithString: [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"]] placeholderImage:[UIImage imageNamed:@"image_default"]];
                    
                }
                
                [mediaButton setHidden:false];
                
                if ([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video"])
                {
                    if([fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
                        [mediaButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [mediaButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
                        [mediaButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    }
                }
                else if ([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"image"])
                {
                    if(![fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
                        [mediaButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [mediaButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
                        [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                    }
                }
                
                if([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] != nil && [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] integerValue] != 1)
                {
                    [mediaButton setHidden:true];
                    [ActivityIndicator setHidden:false];
                    [ActivityIndicator startAnimating];
                }
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            NSDate *tempDate = [dateFormatter dateFromString:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"]];
            [dateFormatter setDateFormat:@"hh:mm a"];
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        else if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"file"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderDocCell"  forIndexPath: indexPath];
            UIView *bgView = [cell viewWithTag:1];
            UIImageView *fileImageView = [cell viewWithTag:2];
            UILabel *textLabel = [cell viewWithTag:3];
            UILabel *sizeLabel = [cell viewWithTag:4];
            [sizeLabel setHidden:true];
            UIButton *downloadButton = [cell viewWithTag:5];
            
            UIImageView *statusImageView = [cell viewWithTag:6];
            [statusImageView setHidden:true];
            UIImageView *divider = [cell viewWithTag:10];
            [divider setHidden:true];
            UILabel *timeLabel = [cell viewWithTag:7];
            UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
            bgView.layer.cornerRadius = 10;
            ActivityIndicator.hidden = true;
            bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
            NSString *filename = @"";
            NSArray *fileType = [[NSArray alloc] init];
            [downloadButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
            if([_from isEqualToString:@"new"])
            {
                [bgView addGestureRecognizer:longGesture];
                filename = [[dataArray objectAtIndex: indexPath.row] objectForKey:@"file_name"];
                fileType = [filename componentsSeparatedByString:@"."];
                textLabel.text = filename;
                [bgView addGestureRecognizer:longGesture];
                [downloadButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
            }
            else
            {
                filename = [[dataArray objectAtIndex: indexPath.row] objectForKey:@"file"];
                fileType = [filename componentsSeparatedByString:@"/"];
                
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
                textLabel.text = [fileName componentsSeparatedByString:@"_mds_"][1];
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                sizeLabel.text = @"";
                // sizeLabel.text = [self transformedValue:[[[dataArray objectAtIndex:indexPath.row - 1] objectForKey:@"filesize"] longLongValue]];
                
                if ([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] != nil && [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"progressive"] integerValue] < 1)
                {
                    downloadButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                }
                else
                {
                    [downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    
                    downloadButton.hidden = false;
                    ActivityIndicator.hidden = true;
                    [ActivityIndicator stopAnimating];
                }
                
                
                if([fileManager fileExistsAtPath:filePath])
                {
                    [downloadButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
                }
                else
                {
                    [downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    [downloadButton setTitle:@"" forState:UIControlStateNormal];
                }
                filename = fileName;
            }
            
            //filename = [filename stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            
            if([fileType[[fileType count] -1] containsString:@"pdf"])
            {
                fileImageView.image = [UIImage imageNamed:@"pdf"];
            }
            else if([fileType[[fileType count] -1] containsString:@"msword"] || [fileType[[fileType count] -1] containsString:@"doc"])
            {
                fileImageView.image = [UIImage imageNamed:@"doc"];
            }
            else if([fileType[[fileType count] -1] containsString:@"csv"] || [fileType[[fileType count] -1] containsString:@"xlsx"] ||[fileType[[fileType count] -1] containsString:@"xls"])
            {
                fileImageView.image = [UIImage imageNamed:@"xcel"];
            }
            else
            {
                fileImageView.image = [UIImage imageNamed:@"defaultFile"];
            }
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *tempDate = [dateFormatter dateFromString:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"]];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        else if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"map"])
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"mapView"];
            UILabel *timeLabel = [cell viewWithTag:2];
            GMSMapView *map = [cell viewWithTag:1];
            [map clear];
            double lat = [[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"latitude"]] doubleValue];
            double lon = [[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"longitude"]] doubleValue];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lon);
             dispatch_async(dispatch_get_main_queue(), ^{
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.map = map;
            [map animateToLocation:position];
            [map animateToZoom:15.0];
            
            map.settings.scrollGestures = false;
            marker.icon = [UIImage imageNamed:@"location"];
                 });
            
//            TODO
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *tempDate = [dateFormatter dateFromString:[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"generated_at"]];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        
        cell.backgroundColor = [UIColor colorWithRed:250 green:250 blue:250 alpha:1.0];
        cell.contentView.backgroundColor = [UIColor colorWithRed:250 green:250 blue:250 alpha:1.0];
    }
    else if([[dataDic valueForKey:@"commentArray"] count] > 0 && indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"commentHeaderCell"];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
            UILabel *charLbl = [cell viewWithTag:1];
            UILabel *nameLbl = [cell viewWithTag:2];
            UILabel *timeLbl = [cell viewWithTag:3];
            UILabel *messageLbl = [cell viewWithTag:4];
            charLbl.layer.cornerRadius = charLbl.frame.size.width/2;
            
            [timeLbl setHidden:NO];

            [cell setHidden:NO];
            
            if([[NSString stringWithFormat:@"%@", [[[dataDic valueForKey:@"commentArray"] objectAtIndex:indexPath.row-1] valueForKey:@"comment_by"]] isEqualToString:[NSString stringWithFormat:@"%@", [[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"user_id"]]])
            {
                
                charLbl.text = [NSString stringWithFormat:@"%c", [[[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"first_name"] uppercaseString] characterAtIndex:0]];
                nameLbl.text = [NSString stringWithFormat:@"ME -"];
            }
            else
            {
                
                charLbl.text = [NSString stringWithFormat:@"%c", [[[[[dataDic valueForKey:@"commentArray"] objectAtIndex:indexPath.row-1] valueForKey:@"commenter_name"] uppercaseString] characterAtIndex:0]];
                nameLbl.text = [NSString stringWithFormat:@"%@ -",[[[dataDic valueForKey:@"commentArray"] objectAtIndex:indexPath.row-1] valueForKey:@"commenter_name"]];
            }
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            df1.dateFormat = @"hh:mm a";
            timeLbl.text = [df1 stringFromDate:[df dateFromString:[[[dataDic valueForKey:@"commentArray"] objectAtIndex:indexPath.row-1] valueForKey:@"comment_date"]]];
            
            NSString *rawString = [[[dataDic valueForKey:@"commentArray"] objectAtIndex:indexPath.row-1] valueForKey:@"comment"];
            
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
            nameLbl.adjustsFontSizeToFitWidth = true;
            timeLbl.adjustsFontSizeToFitWidth = true;
        }
        
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}


- (IBAction)mapImageTapped :(UIButton*)sender
{
//    TODO
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    double lat = [[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"latitude"]] doubleValue];
    double lon = [[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"longitude"]] doubleValue];
    
    
    NSLog(@"Image Tapped");
//    NSString* directionsURL = @"http://maps.apple.com/?address=1.301279,103.854541";
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?address=%f,%f",lat,lon];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
        } else {
            // Fallback on earlier versions
        }
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL]];
    }
    
}

//MARK:- TextView
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    tableView.scrollEnabled = true;
    [[self tableView] addGestureRecognizer:tap];
    textView.text = @"";
    textView.returnKeyType = UIReturnKeyDone;
    if (textView.textColor == [UIColor darkTextColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [[self view] removeGestureRecognizer:tap];
    if ([[textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        
        if([_from isEqualToString:@"new"])
        {
            textView.text = @"Say something...";
        }
        else
        {
            textView.text = @"Enter your comment";
        }
        
        textView.textColor = [UIColor darkTextColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//MARK:- textfield functions
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView addGestureRecognizer:tap];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView removeGestureRecognizer:tap];
    if(textField.tag == 111)
    {
        [dataDic setValue:textField.text forKey:@"title"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
    
    return true;
}


//MARK:- buttons

- (IBAction)addAttachButtonClicked:(UIButton *)sender
{
    tableView.scrollEnabled = true;
    [tableView reloadData];
    
    
    if (iconConst.constant > 0)
    {
        iconConst.constant = 0;
        iconViewConst.constant = 88;
    }
    else
    {
        iconViewConst.constant = 128;
        iconConst.constant = 40;
    }
}


- (IBAction)locationIconTapped:(UIButton *)sender
{
//    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Enter Address"
//                                                                              message: @""
//                                                                       preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"Enter Location";
//        textField.textColor = [UIColor blackColor];
//
//        if([dataDic valueForKey:@"location"] != nil)
//        {
//            textField.text = [dataDic valueForKey:@"location"];
//        }
//        else
//        {
//            textField.text = @"";
//        }
//
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSArray * textfields = alertController.textFields;
//        UITextField * password = textfields[0];
//
//        if(![[[password text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
//        {
//            [dataDic setValue:password.text forKey:@"location"];
//        }
//
//        [self.tableView reloadData];
//    }]];
//
//    [self presentViewController:alertController animated:YES completion:nil];
    
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
    GMSPlacePickerViewController *placePicker =
    [[GMSPlacePickerViewController alloc] initWithConfig:config];
    placePicker.delegate = self;
    
    [self presentViewController:placePicker animated:YES completion:nil];
}

// To receive the results from the place picker 'self' will need to conform to
// GMSPlacePickerViewControllerDelegate and implement this code.
- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
    // Dismiss the place picker, as it cannot dismiss itself.
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dic setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"generated_at"];
    [dic setValue:@"map" forKey:@"type"];
    [dic setValue:[NSString stringWithFormat:@"%f", place.coordinate.latitude] forKey:@"latitude"];
    [dic setValue:[NSString stringWithFormat:@"%f", place.coordinate.longitude] forKey:@"longitude"];
    [dataArray addObject:dic];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[dataArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    
    
//    NSLog(@"Place name %@", place.name);
//    NSLog(@"Place address %@", place.formattedAddress);
//    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
    // Dismiss the place picker, as it cannot dismiss itself.
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    //NSLog(@"No place selected");
}


- (IBAction)audioIconTapped:(UIButton *)sender
{
    //Code here
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *record = [UIAlertAction actionWithTitle:@"Record" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main2" bundle: nil];
        AudioViewController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
        infoVC.delegate = self;
        [[self navigationController] pushViewController:infoVC animated:YES];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:record];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)imageIconTapped:(UIButton *)sender
{
    //Code here
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *gallery = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
        clickImg.delegate = self;
        clickImg.allowsEditing = YES;
        clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController: clickImg animated:YES completion:nil];
    }];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
        clickImg.delegate = self;
        clickImg.allowsEditing = YES;
        clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
        clickImg.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController: clickImg animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:gallery];
    [alert addAction:camera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)videoIconTapped:(UIButton *)sender
{
    //Code here
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *gallery = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
        clickImg.delegate = self;
        clickImg.allowsEditing = YES;
        clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        clickImg.mediaTypes = @[(NSString *)kUTTypeMovie];
        [self presentViewController: clickImg animated:YES completion:nil];
    }];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
        clickImg.delegate = self;
        clickImg.allowsEditing = YES;
        clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
        clickImg.mediaTypes = @[(NSString *)kUTTypeMovie];
        [self presentViewController: clickImg animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:gallery];
    [alert addAction:camera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)documentIconTapped:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cloud = [UIAlertAction actionWithTitle:@"iCloud" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                            {
                                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.composite-content"]//@"public.content"
                                                                                                                                        inMode:UIDocumentPickerModeImport];
                                documentPicker.delegate = self;
                                
                                documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
                                [self presentViewController:documentPicker animated:YES completion:nil];
                            }];
    
    UIAlertAction *dropbox = [UIAlertAction actionWithTitle:@"Dropbox" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  
                                  [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypePreview
                                                                  fromViewController:self completion:^(NSArray *results)
                                   {
                                       if ([results count]) {
                                           
                                           DBChooserResult *result = results[0];
                                           
                                           // Process results from Chooser
                                           
                                           NSData * data = [[NSData alloc] initWithContentsOfURL: result.link];
                                           if ( data != nil )
                                           {
                                               
                                               if ([data length] > 5000000)
                                               {
                                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"File cannot be greater than 5Mb." preferredStyle:UIAlertControllerStyleAlert];
                                                   UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                                                   [alert addAction:ok];
                                                   return;
                                               }
                                               
                                           }
                                           else
                                           {
                                               //            NSLog(@"INVALID URL!!!");
                                           }
                                           
                                           
                                       } else {
                                           // User canceled the action
                                       }
                                   }];
                              }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:cloud];
    [alert addAction:dropbox];
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction) sidemenu: (UIButton*) sender {
    if([_from isEqualToString:@"view"])
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
    }
}


- (IBAction)sendIR:(UIButton *)sender
{
    [self.view endEditing:true];
    if([dataDic valueForKey:@"title"] == nil || [[dataDic valueForKey:@"title"] isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:emptyTitle];
        return;
    }
    else if ([dataArray count] == 0)
    {
        [SVProgressHUD showErrorWithStatus:emptydata];
        return;
    }
    
    
    NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] init];
    
    //[NSString stringWithFormat:@"generated_at[%d]",i]
    
    for(int i = 0; i< [dataArray count];i++)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        //[dateFormatter dateFromString:[[dataArray objectAtIndex:i] valueForKey:@"generated_at"]]
        [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"generated_at"] forKey: @"generated_at"];
        
        if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"text"])
        {
            [dic setValue:[appDelegate.constant generateMessage:[[dataArray objectAtIndex:i] valueForKey:@"message"]] forKey:@"message"];
            [dic setValue:@"text" forKey:@"type"];
        }
        else if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"audio"])
        {
            [dic setValue:@"audio" forKey:@"type"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"duration"] forKey:@"duration"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"file"] forKey:@"file"];
        }
        else if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"image"])
        {
            [dic setValue:@"image" forKey:@"type"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"file"] forKey:@"file"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"thumb"] forKey:@"thumb"];
        }
        else if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"file"])
        {
            [dic setValue:@"file" forKey:@"type"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"file_name"] forKey:@"file_name"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"file"] forKey:@"file"];
        }
        else if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex: i] valueForKey:@"type"] containsString:@"video_"])
        {
            [dic setValue:@"video" forKey:@"type"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"file"] forKey:@"file"];
            [dic setValue:[[dataArray objectAtIndex:i] valueForKey:@"thumb"] forKey:@"thumb"];
        }
        else if([[[dataArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"map"])
        {
            [dic setValue:@"map" forKey:@"type"];
            [dic setValue:[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:i] valueForKey:@"latitude"]] forKey:@"latitude"];
            [dic setValue:[NSString stringWithFormat:@"%@", [[dataArray objectAtIndex:i] valueForKey:@"longitude"]] forKey:@"longitude"];
        }
        
        [mutDic setValue:dic forKey:[NSString stringWithFormat:@"incident_files[%d]",i]];
    }
    
    [mutDic setValue:[dataDic valueForKey:@"title"] forKey:@"title"];
    [mutDic setValue:[dataDic valueForKey:@"date"] forKey:@"incident_post_time"];
    [mutDic setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"]valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"user_id"];
    
    [self webService:[mutDic mutableCopy]];
}

- (IBAction)sendChatClicked:(UIButton *)sender
{
    [self.view endEditing:true];
    if ([[textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || textView.textColor == [UIColor darkTextColor])
        // || [[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]]
    {
        // [self.view endEditing:true];
        
        //  NSLog(@"%@----",textView.text);
    }
    else
    {
        if([_from isEqualToString:@"new"])
        {
            optionView.hidden = true;
            tableView.scrollEnabled = true;
            [self addObjects:nil typeofData:@"text" thumbImage:nil timeofSelection:textView.text];
        }
        else
        {
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:[df stringFromDate:[NSDate date]] forKey:@"comment_date"];
            [params setValue:[dataDic valueForKey:@"id"] forKey:@"incident_id"];
            [params setValue:[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"comment_by"];
            [params setValue:[appDelegate.constant generateMessage:textView.text] forKey:@"comment"];
            [self commentWebservice:params];
        }
    }
}

//MARK:- Long Press Gesture
-(void) longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:true];
    self.tableView.scrollEnabled = false;
    
    if(optionView != nil && optionView.hidden == false)
    {
        return;
    }
    
    //HIDING Icon view so that no new msg can be added
    iconConst.constant = 0;
    iconViewConst.constant = 88;
    
    
    CGPoint hitPoint = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *bgView = [cell viewWithTag:1];
    CGRect bgViewframeToView = [bgView.superview convertRect:bgView.frame toView:nil];
    CGSize basicOptionSize = CGSizeMake(170, 40);
    UIImage *menuImage = [[UIImage alloc] init];
    selectedIndexPath = indexPath;
    
    bgView.backgroundColor = [UIColor colorWithRed:(192/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
    
    if (cell != nil)
    {
        //CGRect cellRect = [cell convertRect:cell.frame toView:nil];
        
        //MAKING OPTION VIEW
        if(bgViewframeToView.size.width >= (self.view.frame.size.width/2) - 50)
        {
            if(bgViewframeToView.origin.y < 64)
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(bgViewframeToView.origin.x +(bgViewframeToView.size.width/2 - basicOptionSize.width/2),bgViewframeToView.origin.y + bgViewframeToView.size.height + 10, basicOptionSize.width, basicOptionSize.height)];
                
                menuImage = [UIImage imageNamed: @"upMiddle_optionMenu"];
                ///up Middle image view
            }
            else
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(bgViewframeToView.origin.x +(bgViewframeToView.size.width/2 - basicOptionSize.width/2) ,bgViewframeToView.origin.y - 50, basicOptionSize.width, basicOptionSize.height)];
                menuImage = [UIImage imageNamed: @"optionMenu"];
                ///down Middle image view
            }
        }
        else
        {
            
            if(bgViewframeToView.origin.y < 64 && bgViewframeToView.origin.x == 56)
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(bgViewframeToView.origin.x + bgViewframeToView.size.width - 15,bgViewframeToView.origin.y + bgViewframeToView.size.height + 10, basicOptionSize.width, basicOptionSize.height)];
                
                menuImage = [UIImage imageNamed: @"upLeft_optionMenu"];
                ///up Left image view
            }
            else if (bgViewframeToView.origin.y < 64 && bgViewframeToView.origin.x > 56)
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - bgViewframeToView.size.width - basicOptionSize.width - 15,bgViewframeToView.origin.y + bgViewframeToView.size.height + 10, basicOptionSize.width, basicOptionSize.height)];
                
                menuImage = [UIImage imageNamed: @"upRight_optionMenu"];
                ///up Right image view
            }
            else if (bgViewframeToView.origin.y > 64 && bgViewframeToView.origin.x == 56)
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(bgViewframeToView.origin.x + bgViewframeToView.size.width - 15,bgViewframeToView.origin.y - 50, basicOptionSize.width, basicOptionSize.height)];
                
                menuImage = [UIImage imageNamed: @"downLeft_optionMenu"];
                ///down Left image view
            }
            else
            {
                optionView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - bgViewframeToView.size.width - basicOptionSize.width - 15,bgViewframeToView.origin.y - 50, basicOptionSize.width, basicOptionSize.height)];
                
                menuImage = [UIImage imageNamed: @"downRight_optionMenu"];
                //down Right image view
            }
        }
        
        
        optionView.hidden = false;
        optionView.clipsToBounds = true;
        UIImageView *optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 0, optionView.frame.size.width, optionView.frame.size.height)];
        
        optionImageView.image = menuImage;
        
        [optionView addSubview:optionImageView];
        
        CGFloat basicButtonY = -5;
        
        if(bgViewframeToView.origin.y < 64)
        {
            basicButtonY = 5;
        }
        
        
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , basicButtonY, basicOptionSize.width, basicOptionSize.height)];
        
        //UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(optionView.frame.size.width/2 ,basicButtonY + 16, 1, 11)];
        
        //imageView1.backgroundColor = [UIColor whiteColor];
        
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
        
        [deleteButton addTarget:self action:@selector(deleteSome) forControlEvents:UIControlEventTouchUpInside];
        
        [optionView addSubview:deleteButton];
        //[optionView addSubview:imageView1];
        
        [self.tableView addGestureRecognizer:tap];
        [self.view addSubview:optionView];
        [self.view bringSubviewToFront:optionView];
        optionView.hidden = false;
    }
}


-(void)deleteSome
{
    if([dataArray count] >= selectedIndexPath.row)
    {
        optionView.hidden = true;
        [dataArray removeObjectAtIndex:selectedIndexPath.row];
        [self.tableView reloadData];
        selectedIndexPath = [[NSIndexPath alloc] init];
    }
}


//MARK:- protocols
-(void) getAudio: (NSData *)audio withDuration:(NSString *)duration;
{
    [self addObjects:audio typeofData:@"audio" thumbImage:nil timeofSelection:duration];
}


-(void)audioMessageTapped:(UIButton *)sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    playingDict = [[dataArray objectAtIndex:indexPath.row - 1] mutableCopy];
    
    if([_from isEqualToString:@"new"])
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        NSError *error;
        
        audioPlayer = [[AVAudioPlayer alloc] initWithData:[playingDict objectForKey:@"file"] error:&error];
        [audioPlayer prepareToPlay];
        [audioPlayer play];
        
        NSMutableDictionary *dic = [[dataArray objectAtIndex:indexPath.row - 1] mutableCopy];
        [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressivePlaying"];
        [dataArray replaceObjectAtIndex:indexPath.row withObject:dic];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateupdateAudioProgressView:) userInfo:nil repeats:YES];
        
        [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        [self.tableView reloadData];
    }
    else
    {
        if ([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] != nil && ![[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isKindOfClass:[NSNull class]] && ![[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@""])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
            NSString *documentPath = [paths objectAtIndex:0];
            
            NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"] componentsSeparatedByString:@"/"]];
            NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:filePath])
            {
                NSMutableDictionary *dic = [[dataArray objectAtIndex:indexPath.row - 1] mutableCopy];
                [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
                [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
                [dataArray replaceObjectAtIndex:indexPath.row withObject:dic];
                [tableView reloadData];
                [appDelegate.downlaodArray addObject:[dataArray objectAtIndex:indexPath.row - 1]];
                [appDelegate.constant downloadWithNsurlconnection];
            }
            else
            {
                if([dataArray containsObject:playingDict]  && audioPlayer.isPlaying)
                {
                    [audioPlayer stop];
                    playingDict = [[NSMutableDictionary alloc] init];
                    [tableView reloadData];
                }
                else
                {
                    AVAudioSession *session = [AVAudioSession sharedInstance];
                    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
                    NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath relativeToURL:nil];
                    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                    [audioPlayer prepareToPlay];
                    [audioPlayer play];
                    
                    NSMutableDictionary *dic = [[dataArray objectAtIndex:indexPath.row - 1] mutableCopy];
                    [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressivePlaying"];
                    [dataArray replaceObjectAtIndex:indexPath.row withObject:dic];
                    
                    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateupdateAudioProgressView:) userInfo:nil repeats:YES];
                    
                    [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

-(void)updateupdateAudioProgressView:(NSTimer *)sender
{
    if([_from isEqualToString:@"new"])
    {
        for(int i = 0;i<[dataArray count]; i++)
        {
            if([[dataArray objectAtIndex:i] objectForKey:@"generated_at"] == [playingDict objectForKey:@"generated_at"])
            {
                NSMutableDictionary *dic = [[dataArray objectAtIndex:i] mutableCopy];
                if(audioPlayer.isPlaying)
                {
                    [dic setObject:[NSNumber numberWithFloat:audioPlayer.currentTime/audioPlayer.duration] forKey:@"progressivePlaying"];
                }
                else
                {
                    [dic setObject:[NSNumber numberWithFloat:1.0] forKey:@"progressivePlaying"];
                    [sender invalidate];
                }
                [dataArray replaceObjectAtIndex:i withObject:dic];
                break;
            }
        }
    }
    else
    {
        for(int i = 0;i<[dataArray count]; i++)
        {
            if([[dataArray objectAtIndex:i] objectForKey:@"id"] == [playingDict objectForKey:@"id"])
            {
                NSMutableDictionary *dic = [[dataArray objectAtIndex:i] mutableCopy];
                
                if(audioPlayer.isPlaying)
                {
                    [dic setObject:[NSNumber numberWithFloat:audioPlayer.currentTime/audioPlayer.duration] forKey:@"progressivePlaying"];
                }
                else
                {
                    [dic setObject:[NSNumber numberWithFloat:1.0] forKey:@"progressivePlaying"];
                    [sender invalidate];
                }
                [dataArray replaceObjectAtIndex:i withObject:dic];
                break;
            }
        }
    }
    
    
    
    [tableView reloadData];
}


-(void)mediaMessageTapped:(UIButton *)sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    if ([[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] != nil && ![[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isKindOfClass:[NSNull class]] && ![[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@""])
    {
        if([_from isEqualToString:@"new"])
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
            MediaViewController *infoVC = [story instantiateViewControllerWithIdentifier:@"MediaViewController"];
            infoVC.filePath = nil;
            
            if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"image"])
            {
                infoVC.from = @"image";
                infoVC.data = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"];
            }
            else if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"file"])
            {
                NSString *fileName = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file_name"];
                infoVC.from = @"document";
                infoVC.data = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"];
                infoVC.filePath = fileName;
            }
            else  if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"] || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video"])
            {
                infoVC.from = @"video";
                infoVC.data = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"];
                infoVC.filePath = [[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] componentsSeparatedByString:@"video_"] objectAtIndex:1];
            }
            [[self navigationController] pushViewController:infoVC animated:YES];
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
            NSString *documentPath = [paths objectAtIndex:0];
            
            NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"file"] componentsSeparatedByString:@"/"]];
            NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:filePath])
            {
                NSMutableDictionary *dic = [[dataArray objectAtIndex:indexPath.row - 1] mutableCopy];
                [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
                [dic setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
                [dataArray replaceObjectAtIndex:indexPath.row withObject:dic];
                [tableView reloadData];
                [appDelegate.downlaodArray addObject:[dataArray objectAtIndex:indexPath.row - 1]];
                [appDelegate.constant downloadWithNsurlconnection];
            }
            else
            {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main2" bundle:nil];
                MediaViewController *infoVC = [story instantiateViewControllerWithIdentifier:@"MediaViewController"];
                infoVC.filePath = filePath;
                infoVC.data = nil;
                
                if([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"image"])
                {
                    infoVC.from = @"image";
                }
                else if(([[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] isEqualToString:@"video"]) || [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"type"] containsString:@"video_"])
                {
                    infoVC.from = @"video";
                }
                else
                {
                    infoVC.from = @"document";
                }
                [[self navigationController] pushViewController:infoVC animated:YES];
            }
            NSLog(@"Already Downloaded");
        }
        
    }
}

//MARK:- downlaod progress
-(void)downloadProgress:(NSNotification *)info
{
    NSDictionary *data = [[NSDictionary alloc] initWithDictionary:[info object]];
    if ([data valueForKey:@"type"] != nil && ![[data valueForKey:@"type"] isKindOfClass:[NSNull class]] && ![[data valueForKey:@"type"] isEqualToString:@""])
    {
        for(int i = 0;i< [dataArray count]; i++)
        {
            if([[dataArray objectAtIndex:i] valueForKey:@"id"] == [data valueForKey:@"id"])
            {
                NSMutableDictionary *mut = [[dataArray objectAtIndex: i] mutableCopy];
                [mut setValue:[data objectForKey:@"receivedData"] forKey:@"receivedData"];
                [mut setValue:[data objectForKey:@"expectedBytes"] forKey:@"expectedBytes"];
                [mut setValue:[data objectForKey:@"progressive"] forKey:@"progressive"];
                [dataArray replaceObjectAtIndex:i withObject:mut];
            }
        }
        
        [tableView reloadData];
    }
}

#pragma mark- UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        //NSString *str = [info valueForKey:UIImagePickerControllerImageURL];
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        
        //NSLog(@"File size: %@ kb", fileSize);
        if ([imageData length] > 5000000)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self addObjects:imageData typeofData:@"image" thumbImage:UIImageJPEGRepresentation(image, 0.2) timeofSelection:nil];
    }
    else
    {
        
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSString stringWithFormat:@"%@",videoURL] stringByReplacingOccurrencesOfString:@"file://" withString:@""] error:nil];
        
        if(fileAttributes != nil)
        {
            NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
            //NSLog(@"File size: %@ kb", fileSize);
            if ([fileSize intValue] > 5000000)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        //        [dic setValue:@"video" forKey:@"type"];
        //        [dic setValue:[NSData dataWithContentsOfURL:videoURL] forKey:@"file"];
        //        [dic setValue:UIImageJPEGRepresentation(thumbnail, 0.5) forKey:@"thumbnail"];
        //        [dic setValue:[NSString stringWithFormat:@"video%@.mp4",[dateFormatter stringFromDate:[NSDate date]]] forKey:@"file_name"];
        //        [dic setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"generated_at"];
        
        [self addObjects:[NSData dataWithContentsOfURL:videoURL] typeofData:[NSString stringWithFormat:@"video_%@",videoURL] thumbImage:UIImageJPEGRepresentation(thumbnail, 0.5) timeofSelection:[NSString stringWithFormat:@"video%@.mp4",[dateFormatter stringFromDate:[NSDate date]]]];
        
        //        [dataArray addObject:dic];
        [self.tableView reloadData];
        //video
    }
    
}

#pragma mark - iCloud files
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport)
    {
        NSData * data = [[NSData alloc] initWithContentsOfURL: url];
        if ( data != nil )
        {
            if ([data length] > 5000000)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            // NSString *type = [[NSString stringWithFormat:@"%@",[url lastPathComponent]] componentsSeparatedByString:@"."][1];
            
            [self addObjects:data typeofData:@"file" thumbImage:nil timeofSelection:[url lastPathComponent]];
        }
        else
        {
            //  NSLog(@"INVALID URL!!!");
        }
    }
}

-(void)addObjects:(NSData *)data typeofData:(NSString *)type thumbImage:(NSData *)thumb timeofSelection:(NSString *)duration
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dic setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"generated_at"];
    [dic setValue:type forKey:@"type"];
    
    if([type isEqualToString:@"text"])
    {
        [dic setValue:duration forKey:@"message"];
        [self.view  endEditing:true];
        textView.text = @"Say something...";
        [textView resignFirstResponder];
        textView.textColor = [UIColor darkTextColor];
    }
    else if([type isEqualToString:@"audio"])
    {
        [dic setValue:data forKey:@"file"];
        [dic setValue:duration forKey:@"duration"];
    }
    else if([type isEqualToString:@"image"])
    {
        [dic setValue:data forKey:@"file"];
        [dic setValue:thumb forKeyPath:@"thumb"];
    }
    else if([type isEqualToString:@"file"])
    {
        [dic setValue:data forKey:@"file"];
        [dic setValue:duration forKey:@"file_name"];
    }
    
    else if([type isEqualToString:@"video"] || [type containsString:@"video_"])
    {
        [dic setValue:data forKey:@"file"];
        [dic setValue:thumb forKeyPath:@"thumb"];
        [dic setValue:duration forKey:@"duration"];
    }
    
    
    [dataArray addObject:dic];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[dataArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
}

-(void)getCommentWebservice:(Boolean)show
{
    
    if (![appDelegate hasConnectivity]) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    if(show)
    {
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"Please Wait"];
    }
    
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    
    NSString *urlget = [NSString stringWithFormat:@"%@api/auth/show-comment?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[dataDic valueForKey:@"id"] forKey:@"incident_id"];
    
    
    [webConnector commentIncident:params url:urlget completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [dataDic setValue:[[responseObject valueForKey:@"data"] mutableCopy] forKey:@"commentArray"];
            [self.tableView reloadData];
            
            NSIndexPath *index;
            if([[dataDic valueForKey:@"commentArray"] count] == 0)
            {
                index = [NSIndexPath indexPathForRow:[dataArray count]-1 inSection:0];
            }else
            {
                index = [NSIndexPath indexPathForItem:[[dataDic valueForKey:@"commentArray"] count] inSection:1];
                
            }
            if ([[dataDic valueForKey:@"commentArray"] count] > 0 && [dataDic valueForKey:@"commentArray"] != nil)
            {
            [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:false];
            }
            
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
            [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
            [self commentWebservice:params];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [SVProgressHUD dismiss];
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

-(void)commentWebservice:(NSMutableDictionary *)params
{
    [SVProgressHUD dismiss];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please Wait"];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    
    NSString *urlget = [NSString stringWithFormat:@"%@api/auth/comment-incident?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    [webConnector commentIncident:params url:urlget completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            //            NSMutableArray *arr = [[NSMutableArray alloc] init];
            //            if([dataDic valueForKey:@"commentArray"] != nil)
            //            {
            //                arr = [[dataDic valueForKey:@"commentArray"] mutableCopy];
            //            }
            //
            //            [arr addObject:params];
            //            [dataDic setValue:arr forKey:@"commentArray"];
            textView.text = @"Enter your comment";
            textView.textColor = [UIColor darkTextColor];
            [self getCommentWebservice:true];
            
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
            [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
            [self commentWebservice:params];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [SVProgressHUD dismiss];
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

-(void)webService:(NSMutableDictionary *)params
{
    [SVProgressHUD dismiss];
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please Wait"];
    
    WebConnector *webConnector = [[WebConnector alloc] init];
    
    NSString *urlget = [NSString stringWithFormat:@"%@api/auth/store-incident?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    
    [webConnector createIR:params url:urlget completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
        {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
            dataArray = [[NSMutableArray alloc] init];
            dataDic = [[NSMutableDictionary alloc] init];
            
            [self.tableView reloadData];
            textfield.text = @"";
            textView.text = @"Say something...";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [self.tabBarController setSelectedIndex:0];
            });
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
        {
            NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
            [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
            [self webService:params];
        }
        else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
        {
            [SVProgressHUD dismiss];
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

@end
