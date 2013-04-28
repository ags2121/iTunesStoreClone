//
//  App.h
//  iTunesStore
//
//  Created by Alex Silva on 4/27/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface App : NSManagedObject

@property (nonatomic, retain) NSString * appDescription;
@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) NSString * appPrice;
@property (nonatomic, retain) NSString * buyLink;
@property (nonatomic, retain) NSString * developerName;
@property (nonatomic, retain) NSNumber * starRating;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * largeImageURL;

@end
