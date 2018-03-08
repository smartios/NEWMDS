//
//  Constant.m
//  MDS
//
//  Created by SL-167 on 12/4/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import "Constant.h"
#import "SVProgressHUD.h"

@interface Constant()
@end

@implementation Constant

#pragma mark - Dismiss Methods Sample

- (id)init
{
    self = [super init];
    //Code to customize SVProgressHUD
   // [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
   // [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    return self;
}

-(BOOL)emailValidation:(NSString *)emailText
{
    //  NSString *emailText=(NSString *)str;
    NSString *emailRegex = @"(?:[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailText];
}


-(BOOL)passwordValidation:(NSString *)passText
{
    NSString *Regex = @"((?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,20})";
    
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    
    return [Test evaluateWithObject:passText];
}


//Code for adding character spacing in text
- (NSAttributedString *)addCharacterSpacing:(NSString *)str space:(CGFloat)space
{
    //Code here
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    
    float spacing = space;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [str length])];
    return attributedString;
}

//code for logout
-(void)logoutFromApp
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue: [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"]] forKey:@"user_id"];
    WebConnector *webConnector = [[WebConnector alloc] init];
    [webConnector logout:params completionHandler:nil errorHandler:nil];
}

//{
//    [SVProgressHUD showSuccessWithStatus: @"You have been logout from App."];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"userData"];
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//
//
//    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController: [mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController"] withCompletion:nil];
//
//    [appDelegate.socketManager closeConnection];
//}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


//Generate encrypted IV Message
-(NSString *)generateMessage:(NSString *)plainText
{
    // NSString *random = [NSString stringWithFormat:@"%i",arc4random_uniform(1000000000)];
    
    NSString *random = [appDelegate.cryptoLib generateRandomIV:16];
    
    // NSString *key = [[self cryptoLib] sha256:encryptionKey length:32];
    
    NSString *encryptedString = [appDelegate.cryptoLib encryptPlainTextWith:plainText key:encryptionKey iv:random];
    
    NSLog(@"%@",encryptedString);
    
    NSString *message = @"";
    
    if(([encryptedString length]/2) < 9)
    {
        [message stringByAppendingString:[NSString stringWithFormat:@"%.0f",ceilf(([encryptedString length]/2))]];
        //message = [NSString stringWithFormat:@"%i",ceilf(([encryptedString length]/2))];
    }
    else
    {
        int num = ceilf([encryptedString length]/2);
        
        for(int i = 0;i < [[NSString stringWithFormat:@"%i",num] length]; i++)
        {
            if(i == 0)
            {
                message = [NSString stringWithFormat:@"%@",[[NSString stringWithFormat:@"%i", num] substringWithRange:NSMakeRange(0,1)]];
            }
            else
            {
                message = [NSString stringWithFormat:@"%@**%@",message,[[NSString stringWithFormat:@"%i", num] substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        
    }
    
    message = [NSString stringWithFormat:@"%@%@",message,[encryptedString substringWithRange:NSMakeRange(0, ([encryptedString length]/2))]];
    message = [NSString stringWithFormat:@"%@%.0lu",message,[random length]/2];
    message = [NSString stringWithFormat:@"%@%@",message,[random substringWithRange:NSMakeRange(0, ([random length]/2))]];
    
    if(([encryptedString length] - ([encryptedString length]/2)) < 9)
    {
        message = [NSString stringWithFormat:@"%@%.0f",message,ceilf(([encryptedString length] - ([encryptedString length]/2)))];
    }
    else
    {
        int num2 = ceilf(([encryptedString length] - ([encryptedString length]/2)));
        
        for(int i = 0;i < [[NSString stringWithFormat:@"%i",num2] length]; i++)
        {
            if(i == 0)
            {
                message = [NSString stringWithFormat:@"%@%@",message,[[NSString stringWithFormat:@"%i", num2] substringWithRange:NSMakeRange(i, i + 1)]];
            }
            else
            {
                message = [NSString stringWithFormat:@"%@**%@",message,[[NSString stringWithFormat:@"%i", num2] substringWithRange:NSMakeRange(i, 1)]];
            }
        }
        
    }
    message = [NSString stringWithFormat:@"%@%@",message,[encryptedString substringWithRange:NSMakeRange(([encryptedString length]/2),[encryptedString length] - ([encryptedString length]/2))]];
    message = [NSString stringWithFormat:@"%@%.0lu",message,([random length] - ([random length]/2))];
    message = [NSString stringWithFormat:@"%@%@",message,[random substringWithRange:NSMakeRange(([random length]/2),[random length] - ([random length]/2))]];
    
    
    return message;
}

-(NSString *)UTF8Message:(NSString *)message
{
    message = [message stringByReplacingOccurrencesOfString:@"\\\\N" withString:@"\n"];
    message = [message stringByReplacingOccurrencesOfString:@"\\\\n" withString:@"\r"];
    message = [message stringByReplacingOccurrencesOfString:@"\\\\R" withString:@"\r"];
    message = [message stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    message = [message stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    message = [message stringByReplacingOccurrencesOfString:@"\\n\\n" withString:@"\n"];
    message = [message stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    message = [message stringByReplacingOccurrencesOfString:@"‍" withString:@""];
    message = [message stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    message = [message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    
    NSData *data = [[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] dataUsingEncoding:NSUTF8StringEncoding];
    
    return [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
}

-(NSString *)getSubString:(NSString *)str
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]{1}((\\*\\*[0-9])?)+" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSTextCheckingResult *newSearchString = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    NSString *substr = [str substringWithRange:newSearchString.range];
    
    return substr;
}


//Get IV and message
-(NSArray *)getMessageAndIV:(NSString *)str
{
    int range = 0;
    NSString *message = @"";
    NSString *iv = @"";
    NSString *substr = @"";
    
    //Step1
    substr = [self getSubString:str];
    str = [str substringWithRange:NSMakeRange([substr length], [str length] - [substr length])];
    range = [[substr stringByReplacingOccurrencesOfString:@"**" withString:@""] intValue];
    message = [str substringWithRange:NSMakeRange(0, range)];
    str = [str substringWithRange:NSMakeRange([message length], [str length] - [message length])];
    
    //Step2
    substr = [self getSubString:str];
    str = [str substringWithRange:NSMakeRange([substr length], [str length] - [substr length])];
    range = [[substr stringByReplacingOccurrencesOfString:@"**" withString:@""] intValue];
    iv = [str substringWithRange:NSMakeRange(0, range)];
    str = [str substringWithRange:NSMakeRange([iv length], [str length] - [iv length])];
    
    //Step3
    substr = [self getSubString:str];
    str = [str substringWithRange:NSMakeRange([substr length], [str length] - [substr length])];
    range = [[substr stringByReplacingOccurrencesOfString:@"**" withString:@""] intValue];
    message = [NSString stringWithFormat:@"%@%@",message,[str substringWithRange:NSMakeRange(0, range)]];
    str = [str substringWithRange:NSMakeRange([[str substringWithRange:NSMakeRange(0, range)] length], [str length] - [[str substringWithRange:NSMakeRange(0, range)] length])];
    
    //Step4
    substr = [self getSubString:str];
    str = [str substringWithRange:NSMakeRange([substr length], [str length] - [substr length])];
    range = [[substr stringByReplacingOccurrencesOfString:@"**" withString:@""] intValue];
    iv = [NSString stringWithFormat:@"%@%@",iv,[str substringWithRange:NSMakeRange(0, range)]];
    
    NSArray *arr = [[NSArray alloc] initWithObjects:message,iv, nil];
    
    return arr;
}




//MARK:- Delete Expired Msg

-(void) getExpireMessage
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* localTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"];
    [dateFormatter setTimeZone:localTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [[appDelegate generalFunction] Delete_Record_From:@"mds_messages" where:[NSString stringWithFormat:@"delete_after <> '' and read_status = 'read'  and  datetime('%@') >= datetime(read_at,  '+' || delete_after || '  seconds'  )",[dateFormatter stringFromDate:[NSDate date]]]];
}

//MARK:- DOWNLOAD
-(void)downloadWithNsurlconnection
{
   //  WebConnector *webConnector = [[WebConnector alloc] init];
    NSURL *url = [[NSURL alloc] init];
  
    if([[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"attachment"] != nil)
    {
        url = [NSURL URLWithString: [NSString stringWithFormat:@"%@",[[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"attachment"]]];
    }
    else if([[NSString stringWithFormat:@"%@", [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"file"]] containsString:@"index.php"])
    {
        NSString *file = [[NSString stringWithFormat:@"%@", [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"file"]] componentsSeparatedByString:@"index.php/"][0];
        NSString *file_name = [[NSString stringWithFormat:@"%@", [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"file"]] componentsSeparatedByString:@"index.php/"][1];
        url = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@",file,file_name]];
    }
    else 
    {
        url = [NSURL URLWithString: [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] valueForKey:@"file"]];
    }
    
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    NSMutableData *receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    
    [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] setValue:receivedData forKey:@"receivedData"];
    [[appDelegate.downlaodArray objectAtIndex:[appDelegate.downlaodArray count] - 1] setValue:connection forKey:@"connection"];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    progress.hidden = NO;
    for(int i=0;i<[appDelegate.downlaodArray count];i++)
    {
        if(connection == [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"connection"])
        {
            NSMutableData *data = [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"receivedData"];
            
            NSNumber *expectedBytes = [NSNumber numberWithLongLong:[response expectedContentLength]];
            
            [data setLength:0];
            [[appDelegate.downlaodArray objectAtIndex:i] setValue:data forKey:@"receivedData"];
            [[appDelegate.downlaodArray objectAtIndex:i] setValue:expectedBytes forKey:@"expectedBytes"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadProggressUpdate" object:[appDelegate.downlaodArray objectAtIndex:i]];
            break;
        }
        
    }
    
    //    expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    for(int i=0;i<[appDelegate.downlaodArray count];i++)
    {
        if(connection == [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"connection"])
        {
            NSMutableData *receivedData = [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"receivedData"];
            
            
            NSNumber *expectedBytes = [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"expectedBytes"];
            
            [receivedData appendData:data];
            float progressive = (float)[receivedData length] / (float)[expectedBytes longLongValue];
            [[appDelegate.downlaodArray objectAtIndex:i] setValue:[NSNumber numberWithFloat:progressive] forKey:@"progressive"];
            
            //Send Progressive notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadProggressUpdate" object:[appDelegate.downlaodArray objectAtIndex:i]];
            break;
            
        }
    }
    
    //    [receivedData appendData:data];
    //    float progressive = (float)[receivedData length] / (float)expectedBytes;
    //    [progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    for(int i=0;i<[appDelegate.downlaodArray count];i++)
    {
        if(connection == [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"connection"])
        {
            [appDelegate.downlaodArray removeObjectAtIndex:i];
            [SVProgressHUD showErrorWithStatus: @"Please try again."];
            break;
        }
    }
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    for(int i=0;i<[appDelegate.downlaodArray count];i++)
    {
        if(connection == [[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"connection"])
        {
            
            NSArray *tempArr = [[NSArray alloc] initWithArray:[[NSString stringWithFormat:@"%@",connection.originalRequest.URL ] componentsSeparatedByString:@"/"]];
            NSString *fileName = [tempArr objectAtIndex:[tempArr count] - 1];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *pdfPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
            // NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[appDelegate.downlaodArray objectAtIndex:i] valueForKey:@"receivedData"] writeToFile:pdfPath atomically:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadProggressUpdate" object:[appDelegate.downlaodArray objectAtIndex:i]];
                [appDelegate.downlaodArray removeObjectAtIndex:i];
            });
            //progress.hidden = YES;
            
            
            //Send Complete notification
            break;
        }
    }
    
}

@end
