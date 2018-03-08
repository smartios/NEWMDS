//
//  SecureTRController.h
//  MDS
//
//  Created by SS068 on 21/12/17.
//  Copyright © 2017 SL-167. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecureTRController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataDic;


@end
