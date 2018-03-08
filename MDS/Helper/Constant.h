//
//  Constant.h
//  MDS
//
//  Created by SL-167 on 12/4/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject


#pragma mark- Reachability and ProgressHud Methods

-(void) getExpireMessage;
-(BOOL)emailValidation:(NSString *)emailText;
- (NSAttributedString *)addCharacterSpacing:(NSString *)str space:(CGFloat)space;
-(void)logoutFromApp;
- (UIColor *)colorFromHexString:(NSString *)hexString;
-(NSString *)generateMessage:(NSString *)plainText;
-(NSArray *)getMessageAndIV:(NSString *)str;
-(NSString *)getSubString:(NSString *)str;
-(NSString *)UTF8Message:(NSString *)message;
-(void)downloadWithNsurlconnection;
-(BOOL)passwordValidation:(NSString *)passText;
@end
