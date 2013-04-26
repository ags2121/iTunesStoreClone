//
//  iTunesStoreCell.h
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iTunesStoreCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *starRatingImage;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UILabel *developerName;

@property (nonatomic) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end
