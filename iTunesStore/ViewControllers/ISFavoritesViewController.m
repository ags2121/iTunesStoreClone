//
//  ISFavoritesViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/27/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//


//TODO: add functionality to delete all favorite apps
//TODO: add functionality to sort favorites into sections

#import "ISFavoritesViewController.h"
#import "ISDataFetchSingleton.h"
#import "iTunesStoreCell.h"
#import "ISCollectionHeaderView.h"
#import "ISDetailsViewController.h"
#import "App.h"

@interface ISFavoritesViewController ()

@property (strong, nonatomic) UIView *noDataView;
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedItem;
@property (strong, nonatomic) iTunesStoreCell *theSelectedCell;
@property (strong, nonatomic) UIImage *catPhoto;
@property (strong, nonatomic) UICollectionView *theRealCollectionView;

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

    
    //set delegates, datasource
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //TODO: if there are no favorites, show default screen
    //[self.collectionView addSubview:_noDataView];
    
//    [self.collectionView registerClass: [UICollectionReusableView class]forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader"];
    
    self.catPhoto = [UIImage imageNamed:@"catPhone"];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    // Fetch the data
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    NSLog(@"view will appear");
    NSLog(@"row count in view will appear: %lu", (unsigned long)[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] );
//    if (  [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 1 ){
//        [self.collectionView deleteSections: [NSIndexSet indexSetWithIndex:0]];
//        NSLog(@"row count after delete: %lu", (unsigned long)[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] );
//    }
    
    [self.collectionView reloadData];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched results controller Delegate
/*******************************************************************************
 * @method          fetchedResultsController
 * @abstract
 * @description
 ******************************************************************************/
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the App entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    
	// Create the sort descriptors array.
	NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:authorDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil cacheName:nil];
    
    
	self.fetchedResultsController.delegate = self;
    
    
	return self.fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSLog(@"fetched results controller delegate method firing");
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"%d rows in section %d", [sectionInfo numberOfObjects], section);
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    
    NSLog(@"sections in tableview: %lu", (unsigned long)[[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    iTunesStoreCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"iTunesStoreCell" forIndexPath:indexPath];
    
    App *app = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.appName.text = app.appName;
    cell.developerName.text = app.developerName;
    cell.starRatingImage.image = [UIImage imageNamed: [NSString stringWithFormat:@"%dStar", [app.starRating intValue]]];
    cell.thumbnail.image = [UIImage imageWithData:app.thumbnail];
    cell.thumbnail.layer.cornerRadius = 10;
    cell.thumbnail.clipsToBounds = YES;
    cell.price.text = app.appPrice;
    
    //give cell a border
    cell.layer.borderWidth = 2.0f;
    cell.layer.borderColor = [[UIColor magentaColor] CGColor];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:
(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ISCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                          UICollectionElementKindSectionHeader withReuseIdentifier:@"iTunesStoreHeader" forIndexPath:indexPath];
    [headerView.eraseButton addTarget:self action:@selector(eraseFavorites:event:) forControlEvents:UIControlEventTouchUpInside];
    
    headerView.eraseButton.layer.cornerRadius = 10;
    headerView.eraseButton.clipsToBounds = YES;
    headerView.eraseButton.layer.borderWidth = 2.0f;
    headerView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    //give header a border
    headerView.layer.borderWidth = 4.0f;
    headerView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    return headerView;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    NSLog(@"DID select item at indexPath: %@", indexPath);
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    self.indexPathForSelectedItem = indexPath;

    App *app = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell.isSelected) {
        cell.isSelected = NO;
    }
    else{
        cell.isSelected = YES;
    }
    
    //add cat image to cell
    //cell.selectedView.image = self.catPhoto;
    
    ISDetailsViewController *dvc;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        dvc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ISDetailsViewController"];
    
    else
        dvc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"ISDetailsViewController"];
    
    //set delegate
    dvc.delegate = self;
    
    //pass values to properties
    dvc.appDescrip = app.appDescription;
    dvc.appName = app.appName;
    dvc.buyLink = app.buyLink;
    
    //Download and pass large image
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData *bigImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: app.largeImageURL]];
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
    
    //assemble dictionary for readding favorites in the detail VC
    dvc.appInfoForCoreData = @{@"appName" : app.appName, @"appDescription" : app.appDescription, @"buyLink" : app.buyLink, @"starRating" : app.starRating, @"developerName" : app.developerName, @"appPrice" : app.appPrice, @"thumbnail" : app.thumbnail, @"largeImageURL" : app.largeImageURL};
    
    [self presentViewController:dvc animated:YES completion:nil];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
    NSLog(@"DID deselect item");
    iTunesStoreCell *cell = (iTunesStoreCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
}

//TODO: why can't we access the cells' properties?
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    //why does cell return null? 
    iTunesStoreCell *cell = (iTunesStoreCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"we are in the deselect method, celL: %@", cell);
    NSLog(@"index path: %@", indexPath);
    //NSLog(@"the collection view: %@", self.collectionView);
    
    [UIView animateWithDuration:1.2 animations:^{
        
        cell.selectedView.alpha = 0;
        
    }completion:^(BOOL finished){
        cell.selectedView.image = nil;
        cell.selectedView.alpha = 1;
    }];
    
}

//TODO: why is indexPath returning null in prepareForSegue?
/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"using fecthed results method: %@",[_fetchedResultsController objectAtIndexPath: [self.collectionView indexPathsForSelectedItems][0]]);
    NSArray *indexPathArray = [self.collectionView indexPathsForSelectedItems];
    
    NSLog(@"indexPath array in prepare for segue: %@", indexPathArray);
    NSIndexPath *indexPath = indexPathArray[0];
    
    NSLog(@"indexPath in prepare for segue: %@", indexPath);
    
    iTunesStoreCell *cell = (iTunesStoreCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    App *app = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([segue.identifier isEqualToString:@"segueToDetailVC"]){
        
        //add cat image to cell
        cell.selectedView.image = [UIImage imageNamed:@"catPhone"];
        
        ISDetailsViewController *dvc = (ISDetailsViewController*)segue.destinationViewController;
        
        //set delegate
        dvc.delegate = self;
        
        NSLog(@"app descript: %@", app.appDescription);
        
        //pass values to properties
        dvc.appDescrip = app.appDescription;
        dvc.appName = app.appName;
        dvc.buyLink = app.buyLink;
        
        //Download and pass large image
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData *bigImageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: app.largeImageURL]];
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
            });
        });
    }
}
*/

#pragma mark - ModalDelegate delegate

- (void)detailsViewDidDismiss: (ISDetailsViewController*)dvc
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    //this method doesn't work
    [self deselectItemAtIndexPath:self.indexPathForSelectedItem animated:YES];
}

- (void)reloadData: (ISDetailsViewController*)dvc
{    
    // Fetch the data
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.collectionView reloadData];
}

#pragma mark - UIAlertView methods

-(void)eraseFavorites:(id)sender event:(id)event
{
    
    UIAlertView *av;
    
    if( [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0)
        av = [[UIAlertView alloc] initWithTitle:nil message:@"There are no favorites to erase!\nAdd some favorites in the search zone." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    else
        av = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to erase all of your favorite apps?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clicked button at index: %d", buttonIndex);
    if (buttonIndex == 0) {
        [[ISDataFetchSingleton sharedInstance] deleteAllApps];
        [self.collectionView reloadData];
    }
}


@end
