//
//  ChatViewController.h
//  mds
//
//  Created by SS-181 on 7/3/17.
//
//

#import <UIKit/UIKit.h>
#import "AGEmojiKeyboardView.h"
#import "AudioViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIDocumentPickerDelegate, UIActionSheetDelegate,AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource,getAudio,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UIButton *optionButton;
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;

@property (strong, nonatomic) IBOutlet UIButton *exportButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteChatButton;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) IBOutlet UIView *keyBoardView;
@property (strong, nonatomic) IBOutlet UIButton *emojiButton;
//@property (strong, nonatomic) IBOutlet UIView *iconView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendViewConst;
@property (strong, nonatomic) IBOutlet UIView *topOptionMenu;

@property (strong, nonatomic) NSMutableDictionary *prevDataDic;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIView *deleteAfterMainView;



@end
