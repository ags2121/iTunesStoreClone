//
//  ISDataFetchSingleton.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

NSString * const kCachedDate = @"cachedDate";

#import "ISDataFetchSingleton.h"
#import "App.h"

@interface ISDataFetchSingleton ()

@property (strong, nonatomic) NSString *currentQueryURL;
@property (strong, nonatomic) NSString *storedFilePath;

@end

@implementation ISDataFetchSingleton

+ (ISDataFetchSingleton *) sharedInstance {

    static dispatch_once_t _p;
    
    __strong static id _singleton = nil;
    
    dispatch_once(&_p, ^{
        _singleton = [[self alloc] init];
    });
    
    return _singleton;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _queryCache = [[NSCache alloc] init];
        NSLog(@"queryCache after alloc init: %@", _queryCache);
    }
    
    return self;
}

-(void)beginQuery: (NSString*)queryURL
{
    //TODO: implement Activity Refresher
    //if (!tbvc.refreshControl.isRefreshing) [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
    if( [self cacheNeedsToBeUpdated: queryURL] ){
        NSLog(@"Cache needed to be updated");
        
    //set currentQueryURL to current query url, so we can use it as a key in the cache later
    self.currentQueryURL = queryURL;
    
    NSURL *url = [NSURL URLWithString: queryURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(fetchQuery:finishedWithData:error:)];
    }
    
    //else, send useCachedData notification
    else{
        NSLog(@"Cache DIDNT need to be updated");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"useCachedData" object:nil];
    }
    
    
}

- (void)fetchQuery:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    
    if (error != nil) {
        // failed; either an NSURLConnection error occurred, or the server returned
        // a status value of at least 300
        //
        // the NSError domain string for server status errors is kGTMHTTPFetcherStatusDomain
        int status = [error code];
        
        NSLog(@"Connection error! Error code: %d", status);
        
        //TODO: no connection, connection time-out handling
        
        //send message to present AlertView that connection could not be established.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CouldNotConnectToFeed"
                                                            object:nil];
        
    } else {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
        NSMutableDictionary *mutableResults = [NSMutableDictionary dictionaryWithDictionary:results];
        
        //sort results by rating
        NSMutableArray *resultsArray = [mutableResults[@"results"] mutableCopy];
        
        [resultsArray sortUsingComparator:^(NSDictionary* dict1, NSDictionary* dict2) {
            
            
            NSNumber *rating1 = [NSNumber numberWithInt:[[dict1 objectForKey:@"averageUserRating"] intValue]];
            NSNumber *rating2 = [NSNumber numberWithInt:[[dict2 objectForKey:@"averageUserRating"] intValue]];

            return [rating2 compare: rating1];
            
        }];
        
       //NSLog(@"sorted results: %@", resultsArray);
        
        //Iterate through sorted array, once a new rating is found, extract subset into array of uniform rating
        //TODO: account for apps with no ratings
        NSUInteger lowerBound = 0;
        NSMutableArray *resultsGroupedBySections = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < resultsArray.count-1; i++) {
            if ( [resultsArray[i][@"averageUserRating"] intValue] != [resultsArray[i+1][@"averageUserRating"] intValue]) {
                [resultsGroupedBySections addObject: [resultsArray subarrayWithRange:NSMakeRange(lowerBound, (i-lowerBound)+1)] ];
                lowerBound = i+1;
            }
        }
        //account for dict at last index, put it in its own section array
        NSUInteger lastIndex = resultsArray.count-1;
        if( [resultsArray[lastIndex-1][@"averageUserRating"] intValue] != [resultsArray[lastIndex][@"averageUserRating"] intValue] ){
            [resultsGroupedBySections addObject: @[resultsArray[lastIndex]]];
            NSLog(@"last object: %@", [resultsGroupedBySections lastObject]);
        }

        
        //NSLog(@"results grouped by %d sections: %@", resultsGroupedBySections.count, resultsGroupedBySections);
        
        //TODO: download images in this class instead
    
        //Replace "results" array with new sorted, sectioned array
        [mutableResults setObject:resultsGroupedBySections forKey:@"results"];
        
        //add date of retrievel to result dictionary
        [mutableResults setObject:[NSDate date] forKey: kCachedDate];
        
        [self.queryCache setObject: mutableResults forKey:self.currentQueryURL];
        
         NSLog(@"retrieving cached date after setting it %@", [self.queryCache objectForKey:self.currentQueryURL][kCachedDate]);
        
        //NSLog(@"query Cache: %@", [self.queryCache objectForKey:self.currentQueryURL]);
        
        //send message to reload search VC
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoadNewData"
                                                            object:nil];
        
    }
    
}

-(BOOL)cacheNeedsToBeUpdated:(NSString*)queryURL
{
    
    NSDate *dateOfCache = (NSDate*)[self.queryCache objectForKey:self.currentQueryURL][kCachedDate];
    
    if( ![self.queryCache objectForKey:queryURL] )
        return YES;
    
    
    else if( [self hasBeenMoreThanAWeek: dateOfCache] ){
        return YES;
    }
    
    return NO;
        
}

-(BOOL)hasBeenMoreThanAWeek:(NSDate*)cachedDate
{
    NSLog(@"cachedDate: %@", cachedDate);

    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:cachedDate toDate:[NSDate date] options:0];
    if ( ([components day] + 1) >= 7){
        NSLog(@"Days between dates: %d", ([components day] + 1));
        return YES;
    }
    
    return NO;
}

#pragma mark - Core data methods 

- (void)addAppToFavorites:(NSDictionary *)appInfo
{
    // Create a new instance of App object
	App *app = (App *)[NSEntityDescription insertNewObjectForEntityForName:@"App"
                                                    inManagedObjectContext:self.managedObjectContext];
    app.appName = appInfo[@"appName"];
    app.appPrice = appInfo[@"appPrice"];
    app.appDescription = appInfo[@"appDescription"];
    app.thumbnail = appInfo[@"thumbnail"];
    app.starRating = appInfo[@"starRating"];
    app.buyLink = appInfo[@"buyLink"];
    app.developerName = appInfo[@"developerName"];
    app.largeImageURL = appInfo[@"largeImageURL"];
    
    NSError *error = nil;
	// Commit the change to on-disk store
	if (![self.managedObjectContext save:&error]) {
		//TODO: Handle the error.
	}
}
- (void)removeAppFromFavorites:(NSString *)appName
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appName == %@", appName];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"appName", nil];
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [self.managedObjectContext deleteObject:items[0]];
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@", appName, error);
    }
    
}

- (void) deleteAllApps
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (App *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted", managedObject.appName);
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",@"App",error);
    }
}

- (BOOL)doesAppExistInDB:(NSString*)appName
{
    // Create a new App object (if needed)
   	NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"App"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appName == %@", appName];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"appName", nil];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems.count == 0)
        return NO;
    
    return YES;
}
    
@end
