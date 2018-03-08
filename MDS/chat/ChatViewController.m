//
//  ChatViewController.m
//  mds
//
//  Created by SS-181 on 7/3/17.
//
//

#import "ChatViewController.h"
#import "MediaViewController.h"
#import "SocketIOManger.h"
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "WebConnector.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "GroupProfileViewController.h"
#import <DBChooser/DBChooser.h>
#import "AGEmojiKeyBoardView.h"
#import "favouriteViewController.h"
#import "ProfileViewController.h"


@interface ChatViewController ()
{
    UITapGestureRecognizer *tapGesture;
    NSMutableArray *chatArray;
    NSMutableArray *dateArray;
    WebConnector *webConnector;
    UIRefreshControl *pullToRefresh;
    NSString *serverTimeZone;
    NSArray *tempKeyArr;
    UIView *optionView;
    NSIndexPath *selectedIndexPath;
    NSInteger offset;
    NSString *playingMessageID;
    NSTimer *DeleteMessageTimer;
    NSString *deleteAfterSecondValue;
    NSTimer *typingTimer;
}
@end

@implementation ChatViewController

@synthesize tableView,emojiButton,iconConst,sendViewConst,textView,bottomConst,prevDataDic,titleButton,optionButton,userStatusLabel,topOptionMenu,audioPlayer,deleteAfterMainView,exportButton,clearButton,deleteChatButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    optionView.hidden = true;
    topOptionMenu.hidden = true;
    
    [exportButton setTitle:@"Export" forState:UIControlStateNormal];
    [clearButton setTitle:@"Clear Chat" forState:UIControlStateNormal];
    [deleteChatButton setTitle:@"Delete Chat" forState:UIControlStateNormal];
    
    selectedIndexPath = [[NSIndexPath alloc] init];
    
    chatArray = [[NSMutableArray alloc] init];
    dateArray = [[NSMutableArray alloc] init];
    
    offset = 0;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    
    //iconView.clipsToBounds = true;
    
    
    
    textView.delegate = self;
    textView.text = @"Say something...";
    textView.textColor = [UIColor darkTextColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(newMsgRecieved:) name: @"newMsg" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(msgStatusChanged:) name: @"updateMsgStatus" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(downloadUpdateStatus:) name: @"downloadProggressUpdate" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onlineStatusChanged) name: @"online_users_list" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(userTyping:) name: @"typing" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateGroupProfile:) name: @"update_group_profile" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateGroupinfo) name: @"updateGroup" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deletedGroup:) name: @"deleted" object: nil];
    
    if([prevDataDic valueForKey:@"group_id"] != nil && ![[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] && ![[prevDataDic valueForKey:@"group_id"] isEqualToString:@""])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateGroupinfo) name: @"updateGroup" object: nil];
    }
    
    
    tempKeyArr = [[NSArray alloc] initWithObjects:@"id",@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    // titleLabel.text = @"CHAT";
    if([prevDataDic valueForKey:@"group_id"] != nil && ![[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] && ![[prevDataDic valueForKey:@"group_id"] isEqualToString:@""])
    {
        for (NSLayoutConstraint *constraint in userStatusLabel.constraints) {
            if ([constraint.identifier isEqualToString:@"height"])
            {
                constraint.constant = 8;
                break;
            }
        }
        
        [titleButton setTitle:[[[self prevDataDic] objectForKey: @"group_name"] uppercaseString] forState:UIControlStateNormal];
        userStatusLabel.text = @"";
    }
    else
    {
        for (NSLayoutConstraint *constraint in userStatusLabel.constraints) {
            if ([constraint.identifier isEqualToString:@"height"])
            {
                constraint.constant = 13;
                break;
            }
        }
        
        
        if([[self prevDataDic] objectForKey: @"first_name"] != nil && ![[[self prevDataDic] objectForKey: @"first_name"] isKindOfClass:[NSNull class]] && ([[self prevDataDic] objectForKey: @"last_name"] != nil && ![[[self prevDataDic] objectForKey: @"last_name"] isKindOfClass:[NSNull class]]))
        {
            
            [titleButton setTitle:[NSString stringWithFormat:@"%@ %@", [[[self prevDataDic] objectForKey: @"first_name"] uppercaseString], [[[self prevDataDic] objectForKey: @"last_name"] uppercaseString]] forState:UIControlStateNormal];
        }
        else if ([[self prevDataDic] objectForKey: @"email"] != nil && ![[[self prevDataDic] objectForKey: @"email"] isKindOfClass:[NSNull class]])
        {
            [titleButton setTitle:[[[self prevDataDic] objectForKey: @"email"] uppercaseString] forState:UIControlStateNormal];
        }
        
        [prevDataDic setValue:@"" forKey:@"group_id"];
        //[prevDataDic setValue:@"" forKey:@"group_id"];
        
        [self onlineStatusChanged];
    }
    
    //settings contraints
    iconConst.constant = 0;
    if([prevDataDic valueForKey:@"group_type"] != nil && ![[prevDataDic valueForKey:@"group_type"] isKindOfClass:[NSNull class]] && ![[prevDataDic valueForKey:@"group_type"] isEqualToString:@""] && [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
    {
        sendViewConst.constant = 0;
        optionButton.hidden = true;
        titleButton.enabled = false;
    }
    
    
    tempArr = [appDelegate.generalFunction getChat:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]] orWithGroup:[[self prevDataDic] objectForKey: @"group_id"] withOffset: offset];
    
    offset = [tempArr count];
    
    for(int i=0;i<[tempArr count];i++)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];;
        
        NSDate *deleteDateWithSec = [[NSDate alloc] init];
        
        deleteDateWithSec = [dateFormatter dateFromString:[[tempArr objectAtIndex:i] valueForKey:@"read_at"]];
        
        if(deleteDateWithSec == nil)
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            deleteDateWithSec = [dateFormatter dateFromString:[[tempArr objectAtIndex:i] valueForKey:@"read_at"]];
        }
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        ////
        
        NSDate *tempDateWithSec = [dateFormatter dateFromString:[[tempArr objectAtIndex:i] valueForKey:@"created_at"]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateString = [dateFormatter stringFromDate:tempDateWithSec];
        
        NSDate *tempDate = [dateFormatter dateFromString:dateString];
        
        if(![[[tempArr objectAtIndex:i] objectForKey:@"delete_after"] isEqualToString:@""])
        {
            NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:deleteDateWithSec];
            // NSLog(@"Seconds --------> %f", intervalString);
            
            if (secs > [[[tempArr objectAtIndex:i] objectForKey:@"delete_after"] floatValue])
            {
                [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"message_id = '%@'",[[tempArr objectAtIndex:i] objectForKey:@"message_id"]]];
                continue;
            }
        }
        
        NSMutableArray *downloadArr = [[NSMutableArray alloc] initWithArray:[appDelegate downlaodArray]];
        
        
        for(int counter = 0; counter < [downloadArr count]; counter++)
        {
            if([[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:i] valueForKey:@"message_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[downloadArr objectAtIndex:counter] objectForKey:@"message_id"]]])
            {
                [[tempArr objectAtIndex:i] setValue:[[downloadArr objectAtIndex:counter ] objectForKey:@"receivedData"] forKey:@"receivedData"];
                [[tempArr objectAtIndex:i] setValue:[[downloadArr objectAtIndex:counter ] objectForKey:@"expectedBytes"] forKey:@"expectedBytes"];
                [[tempArr objectAtIndex:i] setValue:[[downloadArr objectAtIndex:counter ] objectForKey:@"progressive"] forKey:@"progressive"];
                
            }
        }
        
        if(![dateArray containsObject:tempDate])
        {
            [dateArray insertObject:tempDate atIndex:0];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:tempDate forKey:@"date"];
            [dic setObject:[[NSArray alloc] initWithObjects:[tempArr objectAtIndex:i], nil] forKey:@"messages"];
            
            [chatArray insertObject:dic atIndex:0];
            
        }
        else
        {
            for(int j = 0; j<[dateArray count];j++)
            {
                if([[dateArray objectAtIndex:j] isEqualToDate:tempDate])
                {
                    NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
                    
                    [tempMessageArr addObject:[tempArr objectAtIndex:i]];
                    [tempMessageArr addObjectsFromArray:[[chatArray objectAtIndex:j] objectForKey:@"messages"]];
                    [[chatArray objectAtIndex:j] setObject:tempMessageArr forKey:@"messages"];
                }
            }
        }
    }
    
    
    webConnector = [[WebConnector alloc] init];
    
    NSArray *readArr = [[NSArray alloc] initWithObjects:@"read_status", nil];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"read" forKey:@"read_status"];
    NSArray *valueArr = [[NSArray alloc] initWithObjects:dic, nil];
    
    
    [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:readArr setValue:valueArr andWhere:[NSString stringWithFormat:@"sender_id = '%@' AND receiver_id = '%@'",[[self prevDataDic] objectForKey: @"user_id"],[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] objectForKey: @"user_id"]]];
    
    
    //USER WATER MARK LABEL
    if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height/2) - 75, self.view.frame.size.width , 150)];
        
        label.transform = CGAffineTransformMakeRotation(17.8/M_PI);
        label.textAlignment = NSTextAlignmentCenter;
        [label setFont:[UIFont fontWithName:@"Roboto-Regular" size:100.0]];
        label.textColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
        //label.text = [titleButton.titleLabel.text componentsSeparatedByString:@" "][0];
        label.text = [[[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] uppercaseString] componentsSeparatedByString:@" "][0];
        [label setAdjustsFontSizeToFitWidth:YES];
        [[self view] addSubview:label];
        [[self view] sendSubviewToBack:label];
        [self getUserLastOnlineTime];
        
    }
    
    
    tableView.hidden = true;
    //    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    //    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
    //        tableView.hidden = false;
    //    });
    
    [[self tableView] addGestureRecognizer:tapGesture];
    
    //Delete after///
    //callDeleteMessageTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(getExpireMessage) userInfo:nil repeats:YES];
    
    DeleteMessageTimer = [[NSTimer alloc] init];
    
    deleteAfterMainView.hidden = true;
    deleteAfterSecondValue = @"";
    
    DeleteMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getExpireMessage) userInfo:nil repeats:YES];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    
    if([chatArray count] >0 && tableView.hidden == true)
    {
        
        NSIndexPath *myIP = [NSIndexPath indexPathForRow:[[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"] count] - 1 inSection:[chatArray count] - 1];
        
        [self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionBottom animated:false];
    }
    
    tableView.hidden = false;
    [self readAllMessages];
    [[appDelegate socketManager] checkSocketStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    playingMessageID = @"";
    [audioPlayer stop];
    [DeleteMessageTimer invalidate];
}

-(void)pagging
{
    tableView.scrollsToTop = false;
    if(offset < 0)
    {
        offset = 0;
    }
    NSInteger oldOffset = offset;
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    tempArr = [appDelegate.generalFunction getChat:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]] orWithGroup:[[self prevDataDic] objectForKey: @"group_id"] withOffset: offset];
    
    if([tempArr count] == 0)
    {
        offset = oldOffset;
        return;
    }
    
    offset = offset + [tempArr count];
    
    for(int i=0;i<[tempArr count];i++)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *tempDateWithSec = [dateFormatter dateFromString:[[tempArr objectAtIndex:i] valueForKey:@"created_at"]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateString = [dateFormatter stringFromDate:tempDateWithSec];
        
        NSDate *tempDate = [dateFormatter dateFromString:dateString];
        
        
        if(![dateArray containsObject:tempDate])
        {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:tempDate forKey:@"date"];
            [dic setObject:[[NSArray alloc] initWithObjects:[tempArr objectAtIndex:i], nil] forKey:@"messages"];
            [dateArray insertObject:tempDate atIndex:0];
            [chatArray insertObject:dic atIndex:0];
            
        }
        else
        {
            for(int j = 0; j<[dateArray count];j++)
            {
                if([[dateArray objectAtIndex:j] isEqualToDate:tempDate])
                {
                    NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
                    
                    [tempMessageArr addObjectsFromArray:[[[chatArray objectAtIndex:j] objectForKey:@"messages"] mutableCopy]];
                    
                    [tempMessageArr insertObject:[tempArr objectAtIndex:i] atIndex:0];
                    
                    [[chatArray objectAtIndex:j] setObject:tempMessageArr forKey:@"messages"];
                }
            }
        }
    }
    
    float prevSize = tableView.contentSize.height * 3;
    
    [tableView reloadData];
    
    [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - prevSize)];
    
    
}

//MARK:- Notifications
- (void)onlineStatusChanged
{
    
    if([appDelegate.onlineUsersDictionary objectForKey:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]])
    {
        userStatusLabel.text = @"Online";
    }
    else
    {
        if([userStatusLabel.text isEqualToString:@"Online"])
        {
            [self getUserLastOnlineTime];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        if([[self prevDataDic] objectForKey: @"last_login_time"] != nil &&![[[self prevDataDic] objectForKey: @"last_login_time"] isKindOfClass:[NSNull class]] && ![[[self prevDataDic] objectForKey: @"last_login_time"] isEqualToString:@""])
        {
            NSDate *tempDate = [dateFormatter dateFromString:[[self prevDataDic] objectForKey: @"last_login_time"]];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            if([[NSCalendar currentCalendar] isDateInToday:tempDate])
            {
                [dateFormatter setDateFormat:@"hh:mm a"];
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                userStatusLabel.text = [NSString stringWithFormat:@"Last Seen: Today at %@",dateStr];
            }
            else
            {
                userStatusLabel.text = @"";
                if(tempDate != nil)
                {
                    [dateFormatter setDateFormat:@"dd.MM.yyyy hh:mm a"];
                    NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                    userStatusLabel.text = [NSString stringWithFormat:@"Last Seen: %@",dateStr];
                }
            }
        }
        else
        {
            userStatusLabel.text = @"";
        }
        
    }
}


- (void)userTyping:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
    
    if([[NSString stringWithFormat:@"%@",[info objectForKey: @"sender_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]])
    {
        userStatusLabel.text = @"Typing..";
        
        [typingTimer invalidate];
        typingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(onlineStatusChanged) userInfo:nil repeats:NO];
    }
}


- (void)newMsgRecieved:(NSNotification *)notification
{
    
    NSArray *info = [notification object];
    
    for(int i = 0;i< [info count]; i++)
    {
        if(([[self prevDataDic] objectForKey: @"group_id"] != nil && ![[[self prevDataDic] objectForKey: @"group_id"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@",[[info objectAtIndex:i] objectForKey: @"group_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]]]) || ((![[[self prevDataDic] objectForKey: @"user_id"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@",[[info objectAtIndex:i] objectForKey: @"sender_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]] && ![[[info objectAtIndex:i] objectForKey: @"receiver_id"] isKindOfClass:[NSNull class]]) || ([[NSString stringWithFormat:@"%@",[[info objectAtIndex:i] objectForKey: @"receiver_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]])))
        {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
            [dateFormatter setTimeZone:TimeZone];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *tempDateWithSec = [dateFormatter dateFromString:[[info objectAtIndex:i] valueForKey:@"created_at"]];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSString *dateString = [dateFormatter stringFromDate:tempDateWithSec];
            
            NSDate *tempDate = [dateFormatter dateFromString:dateString];
            
            
            if(![dateArray containsObject:tempDate])
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:tempDate forKey:@"date"];
                [dic setObject:[[NSArray alloc] initWithObjects:[info objectAtIndex:i], nil] forKey:@"messages"];
                [dateArray addObject:tempDate];
                [chatArray addObject:dic];
                
            }
            else
            {
                for(int j = 0; j<[dateArray count];j++)
                {
                    if([[dateArray objectAtIndex:j] isEqualToDate:tempDate])
                    {
                        NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
                        
                        [tempMessageArr addObjectsFromArray:[[[chatArray objectAtIndex:j] objectForKey:@"messages"] mutableCopy]];
                        
                        [tempMessageArr addObject:[info objectAtIndex:i]];
                        // [tempMessageArr insertObject:[info objectAtIndex:i] atIndex:0];
                        
                        [[chatArray objectAtIndex:j] setObject:tempMessageArr forKey:@"messages"];
                    }
                }
            }
            
            offset = offset + 1;
            [optionView removeFromSuperview];
            tableView.scrollEnabled = true;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                
                NSIndexPath *myIP = [NSIndexPath indexPathForRow:[[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"] count] - 1 inSection:[chatArray count] - 1];
                
                [self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionBottom animated:true];
            });
            
            
            
            [self readAllMessages];
            
            //            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            //            [dic setValue:@"read" forKey:@"read_status"];
            //
            //            NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
            //            [dateFormatter setTimeZone:localTimeZone];
            //            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //            [dic setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"read_at"];
            //
            //            NSArray *tempKey = [[NSArray alloc] initWithObjects:@"read_status",@"read_at", nil];
            
            //[appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"sender_id = '%@' AND receiver_id = '%@' AND read_at = ''",[[self prevDataDic] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
            
        }
        
    }
    
    if(DeleteMessageTimer.isValid == false)
    {
        DeleteMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getExpireMessage) userInfo:nil repeats:YES];
    }
    
}

-(void)msgStatusChanged:(NSNotification *)notification
{
    NSArray *info = [notification object];
    
    if ([[info objectAtIndex:0] isKindOfClass:[NSDictionary class]] && (([[info objectAtIndex:0] objectForKey:@"group_id"] != nil && [[NSString stringWithFormat:@"%@",[[info objectAtIndex:0] objectForKey:@"group_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]]]) || ([[info objectAtIndex:0] objectForKey:@"receiver_id"] != nil && [[NSString stringWithFormat:@"%@",[[info objectAtIndex:0] objectForKey:@"receiver_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]])))
    {
        //[chatArray removeAllObjects];
        //chatArray = [appDelegate.generalFunction getChat:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]];
        
        for(int k = 0;k < [info count]; k++)
        {
            for(int i = 0;i < [chatArray count]; i++)
            {
                for(int j = 0;j < [[[chatArray objectAtIndex:i] valueForKey:@"messages"] count]; j++)
                {
                    if([[NSString stringWithFormat:@"%@",[[[[chatArray objectAtIndex:i] valueForKey:@"messages"] objectAtIndex:j] valueForKey:@"message_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[info objectAtIndex:k] objectForKey:@"message_id"]]])
                    {
                        if([[info objectAtIndex:k] objectForKey:@"delivery_status"] != nil)
                        {
                            [[[[chatArray objectAtIndex:i] valueForKey:@"messages"] objectAtIndex:j] setObject:[[info objectAtIndex:k] objectForKey:@"delivery_status"] forKey:@"delivery_status"];
                        }
                        else if([[info objectAtIndex:k] objectForKey:@"read_status"] != nil)
                        {
                            [[[[chatArray objectAtIndex:i] valueForKey:@"messages"] objectAtIndex:j] setObject:[[info objectAtIndex:k] objectForKey:@"read_status"] forKey:@"read_status"];
                            
                            if([[info objectAtIndex:k] objectForKey:@"read_at"] != nil)
                            {
                                [[[[chatArray objectAtIndex:i] valueForKey:@"messages"] objectAtIndex:j] setObject:[[info objectAtIndex:k] objectForKey:@"read_at"] forKey:@"read_at"];
                            }
                            
                        }
                        
                        break;
                    }
                }
            }
            
        }
        
        [tableView reloadData];
    }
}


- (void)downloadUpdateStatus:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
    
    if ([[NSString stringWithFormat:@"%@",[info objectForKey:@"group_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]]] || [[NSString stringWithFormat:@"%@",[info objectForKey:@"receiver_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]] || [[NSString stringWithFormat:@"%@",[info objectForKey:@"sender_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]])
    {
        for(int i = 0;i<[chatArray count]; i++)
        {
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:i] objectForKey:@"messages"]];
            
            for(int j = 0;j<[tempArr count]; j++)
            {
                if([[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:j] valueForKey:@"message_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[info objectForKey:@"message_id"]]])
                {
                    [[tempArr objectAtIndex:j] setValue:[info objectForKey:@"receivedData"] forKey:@"receivedData"];
                    [[tempArr objectAtIndex:j] setValue:[info objectForKey:@"expectedBytes"] forKey:@"expectedBytes"];
                    [[tempArr objectAtIndex:j] setValue:[info objectForKey:@"progressive"] forKey:@"progressive"];
                    
                    if([[info objectForKey:@"progressive"] integerValue] >= 1 &&  [playingMessageID isEqualToString: [NSString stringWithFormat:@"%@",[info objectForKey:@"message_id"]]])
                    {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                        NSString *documentPath = [paths objectAtIndex:0];
                        
                        NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:j] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
                        NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
                        
                        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        
                        if([fileManager fileExistsAtPath:filePath])
                        {
                            
                            AVAudioSession *session = [AVAudioSession sharedInstance];
                            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
                            
                            NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath relativeToURL:nil];
                            
                            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                            
                            
                            [audioPlayer prepareToPlay];
                            [audioPlayer play];
                            
                            [[tempArr objectAtIndex:j] setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressivePlaying"];
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateupdateAudioProgressView:) userInfo:nil repeats:YES];
                        }
                        
                    }
                    
                    [tableView reloadData];
                    break;
                }
                
            }
            
        }
    }
}



-(void)updateGroupProfile:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
    prevDataDic = [info mutableCopy];
    
    [titleButton setTitle:[[[self prevDataDic] objectForKey: @"group_name"] uppercaseString] forState:UIControlStateNormal];
    userStatusLabel.text = @"";
    
}

-(void)updateGroupinfo
{
    if(![[NSString stringWithFormat:@"%@",[prevDataDic valueForKey:@"group_id"]] isEqualToString:@""])
    {
        NSArray *groupInfoArr = [[NSArray alloc] initWithArray:[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_groups" forKeys:[[NSArray alloc] initWithObjects:@"group_name",@"group_icon", nil] andWhere:[NSString stringWithFormat:@"id = '%@'",[prevDataDic valueForKey:@"group_id"]]]];
        
        if([groupInfoArr count] > 0)
        {
            [prevDataDic setValue:[[groupInfoArr objectAtIndex:0] valueForKey:@"group_name"]  forKey:@"group_name"];
            [prevDataDic setValue:[[groupInfoArr objectAtIndex:0] valueForKey:@"group_icon"]  forKey:@"group_icon"];
        }
        
        [titleButton setTitle:[[[self prevDataDic] objectForKey: @"group_name"] uppercaseString] forState:UIControlStateNormal];
        userStatusLabel.text = @"";
    }
}

-(void)deletedGroup:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
    
    if([[NSString stringWithFormat:@"%@",[info objectForKey:@"group_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]]])
    {
        for(UIViewController *vc in self.navigationController.viewControllers)
        {
            if([vc isKindOfClass:[UITabBarController class]])
            {
                [self.navigationController popToViewController:vc animated:true];
            }
        }
    }
}

-(void)readAllMessages
{
    [[appDelegate socketManager] readMesage:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]] withGroupID:[[self prevDataDic] objectForKey: @"group_id"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:@"read" forKey:@"read_status"];
    
    NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dic setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"read_at"];
    
    
    NSArray *tempKey = [[NSArray alloc] initWithObjects:@"read_status",@"read_at", nil];
    
    if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[NSString stringWithFormat:@"%@",[prevDataDic valueForKey:@"group_id"]] isEqualToString:@""])
    {
        [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"sender_id = '%@' AND receiver_id = '%@' AND read_at = ''",[[self prevDataDic] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
    }
    else
    {
        
        [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"group_id = \"%@\" AND sender_id != '%@' AND read_at = \"\"",[[self prevDataDic] objectForKey: @"group_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
    }
}

#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:indexPath.section] objectForKey:@"messages"]];
    
    if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"action"])
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"actionMsgCell"  forIndexPath: indexPath];
        UILabel *textLabel = [cell viewWithTag:1];
        
        //        NSString *rawString = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
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
        textLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
        // }
        
        [textLabel sizeToFit];
        
        
    }
    else if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"] isKindOfClass:[NSNull class]] && ![[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]] isEqualToString:@""] && [[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]])
    {
        if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
        {
            if([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"image"] || ([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"]))
            {
                
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderMediaCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIImageView *imageView = [cell viewWithTag:2];
                UIImageView *statusImageView = [cell viewWithTag:3];
                UILabel *timeLabel = [cell viewWithTag:4];
                UIButton *mediaButton = [cell viewWithTag:5];
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                
                [ActivityIndicator setColor:[UIColor whiteColor]];
                
                bgView.layer.cornerRadius = 10;
                imageView.clipsToBounds = true;
                imageView.hidden = false;
                ActivityIndicator.hidden = true;
                mediaButton.enabled = true;
                imageView.image = [UIImage imageNamed: @"default_profile"];
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
                }
                else
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
                }
                
                
                [mediaButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2f]];
                [mediaButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Medium" size:14.0]];
                [mediaButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempFileArr = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempFileArr objectAtIndex:[tempFileArr count] - 1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                
                [mediaButton setTitle:@"" forState:UIControlStateNormal];
                [mediaButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                
                
                if ([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"])
                {
                    
                    // NSURL *URL = [[NSURL alloc] init];
                    
                    if([fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                        [mediaButton setBackgroundColor:[UIColor clearColor]];
                        [mediaButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                        
                        //                        URL = [NSURL fileURLWithPath:filePath];
                        //
                        //                        AVPlayer *avPlayer = [AVPlayer playerWithURL:URL];
                        //
                        //
                        //                        AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
                        //                        playerLayer.frame = imageView.frame;
                        //                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        //                        playerLayer.needsDisplayOnBoundsChange = YES;
                        //
                        //                        [bgView.layer addSublayer:playerLayer];
                        //                        bgView.layer.needsDisplayOnBoundsChange = YES;
                        //                        //[avPlayer play];
                        
                    }
                    else
                    {
                        [mediaButton setTitle:[NSString stringWithFormat:@"%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]]] forState:UIControlStateNormal];
                        
                    }
                    
                    //[imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                    
                    imageView.hidden = false;
                }
                else
                {
                    
                    if([fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                        [mediaButton setBackgroundColor:[UIColor clearColor]];
                        imageView.image = [UIImage imageWithContentsOfFile:filePath];
                    }
                    else
                    {
                        //[imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                        
                        [mediaButton setTitle:[NSString stringWithFormat:@"%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]]] forState:UIControlStateNormal];
                    }
                    
                    [imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                    
                    [bgView bringSubviewToFront:imageView];
                    
                    
                }
                
                [imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                
                [bgView bringSubviewToFront:mediaButton];
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                    
                {
                    [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                    [mediaButton setTitle:@"" forState:UIControlStateNormal];
                    
                    //[mediaButton setTitle:[NSString stringWithFormat:@"%@/%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"receivedData"] length]],[[tempArr objectAtIndex:indexPath.row] valueForKey:@"fileSize"]] forState:UIControlStateNormal];
                    
                    mediaButton.enabled = false;
                    //mediaButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                    [bgView bringSubviewToFront:ActivityIndicator];
                }
                else
                {
                    if ([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"])
                    {
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                        [mediaButton setBackgroundColor:[UIColor clearColor]];
                        [mediaButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                    }
                    
                    mediaButton.enabled = true;
                    // mediaButton.hidden = false;
                    ActivityIndicator.hidden = true;
                }
                
                statusImageView.backgroundColor = [UIColor clearColor];
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"delivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_delivered"];
                    
                    if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                    {
                        statusImageView.image = [UIImage imageNamed: @"msg_read"];
                    }
                }
                else if ([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"undelivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_sent"];
                }
                else
                {
                    statusImageView.image = [UIImage imageNamed: @"awaiting"];
                }
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_read"];
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
                
            }
            else if([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"Audio"] || [[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"audio"])
            {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderAudioCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIButton *playBtn = [cell viewWithTag:2];
                UIProgressView *progressView = [cell viewWithTag:3];
                UILabel *counterLabel = [cell viewWithTag:4];
                
                UIImageView *statusImageView = [cell viewWithTag:6];
                UILabel *timeLabel = [cell viewWithTag:7];
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                
                [ActivityIndicator setColor:[UIColor whiteColor]];
                
                bgView.layer.cornerRadius = 10;
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
                {
                    
                    bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
                }
                else
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
                }
                
                counterLabel.clipsToBounds = true;
                counterLabel.layer.cornerRadius = 10;
                
                
                
                
                [playBtn addTarget:self action:@selector(audioMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] integerValue] < 1 && audioPlayer.isPlaying && playingMessageID == [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_id"])
                {
                    [progressView setProgress:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] floatValue]];
                    [playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                }
                else
                {
                    [progressView setProgress:0.0];
                    [playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                }
                
                int totalSec = [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"duration"] intValue];
                
                int minutes = totalSec/60;
                int sec = totalSec % 60;
                
                counterLabel.text = [NSString stringWithFormat:@"%d:%d",minutes,sec];
                
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                    
                {
                    
                    playBtn.enabled = false;
                    //mediaButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                    [bgView bringSubviewToFront:ActivityIndicator];
                }
                else
                {
                    playBtn.enabled = true;
                    // mediaButton.hidden = false;
                    ActivityIndicator.hidden = true;
                }
                
                
                
                statusImageView.backgroundColor = [UIColor clearColor];
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"delivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_delivered"];
                    
                    if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                    {
                        statusImageView.image = [UIImage imageNamed: @"msg_read"];
                    }
                }
                else if ([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"undelivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_sent"];
                }
                else
                {
                    statusImageView.image = [UIImage imageNamed: @"awaiting"];
                }
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_read"];
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
                
            }
            else
            {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderDocCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIImageView *fileImageView = [cell viewWithTag:2];
                UILabel *textLabel = [cell viewWithTag:3];
                UILabel *sizeLabel = [cell viewWithTag:4];
                UIButton *downloadButton = [cell viewWithTag:5];
                UIImageView *statusImageView = [cell viewWithTag:6];
                UILabel *timeLabel = [cell viewWithTag:7];
                
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                
                bgView.layer.cornerRadius = 10;
                ActivityIndicator.hidden = true;
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
                }
                else
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
                }
                
                [downloadButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                NSURL *url = [NSURL URLWithString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"]];
                
                NSArray *urlStringArr = [[url lastPathComponent] componentsSeparatedByString:@"/"];
                
                NSString *filename = @"file.ext";
                
                if([urlStringArr count] > 0)
                {
                    filename = [[NSString stringWithFormat:@"%@",urlStringArr[[urlStringArr count] - 1]] componentsSeparatedByString:@"_mds_"][1];
                }
                
                NSArray *fileType = [filename componentsSeparatedByString:@"."];
                
                filename = [filename stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                
                
                textLabel.text = filename;
                
                if([fileType[[fileType count] -1] isEqualToString:@"pdf"])
                {
                    fileImageView.image = [UIImage imageNamed:@"pdf"];
                }
                else if([fileType[[fileType count] -1] isEqualToString:@"msword"] || [fileType[[fileType count] -1] isEqualToString:@"doc"])
                {
                    fileImageView.image = [UIImage imageNamed:@"doc"];
                }
                else if([fileType[[fileType count] -1] isEqualToString:@"csv"] || [fileType[[fileType count] -1] isEqualToString:@"xlsx"] ||[fileType[[fileType count] -1] isEqualToString:@"xls"])
                {
                    fileImageView.image = [UIImage imageNamed:@"xcel"];
                }
                else
                {
                    fileImageView.image = [UIImage imageNamed:@"defaultFile"];
                }
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                
                sizeLabel.text = [self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]];
                
                if([fileManager fileExistsAtPath:filePath])
                {
                    [downloadButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    [downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    [downloadButton setTitle:@"" forState:UIControlStateNormal];
                    
                }
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                {
                    downloadButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                }
                else
                {
                    [downloadButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
                    
                    downloadButton.hidden = false;
                    ActivityIndicator.hidden = true;
                    [ActivityIndicator stopAnimating];
                }
                
                statusImageView.backgroundColor = [UIColor clearColor];
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"delivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_delivered"];
                    
                    if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                    {
                        statusImageView.image = [UIImage imageNamed: @"msg_read"];
                    }
                }
                else if ([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"undelivered"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_sent"];
                }
                else
                {
                    statusImageView.image = [UIImage imageNamed: @"awaiting"];
                }
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
                {
                    statusImageView.image = [UIImage imageNamed: @"msg_read"];
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
                
                
            }
        }
        else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"senderCell"  forIndexPath: indexPath];
            UIView *bgView = [cell viewWithTag:1];
            UILabel *textLabel = [cell viewWithTag:2];
            UIImageView *statusImageView = [cell viewWithTag:3];
            UILabel *timeLabel = [cell viewWithTag:4];
            
            bgView.layer.cornerRadius = 10;
            bgView.clipsToBounds = true;
            
            if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
            {
                bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
            }
            else
            {
                bgView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0];
            }
            
            //            NSString *rawString = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
            //
            //            NSArray *messageArr = [appDel getMessageAndIV:rawString];
            //
            //            NSString *decryptedString = [[appDel cryptoLib] decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
            //
            //            if(decryptedString != nil && ![decryptedString isEqualToString:@""])
            //            {
            //                textLabel.text = [appDel UTF8Message:decryptedString];
            //            }
            //            else
            //            {
            //                textLabel.text = @"";
            //            }
            
            textLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
            
            [textLabel sizeToFit];
            
            statusImageView.backgroundColor = [UIColor clearColor];
            
            if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"delivered"])
            {
                statusImageView.image = [UIImage imageNamed: @"msg_delivered"];
                
            }
            else if ([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"delivery_status"] isEqualToString:@"undelivered"])
            {
                statusImageView.image = [UIImage imageNamed: @"msg_sent"];
            }
            else
            {
                statusImageView.image = [UIImage imageNamed: @"awaiting"];
            }
            
            if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"read_status"] isEqualToString:@"read"])
            {
                statusImageView.image = [UIImage imageNamed: @"msg_read"];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
            [dateFormatter setTimeZone:TimeZone];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
            
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        
    }
    else
    {
        if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
        {
            if([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"image"] || ([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"]))
            {
                
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"recieverMediaCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIImageView *imageView = [cell viewWithTag:2];
                UIImageView *statusImageView = [cell viewWithTag:3];
                UILabel *timeLabel = [cell viewWithTag:4];
                UIButton *mediaButton = [cell viewWithTag:5];
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                UILabel *usernameLabel = [cell viewWithTag:11];
                
                [ActivityIndicator setColor:[UIColor whiteColor]];
                
                bgView.layer.cornerRadius = 10;
                imageView.clipsToBounds = true;
                imageView.hidden = false;
                ActivityIndicator.hidden = true;
                mediaButton.enabled = true;
                imageView.image = [UIImage imageNamed: @"default_profile"];
                
                bgView.backgroundColor = [UIColor whiteColor];
                
                statusImageView.layer.cornerRadius = statusImageView.frame.size.width/2;
                statusImageView.clipsToBounds = true;
                
                for(NSLayoutConstraint *constraint in usernameLabel.constraints)
                {
                    if([constraint.identifier isEqualToString:@"height"])
                    {
                        if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""] || [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                        {
                            constraint.constant = 0;
                        }
                        else
                        {
                            constraint.constant = 16;
                        }
                    }
                }
                
                usernameLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_name"];
                if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"] != nil)
                {
                    usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"]];
                }
                else
                {
                    NSArray *userColorArr = [appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"user_color", nil] andWhere:[NSString stringWithFormat:@"mds_users.user_id = %@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]]];
                    
                    if([userColorArr count] > 0)
                    {
                        usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"]];
                        NSMutableArray *dic = [[tempArr objectAtIndex:indexPath.row] mutableCopy];
                        
                        [dic setValue:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"] forKey:@"sender_color"];
                        
                        [tempArr replaceObjectAtIndex:indexPath.row withObject:dic];
                        
                        [[chatArray objectAtIndex:indexPath.section] setObject:tempArr forKey:@"messages"];
                    }
                }
                
                
                if([[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                {
                    if ([prevDataDic valueForKey:@"group_icon"] != nil && ![[prevDataDic valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
                    {
                        [statusImageView setImageWithURL: [NSURL URLWithString:             [NSString stringWithFormat:@"%@%@",imageBaseURL,[prevDataDic valueForKey:@"group_icon"] ]
                                                           ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                    }
                    
                }
                else if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] isKindOfClass:[NSNull class]])
                {
                    NSString *str = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] ];
                    [statusImageView setImageWithURL: [NSURL URLWithString:str
                                                       ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                }
                
                [mediaButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2f]];
                [mediaButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Medium" size:14.0]];
                [mediaButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                
                [mediaButton setTitle:@"" forState:UIControlStateNormal];
                [mediaButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                
                
                if ([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"])
                {
                    
                    // NSURL *URL = [[NSURL alloc] init];
                    
                    if([fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                        [mediaButton setBackgroundColor:[UIColor clearColor]];
                        [mediaButton setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                        
                        //                        URL = [NSURL fileURLWithPath:filePath];
                        //
                        //                        AVPlayer *avPlayer = [AVPlayer playerWithURL:URL];
                        //
                        //
                        //                        AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
                        //                        playerLayer.frame = imageView.frame;
                        //                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        //                        playerLayer.needsDisplayOnBoundsChange = YES;
                        //
                        //                        [bgView.layer addSublayer:playerLayer];
                        //                        bgView.layer.needsDisplayOnBoundsChange = YES;
                        //                        //[avPlayer play];
                        
                    }
                    else
                    {
                        [mediaButton setTitle:[NSString stringWithFormat:@"%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]]] forState:UIControlStateNormal];
                        
                    }
                    
                    // [imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                    
                    imageView.hidden = false;
                }
                else
                {
                    
                    if([fileManager fileExistsAtPath:filePath])
                    {
                        [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                        [mediaButton setTitle:@"" forState:UIControlStateNormal];
                        [mediaButton setBackgroundColor:[UIColor clearColor]];
                        imageView.image = [UIImage imageWithContentsOfFile:filePath];
                    }
                    else
                    {
                        //[imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                        
                        [mediaButton setTitle:[NSString stringWithFormat:@"%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]]] forState:UIControlStateNormal];
                    }
                    
                    [bgView bringSubviewToFront:imageView];
                    
                    
                }
                
                [imageView  setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"thumb_name"]]] placeholderImage: [UIImage imageNamed: @"newsfeedDefault"]];
                
                [bgView bringSubviewToFront:mediaButton];
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                    
                {
                    [mediaButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                    [mediaButton setTitle:@"" forState:UIControlStateNormal];
                    
                    //[mediaButton setTitle:[NSString stringWithFormat:@"%@/%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"receivedData"] length]],[[tempArr objectAtIndex:indexPath.row] valueForKey:@"fileSize"]] forState:UIControlStateNormal];
                    
                    mediaButton.enabled = false;
                    //mediaButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                    [bgView bringSubviewToFront:ActivityIndicator];
                }
                else
                {
                    mediaButton.enabled = true;
                    // mediaButton.hidden = false;
                    ActivityIndicator.hidden = true;
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
                
            }
            else if([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"Audio"] || [[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"audio"])
            {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"recieverAudioCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIButton *playBtn = [cell viewWithTag:2];
                UIProgressView *progressView = [cell viewWithTag:3];
                UILabel *counterLabel = [cell viewWithTag:4];
                
                UIImageView *statusImageView = [cell viewWithTag:6];
                UILabel *timeLabel = [cell viewWithTag:7];
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                UILabel *usernameLabel = [cell viewWithTag:11];
                
                [ActivityIndicator setColor:[UIColor whiteColor]];
                ActivityIndicator.hidden = true;
                
                
                bgView.layer.cornerRadius = 10;
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
                }
                else
                {
                    bgView.backgroundColor = [UIColor whiteColor];
                }
                
                
                counterLabel.clipsToBounds = true;
                counterLabel.layer.cornerRadius = 10;
                
                statusImageView.layer.cornerRadius = statusImageView.frame.size.width/2;
                statusImageView.clipsToBounds = true;
                
                for(NSLayoutConstraint *constraint in usernameLabel.constraints)
                {
                    if([constraint.identifier isEqualToString:@"height"])
                    {
                        if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""] || [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                        {
                            constraint.constant = 0;
                        }
                        else
                        {
                            constraint.constant = 16;
                        }
                    }
                }
                
                
                usernameLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_name"];
                if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"] != nil)
                {
                    usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"]];
                }
                else
                {
                    
                    
                    NSArray *userColorArr = [appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"user_color", nil] andWhere:[NSString stringWithFormat:@"mds_users.user_id = %@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]]];
                    
                    if([userColorArr count] > 0)
                    {
                        usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"]];
                        NSMutableArray *dic = [[tempArr objectAtIndex:indexPath.row] mutableCopy];
                        
                        [dic setValue:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"] forKey:@"sender_color"];
                        
                        [tempArr replaceObjectAtIndex:indexPath.row withObject:dic];
                        
                        [[chatArray objectAtIndex:indexPath.section] setObject:tempArr forKey:@"messages"];
                    }
                }
                
                
                if([[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                {
                    if ([prevDataDic valueForKey:@"group_icon"] != nil && ![[prevDataDic valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
                    {
                        [statusImageView setImageWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@%@",imageBaseURL,[prevDataDic valueForKey:@"group_icon"] ]
                                                           ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                    }
                    
                }
                else if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] isKindOfClass:[NSNull class]])
                {
                    [statusImageView setImageWithURL: [NSURL URLWithString:             [NSString stringWithFormat:@"%@uploads/profile_profile/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] ]
                                                       ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                }
                
                [playBtn addTarget:self action:@selector(audioMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] integerValue] < 1 && audioPlayer.isPlaying && playingMessageID == [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_id"])
                {
                    [progressView setProgress:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressivePlaying"] floatValue]];
                    [playBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                }
                else
                {
                    [progressView setProgress:0.0];
                    [playBtn setImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
                }
                
                int totalSec = [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"duration"] intValue];
                
                int minutes = totalSec/60;
                int sec = totalSec % 60;
                
                counterLabel.text = [NSString stringWithFormat:@"%d:%d",minutes,sec];
                
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                    
                {
                    
                    playBtn.enabled = false;
                    //mediaButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                    [bgView bringSubviewToFront:ActivityIndicator];
                }
                else
                {
                    playBtn.enabled = true;
                    // mediaButton.hidden = false;
                    ActivityIndicator.hidden = true;
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
                
            }
            else
            {
                cell = [self.tableView dequeueReusableCellWithIdentifier:@"recieverDocCell"  forIndexPath: indexPath];
                UIView *bgView = [cell viewWithTag:1];
                UIImageView *fileImageView = [cell viewWithTag:2];
                UILabel *textLabel = [cell viewWithTag:3];
                UILabel *sizeLabel = [cell viewWithTag:4];
                UIButton *downloadButton = [cell viewWithTag:5];
                UIImageView *statusImageView = [cell viewWithTag:6];
                UILabel *timeLabel = [cell viewWithTag:7];
                UILabel *usernameLabel = [cell viewWithTag:11];
                
                UIActivityIndicatorView *ActivityIndicator = [cell viewWithTag:666];
                
                bgView.layer.cornerRadius = 10;
                ActivityIndicator.hidden = true;
                statusImageView.layer.cornerRadius = statusImageView.frame.size.width/2;
                statusImageView.clipsToBounds = true;
                
                if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
                {
                    bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
                }
                else
                {
                    bgView.backgroundColor = [UIColor whiteColor];
                }
                
                for(NSLayoutConstraint *constraint in usernameLabel.constraints)
                {
                    if([constraint.identifier isEqualToString:@"height"])
                    {
                        if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""] || [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                        {
                            constraint.constant = 0;
                        }
                        else
                        {
                            constraint.constant = 16;
                        }
                    }
                }
                
                [downloadButton addTarget:self action:@selector(mediaMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                usernameLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_name"];
                if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"] != nil)
                {
                    usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"]];
                }
                else
                {
                    
                    
                    NSArray *userColorArr = [appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"user_color", nil] andWhere:[NSString stringWithFormat:@"mds_users.user_id = %@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]]];
                    
                    if([userColorArr count] > 0)
                    {
                        usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"]];
                        NSMutableArray *dic = [[tempArr objectAtIndex:indexPath.row] mutableCopy];
                        
                        [dic setValue:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"] forKey:@"sender_color"];
                        
                        [tempArr replaceObjectAtIndex:indexPath.row withObject:dic];
                        
                        [[chatArray objectAtIndex:indexPath.section] setObject:tempArr forKey:@"messages"];
                    }
                }
                
                
                if([[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                {
                    if ([prevDataDic valueForKey:@"group_icon"] != nil && ![[prevDataDic valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
                    {
                        [statusImageView setImageWithURL: [NSURL URLWithString:             [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[prevDataDic valueForKey:@"group_icon"] ]
                                                           ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                    }
                    
                }
                else if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] isKindOfClass:[NSNull class]])
                {
                    [statusImageView setImageWithURL: [NSURL URLWithString:             [NSString stringWithFormat:@"%@uploads/profile_profile/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] ]
                                                       ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                }
                
                
                NSURL *url = [NSURL URLWithString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"]];
                NSArray *urlStringArr = [[url lastPathComponent] componentsSeparatedByString:@"/"];
                
                NSString *filename = @"file.ext";
                
                if([urlStringArr count] > 0)
                {
                    filename = [[NSString stringWithFormat:@"%@",urlStringArr[[urlStringArr count] - 1]] componentsSeparatedByString:@"_mds_"][1];
                }
                
                NSArray *fileType = [filename componentsSeparatedByString:@"."];
                
                filename = [filename stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                
                textLabel.text = filename;
                
                if([fileType[[fileType count] -1] isEqualToString:@"pdf"])
                {
                    fileImageView.image = [UIImage imageNamed:@"pdf"];
                }
                else if([fileType[[fileType count] -1] isEqualToString:@"doc"])
                {
                    fileImageView.image = [UIImage imageNamed:@"doc"];
                }
                else if([fileType[[fileType count] -1] isEqualToString:@"xls"] || [fileType[[fileType count] -1] isEqualToString:@"excel"])
                {
                    fileImageView.image = [UIImage imageNamed:@"xcel"];
                }
                else
                {
                    fileImageView.image = [UIImage imageNamed:@"defaultFile"];
                }
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
                NSString *documentPath = [paths objectAtIndex:0];
                
                NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
                NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                
                sizeLabel.text = [NSString stringWithFormat:@"%@",[self transformedValue:[[[tempArr objectAtIndex:indexPath.row] objectForKey:@"filesize"] longLongValue]]];
                
                if([fileManager fileExistsAtPath:filePath])
                {
                    [downloadButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    [downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    [downloadButton setTitle:@"" forState:UIControlStateNormal];
                    
                }
                
                if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] != nil && [[[tempArr objectAtIndex:indexPath.row] valueForKey:@"progressive"] integerValue] < 1)
                {
                    downloadButton.hidden = true;
                    ActivityIndicator.hidden = false;
                    [ActivityIndicator startAnimating];
                }
                else
                {
                    downloadButton.hidden = false;
                    ActivityIndicator.hidden = true;
                    [ActivityIndicator stopAnimating];
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                [dateFormatter setTimeZone:TimeZone];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                dateFormatter.AMSymbol =@"AM";
                dateFormatter.PMSymbol =@"PM";
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSString *dateStr = [dateFormatter stringFromDate:tempDate];
                timeLabel.text = dateStr;
            }
        }
        else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"recieverCell"  forIndexPath: indexPath];
            UILabel *bgView = [cell viewWithTag:1];
            UILabel *textLabel = [cell viewWithTag:2];
            UIImageView *userImageView = [cell viewWithTag:3];
            UILabel *timeLabel = [cell viewWithTag:4];
            UILabel *usernameLabel = [cell viewWithTag:11];
            
            bgView.layer.cornerRadius = 10;
            bgView.clipsToBounds = true;
            userImageView.layer.cornerRadius = userImageView.frame.size.width/2;
            userImageView.clipsToBounds = true;
            
//            if(![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]] && [[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isEqualToString:@""])
//            {
//                NSString *str = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]];
//                [userImageView setImageWithURL: [NSURL URLWithString: str] placeholderImage: [UIImage imageNamed: @"default_profile"]];
//            }
            
            
            if([[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"broadcast"])
            {
                bgView.backgroundColor = [UIColor colorWithRed:(229/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
            }
            else
            {
                bgView.backgroundColor = [UIColor whiteColor];
            }
            
            for(NSLayoutConstraint *constraint in usernameLabel.constraints)
            {
                if([constraint.identifier isEqualToString:@"height"])
                {
                    if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""] || [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
                    {
                        constraint.constant = 0;
                    }
                    else
                    {
                        constraint.constant = 16;
                    }
                }
            }
            
            //            NSString *rawString = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
            //
            //            NSArray *messageArr = [appDel getMessageAndIV:rawString];
            //
            //            NSString *decryptedString = [[appDel cryptoLib] decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
            //
            //            if(decryptedString != nil && ![decryptedString isEqualToString:@""])
            //            {
            //                textLabel.text = [appDel UTF8Message:decryptedString];
            //            }
            //            else
            //            {
            //                textLabel.text = @"";
            //            }
            
            textLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message"];
            
            usernameLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_name"];
            if([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"] isEqualToString:@""])
            {
                usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_color"]];
            }
            else
            {
                
                
                NSArray *userColorArr = [appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"user_color", nil] andWhere:[NSString stringWithFormat:@"mds_users.user_id = %@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_id"]]];
                
                if([userColorArr count] > 0)
                {
                    usernameLabel.textColor = [appDelegate.constant colorFromHexString:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"]];
                    NSMutableArray *dic = [[tempArr objectAtIndex:indexPath.row] mutableCopy];
                    
                    [dic setValue:[[userColorArr objectAtIndex:0] valueForKey:@"user_color"] forKey:@"sender_color"];
                    
                    [tempArr replaceObjectAtIndex:indexPath.row withObject:dic];
                    
                    [[chatArray objectAtIndex:indexPath.section] setObject:tempArr forKey:@"messages"];
                }
            }
            
            if([[prevDataDic valueForKey:@"group_type"] isEqualToString:@"Broadcast"])
            {
                if ([prevDataDic valueForKey:@"group_icon"] != nil && ![[prevDataDic valueForKey:@"group_icon"] isKindOfClass:[NSNull class]])
                {
                    NSString *str = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[prevDataDic valueForKey:@"group_icon"] ];
                    [userImageView setImageWithURL: [NSURL URLWithString:str
                                                     ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
                }
                
            }
            else if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] isKindOfClass:[NSNull class]])
            {
                NSString *str = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"sender_image_thumb"] ];
                [userImageView setImageWithURL: [NSURL URLWithString:str
                                                 ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
            }
            else if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] isKindOfClass:[NSNull class]])
            {
                NSString *str = [NSString stringWithFormat:@"%@uploads/profile_picture/%@",imageBaseURL,[[tempArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"] ];
                [userImageView setImageWithURL: [NSURL URLWithString:str
                                                 ] placeholderImage: [UIImage imageNamed: @"default_profile"]];
            }
            
            if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"] isEqualToString:@""])
            {
                timeLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"];
            }
            else
            {
                timeLabel.text = [[tempArr objectAtIndex:indexPath.row] valueForKey:@""];
            }
            
            //timeLabel = timeLabel.intrinsicContentSize.width
            [textLabel sizeToFit];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
            [dateFormatter setTimeZone:TimeZone];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *tempDate = [dateFormatter dateFromString:[[tempArr objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
            
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateFormatter.AMSymbol =@"AM";
            dateFormatter.PMSymbol =@"PM";
            
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            NSString *dateStr = [dateFormatter stringFromDate:tempDate];
            timeLabel.text = dateStr;
        }
        
    }
    
    
    
    //    if (textLabel.frame.size.width > self.view.frame.size.width /2 - 8)
    //    {
    //        textLabel.frame = CGRectMake(8, 8, self.view.frame.size.width /2 - 28, textLabel.frame.size.height);
    //        bgView.frame = CGRectMake(self.view.frame.size.width /2, 8, self.view.frame.size.width /2 - 20, textLabel.frame.size.height);
    //    }
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    
    UILabel *bgView = [cell viewWithTag:1];
    
    [bgView addGestureRecognizer:longGesture];
    
    [cell updateConstraints];
    [cell setNeedsLayout];
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[[chatArray objectAtIndex:section] objectForKey:@"messages"] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [chatArray count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    bgView.clipsToBounds = true;
    
    label.backgroundColor = [UIColor colorWithRed:(251/255.0) green:(251/255.0) blue:(251/255.0) alpha:1.0];
    label.font = [UIFont fontWithName:@"Roboto-Regular" size:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    
    
    if([[NSCalendar currentCalendar] isDateInToday:[[chatArray objectAtIndex:section] objectForKey:@"date"]])
    {
        label.text = @"Today";
    }
    else if([[NSCalendar currentCalendar] isDateInYesterday:[[chatArray objectAtIndex:section] objectForKey:@"date"]])
    {
        label.text = @"Yesterday";
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:[[chatArray objectAtIndex:section] objectForKey:@"date"]];
        label.text = dateString;
    }
    
    
    [bgView addSubview:label];
    return bgView;
}



//MARK:- ScrollView Delegate
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == tableView && tableView.hidden == false && scrollView.contentOffset.y < 70)
    {
        [self pagging];
    }
}

//MARK:- Button

- (IBAction)backButtonClicked:(UIButton *)sender
{
    [[self navigationController] popViewControllerAnimated: YES];
}

-(IBAction)userNameTapped:(UIButton *)sender
{
    if([[prevDataDic objectForKey:@"group_id"] isEqualToString:@""])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ProfileViewController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        infoVC.from = @"otherUserProfile";
        infoVC.dataDic = [prevDataDic mutableCopy];
        [[self navigationController] pushViewController:infoVC animated:YES];
    }
    else
    {
        GroupProfileViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"GroupProfileViewController"];
        infoVC.from = @"profile";
        infoVC.prevDataDic = prevDataDic;
        [[self navigationController] pushViewController:infoVC animated:YES];
    }
}

- (IBAction)sendChatClicked:(UIButton *)sender
{
    
    if ([[textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || textView.textColor == [UIColor darkTextColor])
        // || [[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]]
    {
        // [self.view endEditing:true];
        
        NSLog(@"%@----",textView.text);
    }
    else
    {
        optionView.hidden = true;
        tableView.scrollEnabled = true;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        
        [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
        [tempDic setObject:@"" forKey:@"mid"];
        
        [tempDic setObject:[textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"message"];
        [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
        [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
        
        [tempDic setObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"profile_picture"] forKey:@"sender_image_thumb"];
        
        
        if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""])
        {
            [tempDic setObject:[[self prevDataDic] objectForKey: @"user_id"] forKey:@"receiver_id"];
            [tempDic setObject: [NSNull null] forKey:@"group_id"];
            [tempDic setObject: @"" forKey:@"group_type"];
        }
        else
        {
            [tempDic setObject: [[self prevDataDic] objectForKey: @"group_id"] forKey:@"group_id"];
            [tempDic setObject: [prevDataDic valueForKey:@"group_type"] forKey:@"group_type"];
            [tempDic setObject: [[self prevDataDic] objectForKey: @"group_name"] forKey:@"group_name"];
            [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
        }
        
        [tempDic setObject: @"unread" forKey:@"read_status"];
        [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
        [tempDic setObject: @"" forKey:@"deleted_at"];
        [tempDic setObject: deleteAfterSecondValue forKey:@"delete_after"];
        
        NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:localTimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
        
        [[appDelegate socketManager] sendMessage:[tempDic mutableCopy]];
        [self resetDeleteAfterTime];
        textView.text = @"";
        
        if([prevDataDic valueForKey:@"group_id"] != nil && ![[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] && ![[prevDataDic valueForKey:@"group_id"] isEqualToString:@""] && [[prevDataDic valueForKey:@"group_type"] isEqualToString:@"broadcast"])
        {
            [self sendBroadcastLoop:[tempDic mutableCopy]];
        }
        
        //
        //        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        //        NSString *dateStr2 = [dateFormatter stringFromDate:[NSDate date]];
        //        NSDate *date2 = [dateFormatter dateFromString:dateStr2];
        //
        //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        //
        //        if(![dateArray containsObject:date2])
        //        {
        //            [dic setObject:date2 forKey:@"date"];
        //            [dateArray addObject:date2];
        //            [dic setObject:[[NSArray alloc] initWithObjects:tempDic, nil] forKey:@"messages"];
        //
        //            [chatArray addObject:dic];
        //        }
        //        else
        //        {
        //            dic = [chatArray objectAtIndex:[chatArray count] - 1];
        //
        //            NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
        //            [tempMessageArr addObjectsFromArray:[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"]];
        //            [tempMessageArr addObject:tempDic];
        //
        //            [dic setObject:tempMessageArr forKey:@"messages"];
        //
        //            [chatArray replaceObjectAtIndex:[chatArray count] - 1 withObject:dic];
        //        }
        //
        //        if(![deleteAfterSecondValue isEqualToString:@""] && DeleteMessageTimer.isValid == false)
        //        {
        //            DeleteMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getExpireMessage) userInfo:nil repeats:YES];
        //
        //        }
        //
        //
        //        [self.tableView reloadData];
        
        
        
        //        NSIndexPath *myIP = [NSIndexPath indexPathForRow:[[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"] count] - 1 inSection:[chatArray count] - 1] ;
        //
        //        [self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionBottom animated:true];
        //
        //        [self resetDeleteAfterTime];
        
        
    }
}

-(void)sendBroadcastLoop:(NSMutableDictionary *)tempDic
{
    NSMutableArray *tempArr = [[appDelegate.generalFunction getAllGroupMembers:[prevDataDic valueForKey:@"group_id"]] mutableCopy];
    
    for(NSDictionary *userDic in tempArr)
    {
        
        if([[NSString stringWithFormat:@"%@",[userDic objectForKey: @"user_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]])
        {
            continue;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[userDic objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
        [tempDic setObject:@"" forKey:@"mid"];
        
        [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
        [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
        [tempDic setObject:[userDic objectForKey: @"user_id"] forKey:@"receiver_id"];
        [tempDic setObject: [NSNull null] forKey:@"group_id"];
        [tempDic setObject: @"" forKey:@"group_type"];
        [tempDic setObject: @"" forKey:@"group_name"];
        [tempDic setObject: @"broadcast" forKey:@"message_type"];
        [tempDic setObject: @"unread" forKey:@"read_status"];
        [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
        [tempDic setObject: @"" forKey:@"deleted_at"];
        [tempDic setObject: deleteAfterSecondValue forKey:@"delete_after"];
        
        NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:localTimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
        
        [[appDelegate socketManager] sendMessage:[tempDic mutableCopy]];
    }
}

- (IBAction)addAttachButtonClicked:(UIButton *)sender
{
    [optionView removeFromSuperview];
    tableView.scrollEnabled = true;
    [tableView reloadData];
    
    
    if (iconConst.constant > 0)
    {
        iconConst.constant = 0;
    }
    else
    {
        iconConst.constant = 40;
    }
}

- (IBAction)emojiButtonClicked:(UIButton *)sender
{
    [[self view] endEditing:true];
    
    if(self.textView.tag == 666)
    {
        [[self textView] setTag:0];;
        self.textView.inputView = nil;
        sender.selected = false;
    }
    else
    {
        AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        emojiKeyboardView.backgroundColor = [UIColor colorWithRed:(250/255.0) green:(250/255.0) blue:(250/255.0) alpha:1.0];
        
        sender.selected = true;
        [[self textView] setTag:666];
        self.textView.inputView = emojiKeyboardView;
    }
    
    [self.textView becomeFirstResponder];
    
    //[self textView] inp
}

- (IBAction)audioIconTapped:(UIButton *)sender
{
    //Code here
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Record" otherButtonTitles:nil, nil];
    option.tag = 1;
    [option showInView:self.view];
}

- (IBAction)imageIconTapped:(UIButton *)sender
{
    //Code here
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Gallery" otherButtonTitles:@"Camera", nil];
    option.tag = 2;
    [option showInView:self.view];
}

- (IBAction)videoIconTapped:(UIButton *)sender
{
    //Code here
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Gallery" otherButtonTitles:@"Camera", nil];
    option.tag = 3;
    [option showInView:self.view];
}

- (IBAction)documentIconTapped:(UIButton *)sender
{
    //Code here
    UIActionSheet *option = [[UIActionSheet alloc] initWithTitle:@"" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"iCloud" otherButtonTitles:@"Dropbox", nil];
    option.tag = 4;
    [option showInView:self.view];
}

-(IBAction) deletAfterButtonTapped:(UIButton *)sender
{
    UILabel *l1 = [self.view viewWithTag:991];
    UILabel *l2 = [self.view viewWithTag:992];
    UILabel *l3 = [self.view viewWithTag:993];
    UILabel *l4 = [self.view viewWithTag:994];
    UILabel *l5 = [self.view viewWithTag:995];
    
    l1.text = @"30 seconds";
    l2.text = @"1 hour";
    l3.text = @"1 Day";
    l4.text = @"1 Week";
    l5.text = @"Lifetime";
    
    [[self view] endEditing:true];
    [[self view] bringSubviewToFront:deleteAfterMainView];
    deleteAfterMainView.hidden = false;
}

-(void)mediaMessageTapped:(UIButton *)sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:indexPath.section] objectForKey:@"messages"]];
    
    
    if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:filePath])
        {
            [[tempArr objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
            [[tempArr objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
            [tableView reloadData];
            [appDelegate.downlaodArray addObject:[tempArr objectAtIndex:indexPath.row]];
            [appDelegate.constant downloadWithNsurlconnection];
        }
        else
        {
            
            MediaViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"MediaViewController"];
            infoVC.filePath = filePath;
            
            
            if([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"image"])
            {
                infoVC.from = @"image";
            }
            else if(([[[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"]] componentsSeparatedByString:@"/"][0] isEqualToString:@"video"]))
            {
                infoVC.from = @"video";
            }
            else
            {
                infoVC.from = @"document";
            }
            
            [[self navigationController] pushViewController:infoVC animated:YES];
        }
        
    }
    
}


-(void)audioMessageTapped:(UIButton *)sender
{
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: hitPoint];
    
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:indexPath.section] objectForKey:@"messages"]];
    
    
    if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *tempArr2 = [[NSArray alloc] initWithArray:[[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment"] componentsSeparatedByString:@"/"]];
        NSString *fileName = [tempArr2 objectAtIndex:[tempArr2 count] - 1];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentPath,fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        
        if(![fileManager fileExistsAtPath:filePath])
        {
            [[tempArr objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:0.0] forKey:@"receivedData"];
            [[tempArr objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressive"];
            [tableView reloadData];
            [appDelegate.downlaodArray addObject:[tempArr objectAtIndex:indexPath.row]];
            [appDelegate.constant downloadWithNsurlconnection];
        }
        else
        {
            if([playingMessageID isEqualToString:[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_id"]]]  && audioPlayer.isPlaying)
            {
                [audioPlayer stop];
                playingMessageID = @"";
                [tableView reloadData];
            }
            else
            {
                
                //                NSString *tempDir = NSTemporaryDirectory();
                //                NSString *soundFilePath = [tempDir stringByAppendingPathComponent:@"sound.m4a"];
                //
                //                NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
                //                NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                //                                                [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                //                                                [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                //                                                [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                //                                                [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                //                                                [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                //                                                [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                //                                                nil];
                
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setCategory:AVAudioSessionCategoryPlayback error:nil];
                
                NSURL *url = [[NSURL alloc]initFileURLWithPath:filePath relativeToURL:nil];
                
                
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                
                [audioPlayer prepareToPlay];
                [audioPlayer play];
                
                [[tempArr objectAtIndex:indexPath.row] setObject:[NSNumber numberWithFloat:0.0] forKey:@"progressivePlaying"];
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateupdateAudioProgressView:) userInfo:nil repeats:YES];
                
                [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                
            }
            
            
        }
        
        playingMessageID = [[tempArr objectAtIndex:indexPath.row] valueForKey:@"message_id"];
        
    }
    
}






-(void)copyButtonPressed:(UIButton *)sender
{
    
    optionView.hidden = true;
    [optionView removeFromSuperview];
    
    self.tableView.scrollEnabled = true;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:selectedIndexPath.section] objectForKey:@"messages"]];
    
    //    NSData *data = [[[[tempArr objectAtIndex:selectedIndexPath.row] valueForKey:@"message"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] dataUsingEncoding:NSUTF8StringEncoding];
    //
    //    NSString *emojiString = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    [pasteboard setString:[[tempArr objectAtIndex:selectedIndexPath.row] valueForKey:@"message"]];
}

-(void)deleteButtonPressed:(UIButton *)sender
{
    optionView.hidden = true;
    [optionView removeFromSuperview];
    self.tableView.scrollEnabled = true;
    
    [self deleteMessage];
}

-(void)forwardButtonPressed:(UIButton *)sender
{
    optionView.hidden = true;
    [optionView removeFromSuperview];
    
    self.tableView.scrollEnabled = true;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    favouriteViewController *infoVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"favouriteViewController"];
    infoVC.from = @"forwardMessage";
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:selectedIndexPath.section] objectForKey:@"messages"]];
    
    infoVC.prevDataDic = [tempArr objectAtIndex:selectedIndexPath.row];
    [[self navigationController] pushViewController:infoVC animated:YES];
}

- (IBAction)optionsButtonClicked:(UIButton *)sender
{
    [optionView removeFromSuperview];
    tableView.scrollEnabled = true;
    [tableView reloadData];
    
    if(topOptionMenu.hidden == true)
    {
        topOptionMenu.hidden = false;
    }
    else
    {
        topOptionMenu.hidden = true;
    }
}

- (IBAction)clearDeleteChatButtonTapped:(UIButton *)sender
{
    topOptionMenu.hidden = true;
    if(sender.tag == 2)
    {
        [self deleteChatFromChatList:@"Y"];
    }
    else
    {
        [self deleteChatFromChatList:@"N"];
    }
}

//MARK:- Action Sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (actionSheet.tag == 1)
    {
        
        if (buttonIndex == 0)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main2" bundle: nil];
            AudioViewController *infoVC = [storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
            infoVC.delegate = self;
            [[self navigationController] pushViewController:infoVC animated:YES];
            
        }
        
    }
    else if (actionSheet.tag == 2)
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
    else if (actionSheet.tag == 3)
    {
        UIImagePickerController *clickImg = [[UIImagePickerController alloc] init];
        clickImg.delegate = self;
        clickImg.allowsEditing = YES;
        
        if (buttonIndex == 0)
        {
            clickImg.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            clickImg.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController: clickImg animated:YES completion:nil];
        }
        else if (buttonIndex == 1)
        {
            clickImg.sourceType = UIImagePickerControllerSourceTypeCamera;
            clickImg.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController: clickImg animated:YES completion:nil];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.composite-content"]
                                                                                                                    inMode:UIDocumentPickerModeImport];
            documentPicker.delegate = self;
            
            documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:documentPicker animated:YES completion:nil];
        }
        else if (buttonIndex == 1)
        {
            //            [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
            //                                           controller:self
            //                                              openURL:^(NSURL *url) {
            //                                                  [[UIApplication sharedApplication] openURL:url];
            //                                              }];
            
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
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alert show];
                             return;
                         }
                         NSString *type = [[NSString stringWithFormat:@"%@",result.name] componentsSeparatedByString:@"."][1];
                         [self uploadDocument:data withThumbnailImage:nil withFileName:result.name forType:[NSString stringWithFormat:@"application/%@",type] withDuration:@""];
                     }
                     else
                     {
                         NSLog(@"INVALID URL!!!");
                     }
                     
                     
                 } else {
                     // User canceled the action
                 }
             }];
            
            
            
        }
    }
    
}

//MARK:- Audio
-(void) getAudio: (NSData *)audio withDuration:(NSString *)duration
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    [self uploadDocument:audio withThumbnailImage:nil withFileName:[NSString stringWithFormat:@"Audio%@.mp4",dateStr] forType:@"Audio/mp4" withDuration:duration];
}

-(void)updateupdateAudioProgressView:(NSTimer *)sender
{
    if(audioPlayer.isPlaying)
    {
        
        for(int i = 0;i<[chatArray count]; i++)
        {
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:i] objectForKey:@"messages"]];
            
            for(int j = 0;j<[tempArr count]; j++)
            {
                if([[NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:j] valueForKey:@"message_id"]] isEqualToString: playingMessageID])
                {
                    [[[[chatArray objectAtIndex:i] objectForKey:@"messages"] objectAtIndex:j] setObject:[NSNumber numberWithFloat:audioPlayer.currentTime/audioPlayer.duration] forKey:@"progressivePlaying"];
                }
            }
        }
        
        
    }
    else
    {
        [sender invalidate];
    }
    
    [tableView reloadData];
}


#pragma mark- UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        
        if ([imageData length] > 5000000)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image cannot be greater than 5Mb." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        [self uploadDocument:imageData withThumbnailImage:UIImageJPEGRepresentation(image, 0.2) withFileName:[NSString stringWithFormat:@"image%@.jpg",dateStr] forType:@"image/jpg" withDuration:@""];
    }
    else
    {
        
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSString stringWithFormat:@"%@",videoURL] stringByReplacingOccurrencesOfString:@"file://" withString:@""] error:nil];
        
        if(fileAttributes != nil)
        {
            NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
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
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        [self uploadDocument:[NSData dataWithContentsOfURL:videoURL] withThumbnailImage:UIImageJPEGRepresentation(thumbnail, 0.5) withFileName:[NSString stringWithFormat:@"video%@.mp4",dateStr] forType:@"video/mp4" withDuration:@""];
        
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
            NSString *type = [[NSString stringWithFormat:@"%@",[url lastPathComponent]] componentsSeparatedByString:@"."][1];
            
            [self uploadDocument:data withThumbnailImage:nil withFileName:[url lastPathComponent] forType:[NSString stringWithFormat:@"application/%@",type] withDuration:@""];
        }
        else
        {
            NSLog(@"INVALID URL!!!");
        }
    }
}

//MARK:- TextView
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    optionView.hidden = true;
    tableView.scrollEnabled = true;
    [[self tableView] addGestureRecognizer:tapGesture];
    [emojiButton removeGestureRecognizer:tapGesture];
    
    
    if (textView.textColor == [UIColor darkTextColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    [[appDelegate socketManager] typing:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]]];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [[self view] removeGestureRecognizer:tapGesture];
    
    
    if ([[textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:@""]) {
        textView.text = @"Say something...";
        textView.textColor = [UIColor darkTextColor];
    }
    
}

//MARK:- Keyboard

-(void) keyboardWillShow:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    bottomConst.constant = keyBoardSize.height;
    
    //    if (keyBoardView.frame.origin.y == self.view.frame.size.height - 80)
    //    {
    //        keyBoardView.frame = CGRectMake(keyBoardView.frame.origin.x, keyBoardView.frame.origin.y - keyBoardSize.height, keyBoardView.frame.size.width, keyBoardView.frame.size.height);
    //    }
    
}

-(void) keyboardWillHide:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    
    CGSize keyBoardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    bottomConst.constant = 0;
    
    textView.inputView = nil;
    // [textView reloadInputViews];
    
    //    if (keyBoardView.frame.origin.y != self.view.frame.size.height - 80)
    //    {
    //        keyBoardView.frame = CGRectMake(keyBoardView.frame.origin.x, keyBoardView.frame.origin.y + keyBoardSize.height, keyBoardView.frame.size.width, keyBoardView.frame.size.height);
    //    }
    
}

-(void) hideKeyboard
{
    [self.view endEditing:true];
    tapGesture.cancelsTouchesInView = false;
    //[[self view] removeGestureRecognizer:tapGesture];
    
    self.tableView.scrollEnabled = true;
    
    if(selectedIndexPath != nil)
    {
        //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView reloadData];
        selectedIndexPath = nil;
    }
    optionView .hidden = true;
    
    [[self textView] setTag:0];
    emojiButton.selected = false;
    
    topOptionMenu.hidden = true;
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
    
    // CGPoint hitPointView = [gestureRecognizer locationInView:self.view];
    CGPoint hitPoint = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    selectedIndexPath = indexPath;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *bgView = [cell viewWithTag:1];
    
    
    
    CGRect bgViewframeToView = [bgView.superview convertRect:bgView.frame toView:nil];
    
    //CGSize basicOptionSize = CGSizeMake(208, 46);
    //CGSize basicOptionSize = CGSizeMake(self.view.frame.size.width/2, (self.view.frame.size.width/2)/4);
    
    CGSize basicOptionSize = CGSizeMake(170, 40);
    
    
    UIImage *menuImage = [[UIImage alloc] init];
    
    
    if(bgViewframeToView.origin.x == 56)
    {
        bgView.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(243/255.0) blue:(243/255.0) alpha:1.0];
    }
    else
    {
        bgView.backgroundColor = [UIColor colorWithRed:(192/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];
    }
    
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
        
        
        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:indexPath.section] objectForKey:@"messages"]];
        
        if ([[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] != nil && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isKindOfClass:[NSNull class]] && ![[[tempArr objectAtIndex:indexPath.row] valueForKey:@"attachment_type"] isEqualToString:@""])
        {
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , basicButtonY, optionView.frame.size.width/2, optionView.frame.size.height)];
            UIButton *forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(optionView.frame.size.width/2 , basicButtonY, optionView.frame.size.width/2, optionView.frame.size.height)];
            
            UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(optionView.frame.size.width/2 ,basicButtonY + 16, 1, 11)];
            
            imageView1.backgroundColor = [UIColor whiteColor];
            
            [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
            [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            deleteButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
            
            
            [forwardButton setTitle:@"Forward" forState:UIControlStateNormal];
            [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            forwardButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
            
            [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [forwardButton addTarget:self action:@selector(forwardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [optionView addSubview:deleteButton];
            [optionView addSubview:forwardButton];
            [optionView addSubview:imageView1];
        }
        else
        {
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , basicButtonY, optionView.frame.size.width/3, optionView.frame.size.height)];
            UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(optionView.frame.size.width/3 , basicButtonY, optionView.frame.size.width/3, optionView.frame.size.height)];
            UIButton *forwardButton = [[UIButton alloc] initWithFrame:CGRectMake((optionView.frame.size.width/3)*2 , basicButtonY, optionView.frame.size.width/3, optionView.frame.size.height)];
            
            UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(optionView.frame.size.width/3 , basicButtonY + 16, 1, 11)];
            
            UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake((optionView.frame.size.width/3)*2 , basicButtonY + 16, 1, 11)];
            
            imageView1.backgroundColor = [UIColor whiteColor];
            imageView2.backgroundColor = [UIColor whiteColor];
            
            
            [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
            [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            deleteButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
            
            [copyButton setTitle:@"Copy" forState:UIControlStateNormal];
            [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            copyButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
            
            [forwardButton setTitle:@"Forward" forState:UIControlStateNormal];
            [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            forwardButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
            
            [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [copyButton addTarget:self action:@selector(copyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [forwardButton addTarget:self action:@selector(forwardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [optionView addSubview:deleteButton];
            [optionView addSubview:copyButton];
            [optionView addSubview:forwardButton];
            [optionView addSubview:imageView1];
            [optionView addSubview:imageView2];
        }
        
        [self.tableView addGestureRecognizer:tapGesture];
        [emojiButton removeGestureRecognizer:tapGesture];
        
        [self.view addSubview:optionView];
        [self.view bringSubviewToFront:optionView];
        optionView.hidden = false;
        
    }
    
    
}

//MARK:- Delete View
- (IBAction)deleteAfterTimeButtonClicked:(UIButton*)sender {
    
    UIButton *b1 = [self.view viewWithTag:661];
    UIButton *b2 = [self.view viewWithTag:662];
    UIButton *b3 = [self.view viewWithTag:663];
    UIButton *b4 = [self.view viewWithTag:664];
    UIButton *b5 = [self.view viewWithTag:665];
    
    if (sender.tag == 661)
    {
        //30sec
        
        deleteAfterSecondValue = @"30";
        
        [b1 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b3 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b4 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b5 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        
    }
    else if (sender.tag == 662)
    {
        //1hour
        
        deleteAfterSecondValue = @"3600";
        
        
        [b1 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
        [b3 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b4 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b5 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        
    }
    else if (sender.tag == 663)
    {
        //1day
        deleteAfterSecondValue = @"86400";
        
        [b1 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b3 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
        [b4 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b5 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        
    }
    else if (sender.tag == 664)
    {
        //1week
        
        deleteAfterSecondValue = @"604800";
        
        [b1 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b3 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b4 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
        [b5 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        
    }
    else if (sender.tag == 665)
    {
        //lifetime
        deleteAfterSecondValue = @"";
        [b1 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b2 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b3 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b4 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
        [b5 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
        
    }
    
}


- (IBAction)okButtonForSelectDeleteAfterOptionClicked:(id)sender {
    
    deleteAfterMainView.hidden = true;
    
}

- (IBAction)closeDeleteAfterView:(id)sender {
    deleteAfterMainView.hidden = true;
    [self resetDeleteAfterTime];
    
}


-(void)resetDeleteAfterTime
{
    deleteAfterSecondValue = @"";
    UIButton *b1 = [self.view viewWithTag:661];
    UIButton *b2 = [self.view viewWithTag:662];
    UIButton *b3 = [self.view viewWithTag:663];
    UIButton *b4 = [self.view viewWithTag:664];
    UIButton *b5 = [self.view viewWithTag:665];
    
    [b1 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
    [b2 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
    [b3 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
    [b4 setImage:[UIImage imageNamed:@"awaiting"] forState:UIControlStateNormal];
    [b5 setImage:[UIImage imageNamed:@"msg_delivered"] forState:UIControlStateNormal];
}


//MARK:- EMO JI
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.textView.text = [self.textView.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    [self.textView deleteBackward];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    //UIImage *img = [self randomImage];
    UIImage *img = [[UIImage alloc] init];
    
    if(category == AGEmojiKeyboardViewCategoryImageRecent)
    {
        img = [UIImage imageNamed:@"Recent"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageFace)
    {
        img = [UIImage imageNamed:@"smiley"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageBell)
    {
        img = [UIImage imageNamed:@"Tools"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageFlower)
    {
        img = [UIImage imageNamed:@"Teddy"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageCar)
    {
        img = [UIImage imageNamed:@"Car"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageCharacters)
    {
        img = [UIImage imageNamed:@"symbols"];
    }
    else
    {
        img = [self randomImage];
    }
    
    
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    // UIImage *img = [self randomImage];
    UIImage *img = [[UIImage alloc] init];
    
    if(category == AGEmojiKeyboardViewCategoryImageRecent)
    {
        img = [UIImage imageNamed:@"unSelectedRecent"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageFace)
    {
        img = [UIImage imageNamed:@"unSelectedSmiley"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageBell)
    {
        img = [UIImage imageNamed:@"unSelectedTools"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageFlower)
    {
        img = [UIImage imageNamed:@"unSelectedTeddy"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageCar)
    {
        img = [UIImage imageNamed:@"unSelectedCar"];
    }
    else if(category == AGEmojiKeyboardViewCategoryImageCharacters)
    {
        img = [UIImage imageNamed:@"unSelectedSymbols"];
    }
    else
    {
        img = [self randomImage];
    }
    
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    //UIImage *img = [self randomImage];
    UIImage *img = [UIImage imageNamed:@"backspace"];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return img;
}


//MARK:- Webservice
-(void) deleteMessage
{
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
        NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[[chatArray objectAtIndex:selectedIndexPath.section] objectForKey:@"messages"]];
        
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        [params setObject: [[tempArr objectAtIndex:selectedIndexPath.row] valueForKey:@"message_id"] forKey: @"message_id"];
        
        //[params setObject: @"des" forKey: @"order_by"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector deleteMessage: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"message_id = \"%@\"",[[tempArr objectAtIndex:selectedIndexPath.row] valueForKey:@"message_id"]]];
                
                [tempArr removeObjectAtIndex:selectedIndexPath.row];
                offset = offset - 1;
                
                if([tempArr count] > 0)
                {
                    [[chatArray objectAtIndex:selectedIndexPath.section] setObject:tempArr forKey:@"messages"];
                }
                else
                {
                    [chatArray removeObjectAtIndex:selectedIndexPath.section];
                    [dateArray removeObjectAtIndex:selectedIndexPath.section];
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
                        
                        [self deleteMessage];
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
            
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
      //      [SVProgressHUD showErrorWithStatus: @"Please try again. (Delete message)"];
            
        }];
    }
}


-(void) getUserLastOnlineTime
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        //[appDel showWithStatus: [appDel getString: @"loading"]];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
        [params setObject: [[self prevDataDic] objectForKey: @"user_id"] forKey: @"user_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        //[params setObject: @"des" forKey: @"order_by"];
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector lastOnlineTime: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseObject objectForKey: @"response"] isKindOfClass:[NSString class]] && [[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                // NSString *val = [[NSString stringWithFormat:@"%@",[[responseObject objectForKey: @"updated_at"] objectForKey: @"date"]] stringByReplacingOccurrencesOfString:@".000000" withString:@""];
                
                NSArray *val = [[NSString stringWithFormat:@"%@",[[responseObject objectForKey: @"updated_at"] objectForKey: @"date"]] componentsSeparatedByString:@"."];
                
                
                [dic setValue:val[0] forKey:@"last_login_time"];
                [self.prevDataDic setValue:val[0] forKey:@"last_login_time"];
                
                [self onlineStatusChanged];
                
                [appDelegate.generalFunction updateTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"last_login_time", nil] setValue:[[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"user_id = '%@'",[[self prevDataDic] objectForKey: @"user_id"]]];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self getUserLastOnlineTime];
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
            
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
       //     [SVProgressHUD showErrorWithStatus: @"Please try again. (user last online time)"];
            
        }];
    }
}

-(void) uploadDocument:(NSData *)doc withThumbnailImage:(NSData*)thumb withFileName:(NSString *)fileName forType:(NSString *)type withDuration:(NSString *)duration
{
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus: @"Please wait"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector uploadDocument:type withName:fileName document:doc andThumbnail:thumb withDuration:duration completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                
                if ([responseObject objectForKey: @"result"] != nil && [[responseObject objectForKey: @"result"] isKindOfClass:[NSDictionary class]])
                {
                    
                    NSDictionary *tempDataDic = [responseObject objectForKey: @"result"];
                    
                    //Writing File to Document directory
                    NSArray *tempArr = [[NSArray alloc] initWithArray:[[tempDataDic objectForKey: @"upload_path"] componentsSeparatedByString:@"/"]];
                    NSString *fileName = [tempArr objectAtIndex:[tempArr count] - 1];
                    
                    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString  *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
                    
                    //saving is done on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [doc writeToFile:filePath atomically:YES];
                        NSLog(@"File Saved !");
                    });
                    
                    
                    //Sending Message
                    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
                    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                    
                    
                    [tempDic setObject:[NSString stringWithFormat:@"%@%@iOS",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],dateStr] forKey:@"message_id"];
                    [tempDic setObject:@"" forKey:@"message"];
                    [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey:@"sender_id"];
                    [tempDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey: @"name"] forKey:@"sender_name"];
                    [tempDic setObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"profile_picture"] forKey:@"sender_image_thumb"];
                    //MARK:- changes here
                    //[tempDic setObject:[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] objectForKey: @"user_image_thumb"] forKey:@"sender_image_thumb"];
                    
                    if([prevDataDic valueForKey:@"group_id"] == nil || [[prevDataDic valueForKey:@"group_id"] isKindOfClass:[NSNull class]] || [[prevDataDic valueForKey:@"group_id"] isEqualToString:@""])
                    {
                        [tempDic setObject:[[self prevDataDic] objectForKey: @"user_id"] forKey:@"receiver_id"];
                        [tempDic setObject: [NSNull null] forKey:@"group_id"];
                        [tempDic setObject: @"" forKey:@"group_type"];
                    }
                    else
                    {
                        [tempDic setObject: [[self prevDataDic] objectForKey: @"group_id"] forKey:@"group_id"];
                        [tempDic setObject: @"Normal" forKey:@"group_type"];
                        [tempDic setObject: [NSNull null] forKey:@"receiver_id"];
                    }
                    //[tempDic setObject: [NSNull null] forKey:@"group_id"];
                    [tempDic setObject: [tempDataDic objectForKey: @"info"] forKey:@"attachment_type"];
                    [tempDic setObject: [tempDataDic objectForKey: @"upload_path"] forKey:@"attachment"];
                    [tempDic setObject: @"unread" forKey:@"read_status"];
                    [tempDic setObject:@"awaiting" forKey:@"delivery_status"];
                    [tempDic setObject: @"" forKey:@"deleted_at"];
                    [tempDic setObject: [tempDataDic objectForKey: @"filesize"] forKey:@"filesize"];
                    [tempDic setObject: deleteAfterSecondValue forKey:@"delete_after"];
                    [tempDic setObject: [tempDataDic objectForKey: @"thumb_name"] forKey:@"thumb_name"];
                    [tempDic setObject: duration forKey:@"duration"];
                    
                    [tempDic setObject: @"1" forKey:@"progressive"];
                    
                    NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
                    [dateFormatter setTimeZone:localTimeZone];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [tempDic setObject: [dateFormatter stringFromDate:[NSDate date]] forKey:@"created_at"];
                    
                    [[appDelegate socketManager] sendMessage:tempDic];
                    [self resetDeleteAfterTime];
                    
                    //                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    //                    NSString *dateStr2 = [dateFormatter stringFromDate:[NSDate date]];
                    //                    NSDate *date2 = [dateFormatter dateFromString:dateStr2];
                    //
                    //                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    //
                    //                    if(![dateArray containsObject:date2])
                    //                    {
                    //                        [dic setObject:date2 forKey:@"date"];
                    //                        [dateArray addObject:date2];
                    //                        [dic setObject:[[NSArray alloc] initWithObjects:tempDic, nil] forKey:@"messages"];
                    //
                    //                        [chatArray addObject:dic];
                    //                    }
                    //                    else
                    //                    {
                    //                        dic = [chatArray objectAtIndex:[chatArray count] - 1];
                    //
                    //                        NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
                    //                        [tempMessageArr addObjectsFromArray:[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"]];
                    //                        [tempMessageArr addObject:tempDic];
                    //
                    //                        [dic setObject:tempMessageArr forKey:@"messages"];
                    //
                    //                        [chatArray replaceObjectAtIndex:[chatArray count] - 1 withObject:dic];
                    //                    }
                    //
                    //
                    //                    if(![deleteAfterSecondValue isEqualToString:@""] && DeleteMessageTimer.isValid == false)
                    //                    {
                    //                        DeleteMessageTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getExpireMessage) userInfo:nil repeats:YES];
                    //
                    //                    }
                    //
                    //
                    //                    [self.tableView reloadData];
                    
                    
                    
                    //                    NSIndexPath *myIP = [NSIndexPath indexPathForRow:[[[chatArray objectAtIndex:[chatArray count] - 1] objectForKey:@"messages"] count] - 1 inSection:[chatArray count] - 1] ;
                    //
                    //                    [self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionBottom animated:true];
                    //
                    //                    [self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionBottom animated:true];
                    
                    
                }
                else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
                {
                    [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                        {
                            NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                            [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                            
                            [self uploadDocument:doc withThumbnailImage:thumb withFileName:fileName forType:type withDuration:duration];
                        }
                    } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"message"]];
                    }];
                }
                else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"402"])
                {
                    [appDelegate.constant logoutFromApp];
                }
                
            }
            else
            {
                [SVProgressHUD showErrorWithStatus: [responseObject valueForKey:@"message"]];
            }
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
     //       [SVProgressHUD showErrorWithStatus: @"Please try again. (upload document)"];
        }];
        
    }
}


-(void) deleteChatFromChatList:(NSString *)deleteMessages
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
        // [params setObject: @"English" forKey: @"language"];
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        //[params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"location_id"] forKey: @"location_id"];
        
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        
        if([[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]] isEqualToString: @""])
        {
            
            tempArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_chat_list" forKeys:[[NSArray alloc] initWithObjects:@"id", nil] andWhere:[NSString stringWithFormat:@"user_id = %@ AND connected_user_id = %@",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[self prevDataDic] objectForKey: @"user_id"]]] mutableCopy];
        }
        else
        {
            tempArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_chat_list" forKeys:[[NSArray alloc] initWithObjects:@"id", nil] andWhere:[NSString stringWithFormat:@"group_id = %@",[[self prevDataDic] objectForKey: @"group_id"]]] mutableCopy];
            
        }
        
        
        
        NSString *chatID = @"";
        
        if([tempArr count] > 0)
        {
            chatID = [NSString stringWithFormat:@"%@",[[tempArr objectAtIndex:0] objectForKey: @"id"]];
        }
        else
        {
            [SVProgressHUD dismiss];
            return;
        }
        
        //        if([chatID isEqualToString:@""] && [prevDataDic valueForKey:@"id"] != nil)
        //        {
        //            return;
        //            //[params setObject: [prevDataDic valueForKey:@"id"] forKey: @"chat_id"];
        //        }
        //        else
        //        {
        [params setObject: chatID forKey: @"chat_id"];
        //        }
        
        [params setObject:deleteMessages  forKey: @"only_message"];
        
        [webConnector deleteChatFromChatList: params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                [SVProgressHUD dismiss];
                
                
                if([[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]] isEqualToString: @""])
                {
                    [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"(`receiver_id` = '%@' OR `sender_id` = '%@') AND (`receiver_id` = '%@' OR `sender_id` = '%@') AND group_id = \"\"",[prevDataDic valueForKey:@"user_id"],[prevDataDic valueForKey:@"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
                }
                else
                {
                    [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"group_id = \"%@\"",[[self prevDataDic] objectForKey: @"group_id"]]];
                    
                }
                
                
                if([deleteMessages isEqualToString:@"N"])
                {
                    [appDelegate.generalFunction Delete_Record_From:@"mds_chat_list" where:[NSString stringWithFormat:@"id = \"%@\"",[prevDataDic valueForKey:@"id"]]];
                    [[self navigationController] popViewControllerAnimated:true];
                    
                }
                else
                {
                    
                    [chatArray removeAllObjects];
                    [dateArray removeAllObjects];
                    
                    
                    [tableView reloadData];
                }
                
                offset = 0;
                
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self deleteChatFromChatList:deleteMessages];
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
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
     //       [SVProgressHUD showErrorWithStatus: @"Please try again. (delete chat from chatlist)"];
            
        }];
    }
}

//MARK:- FileSize
- (id)transformedValue:(long long)value
{
    
    double convertedValue = value;
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
}


//MARK:- Delete chat

-(void) getExpireMessage
{
    
    NSMutableArray *deleteExpireMessageArray = [[NSMutableArray alloc] init];
    
    
    if([[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"group_id"]] isEqualToString: @""])
    {
        
        deleteExpireMessageArray = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_messages" forKeys:tempKeyArr andWhere:[NSString stringWithFormat:@"(`receiver_id` = '%@' OR `sender_id` = '%@') AND (`receiver_id` = '%@' OR `sender_id` = '%@') AND group_id = \"\" AND (delete_after != \"\" AND delete_after != '0')",[prevDataDic objectForKey:@"user_id"],[prevDataDic objectForKey:@"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]] mutableCopy];
        
    }
    else
    {
        deleteExpireMessageArray = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_messages" forKeys:tempKeyArr andWhere:[NSString stringWithFormat:@"group_id = %@ AND (delete_after != \"\" AND delete_after != '0')",[[self prevDataDic] objectForKey: @"group_id"]]] mutableCopy];
        
    }
    
    // NSLog(@"this is the variable value: %d",deleteExpireMessageArray);
    
    if ([deleteExpireMessageArray count] == 0)
    {
        [DeleteMessageTimer invalidate];
        return;
    }
    
    for (int k = 0; k < [deleteExpireMessageArray count]; k++)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];;
        
        NSString *timeString = [[deleteExpireMessageArray objectAtIndex:k] objectForKey:@"read_at"];
        
        if([timeString isEqualToString:@""])
        {
            [self readAllMessages];
        }
        
        NSDate *tempDateWithSec = [[NSDate alloc] init];
        
        tempDateWithSec = [dateFormatter dateFromString:timeString];
        
        if(tempDateWithSec == nil)
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            tempDateWithSec = [dateFormatter dateFromString:timeString];
        }
        
        NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:tempDateWithSec];
        
        if (secs > [[[deleteExpireMessageArray objectAtIndex:k] objectForKey:@"delete_after"] floatValue])
        {
            [appDelegate.generalFunction Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"message_id = '%@'",[[deleteExpireMessageArray objectAtIndex:k] objectForKey:@"message_id"]]];
            
            
            for(int i = 0;i < [chatArray count]; i++)
            {
                for(int j = 0;j < [[[chatArray objectAtIndex:i] valueForKey:@"messages"] count]; j++)
                {
                    if([[NSString stringWithFormat:@"%@",[[[[chatArray objectAtIndex:i] valueForKey:@"messages"] objectAtIndex:j] valueForKey:@"message_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[deleteExpireMessageArray objectAtIndex:k] objectForKey:@"message_id"]]])
                    {
                        
                        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                        
                        tempArr = [[chatArray objectAtIndex:i] valueForKey:@"messages"];
                        
                        if([tempArr count] > 1)
                        {
                            [tempArr removeObjectAtIndex:j];
                            [[chatArray objectAtIndex:i] setObject:tempArr forKey:@"messages"];
                        }
                        else
                        {
                            [chatArray removeAllObjects];
                        }
                        
                        offset = offset - 1;
                        
                        [tableView reloadData];
                        break;
                    }
                }
            }
            
            
        }
    }
    
}

//MARK:- Export
-(IBAction)exportButtonClicked:(UIButton*)sender
{
    
    topOptionMenu.hidden = true;
    [[self view] endEditing:true];
    
    NSMutableArray *array1 = [appDelegate.generalFunction getWholeChat:[NSString stringWithFormat:@"%@",[[self prevDataDic] objectForKey: @"user_id"]] orWithGroup:[[self prevDataDic] objectForKey: @"group_id"]];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    array = [array1 mutableCopy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.AMSymbol = @"AM";
    dateFormatter.PMSymbol = @"PM";
    [dateFormatter setDateFormat:@"dd-MMM-yyyy hh-mm-ssa"];
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *text = [NSString stringWithFormat:@"MDS Export - CHAT as at %@\n\n",date];
    
    //NSString *header_message = @"mds Export\n\n";
    //w
    // by @ Andriod at 5:12PM 13-Sep-17
    
    for(int i = 0;i< [array count];i++)
    {
        
        NSString *user_name = [[array objectAtIndex:i] valueForKey:@"sender_name"];
        NSString *message = [[array objectAtIndex:i] valueForKey:@"message"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone* TimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
        [dateFormatter setTimeZone:TimeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *tempDateWithSec = [dateFormatter dateFromString:[[array objectAtIndex:i] valueForKey:@"created_at"]];
        
        [dateFormatter setDateFormat:@"hh:mma dd-MMM-yy"];
        
        NSString *time = [dateFormatter stringFromDate:tempDateWithSec];
        
        
        //        if ([text isEqualToString:@""])
        //
        //        {
        if ([[[array objectAtIndex:i] objectForKey:@"attachment_type"] isEqualToString:@""])
        {
            message = [message stringByReplacingOccurrencesOfString:@"\n " withString:@" "];
            message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            
            //text = [NSString stringWithFormat:@"%@%@: %@ %@\n\n",text,user_name,message,time];
            text = [NSString stringWithFormat:@"%@%@\n by @ %@ at %@\n\n",text,message,user_name,time];
            
        }
        else
        {
            NSString *filePath = [NSString stringWithFormat:@"%@%@",imageBaseURL,[[array objectAtIndex:i] valueForKey:@"attachment"]];
            // text = [NSString stringWithFormat:@"%@%@: (file link) %@ %@\n\n",text,user_name,filePath,time];
            text = [NSString stringWithFormat:@"%@(file link) %@\n by @ %@ at %@\n\n",text,filePath,user_name,time];
            
        }
        
        //        }
        
        //        else
        //        {
        //
        //            if ([[[array objectAtIndex:i] objectForKey:@"attachment_type"] isEqualToString:@""])
        //            {
        //                message = [message stringByReplacingOccurrencesOfString:@"\n " withString:@" "];
        //                message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        //
        //                 text = [NSString stringWithFormat:@"%@%@: %@ %@\n\n",text,user_name,message,time];
        //
        //            }
        //            else
        //            {
        //
        //
        //                NSString *filePath = [NSString stringWithFormat:@"%@%@",appDel.BaseURL,[[array objectAtIndex:i] valueForKey:@"attachment"]];
        //                text = [NSString stringWithFormat:@"%@%@: (file link) %@ %@\n\n",text,user_name,filePath,time];
        //
        //            }
        //
        //        }
        
    }
    
    text = [NSString stringWithFormat:@"%@\nEnd of export",text];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        
        
        
        //SAVING FILE
        //get the documents directory:
        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        NSString *fileName = [NSString stringWithFormat:@"%@/MDS_Export.txt",
                              documentsDirectory];
        //save content to the documents directory
        
        NSError *error;
        
        BOOL success = [text writeToFile:fileName
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if(success == true)
            {
                //SENDING EMAIL
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.AMSymbol = @"AM";
                dateFormatter.PMSymbol = @"PM";
                [dateFormatter setDateFormat:@"dd_MMM-yyyy_hh_mm_ss_a"];
                
                NSString *date = [dateFormatter stringFromDate:[NSDate date]];
                
                NSData *myData = [NSData dataWithContentsOfFile: fileName];
                
                MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                
                if(mc != nil)
                {
                    mc.mailComposeDelegate = self;
                    [mc setSubject: [NSString stringWithFormat:@"MDS_CHAT_Export__as_at_%@",date]];
                    //[mc setMessageBody:@"" isHTML:NO];
                    [mc addAttachmentData:myData mimeType:@"application/txt" fileName:@"MDS_Export.txt"];
                    
                    //  [mc setToRecipients:[NSArray arrayWithObject:@""]];
                    [self presentViewController:mc animated:YES completion:NULL];
                    
                }
            }
        });
    });
}



//MARK:- MAIL
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

@end
