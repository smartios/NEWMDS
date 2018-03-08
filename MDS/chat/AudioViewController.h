//
//  AudioViewController
//  AudioDemo
//
//  Created by Simon on 24/2/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol getAudio <NSObject>

-(void) getAudio: (NSData *)audio withDuration:(NSString *)duration;

@end

@interface AudioViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    NSTimer *timer;
    IBOutlet UILabel *myCounterLabel;
}

@property (strong, nonatomic) id<getAudio> delegate;

@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;

@property (nonatomic, retain) UILabel *myCounterLabel;

-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;


@end
