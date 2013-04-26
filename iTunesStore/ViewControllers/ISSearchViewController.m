//
//  ISSearchViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISSearchViewController.h"
#import "ISDataFetchSingleton.h"
#import "iTunesStoreCell.h"

@interface ISSearchViewController ()

@property (strong, nonatomic) NSString *currentQuery;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UIView *noDataView;
@property (nonatomic) BOOL isKeyboardShowing;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnCollectionView;

@end

@implementation ISSearchViewController

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
    
    //set delegates, datasource
    self.searchBar.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //if the searchResults array is null, show a default screen
    if(!self.searchResults){
        //TODO: subclass noDataView?
       _noDataView = [[[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:self options:nil] objectAtIndex:0];
        _noDataView.frame = self.collectionView.frame;
        [self.collectionView addSubview:_noDataView];
    }
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    //Tap Gesture recognizer
    _tapOnCollectionView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnCollectionView:)];
    [_tapOnCollectionView setDelegate:self];
    [self.collectionView addGestureRecognizer:_tapOnCollectionView];
    
    [self.collectionView registerClass: [UICollectionReusableView class]forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification callback methods
-(void)loadTable:(NSNotification*)notif
{
    self.searchResults = [[[ISDataFetchSingleton sharedInstance] queryCache] objectForKey:self.currentQuery][@"results"];
    
    //NSLog(@"Print data from cache: %@", self.searchResults);
    
    [self.collectionView reloadData];
    
    [UIView animateWithDuration:0.8 animations:^{
        self.noDataView.alpha = 0;
    }completion:^(BOOL finished){
        
        [self.noDataView removeFromSuperview];
    }];
    
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [self.searchResults[section] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.searchResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    iTunesStoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"iTunesStoreCell" forIndexPath:indexPath];

    cell.selectedBackgroundView.layer.contents =  (id) [UIImage imageNamed:@"star"].CGImage;
    cell.selectedBackgroundView.layer.masksToBounds = YES;
    
    //Show thumbnail image
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * thumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl60"] ]];
        if ( thumbnailData == nil )
            NSLog(@"could not download thumbnail in cell: %@", indexPath);
                                                                                               
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.thumbnail.image = [UIImage imageWithData: thumbnailData];
        });
    });
    
    //Show star rating
    NSUInteger starRating = [self.searchResults[indexPath.section][indexPath.row][@"averageUserRating"] intValue];
    cell.starRatingImage.image = [UIImage imageNamed: [NSString stringWithFormat:@"%dStar", starRating]];
    
    //Show price
    cell.price.text = self.searchResults[indexPath.section][indexPath.row][@"formattedPrice"];

    //Show app name
    cell.appName.text = self.searchResults[indexPath.section][indexPath.row][@"trackName"];
    
    //Show developer name
    cell.developerName.text = self.searchResults[indexPath.section][indexPath.row][@"artistName"];

    //Download, but don't show isSelected image
    
    [cell.selectedView setHidden:YES];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * isSelectedImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl100"] ]];
        if ( isSelectedImageData == nil )
            NSLog(@"could not download isSelectedImage in cell: %@", indexPath);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.selectedView.image = [UIImage imageWithData: isSelectedImageData];
        });
    });

    
    return cell;
}

- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
     UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                          UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader" forIndexPath:indexPath];
     headerView.backgroundColor = [UIColor whiteColor];
     return headerView;
 }

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    
    NSLog(@"DID select item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isSelected) {
        cell.backgroundColor = [UIColor clearColor];
        //[cell.selectedView setHidden:YES];
        cell.isSelected = NO;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.isSelected = YES;
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
        NSLog(@"DID deselect item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.isSelected = NO;
}

#pragma mark - UISearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search button clicked");
    
    NSString *caseOfMultipleParams = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    self.currentQuery = [NSString stringWithFormat: @"https://itunes.apple.com/search?term=%@&media=software", caseOfMultipleParams];
    [[ISDataFetchSingleton sharedInstance] beginQuery:self.currentQuery];

   
    [searchBar resignFirstResponder];
}

#pragma mark - keyboard notification callbacks

- (void)keyboardDidShow: (NSNotification *) notif{
    _isKeyboardShowing = YES;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    _isKeyboardShowing = NO;
}


#pragma mark - gestureRecognizer delegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.tapOnCollectionView && self.isKeyboardShowing){
        return YES;
    }
    else if (gestureRecognizer == self.tapOnCollectionView && !self.isKeyboardShowing){
        return NO;
    }
    
    return NO;
    
}

-(void)handleTapOnCollectionView:(UITapGestureRecognizer *)recognizer
{

    [self.searchBar resignFirstResponder];
}


@end
