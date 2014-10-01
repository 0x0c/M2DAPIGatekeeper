//
//  M2DURLConnection.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class M2DURLConnectionOperation;

@protocol M2DURLConnectionOperationDelegate <NSObject>

- (void)connectionOperationDidComplete:(M2DURLConnectionOperation *)operation connection:(NSURLConnection *)connection;

@end

@interface M2DURLConnectionOperation : NSObject <NSURLConnectionDataDelegate>
{
	void (^completeBlock_)(NSURLResponse *response, NSData *data, NSError *error);
	void (^progressBlock_)(CGFloat progress);
	CGFloat dataLength_;
	NSMutableData *data_;
	NSURLConnection *connection_;
	NSURLResponse *response_;
	BOOL executing_;
}

@property id<M2DURLConnectionOperationDelegate> delegate;
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSString *identifier;

+ (void)globalStop:(NSString *)identifier;
- (void)stop;
- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (void)setProgressBlock:(void (^)(CGFloat progress))progressBlock;
- (NSString *)sendRequest;
- (NSString *)sendRequestWithCompleteBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;
- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completeBlock;

@end
