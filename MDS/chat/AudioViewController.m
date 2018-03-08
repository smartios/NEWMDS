//
//  AudioViewController
//  AudioDemo
//
//  Created by Simon on 24/2/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "AudioViewController.h"
#import "AppDelegate.h"

@interface AudioViewController () {
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
}

@end

@implementation AudioViewController
@synthesize myCounterLabel,delegate,recordTimeLabel;

int hours, minutes, seconds;
int secondsLeft;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable Stop/Play button when the application launches
    [_saveButton setTitle:@"SEND" forState:UIControlStateNormal];
    recordTimeLabel.text = @"RECORDING TIME";
    
    [_stopButton setHidden:YES];
    [_playButton setHidden:YES];
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    [_deleteButton setHidden:YES];
    [_saveButton setHidden:YES];
    
    _stopButton.layer.cornerRadius = _stopButton.frame.size.width/2;
    _playButton.layer.cornerRadius = _playButton.frame.size.width/2;
    _recordPauseButton.layer.cornerRadius = _recordPauseButton.frame.size.width/2;
    _deleteButton.layer.cornerRadius = _deleteButton.frame.size.width/2;
    
    // Set up the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject],@"MyAudioMemo.m4a",nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL
                                            settings:recordSetting
                                               error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    [_recorder prepareToRecord];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self recordPauseTapped:_recordPauseButton];
    [self stopTapped:_stopButton];
    [self deleteTapped:_deleteButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(UIButton *)sender
{
    [[self navigationController] popViewControllerAnimated: YES];
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    
    [_recordPauseButton setHidden:YES];
    [_playButton setHidden:YES];
    [_stopButton setHidden:NO];
    if (_player.playing) {
        [_player stop];
    }
    
    if (!_recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [_recorder record];
       // [_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self countdownTimer];
        [_recordPauseButton setEnabled:NO];
    }
    
    [_stopButton setEnabled:YES];
    [_playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    [_recordPauseButton setHidden:YES];
    [_playButton setHidden:NO];
    [_stopButton setHidden:YES];
    
    [_deleteButton setHidden:NO];
    [_saveButton setHidden:NO];
    
    [_recorder stop];
    [_recordPauseButton setEnabled:YES];
    [timer invalidate];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
   // [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    [_recordPauseButton setHidden:YES];
    [_playButton setHidden:NO];
    [_stopButton setHidden:YES];
    
    if (!_recorder.recording && !_player.playing) {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        // [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        [audioSession setActive:YES error:nil];
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:nil];
        [_player setDelegate:self];
        [_player play];
        
        [sender setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }
    else
    {
        [_player stop];
        [sender setBackgroundImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    }
}

- (IBAction)deleteTapped:(id)sender {
    [_recordPauseButton setHidden:NO];
    [_playButton setHidden:YES];
    [_stopButton setHidden:YES];
    
    [_deleteButton setHidden:YES];
    [_saveButton setHidden:YES];
    
    hours = 0;
    minutes = 0;
    seconds = 0;
    myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
    [_recorder stop];
    [_recordPauseButton setEnabled:YES];
    [timer invalidate];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [_playButton setBackgroundImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
}

- (IBAction)saveTapped:(id)sender
{
    if(seconds > 0 || minutes > 0)
    {
        NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject],@"MyAudioMemo.m4a",nil];
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/%@",pathComponents[0],pathComponents[1]]];
        
        int finalSec = (minutes * 60) + seconds;
        
        [delegate getAudio:data withDuration:[NSString stringWithFormat:@"%d",finalSec]];
        [[self navigationController] popViewControllerAnimated:true];

    }
}


#pragma mark - DELEGATE METHODS
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    [_recordPauseButton setTitle:@"" forState:UIControlStateNormal];
    
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Finish playing the recording!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    
//    [alert show];
    
    [_playButton setBackgroundImage:[UIImage imageNamed:@"videoPlay"] forState:UIControlStateNormal];
    
}

//timer function

- (void)updateCounter:(NSTimer *)theTimer {
    
    secondsLeft ++ ;
    hours = secondsLeft / 3600;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    
    if (minutes > 15)
    {
        [_recordPauseButton setHidden:YES];
        [_playButton setHidden:NO];
        [_stopButton setHidden:YES];
        
        [_recorder stop];
        [_recordPauseButton setEnabled:YES];
        [timer invalidate];
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: @"Recording time limit is 15 minutes."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
    
}
-(void)countdownTimer {
    
    secondsLeft = hours = minutes = seconds = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

@end
