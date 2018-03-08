//
//  CalendarView.h
//  MDS
//
//  Created by SL-167 on 1/2/18.
//  Copyright © 2018 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarView : UIView

@property (nonatomic, strong) IBOutlet UIButton *select;
@property (nonatomic, strong) IBOutlet UIButton *cancel;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

@end
