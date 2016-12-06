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

- (void)connectionOperationDidComplete:(M2DURLConnectionOperation * _Nonnull)operation session:(NSURLSession * _Nonnull)session task:(NSURLSessionTask * _Nonnull)task error:(NSError * _Nullable)error;

@end

@interface M2DURLConnectionOperation : NSObject <NSURLSessionDataDelegate>

@property id<M2DURLConnectionOperationDelegate> _Nullable delegate;
@property (nonatomic, readonly) NSURLRequest *_Nonnull request;
@property (nonatomic, readonly) NSString * _Nonnull identifier;
@property (nonatomic, strong) NSURLSessionConfiguration * _Nonnull configuration;

+ (void)globalStop:(NSString * _Nonnull)identifier;
- (void)stop;
- (instancetype _Nonnull)initWithRequest:(NSURLRequest * _Nonnull)request;
- (instancetype _Nonnull)initWithRequest:(NSURLRequest * _Nonnull)request completeBlock:(void  (^_Nullable)(M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (void)setProgressBlock:(void (^_Nullable)(CGFloat progress))progressBlock;
- (NSString * _Nonnull)sendRequest;
- (NSString * _Nonnull)sendRequestWithCompleteBlock:(void (^_Nullable)(M2DURLConnectionOperation * _Nonnull op, NSURLResponse  * _Nonnull response, NSData * _Nullable data, NSError * _Nullable error))completeBlock;
- (NSString * _Nonnull)sendRequest:(NSURLRequest * _Nonnull)request completeBlock:(void (^_Nullable)(M2DURLConnectionOperation  * _Nonnull op, NSURLResponse  * _Nonnull response, NSData  * _Nullable data, NSError * _Nullable error))completeBlock;

@end
