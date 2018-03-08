//
//  SocketIOManger.m
//  mds
//
//  Created by SS-181 on 6/27/17.
//

#import "SocketIOManger.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "CryptLib.h"
@import SocketIO;

@interface SocketIOManger ()

@end
@implementation SocketIOManger

@synthesize sharedInstance,socket;

- (id)init
{
    self = [super init];
    if (self != nil) {
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkSocketStatus) name: @"SocketDisconnected" object: nil];
        
        NSURL* url = [[NSURL alloc] initWithString:@"http://203.175.166.19:5002"]; //production
        
        
        //        NSURL* url = [[NSURL alloc] initWithString:@"http://103.15.232.35:5002"]; //stagging
        //NSURL* url = [[NSURL alloc] initWithString:@"http://115.249.91.204:8081"]; //develop url
        //NSURL* url = [[NSURL alloc] initWithString:@"http://192.168.5.101:8081"]; //local url
        socket = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
        
        [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"socket connected");
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] != nil )
            {
                [self addUserMethod];
            }
        }];
    }
    return self;
}

//MARK:- Socket Function
-(void) establishConnection
{
    [socket connect];
}

-(void) closeConnection
{
    [socket disconnect];
}

-(BOOL) socketIsConnected
{
    SocketIOClientStatus status = SocketIOClientStatusConnected;
    
    if (status == 3)
    {
        return true;
    }
    
    return false;
}

// Fire Events
-(void)sendMessage:(NSMutableDictionary *)dataDic
{
    //INSERTING RAW MSG
    NSArray *tempKeyArr = [[NSArray alloc] initWithObjects:@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
    
    NSArray *tempValuesArr = [[NSArray alloc] initWithObjects:[dataDic mutableCopy], nil];
    
    [appDelegate.generalFunction insertDataIntoTable:@"mds_messages" forKeys:tempKeyArr Values:tempValuesArr];
    
    //Offline chat list
    NSArray *tempKeyArr2 = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"connected_user_id",@"group_id",@"last_message_time",@"favorite",@"most_priority", nil];
    
    NSMutableArray *chatlistCount = [[NSMutableArray alloc] init];
    
    chatlistCount = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_chat_list" forKeys:tempKeyArr2 andWhere:[NSString stringWithFormat:@"connected_user_id = \"%@\" AND user_id = \"%@\" AND group_id = \"\"",[dataDic objectForKey:@"receiver_id"],[dataDic objectForKey:@"sender_id"]]] mutableCopy];
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    if([chatlistCount count] == 0 && ([[dataDic objectForKey:@"group_type"] isKindOfClass:[NSNull class]] || ![[dataDic objectForKey:@"group_type"] isEqualToString:@"broadcast"]))
    {
        
        [self getChatList];
        [tempDic setObject:[dataDic objectForKey:@"sender_id"] forKey:@"user_id"];
        [tempDic setObject:[dataDic objectForKey:@"receiver_id"] forKey:@"connected_user_id"];
        [tempDic setObject:[dataDic objectForKey:@"created_at"] forKey:@"last_message_time"];
        
        [appDelegate.generalFunction insertDataIntoTable:@"mds_chat_list" forKeys:tempKeyArr2 Values:[[NSArray alloc] initWithObjects:tempDic, nil]];
    }
    else
    {
        // [appDelegate.generalFunction insertDataIntoTable:@"mds_chat_list" forKeys:tempKeyArr2 Values:[[NSArray alloc] initWithObjects:tempDic, nil]];
    }
    
    
    //Sending Message
    NSData *data = [[dataDic objectForKey:@"message" ] dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *UTF8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [dataDic setObject:[appDelegate.constant generateMessage:UTF8String] forKey:@"message"];
    
    
    [self checkSocketStatus];
    
    [socket emit:@"chat.send.message" with:@[dataDic]];
    NSLog(@"chat.send.message =========== %@", [dataDic valueForKey:@"message"]);
}

-(void)messageDelivered:(NSString *)ID withGroupID:(NSString *)groupID
{
    [self checkSocketStatus];
    
    [socket emit:@"chat.message.delivered" with:@[@{@"sender_id": ID,@"receiver_id":[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],@"group_id": groupID}]];
}


-(void)readMesage:(NSString *)ID  withGroupID:(NSString *)groupID
{
    
    [self checkSocketStatus];
    
    OnAckCallback *callback =  [socket emitWithAck:@"chat.message.read" with:@[@{@"sender_id": ID,@"receiver_id":[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],@"group_id": groupID}]];
    
    [callback timingOutAfter:0 callback:^(NSArray* data) {
        
        //NSLog(@"%@",data);
        
        //        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        //        [dic setValue:@"read" forKey:@"read_status"];
        //        [dic setValue:[data[0] objectForKey:@"time"] forKey:@"read_at"];
        //
        //        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"read_status",@"read_at", nil];
        //
        //        if([groupID isEqualToString:@""])
        //        {
        //            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"sender_id = '%@' AND receiver_id = '%@' AND read_at = ''",ID,[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
        //        }
        //        else
        //        {
        //            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:dic, nil] andWhere:[NSString stringWithFormat:@"group_id = '%@' AND sender_id != '%@' AND read_at = ''",groupID,[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]]];
        //        }
        
    }];
    
    
}

-(void)typing:(NSString *)recieverID
{
    [self checkSocketStatus];
    
    [socket emit:@"chat.typing" with:@[@{@"sender_id":[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],@"receiver_id": recieverID,@"sender_name": [[NSUserDefaults standardUserDefaults] objectForKey: @"name"]}]];
}

-(void)groupTyping:(NSMutableDictionary *)dataDic
{
    [self checkSocketStatus];
    
    [socket emit:@"chat.group.typing" with:@[@{@"sender_id": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],@"group_id": @"130",@"group_name": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_name"]}]];
}

-(void)chatGroupUpdate:(NSString *)groupID
{
    [self checkSocketStatus];
    
    [socket emit:@"chat.group.update.action" with:@[@{@"group_id": groupID,@"sender_id": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]}]];
}

-(void)chatGroupDeleteUpdate:(NSString *)deleteToID forGroupID:(NSString *)groupID
{
    [self checkSocketStatus];
    
    [socket emit:@"chat.group.delete.member.action" with:@[@{@"group_id":groupID,@"delete_to": deleteToID,@"for":@"delete",@"sender_id": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]}]];
}

-(void)getAdminGroupID
{
    [self checkSocketStatus];
    
    OnAckCallback *callback =  [socket emitWithAck:@"cwa" with:@[@{@"user_id": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]}]];
    
    [callback timingOutAfter:0 callback:^(NSArray* data)
     {
         NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
         for(id key in data[0])
         {
             if([[data[0] valueForKey:key] isKindOfClass:[NSNull class]])
             {
                 [dic setValue:@"" forKey:key];
             }
             else
             {
                 [dic setValue:[data[0] valueForKey:key] forKey:key];
             }
         }
         
         [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"adminGrouInfo"];
     }];
}

-(void)checkSocketStatus
{
    if(socket.status == 0)
    {
        NSLog(@"SOCKET STATUS: notConnected");
    }
    else if(socket.status == 1)
    {
        NSLog(@"SOCKET STATUS: disconnected");
    }
    else if(socket.status == 2)
    {
        NSLog(@"SOCKET STATUS: connecting");
    }
    else
    {
        NSLog(@"SOCKET STATUS: connected");
    }
    
    if(socket.status == SocketIOClientStatusDisconnected || socket.status == SocketIOClientStatusNotConnected)
    {
        [self establishConnection];
    }
}

//MARK:- Events
-(void) addUserMethod
{
    
    // [socket emit:@"join" with:@[@{@"name": [[NSUserDefaults standardUserDefaults] objectForKey: @"name"],@"id": [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]}]];
    
    OnAckCallback *callback = [socket emitWithAck:@"join" with:@[@{@"name": [NSString stringWithFormat:@"%@ %@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"],[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"last_name"]],@"id": [[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]}]];
    
    [callback timingOutAfter:0 callback:^(NSArray* data) {
        
        
        [self addEventListeners];
        
        //        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        //        dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        [self getChatList];
        [self getNewData];
        
        [self getMessageStatus];
        //[self getAdminGroupID];
        
        //GET ALL UNREAD MSG
        NSMutableArray *tempArr =  [[NSMutableArray alloc] init];
        tempArr = [appDelegate.generalFunction getAllUndeliveredMSG];
        
        for(int i=0;i<[tempArr count]; i++)
        {
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            tempDic = [[tempArr objectAtIndex:i] mutableCopy];
            
            //[NSString stringWithFormat:@"%@ %@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"],[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"last_name"]]
            
            [tempDic setObject:[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"] forKey:@"sender_id"];
            [tempDic setObject:[NSString stringWithFormat:@"%@ %@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"first_name"],[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"last_name"]] forKey:@"sender_name"];
            
            
            
            //MARK:- changes here
            // [tempDic setObject:[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] objectForKey: @"user_image_thumb"] forKey:@"sender_image_thumb"];
            
            [self sendMessage:tempDic];
        }
        
        //});
        
    }];
    
    
}

-(void)getNewData
{
    [self checkSocketStatus];
    
    [socket emit:@"data.not_stored" with:@[@{@"user_id": [[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"],@"mid": [NSString stringWithFormat:@"%@",[[[appDelegate.generalFunction getBiggestMID] objectAtIndex:0] objectForKey:@"mid"]]}]];
}

-(void)getChatList
{
    [self checkSocketStatus];
    
    [self getGroupData];
    [self getGroupMembersData];
    [socket emit:@"data.not_stored_chat_list" with:@[@{@"user_id": [[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]}]];
}

-(void)getGroupData
{
    [self checkSocketStatus];
    
    OnAckCallback *callback =  [socket emitWithAck:@"chat.group.data" with:@[@{@"user_id":[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]}]];
    
    [callback timingOutAfter:0 callback:^(NSArray* data) {
        
        [appDelegate.generalFunction Delete_All_Records_From:@"mds_groups"];
        NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"group_name",@"group_icon",@"user_id",@"created_at",@"updated_at",@"deleted_at",@"group_type", nil];
        NSMutableArray *arr = [data[0] mutableCopy];
        for(int i=0;i<[arr count];i++)
        {
            NSMutableDictionary *dic = [[arr objectAtIndex:i] mutableCopy];
            if([appDelegate.constant UTF8Message:[dic valueForKey:@"group_name"]] != nil)
            {
                 [dic setObject:[appDelegate.constant UTF8Message:[dic valueForKey:@"group_name"]] forKey:@"group_name"];
                  [arr replaceObjectAtIndex:i withObject:dic];
            }

        }
        
       // [appDelegate.constant UTF8Message:decryptedString]
        
        [appDelegate.generalFunction insertDataIntoTable:@"mds_groups" forKeys:keys Values:arr];
        
    }];
}

-(void)getGroupMembersData
{
    [self checkSocketStatus];
    
    OnAckCallback *callback =  [socket emitWithAck:@"chat.group.member.data" with:@[@{@"user_id":[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]}]];
    
    [callback timingOutAfter:0 callback:^(NSArray* data) {
        
        [appDelegate.generalFunction Delete_All_Records_From:@"mds_group_members"];
        
        NSArray *keysForGroupMembers = [[NSArray alloc] initWithObjects:@"group_id",@"user_id",@"is_admin",@"created_at",@"created_by", nil];
        
        [appDelegate.generalFunction insertDataIntoTable:@"mds_group_members" forKeys:keysForGroupMembers Values:data[0]];
        
    }];
    
    
}


-(void)getMessageStatus
{
    [self checkSocketStatus];
    
    NSMutableArray *tempArr =  [appDelegate.generalFunction getAllIncompleteStatusMSG];
    
    if([tempArr count] > 0)
    {
        [socket emit:@"chat.message.status" with:@[@{@"user_id": [[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"],@"mid":tempArr}]];
    }
}




-(void) addEventListeners
{
    
    [socket on:[NSString stringWithFormat:@"chat.new.message.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"NEW MESSAGE");
        // NSLog(@"%@", [NSString stringWithFormat:@"%@",[data objectAtIndex:0]]);
        NSLog([[data objectAtIndex:0] isKindOfClass:[NSString class]] ? @"Yes" : @"No");
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:objectData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&jsonError];
        NSMutableDictionary *json =  [[NSMutableDictionary alloc] init];
        json = [jsonDic mutableCopy];
        
        NSString *rawString = [json valueForKey:@"message"];
        
        NSArray *messageArr = [appDelegate.constant getMessageAndIV:rawString];
        
        
        NSString *decryptedString = [appDelegate.cryptoLib decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
        
        //NSLog(@"%@",decryptedString);
        
        if(decryptedString != nil && ![decryptedString isEqualToString:@""])
        {
            [json setValue:[appDelegate.constant UTF8Message:decryptedString] forKey:@"message"];
            //[json setValue:decryptedString forKey:@"message"];
        }
        else
        {
            [json setValue:@"" forKey:@"message"];
        }
        
        if([[json objectForKey:@"filesize"] isKindOfClass:[NSNull class]])
        {
            [json setValue:@"" forKey:@"filesize"];
        }
        
        if(![[NSString stringWithFormat:@"%@",[json valueForKey:@"sender_id"]] isEqualToString: [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]]])
        {
            [json setValue:@"delivered" forKey:@"delivery_status"];
            [json setValue:@"unread" forKey:@"read_status"];
            [self messageDelivered:[json objectForKey:@"sender_id"] withGroupID:[json objectForKey:@"group_id"]];
        }
        
        
        NSArray *tempKeyArr = [[NSArray alloc] initWithObjects:@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
        
        [appDelegate.generalFunction insertDataIntoTable:@"mds_messages" forKeys:tempKeyArr Values:[[NSArray alloc] initWithObjects:json, nil]];
        
        [self getMessageStatus];
        [self playNewMsgSound];
        [self getChatList];
                NSArray *contactstempKeyArr = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time",@"user_color", nil];
        
        NSMutableArray *DBValueArr = [[NSMutableArray alloc] init];
        
        
        DBValueArr = [[appDelegate.generalFunction getAllWhereValuesInTable:@"mds_users" forKeys:contactstempKeyArr andWhere:[NSString stringWithFormat:@"user_id = '%@'",[json valueForKey:@"user_id"]]] mutableCopy];
        
        if([DBValueArr count] > 0)
        {
            // [appDelegate.generalFunction updateTable:@"mds_users" forKeys:[[NSArray alloc] initWithObjects:@"user_id",@"name",@"user_name",@"mobile",@"user_image",@"last_login_time", nil] setValue:[[NSArray alloc] initWithObjects:json, nil] andWhere:[NSString stringWithFormat:@"user_id = '%@'",[json valueForKey:@"user_id"]]];
        }
        else
        {
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            [tempDic setValue:[json valueForKey:@"sender_id"] forKey:@"id"];
            [tempDic setValue:[json valueForKey:@"sender_id"] forKey:@"user_id"];
            [tempDic setValue:[json valueForKey:@"sender_name"] forKey:@"first_name"];
            [tempDic setValue:[json valueForKey:@"sender_image_thumb"] forKey:@"profile_picture"];
            [tempDic setValue:@"F8BBD0" forKey:@"user_color"];
            [appDelegate.generalFunction insertDataIntoTable:@"mds_users" forKeys:contactstempKeyArr Values:[[NSArray alloc] initWithObjects:tempDic, nil]];
        }
        
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.message.read.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"read_status",@"read_at", nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"read" forKey:@"read_status"];
        
        if([json objectForKey:@"group_id"] != nil)
        {
            [dic setObject:[json objectForKey:@"group_id"] forKey:@"group_id"];
        }
        else
        {
            [dic setObject:[json objectForKey:@"receiver_id"] forKey:@"receiver_id"];
        }
        
        if([json objectForKey:@"read_at"] != nil)
        {
            [dic setObject:[json objectForKey:@"read_at"] forKey:@"read_at"];
        }
        
        //NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
        
        //[appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"receiver_id = '%@'",[json objectForKey:@"receiver_id"]]];
        
        for(int i= 0;i<[[json objectForKey:@"message"] count]; i++)
        {
            [dic setObject:[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] forKey:@"message_id"];
            NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"message_id = '%@'",[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] ]];
        }
        
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.message.delivered.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"MESSAGE DELIVERED");
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"delivery_status", nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"delivered" forKey:@"delivery_status"];
        if([json objectForKey:@"group_id"] != nil)
        {
            [dic setObject:[json objectForKey:@"group_id"] forKey:@"group_id"];
        }
        else
        {
            [dic setObject:[json objectForKey:@"receiver_id"] forKey:@"receiver_id"];
        }
        
        for(int i= 0;i<[[json objectForKey:@"message"] count]; i++)
        {
            [dic setObject:[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] forKey:@"message_id"];
            NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
            
            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"message_id = '%@'",[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] ]];
        }
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.group.message.delivered.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"GROUP MESSAGE DELIVERED");
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"delivery_status", nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"delivered" forKey:@"delivery_status"];
        if([json objectForKey:@"group_id"] != nil)
        {
            [dic setObject:[json objectForKey:@"group_id"] forKey:@"group_id"];
        }
        else
        {
            [dic setObject:[json objectForKey:@"receiver_id"] forKey:@"receiver_id"];
        }
        
        for(int i= 0;i<[[json objectForKey:@"message"] count]; i++)
        {
            [dic setObject:[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] forKey:@"message_id"];
            NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
            
            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"message_id = '%@'",[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] ]];
        }
        
        
        
    }];
    
    [socket on:[NSString stringWithFormat:@"cchat.group.message.read.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"GROUP MESSAGE READ");
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"read_status",@"read_at", nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"read" forKey:@"read_status"];
        
        if([json objectForKey:@"group_id"] != nil)
        {
            [dic setObject:[json objectForKey:@"group_id"] forKey:@"group_id"];
        }
        else
        {
            [dic setObject:[json objectForKey:@"receiver_id"] forKey:@"receiver_id"];
        }
        
        if([json objectForKey:@"read_at"] != nil)
        {
            [dic setObject:[json objectForKey:@"read_at"] forKey:@"read_at"];
        }
        
        //NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
        
        //[appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"receiver_id = '%@'",[json objectForKey:@"receiver_id"]]];
        
        for(int i= 0;i<[[json objectForKey:@"message"] count]; i++)
        {
            [dic setObject:[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] forKey:@"message_id"];
            NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"message_id = '%@'",[[[json objectForKey:@"message"] objectAtIndex:i] objectForKey:@"message_id"] ]];
        }
        
        
        
    }];
    
    
    [socket on:[NSString stringWithFormat:@"chat.message.insert.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"MESSAGE SAVED!");
        //        NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"mid",@"delivery_status", nil];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[json objectForKey:@"mid"] forKey:@"mid"];
        if([json objectForKey:@"group_id"] != nil)
        {
            [dic setObject:[json objectForKey:@"group_id"] forKey:@"group_id"];
        }
        [dic setObject:[json objectForKey:@"receiver_id"] forKey:@"receiver_id"];
        [dic setObject:[json objectForKey:@"message_id"] forKey:@"message_id"];
        [dic setObject:@"undelivered" forKey:@"delivery_status"];
        NSArray *tempValues = [[NSArray alloc] initWithObjects:dic, nil];
        
        
        [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue:tempValues andWhere:[NSString stringWithFormat:@"message_id = '%@'",[json objectForKey:@"message_id"]]];
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.error.message.sent.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"MESSAGE ERROR");
        NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
    }];
    
    
    
    [socket on:[NSString stringWithFormat:@"chat.not_stored_data.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"NEW DATA");
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSLog(@"Aloo=========%@", [NSString stringWithFormat:@"%@",json]);
        
        
        if([json objectForKey:@"messages"] != nil && [[json objectForKey:@"messages"] isKindOfClass: [NSArray class]] && [[json objectForKey:@"messages"] count] > 0)
        {
            
            for(int i = 0; i< [[json objectForKey:@"messages"] count];i++)
            {
                NSMutableDictionary *tempDic = [[[json valueForKey:@"messages"] objectAtIndex:i] mutableCopy];
                
                NSString *rawString = [tempDic valueForKey:@"message"];
                
                NSArray *messageArr = [appDelegate.constant getMessageAndIV:rawString];
                
                NSString *decryptedString = [appDelegate.cryptoLib decryptCipherTextWith:messageArr[0] key:encryptionKey iv:messageArr[1]];
                
                if(decryptedString != nil && ![decryptedString isEqualToString:@""])
                {
                    [tempDic setValue:[appDelegate.constant UTF8Message:decryptedString] forKey:@"message"];
                    //[tempDic setValue:decryptedString forKey:@"message"];
                }
                else
                {
                    [tempDic setValue:@"" forKey:@"message"];
                }
                //[[json valueForKey:@"messages"] replaceObjectAtIndex:i withObject:tempDic];
                
                  NSArray *tempKeyArr = [[NSArray alloc] initWithObjects:@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
                
                [appDelegate.generalFunction insertDataIntoTable:@"mds_messages" forKeys:tempKeyArr Values:[[NSArray alloc] initWithObjects:tempDic, nil]];
            }
            
//            NSArray *tempKeyArr = [[NSArray alloc] initWithObjects:@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
//
//            [appDelegate.generalFunction insertOrUpdateDataIntoTable:@"mds_messages" forKeys:tempKeyArr Values:[json objectForKey:@"messages"]];
            
            //[self getNewData];
        }
        else
        {
            // [self getChatList];
            NSLog(@"DONE");
        }
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.not_stored_chat_list.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"Chat List");
        // NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",json]);
        
        NSArray *tempKeyArr = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"connected_user_id",@"group_id",@"last_message_time",@"favorite",@"most_priority", nil];
        
        [appDelegate.generalFunction Delete_All_Records_From:@"mds_chat_list"];
        
        
        if ([json objectForKey: @"chat_list"] != nil && [[json objectForKey: @"chat_list"] isKindOfClass:[NSArray class]] && [[json objectForKey: @"chat_list"] count] > 0)
        {
            [appDelegate.generalFunction insertDataIntoTable:@"mds_chat_list" forKeys:tempKeyArr Values:[json objectForKey: @"chat_list"]];
        }
    }];
    
    [socket on:@"chat.online_users" callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        [appDelegate.generalFunction Delete_Record_From:@"mds_chat_list" where:@"id = \"\""];
        
        
        // NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",json]);
        
        [[appDelegate onlineUsersDictionary] removeAllObjects];
        appDelegate.onlineUsersDictionary = [json mutableCopy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"online_users_list" object:nil];
    }];
    
    
    [socket on:[NSString stringWithFormat:@"chat.message.status.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"Message Status");
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",json]);
        
        NSArray *tempKey = [[NSArray alloc] initWithObjects:@"mid",@"message_id",@"sender_id",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after", nil];
        
        for(int i = 0; i < [json count]; i ++)
        {
            [appDelegate.generalFunction updateTable:@"mds_messages" forKeys:tempKey setValue: [[NSArray alloc] initWithObjects:[json objectAtIndex:i], nil] andWhere:[NSString stringWithFormat:@"message_id = '%@'",[[json objectAtIndex:i] objectForKey:@"message_id"]]];
        }
        
        
    }];
    
    
    [socket on:[NSString stringWithFormat:@"chat.typing.r.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        
        NSLog(@"Chat TYPING!!!!!!");
        // NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",json]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"typing" object:json];
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.group.update.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        
        NSLog(@"Group update");
        NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if([json isKindOfClass:[NSDictionary class]] && [json objectForKey:@"for"] != nil && [[json objectForKey:@"for"] isEqualToString:@"delete"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleted" object:json];
        }
        
        //[self getChatList];
        
    }];
    
    [socket on:[NSString stringWithFormat:@"chat.disable.%@",[[[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] valueForKey:@"users_details"] valueForKey:@"user_id"]] callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        
        NSLog(@"YOU ARE BLOCKED!!!!!!");
        //NSLog(@"%@", [NSString stringWithFormat:@"%@",data]);
        
        NSError *jsonError;
        NSData *objectData = [[NSString stringWithFormat:@"%@",[data objectAtIndex:0]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] mutableCopy];
        [dic setValue:@"N" forKey:@"is_chat_enable"];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"userData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self closeConnection];
        
    }];
}

-(void)playNewMsgSound
{
    //    AVAudioSession *session = [AVAudioSession sharedInstance];
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //
    //    /* Use this code to play an audio file */
    //    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"new_Message"  ofType:@"mp3"];
    //    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    //
    //    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    //    player.numberOfLoops = 0; //Just Once
    //
    //    [player prepareToPlay];
    //    [player play];
}

@end
