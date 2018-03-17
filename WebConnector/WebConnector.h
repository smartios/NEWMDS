//
//  WebConnector.h
//  Salon Bar
//
//  Created by ShivPoojan on 10/02/16.
//  Copyright (c) 2016 Singsys All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface WebConnector : NSObject {
    AFHTTPRequestOperationManager *httpManager;
    NSString *baseUrl;
    NSString *serverURL;
}

typedef void (^CompleteBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^ErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

-(void)locationWebservice:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
-(void)saveAsDraft_TR:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
//TR Read
-(void)TRRead:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)exportIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//comment listing
-(void)commentIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//export tr
-(void)exportTR:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//IR close Incident
-(void)closeIncident:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//IR Lising
-(void)IRLising:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//create IR
-(void)createIR:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//create TR
-(void)create_TR:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//TR Listing
-(void)TRListing:(NSMutableDictionary* )params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//tr login
-(void)Login_TR:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//tr password
-(void)trPassword:(NSMutableDictionary *)params url:(NSString* )urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//to get default data or multiple status
-(void)defaultData:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//Edit profile Method
-(void)profile:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

//Do Login Method
-(void)Login:(NSMutableDictionary *)params url:(NSString *)urlget completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)logout:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)refreshAccessToken: (CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)editProfile:(NSMutableDictionary *)params profilePhoto:(NSData *)profilePhoto completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)contactslist:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)addNewMembers:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)createGroup:(NSDictionary *)params withImage:(NSData *)image  completionHandler:(CompleteBlock)completed errorHandler:
(ErrorBlock)errorBlock;

-(void)deleteChatFromChatList:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)updateGroup:(NSDictionary *)params withImage:(NSData *)image  completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)exitGroup:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)deleteGroup:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)makeAdmin:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)chatlist:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)setFavChat:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)deleteMessage:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)lastOnlineTime:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;

-(void)uploadDocument:(NSString *)type withName:(NSString*)fileName document:(NSData *)document andThumbnail:(NSData *)thumb withDuration:(NSString *)duration completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
-(void)pushNotificationToggle:(NSMutableDictionary *)params completionHandler:(CompleteBlock)completed errorHandler:(ErrorBlock)errorBlock;
@end
