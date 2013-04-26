//
//  ISSearchCollectionViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISSearchCollectionViewController.h"
#import "ISDataFetchSingleton.h"

@interface ISSearchCollectionViewController ()

@property (strong, nonatomic) NSString* currentQuery;

@end

@implementation ISSearchCollectionViewController

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
    
    //register VC as accepting of notifications named "DidLoadNewData" from dataFetchSingleton
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTable:)
                                                 name:@"DidLoadNewData"
                                               object:nil];
    
    //register VC as accepting of notifications named "DidLoadNewData" from dataFetchSingleton
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTable:)
                                                 name:@"useCachedData"
                                               object:nil];
    
    //register VC as accepting of notifications named "CouldNotConnectToFeed" from dataFetchSingleton
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUIAlert:)
                                                 name:@"CouldNotConnectToFeed"
                                               object:nil];
    
    //register VC as accepting of notifications named "NoDataInFeed" from dataFetchSingleton
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUIAlert:)
                                                 name:@"NoDataInFeed"
                                               object:nil];
    
    
    self.currentQuery = @"https://itunes.apple.com/search?term=tabular&media=software";
    [[ISDataFetchSingleton sharedInstance] beginQuery:self.currentQuery];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification callback methods
-(void)loadTable:(NSNotification*)notif
{
    NSMutableDictionary *data = [[[ISDataFetchSingleton sharedInstance] queryCache] objectForKey:self.currentQuery];
    
    NSLog(@"Print data from cache: %@", data);
}


@end
