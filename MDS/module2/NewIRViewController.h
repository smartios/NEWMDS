//
//  NewIRViewController.h
//  MDS
//
//  Created by SL-167 on 1/6/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioViewController.h"
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <MapKit/MapKit.h>

@interface NewIRViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, getAudio, GMSPlacePickerViewControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) IBOutlet UIButton *menuBtn;
@property (nonatomic, strong) IBOutlet UIButton *dateBTN;
@property (nonatomic, strong) IBOutlet UIButton *sendChatBtn;
@property (nonatomic, strong) IBOutlet UILabel *headLbl;
@property (nonatomic, strong) IBOutlet UILabel *IRLbl;
@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSString *from;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBTnCons;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *showIconBtnConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconViewConst;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

-(void)getCommentWebservice:(Boolean)show;
@end
