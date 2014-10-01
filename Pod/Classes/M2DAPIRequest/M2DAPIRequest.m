//
//  M2DAPIRequest.m
//  M2DAPIGatekeeper
//
//  Created by Akira Matsuda on 2014/04/02.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "M2DAPIRequest.h"
#import "M2DNSURLConnectionExtension.h"
#import "M2DNSURLConnectionExtensionConstant.h"

@interface M2DAPIRequest ()
{
	BOOL (^resultConditionBlock_)(NSURLResponse *response, id parsedObject);
	void (^successBlock_)(M2DAPIRequest *request, id parsedObject);
	void (^failureBlock_)(M2DAPIRequest *request, NSError *error);
}

@end

@implementation M2DAPIRequest

@synthesize successBlock = successBlock_;
@synthesize failureBlock = failureBlock_;

#pragma mark - Override

- (void)setHTTPMethod:(NSString *)HTTPMethod
{
	[super setHTTPMethod:HTTPMethod];
	_httpMethod = HTTPMethod;
}

#pragma mark -

+ (instancetype)GETRequest:(NSURL *)url
{
	M2DAPIRequest *request = [M2DAPIRequest requestWithURL:url];
	[request setHTTPMethod:M2DHTTPMethodGET];
	
	return request;
}

+ (instancetype)POSTRequest:(NSURL *)url
{
	M2DAPIRequest *request = [M2DAPIRequest requestWithURL:url];
	[request setHTTPMethod:M2DHTTPMethodPOST];
	
	return request;
}

+ (instancetype)requestWithURL:(NSURL *)url
{
	M2DAPIRequest *request = [[M2DAPIRequest alloc] initWithURL:url];
	return request;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	}
	return self;
}

- (instancetype)initWithURL:(NSURL *)url successBlock:(void (^)(M2DAPIRequest *request, id parsedObject))successBlock failureBlock:(void (^)(M2DAPIRequest *request, NSError *error))failureBlock
{
	self = [self initWithURL:url];
	if (self) {
		successBlock_ = [successBlock copy];
		failureBlock_ = [failureBlock copy];
	}
	
	return self;
}

- (instancetype)asynchronousRequest
{
	self.willSendAsynchronous = YES;
	return self;
}

- (instancetype)parametors:(NSDictionary *)params
{
	_requestParametors = [params copy];
	return self;
}

- (instancetype)whenSucceeded:(void (^)(M2DAPIRequest *request, id parsedObject))successBlock
{
	self.successBlock = successBlock;
	return self;
}

- (instancetype)whenFailed:(void (^)(M2DAPIRequest *request, NSError *error))failureBlock
{
	self.failureBlock = failureBlock;
	return self;
}

- (instancetype)parseAlgorithm:(id (^)(NSData *, NSError *__autoreleasing *))parseBlock
{
	self.parseBlock = parseBlock;
	return self;
}

- (instancetype)resultCondition:(BOOL (^)(NSURLResponse *, id, NSError *__autoreleasing *))resultConditionBlock
{
	self.resultConditionBlock = resultConditionBlock;
	return self;
}

- (instancetype)initialize:(void (^)(M2DAPIRequest *))initializeBlock
{
	self.initializeBlock = initializeBlock;
	return self;
}

- (instancetype)finalize:(void (^)(M2DAPIRequest *, id))finalizeBlock
{
	self.finalizeBlock = finalizeBlock;
	return self;
}

- (instancetype)inProgress:(void (^)(CGFloat progress))progressBlock
{
	self.progressBlock = progressBlock;
	return self;
}

@end
