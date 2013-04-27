//
//  ISSearchViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

static NSString * const kThumbnails = @"thumbnails";
static NSString * const kLargeImages = @"large images";

#import "ISSearchViewController.h"
#import "ISDataFetchSingleton.h"
#import "iTunesStoreCell.h"
#import "ISCollectionHeaderView.h"
#import "ISDetailsViewController.h"

@interface ISSearchViewController ()

@property (strong, nonatomic) NSString *currentQuery;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UIView *noDataView;
@property (nonatomic) BOOL isKeyboardShowing;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnCollectionView;
@property (strong, nonatomic) NSCache *imageCache;

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
    
    if(!_imageCache){
        _imageCache = [[NSCache alloc] init];
        
        NSString *dictionaryPath = [[NSBundle mainBundle] pathForResource:@"imageCacheInitData" ofType:@"plist"];

        [self.imageCache setObject:[NSMutableDictionary dictionaryWithContentsOfFile:dictionaryPath] forKey:kThumbnails];
        
        [self.imageCache setObject:[NSMutableDictionary dictionaryWithContentsOfFile:dictionaryPath] forKey:kLargeImages];
        
                
        //[[self.imageCache objectForKey:@"thumbnails"][@"0"] setObject:@"test" forKey:@"1"];
        
    
        
    }
    
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
    self.searchBar.placeholder = @"Search for apps!";
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
    
    NSString *section = [@(indexPath.section) stringValue];
    NSString *row = [@(indexPath.row) stringValue];
    
    //if a thumbnail exists, grab from cache
    if( [self.imageCache objectForKey:kThumbnails][section][row] ){
        
        NSData *thumbnailData = [self.imageCache objectForKey:kThumbnails][section][row];
        cell.thumbnail.image = [UIImage imageWithData: thumbnailData];
    }
    
    else{
        //else, download and store thumbnail image in cache
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * thumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl60"] ]];
            if ( thumbnailData == nil )
                NSLog(@"could not download thumbnail in cell: %@", indexPath);
                                                                                                   
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.thumbnail.image = [UIImage imageWithData: thumbnailData];
                [[self.imageCache objectForKey:kThumbnails][section] setObject:thumbnailData forKey:row];
            });
        });
    }
        
    //Show star rating
    NSUInteger starRating = [self.searchResults[indexPath.section][indexPath.row][@"averageUserRating"] intValue];
    cell.starRatingImage.image = [UIImage imageNamed: [NSString stringWithFormat:@"%dStar", starRating]];
    
    //Show price
    cell.price.text = self.searchResults[indexPath.section][indexPath.row][@"formattedPrice"];

    //Show app name
    cell.appName.text = self.searchResults[indexPath.section][indexPath.row][@"trackName"];
    
    //Show developer name
    cell.developerName.text = self.searchResults[indexPath.section][indexPath.row][@"artistName"];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
     ISCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                          UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader" forIndexPath:indexPath];
     
     NSUInteger starRating = [self.searchResults[indexPath.section][indexPath.row][@"averageUserRating"] intValue];
     
     headerView.starRating.text = [NSString stringWithFormat:@"%d Star Rated Apps", starRating];

     return headerView;
 }

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    
    NSLog(@"DID select item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isSelected) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedView.image = nil;
        cell.isSelected = NO;
    }
    else{
        cell.backgroundColor = [UIColor redColor];
        cell.selectedView.image = [UIImage imageNamed:@"catPhone"];
        cell.isSelected = YES;
        
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
        NSLog(@"DID deselect item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectedView.image = nil;
    cell.isSelected = NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *indexPathArray = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *indexPath = indexPathArray[0];
    
    if ([segue.identifier isEqualToString:@"segueToDetailVC"]){
        
        ISDetailsViewController *dvc = (ISDetailsViewController*)segue.destinationViewController;
    
        dvc.appDescrip = self.searchResults[indexPath.section][indexPath.row][@"description"];
        dvc.appName = self.searchResults[indexPath.section][indexPath.row][@"trackName"];
        
        NSLog(@"app name in searchVC: %@", dvc.appName);
        
        NSString *replaceHTTPURL = [self.searchResults[indexPath.section][indexPath.row][@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"https" withString:@"itms"];
        dvc.buyLink = replaceHTTPURL;
        
        NSLog(@"buy link: %@", dvc.buyLink);
        
        //Download and pass
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *bigImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl100"] ]];
            if ( bigImageData == nil )
                NSLog(@"could not pass big image to detail view");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                    dvc.largeImageView.image = [UIImage imageWithData:bigImageData scale:0.625];
                    NSLog(@"big image for iPhone");
                }
                else{
                    dvc.largeImageView.image = [UIImage imageWithData:bigImageData];
                    NSLog(@"big image for iPad");
                }
                
            });
        });
        
    }
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
