//
//  M2DAPIGatekeeper.h
//  BoostMedia
//
//  Created by Akira Matsuda on 2013/01/13.
//  Copyright (c) 2013年 akira.matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2DAPIRequest.h"

extern NSString *const M2DHTTPMethodPOST;
extern NSString *const M2DHTTPMethodGET;

@interface M2DAPIGatekeeper : NSObject

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) NSArray *requestIdentifiers;
@property (nonatomic, copy) NSDictionary *baseParameter;
@property (nonatomic, copy) void (^didRequestIdentifierPushBlock)(NSString *identifier);
@property (nonatomic, copy) void (^didRequestIdentifierPopBlock)(NSArray *identifiers);

@property (nonatomic, copy) void (^initializeBlock)(M2DAPIRequest *request, NSDictionary *params);
@property (nonatomic, copy) void (^finalizeBlock)(M2DAPIRequest *request, id parsedObject);
@property (nonatomic, copy) id (^parseBlock)(NSData *data, NSError **error);
@property (nonatomic, copy) BOOL (^resultConditionBlock)(NSURLResponse *response, id parsedObject, NSError **error);

+ (instancetype)sharedInstance;
- (NSString *)sendRequestWithURL:(NSURL *)url method:(NSString *)method parametors:(NSDictionary *)params success:(void (^)(M2DAPIRequest *request, id parsedObject))successBlock failed:(void (^)(M2DAPIRequest *request, NSError *error))failureBlock asynchronous:(BOOL)flag;
- (NSString *)sendRequest:(M2DAPIRequest *)request;
- (instancetype)parseBlock:(id (^)(NSData *data, NSError **error))parseBlock;
- (instancetype)resultConditionBlock:(BOOL (^)(NSURLResponse *response, id parsedObject, NSError **error))resultConditionBlock;
- (instancetype)initializeBlock:(void (^)(M2DAPIRequest *request, NSDictionary *params))initializeBlock;
- (instancetype)finalizeBlock:(void (^)(M2DAPIRequest *request))finalizeBlock;
- (void)cancelRequestWithIdentifier:(NSString *)identifier;
- (void)cancelAllRequest;

@end
