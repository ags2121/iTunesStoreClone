//
//  ISDataFetchSingleton.m
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

NSString * const kCachedDate = @"cachedDate";

#import "ISDataFetchSingleton.h"

@interface ISDataFetchSingleton ()

@property (strong, nonatomic) NSString* currentQueryURL;

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
        //individualNewsFeeds is a mutable array of dictionaries containing an individual amendment's newsfeed, keyed by title, i.e. "One"
        _queryCache = [[NSCache alloc] init];
    }
    
    return self;
}

-(void)beginQuery: (NSString*)queryURL
{
    //TODO: implement Activity Refresher
    //if (!tbvc.refreshControl.isRefreshing) [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
    if( [self cacheNeedsToBeUpdated: queryURL] ){
        
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
        
        NSLog(@"Connection error!");
        
        //TODO: no connection, connection time-out handling
        
        //send message to present AlertView that connection could not be established.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CouldNotConnectToFeed"
                                                            object:nil];
        
    } else {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:retrievedData options:kNilOptions error:&error];
        NSMutableDictionary *mutableResults = [NSMutableDictionary dictionaryWithDictionary:results];
        
        //add date of retrievel to result dictionary
        [mutableResults setObject:[NSDate date] forKey: kCachedDate];
        
        //TODO: store results in Cache, store date of retrieval in Cache
        [self.queryCache setObject: mutableResults forKey:self.currentQueryURL];
        
        //send message to reload search VC
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoadNewData"
                                                            object:nil];
        
    }
    
}

-(BOOL)cacheNeedsToBeUpdated:(NSString*)queryURL
{
    //TODO: check if cache has results for the given queryParam, and, if so if the results are out of date
    
    if( ![self.queryCache objectForKey:queryURL] )
        return YES;
    
    NSDate *dateOfCache = [self.queryCache objectForKey:kCachedDate];
    
    if( [self hasBeenMoreThanAWeek:dateOfCache] )
        return YES;
    
    return NO;
        
}

-(BOOL)hasBeenMoreThanAWeek:(NSDate*)cachedDate
{

    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:cachedDate toDate:[NSDate date] options:0];
    if ( ([components day] + 1) >= 7)
        return YES;
    
    return NO;
}

@end
