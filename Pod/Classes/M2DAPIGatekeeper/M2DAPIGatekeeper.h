//
//  M2DAPIGatekeeper.h
//  BoostMedia
//
//  Created by Akira Matsuda on 2013/01/13.
//  Copyright (c) 2013年 akira.matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2DAPIRequest.h"

extern NSString * _Nonnull const M2DHTTPMethodPOST;
extern NSString * _Nonnull const M2DHTTPMethodGET;

@interface M2DAPIGatekeeper : NSObject

@property (nonatomic, assign) BOOL showNetworkActivityIndicator;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) NSArray * _Nonnull requestIdentifiers;
@property (nonatomic, strong) BOOL (^_Nullable reachabilityCondition)(M2DAPIRequest * _Nonnull request);
@property (nonatomic, copy) void (^_Nullable didRequestIdentifierPushBlock)(NSString * _Nonnull identifier);
@property (nonatomic, copy) void (^_Nullable didRequestIdentifierPopBlock)(NSArray * _Nonnull identifiers);
@property (nonatomic, copy) void (^_Nullable baseParameterBlock)(M2DAPIRequest * _Nonnull request, NSMutableDictionary * _Nullable params);
@property (nonatomic, copy) void (^_Nullable initializeBlock)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable params);
@property (nonatomic, copy) void (^_Nullable finalizeBlock)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject, NSData * _Nullable rawData);
@property (nonatomic, copy) id _Nullable (^_Nullable parseBlock)(NSData * _Nullable data, NSError * _Nullable * _Nullable error);
@property (nonatomic, copy) BOOL (^_Nullable resultConditionBlock)(M2DAPIRequest * _Nullable request, NSURLResponse * _Nullable response, id _Nullable parsedObject, NSError * _Nullable * _Nullable error);
@property (nonatomic, strong) NSURLSessionConfiguration * _Nonnull configuration;

+ (instancetype _Nonnull)sharedInstance;
- (NSString * _Nonnull)sendRequestWithURL:(NSURL * _Nonnull)url method:(NSString * _Nonnull)method parametors:(NSDictionary * _Nullable)params success:(void (^_Nullable)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject))successBlock failed:(void (^_Nullable)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject, NSError * _Nullable error))failureBlock asynchronous:(BOOL)flag;
- (NSString * _Nonnull)sendRequest:(M2DAPIRequest * _Nonnull)request;
- (id _Nullable)sendSynchronousRequest:(M2DAPIRequest * _Nonnull)request;
- (NSString * _Nonnull)sendAsynchronousRequest:(M2DAPIRequest * _Nonnull)request;
- (NSData * _Nullable)rawDataWithRequest:(M2DAPIRequest * _Nonnull)request;
- (NSString * _Nullable)rawDataWithAsynchronousRequest:(M2DAPIRequest * _Nonnull)request completionHandler:(void (^_Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))handler;
- (instancetype _Nonnull)parseBlock:(id _Nullable (^_Nullable)(NSData * _Nullable data, NSError * _Nullable * _Nullable error))parseBlock;
- (instancetype _Nonnull)resultConditionBlock:(BOOL (^_Nullable)(M2DAPIRequest * _Nonnull request, NSURLResponse * _Nullable response, id _Nullable parsedObject, NSError * _Nullable * _Nullable error))resultConditionBlock;
- (instancetype _Nonnull)initializeBlock:(void (^_Nullable)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nonnull params))initializeBlock;
- (instancetype _Nonnull)finalizeBlock:(void (^_Nullable)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject))finalizeBlock;
- (void)cancelRequestWithIdentifier:(NSString * _Nonnull)identifier;
- (void)cancelAllRequest;

@end
