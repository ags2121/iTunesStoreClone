//
//  ISDetailsViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISDetailsViewController.h"
#import "ISDataFetchSingleton.h"
#import "ISFavoritesViewController.h"

@interface ISDetailsViewController ()

@property (nonatomic) BOOL isFavorited;
@property (nonatomic) BOOL didDelete;

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
    
    [self.activityIndicator startAnimating];
    
    //add textView border
    self.textView.layer.borderWidth = 4.0f;
    self.textView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    //if app exists in data star, change fav btn image to a filled star, and set bool
    if( [[ISDataFetchSingleton sharedInstance] doesAppExistInDB:self.appName] ){
        [self.favBtn setImage: [UIImage imageNamed:@"filled_star"] forState:UIControlStateSelected];
        self.favBtn.selected = YES;
        self.isFavorited = YES;
    }
    else{
        [self.favBtn setImage: [UIImage imageNamed:@"empty_star"] forState:UIControlStateNormal];
        self.favBtn.selected = NO;
        self.isFavorited = NO;
    }
    
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
    
    if ( !self.isFavorited ){
        self.didDelete = NO;
        NSLog(@"app does not exist in core data, we will add it");
        [[ISDataFetchSingleton sharedInstance] addAppToFavorites:self.appInfoForCoreData];
        [self.favBtn setImage: [UIImage imageNamed:@"filled_star"] forState:UIControlStateSelected];
        self.favBtn.selected = YES;
        self.isFavorited = YES;
    }
    else{
        NSLog(@"we are unfavoriting");
        self.didDelete = YES;
        [[ISDataFetchSingleton sharedInstance] removeAppFromFavorites:self.appName];
        [self.favBtn setImage: [UIImage imageNamed:@"empty_star"] forState:UIControlStateNormal];
        self.favBtn.selected = NO;
        self.isFavorited = NO;
        
    }
    
}

- (IBAction)dismissBtnPressed:(id)sender {

    if( [self.delegate isKindOfClass:[ISFavoritesViewController class]] && self.didDelete){
        NSLog(@"we will reload data");
        [self.delegate reloadData:self];
    }
    
    self.didDelete = NO;
    [self.delegate detailsViewDidDismiss:self];
}

@end
