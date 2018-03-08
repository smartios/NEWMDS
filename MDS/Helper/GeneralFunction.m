//
//  GeneralFunction.m
//  ict
//
//  Created by apple on 1/8/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "GeneralFunction.h"

@implementation GeneralFunction

-(NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSLog(@"File Path of Database = %@",[documentsDir stringByAppendingPathComponent:@"mds.db"]);
    
    
    return [documentsDir stringByAppendingPathComponent:@"mds.db"];
}

-(void)openDB
{
    if (sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK )
    {
        sqlite3_close(db);
    }
}

-(NSString *)addcharecter:(NSString *)inputstring
{
    NSRange range = NSMakeRange(0, [inputstring length]);
    
    return [inputstring stringByReplacingOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:range];
}

//MARK:- mds EMPIRE

//MARK:- GET FUNCTIONS
//code to get job details (question type)
-(NSMutableArray *)getChatList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"read_no",@"unread_no",@"profile_picture",@"last_name", @"first_name",@"user_id",@"email",@"phone",@"last_login_time",@"id",@"favorite",@"last_message",@"sender_id",@"receiver_id", @"last_message_time",@"message_id",@"attachment_type",@"group_id",@"group_name",@"group_icon",@"group_type", nil];
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT read_no, unread_no, uu.profile_picture,uu.last_name, uu.first_name, uu.id as user_id,uu.email,uu.phone, uu.last_login_time,ucl.id as id, ucl.favorite, message as last_message, sender_id, receiver_id, msg.last_message_time, message_id, attachment_type, ucl.group_id, ug.group_name, ug.group_icon, ug.group_type, read_status, custom_unique_key FROM mds_chat_list as ucl LEFT JOIN ( SELECT SUM( CASE WHEN( read_status = 'unread' AND (receiver_id = %@ OR (group_id <> ''  AND sender_id != %@) ) ) THEN 1 ELSE 0 END ) AS unread_no, SUM( CASE WHEN( read_status = 'read' AND (sender_id = %@ OR group_id <> '' ) ) THEN 1 ELSE 0 END ) AS read_no, sender_id, receiver_id, message, created_at as last_message_time, message_id, read_status, attachment_type, group_id, CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END as custom_unique_key FROM `mds_messages` GROUP BY CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END ) as msg ON CASE WHEN ucl.group_id <> '' THEN (msg.group_id = ucl.group_id ) ELSE ((msg.sender_id = %@ OR msg.receiver_id = %@) AND (ucl.connected_user_id = msg.sender_id OR ucl.connected_user_id = msg.receiver_id ) and msg.group_id = '') END LEFT JOIN mds_groups as ug ON ug.id = ucl.group_id LEFT JOIN mds_users as uu ON uu.id = ucl.connected_user_id WHERE ucl.id <> '' AND (ug.group_type <> \"broadcast\" OR ucl.group_id = '') GROUP BY ucl.id order BY msg.last_message_time DESC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    //NSString *qsql = [NSString stringWithFormat:@"SELECT unread_no, read_no,uu.user_image,uu.name,uu.user_id,uu.last_login_time, ucl.id as chat_id,ucl.favorite, um.message,um.sender_id,um.receiver_id,um.created_at,um.message_id,um.attachment_type FROM `mds_chat_list` as ucl LEFT JOIN `mds_users` as uu ON uu.user_id = ucl.connected_user_id LEFT JOIN ( select SUM (CASE WHEN (read_status='unread'  and receiver_id = %@ )THEN 1 ELSE 0 END ) as unread_no, SUM (CASE WHEN (read_status='read' and sender_id = %@) THEN 1 ELSE 0 END ) as read_no, sender_id,receiver_id,message,created_at,message_id,read_status,attachment_type from `mds_messages` GROUP BY sender_id+receiver_id ORDER BY created_at ASC   ) as um ON (ucl.connected_user_id = um.sender_id  AND um.receiver_id = %@ ) OR (ucl.connected_user_id = um.receiver_id  AND um.sender_id = %@ )  where ucl.user_id = %@ AND ucl.connected_user_id != 1 GROUP BY um.sender_id+um.receiver_id  order BY um.created_at DESC", [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    //NSString *qsql = [NSString stringWithFormat:@"SELECT unread_no,read_no,uu.user_image,uu.name,uu.user_id,uu.last_login_time, ucl.id as chat_id,ucl.favorite, um.message,um.sender_id,um.receiver_id,um.created_at,um.message_id,um.attachment_type , ug.id as group_id,ug.group_name, ug.group_icon,ug.group_type FROM `mds_chat_list` as ucl LEFT JOIN `mds_users` as uu ON uu.user_id = ucl.connected_user_id LEFT JOIN ( select SUM (CASE WHEN (read_status='unread'  and receiver_id = %@ )THEN 1 ELSE 0 END ) as unread_no, SUM (CASE WHEN (read_status='read' and sender_id = %@) THEN 1 ELSE 0 END ) as read_no, sender_id,receiver_id,message,created_at,message_id,read_status,attachment_type,group_id from `mds_messages` GROUP BY sender_id+receiver_id ORDER BY created_at ASC) as um ON (ucl.connected_user_id = um.sender_id  AND um.receiver_id = %@ ) OR (ucl.connected_user_id = um.receiver_id  AND um.sender_id = %@ ) OR um.group_id  = ucl.group_id LEFT JOIN `mds_groups` as ug ON ug.id = ucl.group_id where (ucl.user_id = %@ OR ug.id IS NOT NULL ) AND ucl.connected_user_id != 1 GROUP BY ucl. id order BY um.created_at DESC", [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
  //  NSString *qsql = [NSString stringWithFormat:@"SELECT  uu.user_image,uu.name,uu.user_id,uu.last_login_time, ucl.id as chat_id,ucl.favorite, um.message,um.sender_id,um.receiver_id,um.created_at,um.message_id,um.attachment_type , ug.id as group_id,ug.group_name, ug.group_icon,ug.group_type FROM `mds_chat_list` as ucl LEFT JOIN `mds_users` as uu ON uu.user_id = ucl.connected_user_id LEFT JOIN `mds_groups` as ug ON ug.id = ucl.group_id LEFT JOIN `mds_messages` as um ON (CASE WHEN (ucl.group_id != \"\" AND ucl.group_id = ug.id )THEN um.group_id = ug.id ELSE (um.receiver_id = ucl.user_id OR um.sender_id = ucl.user_id) END) WHERE ucl.user_id = \"%@\" GROUP BY ucl.id order BY um.created_at DESC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getGroupChatList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"read_no",@"unread_no",@"profile_picture", @"first_name",@"user_id",@"last_login_time",@"id",@"favorite",@"last_message",@"sender_id",@"receiver_id", @"last_message_time",@"message_id",@"attachment_type",@"group_id",@"group_name",@"group_icon",@"group_type", nil];
    
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT read_no, unread_no, uu.profile_picture, uu.first_name, uu.id as user_id, uu.last_login_time,ucl.id as id, ucl.favorite, message as last_message, sender_id, receiver_id, msg.last_message_time, message_id, attachment_type, ucl.group_id, ug.group_name, ug.group_icon, ug.group_type, read_status, custom_unique_key FROM mds_chat_list as ucl LEFT JOIN ( SELECT SUM( CASE WHEN( read_status = 'unread' AND (receiver_id = %@ OR (group_id <> ''  AND sender_id != %@) ) ) THEN 1 ELSE 0 END ) AS unread_no, SUM( CASE WHEN( read_status = 'read' AND (sender_id = %@ OR group_id <> '' ) ) THEN 1 ELSE 0 END ) AS read_no, sender_id, receiver_id, message, created_at as last_message_time, message_id, read_status, attachment_type, group_id, CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END as custom_unique_key FROM `mds_messages` GROUP BY CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END ) as msg ON CASE WHEN ucl.group_id <> '' THEN (msg.group_id = ucl.group_id ) ELSE ((msg.sender_id = %@ OR msg.receiver_id = %@) AND (ucl.connected_user_id = msg.sender_id OR ucl.connected_user_id = msg.receiver_id )) END LEFT JOIN mds_groups as ug ON ug.id = ucl.group_id LEFT JOIN mds_users as uu ON uu.id = ucl.connected_user_id WHERE ucl.id <> '' AND ucl.group_id <> \"\" AND ug.group_type <> \"broadcast\" GROUP BY ucl.id order BY msg.last_message_time DESC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getAllBroadcastGroups
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"group_id",@"group_name",@"group_icon",@"created_at",@"updated_at",@"deleted_at",@"group_type", nil];
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT id,group_name,group_icon,created_at,updated_at,deleted_at,group_type FROM `mds_groups` WHERE `group_type` = \"broadcast\" AND `user_id` = %@ ORDER BY group_name ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getfavouriteChatList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"read_no",@"unread_no",@"profile_picture", @"first_name",@"user_id",@"last_login_time",@"id",@"favorite",@"last_message",@"sender_id",@"receiver_id", @"last_message_time",@"message_id",@"attachment_type",@"group_id",@"group_name",@"group_icon",@"group_type", nil];
    
    
    //[self openDB];
    
   // NSString *qsql = [NSString stringWithFormat:@"SELECT unread_no, read_no,uu.user_image,uu.name,uu.user_id, ucl.id as chat_id,ucl.favorite, um.message,um.sender_id,um.receiver_id,um.created_at,um.message_id,um.attachment_type FROM `mds_chat_list` as ucl LEFT JOIN `mds_users` as uu ON uu.user_id = ucl.connected_user_id LEFT JOIN ( select SUM (CASE WHEN (read_status='unread'  and receiver_id = %@ )THEN 1 ELSE 0 END ) as unread_no, SUM (CASE WHEN (read_status='read' and sender_id = %@) THEN 1 ELSE 0 END ) as read_no, sender_id,receiver_id,message,created_at,message_id,read_status,attachment_type from `mds_messages` GROUP BY sender_id+receiver_id ORDER BY created_at ASC   ) as um ON (ucl.connected_user_id = um.sender_id  AND um.receiver_id = %@ ) OR (ucl.connected_user_id = um.receiver_id  AND um.sender_id = %@ )  where ucl.user_id = %@ AND ucl.favorite = \"Y\" GROUP BY um.sender_id+um.receiver_id  order BY ucl.last_message_time DESC", [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    // NSString *qsql = [NSString stringWithFormat:@"SELECT read_no, unread_no, uu.user_image, uu.name, uu.id as user_id, uu.last_login_time,ucl.id as id, ucl.favorite, message as last_message, sender_id, receiver_id, msg.last_message_time, message_id, attachment_type, ucl.group_id, ug.group_name, ug.group_icon, ug.group_type, read_status, custom_unique_key FROM mds_chat_list as ucl LEFT JOIN ( SELECT SUM( CASE WHEN( read_status = 'unread' AND (receiver_id = %@ OR group_id <> '' ) ) THEN 1 ELSE 0 END ) AS unread_no, SUM( CASE WHEN( read_status = 'read' AND (sender_id = %@ OR group_id <> '' ) ) THEN 1 ELSE 0 END ) AS read_no, sender_id, receiver_id, message, created_at as last_message_time, message_id, read_status, attachment_type, group_id, CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END as custom_unique_key FROM `mds_messages` GROUP BY CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END ) as msg ON CASE WHEN ucl.group_id <> '' THEN (msg.group_id = ucl.group_id ) ELSE ((msg.sender_id = %@ OR msg.receiver_id = %@) AND (ucl.connected_user_id = msg.sender_id OR ucl.connected_user_id = msg.receiver_id )) END LEFT JOIN mds_groups as ug ON ug.id = ucl.group_id LEFT JOIN mds_users as uu ON uu.id = ucl.connected_user_id WHERE ucl.id <> '' AND ucl.favorite = \"Y\" GROUP BY ucl.id order BY msg.last_message_time DESC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT read_no, unread_no, uu.profile_picture, uu.first_name, uu.id as user_id, uu.last_login_time,ucl.id as id, ucl.favorite, message as last_message, sender_id, receiver_id, msg.last_message_time, message_id, attachment_type, ucl.group_id, ug.group_name, ug.group_icon, ug.group_type, read_status, custom_unique_key FROM mds_chat_list as ucl LEFT JOIN ( SELECT SUM( CASE WHEN( read_status = 'unread' AND (receiver_id = %@ OR (group_id <> ''  AND sender_id != %@) ) ) THEN 1 ELSE 0 END ) AS unread_no, SUM( CASE WHEN( read_status = 'read' AND (sender_id = %@ OR group_id <> '' ) ) THEN 1 ELSE 0 END ) AS read_no, sender_id, receiver_id, message, created_at as last_message_time, message_id, read_status, attachment_type, group_id, CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END as custom_unique_key FROM `mds_messages` GROUP BY CASE WHEN group_id <> '' THEN group_id ELSE sender_id + receiver_id END ) as msg ON CASE WHEN ucl.group_id <> '' THEN (msg.group_id = ucl.group_id ) ELSE ((msg.sender_id = %@ OR msg.receiver_id = %@) AND (ucl.connected_user_id = msg.sender_id OR ucl.connected_user_id = msg.receiver_id ) and msg.group_id = '') END LEFT JOIN mds_groups as ug ON ug.id = ucl.group_id LEFT JOIN mds_users as uu ON uu.id = ucl.connected_user_id WHERE ucl.id <> '' AND (ug.group_type <> \"broadcast\" OR ucl.group_id = '') AND ug.group_type = \"broadcast\" GROUP BY ucl.id order BY msg.last_message_time DESC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getContactList
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time",@"user_color",@"branch_id",@"company_id",@"hq_id",@"user_type", nil];

    NSString *qsql = @"";
    
    //[self openDB];
//    if([[[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"staff_permission"]] lowercaseString] isEqualToString:@"y"] || [[[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"user_type"]] lowercaseString] isEqualToString:@"company-admin"])
//    {
//         qsql = [NSString stringWithFormat:@"SELECT * FROM `mds_users` WHERE user_id != \"%@\" ORDER BY `first_name` COLLATE NOCASE ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
//    }
//    else
//    {
//        //staff hq-admin branch-admin
//        if(![[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"branch_id"] isKindOfClass:[NSNull class]] && ![[[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"branch_id"]] lowercaseString] isEqualToString:@""])
//        {
//             qsql = [NSString stringWithFormat:@"SELECT * FROM `mds_users` WHERE user_id != \"%@\" AND branch_id = \"%@\"  ORDER BY `first_name` COLLATE NOCASE ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"branch_id"]];
//        }
//        else if(![[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"hq_id"] isKindOfClass:[NSNull class]] && ![[[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"hq_id"]] lowercaseString] isEqualToString:@""])
//        {
//            qsql = [NSString stringWithFormat:@"SELECT * FROM `mds_users` WHERE user_id != \"%@\" AND hq_id = \"%@\"  ORDER BY `first_name` COLLATE NOCASE ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"hq_id"]];
//        }
//        else
//        {
            qsql = [NSString stringWithFormat:@"SELECT * FROM `mds_users` WHERE user_id != \"%@\" ORDER BY `first_name` COLLATE NOCASE ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
        //}
       
   // }
   
   
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getGroupRemainingContactList:(NSString *)groupID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time", nil];
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT uu.id, uu.user_id, uu.first_name,uu.last_name, uu.phone, uu.email, uu.profile_picture, uu.last_login_time FROM `mds_users` as uu LEFT JOIN `mds_group_members` as ugm ON ugm.group_id = %@ AND ugm.user_id = uu.user_id WHERE uu.user_id != \"1\" AND uu.user_id != \"%@\" AND ugm.group_id is null GROUP BY uu.user_id ORDER BY `first_name` COLLATE NOCASE ASC",groupID,[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getSearchedContact:(NSString *)searchString
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"unread_no",@"read_no",@"user_id",@"last_name",@"first_name",@"phone",@"profile_picture",@"chat_id",@"favorite",@"last_message",@"attachment_type",@"last_message_time",@"last_message_time", nil];
    
    
    
    //[self openDB];
    
    //NSString *qsql = [NSString stringWithFormat:@"uu.user_id, uu.name, uu.mobile,uu.user_image, ucl.id, ucl.favorite,ucl.last_message_time, um.message FROM `mds_users` as uu LEFT JOIN `mds_chat_list` as ucl ON  ucl.connected_user_id = uu.user_id LEFT JOIN `mds_messages` as um ON (um.sender_id = uu.user_id OR um.receiver_id =  uu.user_id) WHERE user_id != \"1\" AND user_id != \"%@\" AND name LIKE \"%%%@%%\" GROUP BY uu.user_id ORDER BY `name` COLLATE NOCASE ASC",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],searchString];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT unread_no,read_no,uu.user_id,uu.last_name, uu.first_name, uu.phone,uu.profile_picture, ucl.id, ucl.favorite, um.message, um.attachment_type,um.created_at as last_message_time FROM `mds_users` as uu LEFT JOIN `mds_chat_list` as ucl ON ucl.connected_user_id = uu.user_id LEFT JOIN ( SELECT SUM( CASE WHEN( read_status = 'unread' AND receiver_id = %@ ) THEN 1 ELSE 0 END ) AS unread_no, SUM( CASE WHEN( read_status = 'read' AND sender_id = %@ ) THEN 1 ELSE 0 END ) AS read_no, sender_id, receiver_id, message, created_at, message_id, read_status, attachment_type FROM `mds_messages` WHERE group_id ='' and sender_id <> '' and receiver_id <> '' GROUP BY (sender_id + receiver_id) ) as um ON uu.user_id = um.sender_id OR um.receiver_id = uu.user_id WHERE uu.user_id != \"1\" AND uu.user_id <> %@ AND (first_name LIKE \"%%%@%%\" OR last_name LIKE \"%%%@%%\") GROUP BY uu.user_id ORDER BY last_message_time DESC, first_name asc",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],searchString,searchString];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getSearchedMessage:(NSString *)searchString
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"profile_picture",@"first_name",@"user_id",@"group_name",@"group_icon",@"group_type",@"group_id",@"sender_id",@"receiver_id",@"last_message",@"last_message_time",@"message_id",@"read_status",@"attachment_type",@"chat_id",@"favorite", nil];
    
    //[self openDB];
    
    
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT  uu.profile_picture,uu.first_name,uu.user_id,ug.group_name,ug.group_icon,ug.group_type,um.group_id,um.sender_id,um.receiver_id,um.message,um.created_at,um.message_id,um.read_status,um.attachment_type,ucl.id,ucl.favorite from `mds_messages` as um LEFT JOIN `mds_users` as uu ON (CASE WHEN (um.sender_id != \"%@\" )THEN um.sender_id = uu.user_id ELSE um.receiver_id = uu.user_id END ) LEFT JOIN `mds_groups` as ug  ON um.group_id = ug.id LEFT JOIN `mds_chat_list` as ucl ON ucl.group_id = um.group_id  OR (ucl.user_id = uu.user_id OR ucl.connected_user_id = uu.user_id)  WHERE um.message_type != \"action\" AND um.message LIKE \"%%%@%%\" GROUP BY um.message_id",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],searchString];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}



-(NSMutableArray *)getChat:(NSString *)userID orWithGroup:(NSString *)groupID withOffset:(NSInteger)offset
{
    NSMutableArray *array = [[NSMutableArray alloc] init];

    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration",@"sender_image_thumb",@"sender_name",@"sender_color", nil];
    
    //[self openDB];
    
     NSString *qsql = @"";
    
    if([groupID isEqualToString:@""])
    {
        qsql = [NSString stringWithFormat:@"SELECT um.id,um.mid,um.message_id,um.sender_id,um.message,um.attachment,um.attachment_type,um.message_type,um.group_id,um.receiver_id,um.receiver_time,um.read_status,um.read_at,um.delivery_status,um.delivery_time,um.deleted_at,um.created_at,um.filesize,um.delete_after,um.thumb_name,um.duration,uu.profile_picture,uu.first_name,uu.user_color FROM `mds_messages` as um LEFT JOIN `mds_users` as uu ON uu.user_id = um.sender_id WHERE (`receiver_id` = '%@' OR `sender_id` = '%@') AND (`receiver_id` = '%@' OR `sender_id` = '%@') AND `group_id` = ''  ORDER BY `created_at` DESC LIMIT 10 OFFSET %li",userID,userID,[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],(long)offset];
    }
    else
    {
         qsql = [NSString stringWithFormat:@"SELECT um.id,um.mid,um.message_id,um.sender_id,um.message,um.attachment,um.attachment_type,um.message_type,um.group_id,um.receiver_id,um.receiver_time,um.read_status,um.read_at,um.delivery_status,um.delivery_time,um.deleted_at,um.created_at,um.filesize,um.delete_after,um.thumb_name,um.duration,uu.profile_picture,uu.first_name,uu.user_color FROM `mds_messages` as um LEFT JOIN `mds_users` as uu ON uu.user_id = um.sender_id WHERE `group_id` = '%@' ORDER BY `created_at` DESC LIMIT 10 OFFSET %li",groupID,(long)offset];
    }

    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getWholeChat:(NSString *)userID orWithGroup:(NSString *)groupID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration",@"sender_image_thumb",@"sender_name",@"sender_color", nil];
    
    //[self openDB];
    
    NSString *qsql = @"";
    
    if([groupID isEqualToString:@""])
    {
        qsql = [NSString stringWithFormat:@"SELECT um.id,um.mid,um.message_id,um.sender_id,um.message,um.attachment,um.attachment_type,um.message_type,um.group_id,um.receiver_id,um.receiver_time,um.read_status,um.read_at,um.delivery_status,um.delivery_time,um.deleted_at,um.created_at,um.filesize,um.delete_after,um.thumb_name,um.duration,uu.profile_picture,uu.first_name,uu.user_color FROM `mds_messages` as um LEFT JOIN `mds_users` as uu ON uu.user_id = um.sender_id WHERE (`receiver_id` = '%@' OR `sender_id` = '%@') AND (`receiver_id` = '%@' OR `sender_id` = '%@') AND `group_id` = ''  ORDER BY `created_at` DESC",userID,userID,[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"],[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]];
    }
    else
    {
        qsql = [NSString stringWithFormat:@"SELECT um.id,um.mid,um.message_id,um.sender_id,um.message,um.attachment,um.attachment_type,um.message_type,um.group_id,um.receiver_id,um.receiver_time,um.read_status,um.read_at,um.delivery_status,um.delivery_time,um.deleted_at,um.created_at,um.filesize,um.delete_after,um.thumb_name,um.duration,uu.profile_picture,uu.first_name,uu.user_color FROM `mds_messages` as um LEFT JOIN `mds_users` as uu ON uu.user_id = um.sender_id WHERE `group_id` = '%@' ORDER BY `created_at` DESC",groupID];
    }
    
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getAllGroupMembers:(NSString *)groupID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"user_id",@"first_name",@"last_name",@"phone",@"email",@"profile_picture",@"last_login_time",@"is_admin", nil];
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT uu.id,uu.user_id,uu.first_name,uu.last_name,uu.phone,uu.email,uu.profile_picture,uu.last_login_time,ugm.is_admin FROM `mds_users` AS uu LEFT JOIN `mds_group_members` AS ugm ON uu.user_id = ugm.user_id  WHERE ugm.group_id = %@",groupID];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)checkIfUserIsInGroup
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"mid", nil];
    
    //[self openDB];
    
    
    
    NSString *qsql = @"SELECT max(mid) as mid FROM `mds_messages` WHERE mid <> ''";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getBiggestMID
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"mid", nil];
    
    //[self openDB];
    
    
    
    NSString *qsql = @"SELECT max(mid) as mid FROM `mds_messages` WHERE mid <> ''";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    NSLog(@"%@",array);
    return array;
}

-(NSMutableArray *)getAllUndeliveredMSG
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"id",@"mid",@"message_id",@"sender_id",@"message",@"attachment",@"attachment_type",@"message_type",@"group_id",@"receiver_id",@"receiver_time",@"read_status",@"read_at",@"delivery_status",@"delivery_time",@"deleted_at",@"created_at",@"filesize",@"delete_after",@"thumb_name",@"duration", nil];
    
    //[self openDB];
    
    
    NSString *qsql = @"SELECT * FROM `mds_messages` WHERE `delivery_status` = \"awaiting\"";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
            }
            [array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

-(NSMutableArray *)getAllIncompleteStatusMSG
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"message_id", nil];
    
    //[self openDB];
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT message_id FROM `mds_messages` WHERE (sender_id = %@) AND ((`delivery_status` = \"awaiting\" OR delivery_status = \"\") OR  (read_status = \"unread\" OR  read_status = \"\") OR (delete_after != \"\"))",[[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"]] ;
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    //[arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                    [array addObject:@""];
                }
                else{
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                   // [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                    [array addObject:field1Str];
                }
            }
            //[array addObject:arr_temp];
        }
        sqlite3_finalize(statement);
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
}

//MARK:- BASIC DB FUNCITONS
-(void)insertDataIntoTable:(NSString *)TableName forKeys:(NSArray*)Keys Values:(NSArray *)Values
{
    //[self openDB];
    
    NSString *Keystring,*Valuestring;
    
    NSMutableArray *totalEnterStringArray = [[NSMutableArray alloc] init];
    
    for (int j = 0; j < [Values count]; j++) {
        
        Keystring = Valuestring = @"";
        
        for (int i = 0; i < [Keys count]; i++)
            
        {
            if ([Keystring isEqualToString:@""] && [Valuestring isEqualToString:@""]) {
                
                Keystring = [NSString stringWithFormat:@"'%@'",[self addcharecter:[Keys objectAtIndex:i]]];
                
                // NSLog(@"values %@", [Values objectAtIndex:j]);
                
                
                if ([[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == nil || [[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] isKindOfClass:[NSNull class]] ||[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]] isEqualToString:@""])
                {
                    Valuestring = [NSString stringWithFormat:@"''"];
                }
                else
                {
                    Valuestring = [NSString stringWithFormat:@"'%@'",[self addcharecter:[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]]]];
                }
                
            }
            
            else
                
            {
                Keystring = [NSString stringWithFormat:@"%@,'%@'",Keystring,[self addcharecter:[Keys objectAtIndex:i]]];
                
                if ([[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == nil || [[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] isKindOfClass:[NSNull class]] || [[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]] isEqualToString:@""]) {
                    
                    Valuestring = [NSString stringWithFormat:@"%@,''",Valuestring];
                }
                else
                {
                    Valuestring = [NSString stringWithFormat:@"%@,'%@'",Valuestring,[self addcharecter:[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]]]];
                }
            }
        }
        
        [totalEnterStringArray addObject:[NSString stringWithFormat:@"(%@)",Valuestring]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) " "VALUES %@",TableName,Keystring,[totalEnterStringArray componentsJoinedByString:@","]];
    
    char *err;
    
    //NSLog(@"dhjk=%@", sql);
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        //sqlite3_close(db);
        
        NSLog(@"Error updating table----'%s'", sqlite3_errmsg(db));
        return;
    }
    //sqlite3_close(db);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_Chat_List" object:nil];
    
     if([TableName isEqualToString:@"mds_users"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_user_List" object:nil];
    }
    else if([TableName isEqualToString:@"mds_messages"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newMsg" object:Values];
    }
    else if([TableName isEqualToString:@"mds_groups"] || [TableName isEqualToString:@"mds_group_members"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGroup" object:nil];
    }

}

-(void)insertOrUpdateDataIntoTable:(NSString *)TableName forKeys:(NSArray*)Keys Values:(NSArray *)Values
{
    
    //[self openDB];
    
    NSString *Keystring,*Valuestring;
    
    NSMutableArray *totalEnterStringArray = [[NSMutableArray alloc] init];
    
    for (int j = 0; j < [Values count]; j++) {
        
        Keystring = Valuestring = @"";
        
        for (int i = 0; i < [Keys count]; i++)
            
        {
            if ([Keystring isEqualToString:@""] && [Valuestring isEqualToString:@""]) {
                
                Keystring = [NSString stringWithFormat:@"'%@'",[self addcharecter:[Keys objectAtIndex:i]]];
                
                // NSLog(@"values %@", [Values objectAtIndex:j]);
                
                
                if ([[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == nil || [[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] isKindOfClass:[NSNull class]] ||[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]] isEqualToString:@""])
                {
                    Valuestring = [NSString stringWithFormat:@"''"];
                }
                else
                {
                    Valuestring = [NSString stringWithFormat:@"'%@'",[self addcharecter:[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]]]];
                }
                
            }
            
            else
                
            {
                Keystring = [NSString stringWithFormat:@"%@,'%@'",Keystring,[self addcharecter:[Keys objectAtIndex:i]]];
                
                if ([[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == nil || [[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] isKindOfClass:[NSNull class]] || [[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]] isEqualToString:@""]) {
                    
                    Valuestring = [NSString stringWithFormat:@"%@,''",Valuestring];
                }
                else
                {
                    Valuestring = [NSString stringWithFormat:@"%@,'%@'",Valuestring,[self addcharecter:[NSString stringWithFormat:@"%@",[[Values objectAtIndex:j] objectForKey:[Keys objectAtIndex:i]]]]];
                }
            }
        }
        
        [totalEnterStringArray addObject:[NSString stringWithFormat:@"(%@)",Valuestring]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' (%@) " "VALUES %@",TableName,Keystring,[totalEnterStringArray componentsJoinedByString:@","]];
    
    char *err;
    
    //NSLog(@"dhjk=%@", sql);
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        //sqlite3_close(db);
        
        NSLog(@"Error updating table----'%s'", sqlite3_errmsg(db));
        return;
    }
    //sqlite3_close(db);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_Chat_List" object:nil];
    
    if([TableName isEqualToString:@"mds_users"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_user_List" object:nil];
    }
    else if([TableName isEqualToString:@"mds_messages"])
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"newMsg" object:Values];
    }
    else if([TableName isEqualToString:@"mds_groups"] || [TableName isEqualToString:@"mds_group_members"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGroup" object:nil];
    }
    
}

-(void)updateTable:(NSString *)tableName forKeys:(NSArray *)keyArray setValue:(NSArray *)value andWhere :(NSString *)where
{
    //[self openDB];
    
    NSString *sql = @"";
    
    sql = [NSString stringWithFormat:@"UPDATE %@", tableName];
    
    NSString *Keystring,*Valuestring;
    
    for (int j = 0; j < [value count]; j++) {
        
        Keystring = Valuestring = @"";
        
        for (int i = 0; i < [keyArray count]; i++)
            
        {
            if ([Keystring isEqualToString:@""] && [Valuestring isEqualToString:@""]) {
                
                Keystring = [NSString stringWithFormat:@"'%@'",[self addcharecter:[keyArray objectAtIndex:i]]];
                
                if ([[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] == nil ||[[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] isKindOfClass:[NSNull class]] || [[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]]] isEqualToString:@""])
                {
                    
                    Valuestring = [NSString stringWithFormat:@""];
                    
                    sql = [NSString stringWithFormat:@"%@ SET %@ = '%@'", sql, [keyArray objectAtIndex:i ], [self addcharecter:Valuestring]];
                }
                else
                {
                    
                    Valuestring = [NSString stringWithFormat:@"%@",[self addcharecter:[NSString stringWithFormat:@"%@",[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]]]]];
                    
                    sql = [NSString stringWithFormat:@"%@ SET %@ = '%@'", sql, [keyArray objectAtIndex:i ], [self addcharecter:Valuestring]];
                    
                }
                
            }
            
            else
                
            {
                Keystring = [NSString stringWithFormat:@"%@,'%@'",Keystring,[self addcharecter:[keyArray objectAtIndex:i]]];
                
                if ([[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] == nil ||[[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] isKindOfClass:[NSNull class]] || [[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]] == NULL || [[NSString stringWithFormat:@"%@",[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]]] isEqualToString:@""]) {
                    
                    Valuestring = [NSString stringWithFormat:@""];
                    
                    sql = [NSString stringWithFormat:@"%@, %@ = '%@'", sql, [keyArray objectAtIndex:i], [self addcharecter:Valuestring]];
                }
                else
                {
                    Valuestring = [NSString stringWithFormat:@"%@",[self addcharecter:[NSString stringWithFormat:@"%@",[[value objectAtIndex:j] objectForKey:[keyArray objectAtIndex:i]]]]];
                    
                    sql = [NSString stringWithFormat:@"%@, %@ = '%@'", sql, [keyArray objectAtIndex:i], [self addcharecter:Valuestring]];                }
            }
        }
        
        
    }
    
    NSString *qsql = [NSString stringWithFormat:@"%@ WHERE %@", sql, where];
    
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            
            [temp addObject:field1Str];
        }
        sqlite3_finalize(statement);
        
    }
    else{
        
        NSLog(@"sqlite3_step4 error: '%s'", sqlite3_errmsg(db));
        
    }
    //NSLog(@"hh==%@", qsql);
    //sqlite3_close(db);
    
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_Chat_List" object:nil];
    
    if([tableName isEqualToString:@"mds_users"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_user_List" object:nil];
    }
    else if([tableName isEqualToString:@"mds_messages"])
    {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMsgStatus" object:value];
    }
    
    
}

-(void)Delete_All_Records_From:(NSString *)tableName
{
    NSString *qsql;
    
    BOOL retValue = YES;
    
    qsql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    
    const char *ret_char = [qsql UTF8String];
    
    //[self openDB];
    
    sqlite3_stmt *statement;
    
    retValue = sqlite3_prepare_v2(db, ret_char, -1, &statement, NULL);
    
    if(SQLITE_DONE != sqlite3_step(statement))
    {
        NSLog(@"sqlite3_step error: '%s'", sqlite3_errmsg(db));
        
        retValue = NO;
        
    }
    else
    {
        sqlite3_finalize(statement);
        
        retValue = YES;
    }
    
    //sqlite3_close(db);
}

-(void)Delete_Record_From:(NSString *)tableName where:(NSString *)Where
{
    NSString *qsql;
    
    BOOL retValue = YES;
    
    qsql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,Where];
    
    const char *ret_char = [qsql UTF8String];
    
    //[self openDB];
    
    sqlite3_stmt *statement;
    
    retValue = sqlite3_prepare_v2(db, ret_char, -1, &statement, NULL);
    
    if(SQLITE_DONE != sqlite3_step(statement))
    {
        NSLog(@"sqlite3_step error: '%s'", sqlite3_errmsg(db));
        
        retValue = NO;
        
    }
    else
    {
        sqlite3_finalize(statement);
        
        retValue = YES;
    }
    
    //sqlite3_close(db);
}



-(NSArray *)getAllWhereValuesInTable:(NSString *)tableName forKeys:(NSArray *)keys andWhere:(NSString *)where
{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //[self openDB];
    
    NSString *Keystring;
    
    Keystring = @"";
    
    for (int i = 0; i < [keys count]; i++)
    {
        if ([Keystring isEqualToString:@""] ) {
            
            Keystring = [NSString stringWithFormat:@"%@",[self addcharecter:[keys objectAtIndex:i]]];
        }
        else
        {
            Keystring = [NSString stringWithFormat:@"%@,%@",Keystring,[self addcharecter:[keys objectAtIndex:i]]];
        }
    }
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",Keystring,tableName,where];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
            
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else
                {
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
                
            }
            
            [array addObject:arr_temp];
        }
        
        sqlite3_finalize(statement);
        
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
    
}

-(NSArray *)getValuesInTable:(NSString *)tableName forKeys:(NSArray *)keys
{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //[self openDB];
    
    NSString *Keystring;
    
    Keystring = @"";
    
    for (int i = 0; i < [keys count]; i++)
    {
        if ([Keystring isEqualToString:@""] ) {
            
            Keystring = [NSString stringWithFormat:@"%@",[self addcharecter:[keys objectAtIndex:i]]];
        }
        else
        {
            Keystring = [NSString stringWithFormat:@"%@,%@",Keystring,[self addcharecter:[keys objectAtIndex:i]]];
        }
    }
    
    NSString *qsql = [NSString stringWithFormat:@"SELECT %@ FROM %@",Keystring,tableName];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
            
        {
            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < [keys count] ; i++) {
                
                if ((char *) sqlite3_column_text(statement, i) == NULL) {
                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
                }
                else
                {
                    char *field1 = (char *) sqlite3_column_text(statement, i);
                    
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
                    
                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
                }
                
            }
            
            [array addObject:arr_temp];
        }
        
        sqlite3_finalize(statement);
        
    }
    
    else{
        
        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
        
    }
    //sqlite3_close(db);
    
    return array;
    
}



//-(NSArray *)getAllValuesInTable:(NSString *)tableName
//{
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    [self openDB];
//    
//    NSString *Keystring;
//    
//    Keystring = @"";
//    
//    
//    NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
//    
//    sqlite3_stmt *statement;
//    
//    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,&statement, nil) == SQLITE_OK)
//    {
//        while (sqlite3_step(statement) == SQLITE_ROW)
//            
//        {
//            NSMutableDictionary *arr_temp = [[NSMutableDictionary alloc] init];
//            
//            for (int i = 0; i < [keys count] ; i++) {
//                
//                if ((char *) sqlite3_column_text(statement, i) == NULL) {
//                    [arr_temp setObject:@"" forKey:[keys objectAtIndex:i]];
//                }
//                else
//                {
//                    char *field1 = (char *) sqlite3_column_text(statement, i);
//                    
//                    NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
//                    
//                    [arr_temp setObject:field1Str forKey:[keys objectAtIndex:i]];
//                }
//                
//            }
//            
//            [array addObject:arr_temp];
//        }
//        
//        sqlite3_finalize(statement);
//        
//    }
//    
//    else{
//        
//        NSLog(@"sqlite3_step3 error: '%s'", sqlite3_errmsg(db));
//        
//    }
//    sqlite3_close(db);
//    
//    return array;
//    
//}

@end
