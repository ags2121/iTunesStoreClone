//
//  ISDetailsViewController.h
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ISDetailsViewController;

@protocol ModalDelegate <NSObject>

- (void)detailsViewDidDismiss: (ISDetailsViewController*)dvc;
@optional
- (void)reloadData: (ISDetailsViewController*)dvc;

@end

@interface ISDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UIButton *dismissVCbtn;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;

@property (strong, nonatomic) NSString *buyLink;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSString *appDescrip;
@property (strong, nonatomic) NSDictionary *appInfoForCoreData;

@property (nonatomic, weak) id <ModalDelegate> delegate;

- (IBAction)favBtnPressed:(id)sender;
- (IBAction)dismissBtnPressed:(id)sender;

@end
