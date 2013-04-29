//
//  NoDataView.h
//  iTunesStore
//
//  Created by Alex Silva on 4/28/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoDataView : UIView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *noDataTitle;
@property (weak, nonatomic) IBOutlet UILabel *noDataSubtitle;


@end
