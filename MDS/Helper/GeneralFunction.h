//
//  GeneralFunction.h
//  ict
//
//  Created by apple on 1/8/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface GeneralFunction : NSObject
{
    sqlite3 *db;
    NSInteger maxId, chpId;
    NSString *sectionID;
    
}
-(void)openDB;

//MARK:- mds EMPIRE
//MARK:- GET FUNCTIONS
-(NSMutableArray *)getChatList;
-(NSMutableArray *)getGroupChatList;
-(NSMutableArray *)getAllBroadcastGroups;
-(NSMutableArray *)getfavouriteChatList;
-(NSMutableArray *)getContactList;
-(NSMutableArray *)getGroupRemainingContactList:(NSString *)groupID;
-(NSMutableArray *)getChat:(NSString *)userID orWithGroup:(NSString *)groupID withOffset:(NSInteger)offset;
-(NSMutableArray *)getWholeChat:(NSString *)userID orWithGroup:(NSString *)groupID;
-(NSMutableArray *)getAllGroupMembers:(NSString *)groupID;
-(NSMutableArray *)getBiggestMID;
-(NSMutableArray *)getAllUndeliveredMSG;
-(NSMutableArray *)getAllIncompleteStatusMSG;
-(NSMutableArray *)getSearchedContact:(NSString *)searckeyBoardViewhString;
-(NSMutableArray *)getSearchedMessage:(NSString *)searchString;


//MARK:- BASIC DB FUNCITONS
-(void)insertDataIntoTable:(NSString *)TableName forKeys:(NSArray*)Keys Values:(NSArray *)Values;

-(void)insertOrUpdateDataIntoTable:(NSString *)TableName forKeys:(NSArray*)Keys Values:(NSArray *)Values;

-(void)updateTable:(NSString *)tableName forKeys:(NSArray *)keyArray setValue:(NSArray *)value andWhere :(NSString *)where;

-(void)Delete_All_Records_From:(NSString *)tableName;

-(void)Delete_Record_From:(NSString *)tableName where:(NSString *)Where;

-(NSArray *)getAllWhereValuesInTable:(NSString *)tableName forKeys:(NSArray *)keys andWhere:(NSString *)where;

-(NSArray *)getValuesInTable:(NSString *)tableName forKeys:(NSArray *)keys;

@end
