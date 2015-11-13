//
//  NSURLRequest+OAuth.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 7/2/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "NSURLRequest+OAuth.h"

#import "TDOAuth.h"

/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */

static NSString * const kConsumerKey       = @"QyJze0skL-NKRQSeDurAsw";
static NSString * const kConsumerSecret    = @"YIAu3cnElB3cTUAmoLX2jGo8pAs";
static NSString * const kToken             = @"XPs8DWooHvNxmLqOzKSJ8vXRDwagFiqG";
static NSString * const kTokenSecret       = @"a_9_YCsvaSe8CAI-TEO1q5JCtCE";

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
  return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
  if ([kConsumerKey length] == 0 || [kConsumerSecret length] == 0 || [kToken length] == 0 || [kTokenSecret length] == 0) {
    NSLog(@"WARNING: Please enter your api v2 credentials before attempting any API request. You can do so in NSURLRequest+OAuth.m");
  }

  return [TDOAuth URLRequestForPath:path
                      GETParameters:params
                             scheme:@"https"
                               host:host
                        consumerKey:kConsumerKey
                     consumerSecret:kConsumerSecret
                        accessToken:kToken
                        tokenSecret:kTokenSecret];
}

@end
