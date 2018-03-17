//
//  WebConnector.m
//  Porsche Tower
//
//  Created by Povel Sanrov on 19/08/15.
//  Copyright (c) 2015 Daniel Liu. All rights reserved.
//

#import "WebConnector.h"

@implementation WebConnector

- (id)init {
    if (self = [super init]) {
        
        NSURL *url = [NSURL URLWithString: baseUrl];
        httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        httpManager.requestSerializer = requestSerializer;
        [httpManager.securityPolicy setAllowInvalidCertificates:YES];
        [httpManager.securityPolicy setValidatesDomainName:NO];
    }
    
    return self;
}


//IR Listing
-(void)IRLising:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

//TR Read
-(void)TRRead:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}




//comment incident
-(void)commentIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

// Export TR

-(void)exportTR:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

// Export IR

-(void)exportIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}


//IR close Incident
-(void)closeIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}


//tr password
-(void)createIR:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic = [params mutableCopy];
    
    for(NSString *key in params.allKeys)
    {
        if([key containsString:@"incident_files"])
        {
            NSMutableDictionary *newDict = [[[NSMutableDictionary alloc] initWithDictionary:[params valueForKey:key]] mutableCopy];
            
            if([newDict valueForKey:@"file"] != nil)
            {
                [newDict removeObjectForKey:@"file"];
            }
            
            if([newDict valueForKey:@"thumb"] != nil)
            {
                [newDict removeObjectForKey:@"thumb"];
            }
            
            [params removeObjectForKey:key];
            [params setObject:[newDict mutableCopy] forKey:key];
        }
    }
    
    
    [httpManager POST:urlget parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for(NSString *key in dic.allKeys)
        {
            if([key containsString:@"incident_files"])
            {
                if([[[dic valueForKey:key] valueForKey:@"type"] isEqualToString:@"audio"])
                {
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"file"] name:[NSString stringWithFormat:@"%@[file]",key] fileName:@"audio.mp4" mimeType:@"Audio/mp4"];
                }
                else if([[[dic valueForKey:key] valueForKey:@"type"] isEqualToString:@"image"])
                {
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"file"] name:[NSString stringWithFormat:@"%@[file]",key] fileName:@"image.jpg" mimeType:@"image/jpg"];
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"thumb"] name:[NSString stringWithFormat:@"%@[thumb]",key] fileName:@"image_thumb.jpg" mimeType:@"image/jpg"];
                }
                else  if([[[dic valueForKey:key] valueForKey:@"type"] isEqualToString:@"file"])
                {
                    
                    NSString *type = [[NSString stringWithFormat:@"%@",[[dic valueForKey:key] valueForKey:@"file_name"]] componentsSeparatedByString:@"."][1];
                    
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"file"] name:[NSString stringWithFormat:@"%@[file]",key] fileName:[NSString stringWithFormat:@"file.%@",type] mimeType:[NSString stringWithFormat:@"application/%@",type]];
                }
                else  if([[[dic valueForKey:key] valueForKey:@"type"] isEqualToString:@"video"])
                {
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"file"] name:[NSString stringWithFormat:@"%@[file]",key] fileName:@"video.mp4" mimeType:@"video/mp4"];
                    [formData appendPartWithFileData:[[dic valueForKey:key] valueForKey:@"thumb"] name:[NSString stringWithFormat:@"%@[thumb]",key] fileName:@"image_thumb.jpg" mimeType:@"image/jpg"];
                }
            }
        }
    } success:completed failure:errorBlock];
}

//tr password
-(void)trPassword:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

//tr login
-(void)Login_TR:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

-(void)create_TR:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    
    NSString *urlget = [NSString stringWithFormat:@"%@api/auth/post_tr?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    [httpManager POST:urlget parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:[NSDate date]];
        
        for(int i = 0; i< [[params valueForKey:@"tr_images"] count]; i ++){
            [formData appendPartWithFileData:[[params valueForKey:@"tr_images"] objectAtIndex:i] name:[NSString stringWithFormat:@"images[%d][tr_images]",i] fileName:[NSString stringWithFormat:@"TR%d_%@.jpg", i, yearString] mimeType:@"image/jpg"];
            [formData appendPartWithFileData:[[params valueForKey:@"tr_images_thumb"] objectAtIndex:i] name:[NSString stringWithFormat:@"images[%d][tr_images_thumb]",i] fileName:[NSString stringWithFormat:@"TR%d_%@_thumb.jpg", i, yearString] mimeType:@"image/jpg"];
        }
        
        for(int i = 0; i< [[params valueForKey:@"tr_file"] count]; i ++){
            
            NSString *type = [[[params valueForKey:@"file_name_"] objectAtIndex:i] componentsSeparatedByString:@"."][1];
            
            [formData appendPartWithFileData:[[params valueForKey:@"tr_file"] objectAtIndex:i] name:[NSString stringWithFormat:@"tr_file[%d]",i] fileName:[[params valueForKey:@"file_name_"] objectAtIndex:i] mimeType:type];
        }
    } success:completed failure:errorBlock];
}

-(void)saveAsDraft_TR:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    
    NSString *urlget = [NSString stringWithFormat:@"%@api/auth/update_tr?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    [httpManager POST:urlget parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSString *yearString = [formatter stringFromDate:[NSDate date]];
        
        for(int i = 0; i< [[params valueForKey:@"tr_images"] count]; i ++){
            [formData appendPartWithFileData:[[params valueForKey:@"tr_images"] objectAtIndex:i] name:[NSString stringWithFormat:@"images[%d][tr_images]",i] fileName:[NSString stringWithFormat:@"TR%d_%@.jpg", i, yearString] mimeType:@"image/jpg"];
            [formData appendPartWithFileData:[[params valueForKey:@"tr_images_thumb"] objectAtIndex:i] name:[NSString stringWithFormat:@"images[%d][tr_images_thumb]",i] fileName:[NSString stringWithFormat:@"TR%d_%@_thumb.jpg", i, yearString] mimeType:@"image/jpg"];
        }
        
        for(int i = 0; i< [[params valueForKey:@"tr_file"] count]; i ++){
            
            NSString *type = [[[params valueForKey:@"file_name_"] objectAtIndex:i] componentsSeparatedByString:@"."][1];
            
            [formData appendPartWithFileData:[[params valueForKey:@"tr_file"] objectAtIndex:i] name:[NSString stringWithFormat:@"tr_file[%d]",i] fileName:[[params valueForKey:@"file_name_"] objectAtIndex:i] mimeType:type];
        }
    } success:completed failure:errorBlock];
}
-(void)Login:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

-(void)refreshAccessToken: (CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please Wait"];
    NSString *str = [NSString stringWithFormat:@"%@api/auth/refreshToken?token=%@", BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    [httpManager POST:str parameters:nil success:completed failure:errorBlock];
    
    //    [httpManager POST:str  parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    //     {
    //         if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
    //         {
    //
    //             NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
    //             [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
    //             [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
    //         }
    //         else
    //         {
    //             [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
    //         }
    //     } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
    //     {
    //         [SVProgressHUD showErrorWithStatus:@"Please try again."];
    //     }];
    
    [SVProgressHUD dismiss];
}

-(void)logout:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    
    if (![appDelegate hasConnectivity]) {
        
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Please wait"];
    
    NSString *str =  [NSString stringWithFormat:@"%@api/auth/logout?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:str parameters:params success: ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
     {
         [SVProgressHUD dismiss];
         if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
         {
             [appDelegate.generalFunction Delete_All_Records_From:@"mds_groups"];
             [appDelegate.generalFunction Delete_All_Records_From:@"mds_group_members"];
             [appDelegate.generalFunction Delete_All_Records_From:@"mds_messages"];
             [appDelegate.generalFunction Delete_All_Records_From:@"mds_chat_list"];
             [appDelegate.generalFunction Delete_All_Records_From:@"mds_users"];
             
             
             
             [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"userData"];
             UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
             
             [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController: [mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController"] withCompletion:nil];
             [appDelegate.socketManager closeConnection];
         }
         else
         {
             [SVProgressHUD showSuccessWithStatus:[responseObject valueForKey:@"message"]];
         }
     } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error)
     {
         [SVProgressHUD dismiss];
         [SVProgressHUD showErrorWithStatus:@"Please try again."];
     }];
}


-(void)profile:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager GET:urlget parameters:nil success:completed failure:errorBlock];
}

-(void)defaultData:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}

-(void)editProfile:(NSMutableDictionary *)params profilePhoto:(NSData *)profilePhoto completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    if (profilePhoto != nil)
    {
        [httpManager.requestSerializer setTimeoutInterval: 6];
    }
    [httpManager POST:[NSString stringWithFormat:@"%@api/auth/editprofile?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (profilePhoto != nil){
            [formData appendPartWithFileData:profilePhoto name:@"profile_picture" fileName:@"profilePhoto.jpg" mimeType:@"image/jpg"];
        }
        else
        {
            [params setValue:@"" forKey:@"profile_picture"];
        }
    } success:completed failure:errorBlock];
}

//TR Listing
-(void)TRListing:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:urlget parameters:params success:completed failure:errorBlock];
}



-(void)contactslist:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/user-listing?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:nil success:completed failure:errorBlock];
}

-(void)addNewMembers:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/add-groups-members?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)createGroup:(NSDictionary *)params withImage:(NSData *)image  completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/create-group?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (image != nil){
            
            [formData appendPartWithFileData:image name:@"group_icon" fileName:@"image.jpg" mimeType:@"image/jpg"];
        }
        
    } success:completed failure:errorBlock];
}

-(void)deleteChatFromChatList:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/clear_chat?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)updateGroup:(NSDictionary *)params withImage:(NSData *)image  completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/edit-group?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (image != nil){
            
            [formData appendPartWithFileData:image name:@"group_icon" fileName:@"image.jpg" mimeType:@"image/jpg"];
        }
        
    } success:completed failure:errorBlock];
}


-(void)exitGroup:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/remove-members?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)deleteGroup:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/delete_group?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)makeAdmin:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/assign-admin?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)chatlist:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:@"get_chat_list" parameters:params success:completed failure:errorBlock];
}

-(void)setFavChat:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    [httpManager POST:@"favorite_chat" parameters:params success:completed failure:errorBlock];
}

-(void)deleteMessage:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/delete_message?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)lastOnlineTime:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/last_login_time?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)pushNotificationToggle:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/push_notification?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)locationWebservice:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSString *url = [NSString stringWithFormat:@"%@api/auth/geoLocation?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    [httpManager POST:url parameters:params success:completed failure:errorBlock];
}

-(void)uploadDocument:(NSString *)type withName:(NSString*)fileName document:(NSData *)document andThumbnail:(NSData *)thumb withDuration:(NSString *)duration completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:type forKey:@"type"];
    NSString *url = [NSString stringWithFormat:@"%@api/auth/media-upload?token=%@",BaseURL,[[[NSUserDefaults standardUserDefaults] objectForKey:@"userData"] valueForKey:@"token"]];
    
    [httpManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (document != nil){
            [formData appendPartWithFileData:document name:@"media" fileName:fileName mimeType:type];
        }
        
        if (thumb != nil){
            
            [formData appendPartWithFileData:thumb name:@"thumb_name" fileName:@"thumb_image.jpg" mimeType:@"image/jpg"];
        }
        
    } success:completed failure:errorBlock];
}
@end
