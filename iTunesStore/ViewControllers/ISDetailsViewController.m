//
//  ISDetailsViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISDetailsViewController.h"
#import "ISDataFetchSingleton.h"

@interface ISDetailsViewController ()

@end

@implementation ISDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"app name in dvc: %@", self.appName);
    
    self.textView.text = self.appDescrip;
    self.appLabel.text = self.appName;
    self.appLabel.layer.cornerRadius = 10;
    self.appLabel.clipsToBounds = YES;
    
    //TODO: grab managed object context
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyBtnPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.buyLink]];
}
    
 

- (IBAction)favBtnPressed:(id)sender {
    NSLog(@"fav btn pressed");
    
    if ( ! [[ISDataFetchSingleton sharedInstance] doesAppExistInDB:self.appName] ){
        NSLog(@"app does not exist in core data, we will add it");
        [[ISDataFetchSingleton sharedInstance] addAppToFavorites:self.appInfoForCoreData];
    }
    
}

- (IBAction)dismissBtnPressed:(id)sender {
    [self.delegate detailsViewDidDismiss:self];
}

@end
