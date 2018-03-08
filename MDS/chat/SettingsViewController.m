//
//  SettingsViewController.m
//  mds
//
//  Created by SS-181 on 8/14/17.
//
//

#import "SettingsViewController.h"
#import "WebConnector.h"
#import "AppDelegate.h"

@interface SettingsViewController ()
{
    WebConnector *webConnector;
}
@end

@implementation SettingsViewController
@synthesize tableView,titleLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"SETTINGS";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleLabel.text = @"SETTINGS";
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
    [[appDelegate socketManager] checkSocketStatus];
}

//MARK:- Buttons
- (IBAction)menuBtnClicked:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"notification"
     object:nil];
    
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

-(IBAction)switchButtonClicked:(UIButton *)sender
{
    if(sender.isSelected == false)
    {
        sender.selected = true;
        [self changePushNotificationStatus:@"Y"];
    }
    else
    {
        sender.selected = false;
        [self changePushNotificationStatus:@"N"];
    }
}


#pragma mark- UITableViewDelegate & UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"  forIndexPath: indexPath];
    
    //    UIImageView *imageView = [cell viewWithTag:1];
    UILabel *label = [cell viewWithTag:2];
    UIButton *switchButton = [cell viewWithTag:3];
    
    label.text = @"Notification Alert";
    //is_ntf_send
    if([[[[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] valueForKey:@"users_details"] valueForKey:@"push_notification"] isEqualToString:@"Y"])
    {
        switchButton.selected = true;
    }
    else
    {
        switchButton.selected = false;
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

//MARK:- Webservice
-(void) changePushNotificationStatus:(NSString *)status
{
    if (![appDelegate hasConnectivity]) {
        [SVProgressHUD showErrorWithStatus: @"No Internet Connection."];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Please wait"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        webConnector = [[WebConnector alloc] init];
        
        // [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"language"] forKey: @"language"];
        
        [params setObject: [[NSUserDefaults standardUserDefaults] objectForKey: @"user_id"] forKey: @"user_id"];
        [params setObject: status forKey: @"push_notification_status"];
        
        WebConnector *webConnector = [[WebConnector alloc] init];
        [webConnector pushNotificationToggle:params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseObject objectForKey: @"response"] isEqualToString: @"success"])
            {
                NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] objectForKey: @"userData"] mutableCopy];
               
                NSMutableDictionary *temp = [[dic valueForKey:@"users_details"] mutableCopy];
                [temp setValue:status forKey:@"push_notification"];
                [dic setValue:temp forKey:@"users_details"];
                [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.tableView reloadData];
            }
            else if([[responseObject valueForKey:@"response"] isEqualToString:@"error"] && [[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"error_code"]] isEqualToString:@"401"])
            {
                [webConnector refreshAccessToken:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if([[responseObject valueForKey:@"response"] isEqualToString:@"success"])
                    {
                        NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userData"] mutableCopy];
                        [dic setValue:[[responseObject valueForKey:@"result"] valueForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"userData"];
                        
                        [self changePushNotificationStatus:status];
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
            
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"isFailed"];
            
        } errorHandler:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD dismiss];
            [tableView reloadData];
            [SVProgressHUD showErrorWithStatus: @"Pleas try again."];
        }];
    }
}

@end
