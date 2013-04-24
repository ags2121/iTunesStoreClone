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

+ (ISDataFetchSingleton *) sharedInstance;
-(void)beginQuery: (NSString*)queryURL;
-(void)fetchQuery:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error;

@end
