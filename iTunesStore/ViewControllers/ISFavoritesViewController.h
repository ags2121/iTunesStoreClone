//
//  ISFavoritesViewController.h
//  iTunesStore
//
//  Created by Alex Silva on 4/27/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISDetailsViewController.h"

@interface ISFavoritesViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, ModalDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController* fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
