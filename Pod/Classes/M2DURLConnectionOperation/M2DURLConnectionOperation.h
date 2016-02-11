//
//  M2DURLConnection.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class M2DURLConnectionOperation;

@protocol M2DURLConnectionOperationDelegate <NSObject>

- (void)connectionOperationDidComplete:(M2DURLConnectionOperation *)operation session:(NSURLSession *)session task:(NSURLSessionTask *)task error:(NSError *)error;

@end

@interface M2DURLConnectionOperation : NSObject <NSURLSessionDataDelegate>

@property id<M2DURLConnectionOperationDelegate> delegate;
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;

+ (void)globalStop:(NSString *)identifier;
- (void)stop;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (void)setProgressBlock:(void (^)(CGFloat progress))progressBlock;
- (NSString *)sendRequest;
- (NSString *)sendRequestWithCompleteBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;

@end
