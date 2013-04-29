//
//  ISSearchViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

static NSString * const kThumbnails = @"thumbnails";

#import "ISSearchViewController.h"
#import "ISDataFetchSingleton.h"
#import "iTunesStoreCell.h"
#import "ISCollectionHeaderView.h"
#import "ISDetailsViewController.h"
#import "NoDataView.h"

@interface ISSearchViewController ()

@property (strong, nonatomic) NSString *currentQuery;
@property (strong, nonatomic) NSString *rawSearchString;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NoDataView *noDataView;
@property (nonatomic) BOOL isKeyboardShowing;
@property (strong, nonatomic) UITapGestureRecognizer * tapOnCollectionView;
@property (strong, nonatomic) NSCache *thumbnailCache;
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedItem;
@property (strong, nonatomic) UIImage *catPhoto;
@property (nonatomic) BOOL noDataViewShowing;

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
    self.searchBar.placeholder = @"Search for apps!";
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //if the searchResults array is null, show a default screen
    if(!self.searchResults){
        //TODO: subclass noDataView?
       _noDataView = [[[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:self options:nil] objectAtIndex:0];
        _noDataView.frame = self.collectionView.frame;
        [self.collectionView addSubview:_noDataView];
        self.noDataViewShowing = YES;
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
    
    //[self.collectionView registerClass: [UICollectionReusableView class]forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader"];
    
    //set reference to catPhoto
    self.catPhoto = [UIImage imageNamed:@"catPhone"];
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
    
    //init thumbnailCache if its nil
    if(!_thumbnailCache) _thumbnailCache = [[NSCache alloc] init];
    
    //create data structure for query, if not present
    if (! [self.thumbnailCache objectForKey:self.currentQuery] ) {
        NSString *dictionaryPath = [[NSBundle mainBundle] pathForResource:@"imageCacheInitData" ofType:@"plist"];
        [self.thumbnailCache setObject:[NSMutableDictionary dictionaryWithContentsOfFile:dictionaryPath] forKey:self.currentQuery];
    }
    
    //load collectionview data
    [self.collectionView reloadData];
    
    //remove placeholder view to reveal results
    [UIView animateWithDuration:0.8 animations:^{
        self.noDataView.alpha = 0;
    }completion:^(BOOL finished){
        
        [self.noDataView.activityIndicator stopAnimating];
        [self.noDataView removeFromSuperview];
        self.noDataViewShowing = NO;
        self.noDataView.alpha = 1;
    }];
}

-(void)showUIAlert:(NSNotification*)notif
{

    NSString* alertMessage;
    
    if ([notif.name isEqualToString:@"CouldNotConnectToFeed"]) alertMessage = @"Could not connect to the App Store.\nPlease check internet connection.";
    
    else if([notif.name isEqualToString:@"NoDataInFeed"]) alertMessage = [NSString stringWithFormat:@"No app results for \"%@\"!", self.rawSearchString];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
    [self.noDataView.activityIndicator stopAnimating];

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
    
    NSLog(@"section: %@", section);
    NSLog(@"row: %@", row);
    
    
    //if a thumbnail exists, grab from cache
    if( [self.thumbnailCache objectForKey:self.currentQuery][section][row] ){
        
        NSData *thumbnailData = [self.thumbnailCache objectForKey:self.currentQuery][section][row];
        cell.thumbnail.image = [UIImage imageWithData: thumbnailData];
    }
    
    else{
        //else, download and store thumbnail image in cache
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * thumbnailData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl60"]]];
            if ( thumbnailData == nil ){
                NSLog(@"could not download thumbnail in cell: %@", indexPath);
                //return;
            }
            else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.thumbnail.image = [UIImage imageWithData: thumbnailData];
                [[self.thumbnailCache objectForKey:self.currentQuery][section] setObject:thumbnailData forKey:row];
            });
            }
        });
    }
    
    //round thumbnail corners
    cell.thumbnail.layer.cornerRadius = 10;
    cell.thumbnail.clipsToBounds = YES;
    
    //give cell a border
    cell.layer.borderWidth = 2.0f;
    cell.layer.borderColor = [[UIColor magentaColor] CGColor];
    
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
     
     NSUInteger starRating = [[self.searchResults[indexPath.section][indexPath.row] objectForKey: @"averageUserRating"] intValue];
     
     headerView.starRating.text = [NSString stringWithFormat:@"%d Star Rated Apps", starRating];
     
     //give header a border
     headerView.layer.borderWidth = 4.0f;
     headerView.layer.borderColor = [[UIColor blackColor] CGColor];

     return headerView;
 }

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    NSLog(@"DID select item");
    self.indexPathForSelectedItem = indexPath;
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isSelected) {
        cell.isSelected = NO;
    }
    else{
        cell.isSelected = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    NSLog(@"DID deselect item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *indexPathArray = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *indexPath = indexPathArray[0];
    iTunesStoreCell *cell = (iTunesStoreCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if ([segue.identifier isEqualToString:@"segueToDetailVC"]){
        
        //add cat image to cell
        cell.selectedView.image = self.catPhoto;
        
        ISDetailsViewController *dvc = (ISDetailsViewController*)segue.destinationViewController;
        
        //set delegate
        dvc.delegate = self;
        
        //pass values to properties
        dvc.appDescrip = self.searchResults[indexPath.section][indexPath.row][@"description"];
        dvc.appName = self.searchResults[indexPath.section][indexPath.row][@"trackName"];

        NSString *replaceHTTPURL = [self.searchResults[indexPath.section][indexPath.row][@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"https" withString:@"itms"];
        dvc.buyLink = replaceHTTPURL;
        
        //pass dictionary of data model properties so user can add app to favorites
        NSNumber *starRating = [NSNumber numberWithInt: [self.searchResults[indexPath.section][indexPath.row][@"averageUserRating"] intValue]];
        
        NSString *largeImageURL = self.searchResults[indexPath.section][indexPath.row][@"artworkUrl100"];
        
        if(cell.thumbnail.image == nil)
            cell.thumbnail.image = [UIImage imageNamed:@"blankThumbnail"];
        
        NSDictionary *appInfoForCoreData = @{@"appName" : dvc.appName, @"appDescription" : dvc.appDescrip, @"buyLink" : dvc.buyLink, @"starRating" : starRating, @"developerName" : cell.developerName.text, @"appPrice" : cell.price.text, @"thumbnail" : UIImagePNGRepresentation(cell.thumbnail.image), @"largeImageURL" : largeImageURL};
        
        dvc.appInfoForCoreData = appInfoForCoreData;
        
        //Download and pass large image
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *bigImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.searchResults[indexPath.section][indexPath.row][@"artworkUrl100"] ]];
            if ( bigImageData == nil )
                NSLog(@"could not pass big image to detail view");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                    dvc.largeImageView.image = [UIImage imageWithData:bigImageData scale:0.625];
                    dvc.largeImageView.layer.cornerRadius = 10;
                    dvc.largeImageView.clipsToBounds = YES;
                    NSLog(@"big image for iPhone");
                }
                else{
                    dvc.largeImageView.image = [UIImage imageWithData:bigImageData];
                    dvc.largeImageView.layer.cornerRadius = 10;
                    dvc.largeImageView.clipsToBounds = YES;
                    NSLog(@"big image for iPad");
                }
                
                [dvc.activityIndicator stopAnimating];
                
            });
        });
        
    }
}

#pragma mark - UISearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search button clicked");
    
    NSString *caseOfMultipleParams = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    self.rawSearchString = searchBar.text;
    
    self.currentQuery = [NSString stringWithFormat: @"https://itunes.apple.com/search?term=%@&media=software", caseOfMultipleParams];
    [[ISDataFetchSingleton sharedInstance] beginQuery:self.currentQuery];
   
    [searchBar resignFirstResponder];
    
    if (!self.noDataViewShowing){
        [self.collectionView addSubview:_noDataView];
        self.noDataViewShowing = YES;
    }
    
    [self.noDataView.activityIndicator startAnimating];
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

#pragma mark - ModalDelegate delegate

- (void)detailsViewDidDismiss: (ISDetailsViewController*)dvc
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self deselectItemAtIndexPath:self.indexPathForSelectedItem animated:YES];
    
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    iTunesStoreCell *cell = (iTunesStoreCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:1.2 animations:^{
        
        cell.selectedView.alpha = 0;
        
    }completion:^(BOOL finished){
        cell.selectedView.image = nil;
        cell.selectedView.alpha = 1;
    }];
}


@end
