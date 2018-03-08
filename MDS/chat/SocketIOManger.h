//
//  SocketIOManger.h
//  MDS
//
//  Created by SS-181 on 6/27/17.
//
//

#import <Foundation/Foundation.h>
#import "SocketIOManger.h"
@import SocketIO;

@interface SocketIOManger : NSObject


@property (strong, nonatomic) SocketIOClient* socket;

@property (strong, nonatomic) SocketIOManger *sharedInstance;
-(void) establishConnection;
-(void) closeConnection;
-(BOOL) socketIsConnected;

-(void)checkSocketStatus;

-(void) addUserMethod;
-(void)getChatList;

-(void)sendMessage:(NSMutableDictionary *)dataDic;
-(void)readMesage:(NSString *)ID withGroupID:(NSString *)groupID;
-(void)typing:(NSString *)msg;
-(void)groupTyping:(NSString *)msg;
-(void)chatGroupUpdate:(NSString *)groupID;
-(void)chatGroupDeleteUpdate:(NSString *)deleteToID forGroupID:(NSString *)groupID;


@end
