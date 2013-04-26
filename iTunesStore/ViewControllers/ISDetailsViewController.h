//
//  ISDetailsViewController.h
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSString *buyLink;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSString *appDescrip;
@property (strong, nonatomic) UIImage *bigAppImage;


@end
