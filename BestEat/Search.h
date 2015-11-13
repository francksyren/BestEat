//
//  Search.h
//  BestEat
//
//  Created by Syren, Franck on 11/6/15.
//  Copyright © 2015 Syren, Franck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@class Search;

@protocol SearchDelegate

-(void)search:(Search *)search didFinishInitialSearch:(NSDictionary *)result;
-(void)search:(Search *)search didFinishFullSearch:(BOOL)success;

@end

@interface Search : NSObject

@property(nonatomic, weak) id<SearchDelegate> delegate;


-(void)cancelAllRequests;
-(void)searchWithQuery:(NSString *)query andLocation:(CLPlacemark *)placemark;

@end
