//
//  M2DURLConnection.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "M2DURLConnectionOperation.h"

static NSOperationQueue *globalConnectionQueue;

@interface M2DURLConnectionOperation ()

@property (nonatomic, copy) void (^completeBlock)(M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(CGFloat progress);
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) CGFloat dataLength;
@property (nonatomic, copy) NSMutableData *data;
@property (nonatomic, copy) NSURLSessionDataTask *task;
@property (nonatomic, copy) NSURLResponse *response;

@end

@implementation M2DURLConnectionOperation

+ (void)globalStop:(NSString *)identifier
{
	NSNotification *n = [NSNotification notificationWithName:identifier object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:n];
}

+ (NSOperationQueue *)globalConnectionQueue
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		globalConnectionQueue = [NSOperationQueue new];
	});
	
	return globalConnectionQueue;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		_identifier = [NSString stringWithFormat:@"%p", self];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request
{
	self = [self init];
	if (self) {
		_request = [request copy];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	self = [self initWithRequest:request];
	if (self) {
		self.completeBlock = completeBlock;
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:self.identifier object:nil];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
	self.response = response;
	self.data = [[NSMutableData alloc] init];
	self.dataLength = response.expectedContentLength;
	completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	[self.data appendData:data];
	if (self.progressBlock) {
		self.progressBlock((double)self.data.length / (double)self.dataLength);
	}
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	[self.delegate connectionOperationDidComplete:self session:session task:task error:error];
	if (error) {
		self.completeBlock(self, self.response, nil, error);
	}
	else {
		if (self.completeBlock) {
			self.completeBlock(self, self.response, self.data, nil);
		}
	}
	[self finish];
}

#pragma mark -

- (void)stop
{
	[self.task cancel];
	[self finish];
}

- (void)setProgressBlock:(void (^)(CGFloat progress))progressBlock
{
	self.progressBlock = progressBlock;
}

- (NSString *)sendRequest
{
	return [self sendRequestWithCompleteBlock:self.completeBlock];
}

- (NSString *)sendRequestWithCompleteBlock:(void (^)(M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	return [self sendRequest:_request completeBlock:completeBlock];
}

- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnectionOperation *op, NSURLResponse *response, NSData *data, NSError *error))completeBlock
{
	self.completeBlock = completeBlock;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:[[self class] globalConnectionQueue]];
	self.task = [session dataTaskWithRequest:request];
	[self.task resume];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:self.identifier object:nil];
	
	return _identifier;
}

- (void)finish
{
	self.executing = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:self.identifier object:nil];
}

@end
