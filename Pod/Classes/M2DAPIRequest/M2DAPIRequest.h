//
//  M2DAPIRequest.h
//  M2DAPIGatekeeper
//
//  Created by Akira Matsuda on 2014/04/02.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M2DAPIRequest : NSMutableURLRequest

+ (instancetype)GETRequest:(NSURL *)url;
+ (instancetype)POSTRequest:(NSURL *)url;
- (instancetype)asynchronousRequest;
- (instancetype)parametors:(NSDictionary *)params;
- (instancetype)whenSucceeded:(void (^)(M2DAPIRequest *request, id parsedObject))successBlock;
- (instancetype)whenFailed:(void (^)(M2DAPIRequest *request, NSError *error))failureBlock;
- (instancetype)parseAlgorithm:(id (^)(NSData *data, NSError **error))parseBlock;
- (instancetype)resultCondition:(BOOL (^)(NSURLResponse *response, id parsedObject, NSError **error))resultConditionBlock;
- (instancetype)initialize:(void (^)(M2DAPIRequest *request))initializeBlock;
- (instancetype)finalize:(void (^)(M2DAPIRequest *request, id parsedObject))finalizeBlock;
- (instancetype)inProgress:(void (^)(CGFloat progress))progressBlock;

@property (nonatomic, assign) BOOL willSendAsynchronous;
@property (nonatomic, readonly) NSString *httpMethod;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSDictionary *requestParametors;
@property (nonatomic, copy) id (^parseBlock)(NSData *data, NSError **error);
@property (nonatomic, copy) BOOL (^resultConditionBlock)(NSURLResponse *response, id parsedObject, NSError **error);
@property (nonatomic, copy) void (^successBlock)(M2DAPIRequest *request, id parsedObject);
@property (nonatomic, copy) void (^failureBlock)(M2DAPIRequest *request, NSError *error);
@property (nonatomic, copy) void (^initializeBlock)(M2DAPIRequest *request);
@property (nonatomic, copy) void (^finalizeBlock)(M2DAPIRequest *request, id parsedObject);
@property (nonatomic, copy) void (^progressBlock)(CGFloat progress);

@end
