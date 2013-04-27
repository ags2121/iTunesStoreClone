//
//  ISDataFetchSingleton.h
//  iTunesStore
//
//  Created by Alex Silva on 4/24/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"

@interface ISDataFetchSingleton : NSObject


@property (strong, nonatomic) NSCache *queryCache;

// The applications core data context
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

+ (ISDataFetchSingleton *) sharedInstance;
-(void)beginQuery: (NSString*)queryURL;
-(void)fetchQuery:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error;

- (BOOL)doesAppExistInDB:(NSString*)appName;
- (void)addAppToFavorites:(NSDictionary *)appInfo;
- (void)removeAppFromFavorites:(NSString *)appName;
- (void) deleteAllApps;

@end
