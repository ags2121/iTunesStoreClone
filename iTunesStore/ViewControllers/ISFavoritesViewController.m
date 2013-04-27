//
//  ISFavoritesViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/27/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISFavoritesViewController.h"
#import "ISDataFetchSingleton.h"
#import "iTunesStoreCell.h"
#import "ISCollectionHeaderView.h"
#import "ISDetailsViewController.h"

@interface ISFavoritesViewController ()

@property (strong, nonatomic) UIView *noDataView;

@end

@implementation ISFavoritesViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
