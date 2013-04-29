//
//  ISCollectionHeaderView.h
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCollectionHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *starRating;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;

@end
