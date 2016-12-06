//
//  M2DAPIRequest.h
//  M2DAPIGatekeeper
//
//  Created by Akira Matsuda on 2014/04/02.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface M2DAPIRequest : NSMutableURLRequest

+ (instancetype _Nonnull)GETRequest:(NSURL * _Nonnull)url;
+ (instancetype _Nonnull)POSTRequest:(NSURL * _Nonnull)url;
- (instancetype _Nonnull)asynchronousRequest;
- (instancetype _Nonnull)parametors:(NSDictionary * _Nullable)params;
- (instancetype _Nonnull)whenSucceeded:(void (^_Nonnull)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject))successBlock;
- (instancetype _Nonnull)whenFailed:(void (^_Nonnull)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject, NSError * _Nullable error))failureBlock;
- (instancetype _Nonnull)parseAlgorithm:(id _Nullable (^_Nonnull)(NSData * _Nullable data, NSError * _Nonnull * _Nullable error))parseBlock;
- (instancetype _Nonnull)resultCondition:(BOOL (^_Nonnull)(M2DAPIRequest * _Nonnull request, NSURLResponse * _Nullable response, id _Nullable parsedObject, NSError * _Nonnull * _Nullable error))resultConditionBlock;
- (instancetype _Nonnull)initialize:(void (^_Nonnull)(M2DAPIRequest * _Nonnull request))initializeBlock;
- (instancetype _Nonnull)finalize:(void (^_Nonnull)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject))finalizeBlock;
- (instancetype _Nonnull)inProgress:(void (^_Nonnull)(CGFloat progress))progressBlock;

@property (nonatomic, assign) BOOL willSendAsynchronous;
@property (nonatomic, assign) BOOL showNetworkActivityIndicator;
@property (nonatomic, strong) NSString * _Nonnull httpMethod;
@property (nonatomic, readonly) NSString * _Nonnull identifier;
@property (nonatomic, strong) NSDictionary * _Nullable requestParametors;
@property (nonatomic, strong) NSURLResponse * _Nullable response;
@property (nonatomic, strong) NSDictionary * _Nullable userInfo;
@property (nonatomic, copy) id _Nullable (^_Nullable parseBlock)(NSData * _Nullable data, NSError *_Nullable * _Nullable error);
@property (nonatomic, copy) BOOL (^_Nullable resultConditionBlock)(M2DAPIRequest * _Nonnull request, NSURLResponse * _Nonnull response, id _Nullable parsedObject, NSError * _Nullable * _Nullable error);
@property (nonatomic, copy) void (^_Nullable successBlock)(M2DAPIRequest * _Nonnull request, NSDictionary *_Nullable httpHeaderFields, id _Nullable parsedObject);
@property (nonatomic, copy) void (^_Nullable failureBlock)(M2DAPIRequest * _Nonnull request, NSDictionary *_Nullable httpHeaderFields, id _Nullable parsedObject, NSError * _Nullable error);
@property (nonatomic, copy) void (^_Nullable initializeBlock)(M2DAPIRequest * _Nonnull request);
@property (nonatomic, copy) void (^_Nullable finalizeBlock)(M2DAPIRequest * _Nonnull request, NSDictionary * _Nullable httpHeaderFields, id _Nullable parsedObject);
@property (nonatomic, copy) void (^_Nullable progressBlock)(CGFloat progress);

@end
