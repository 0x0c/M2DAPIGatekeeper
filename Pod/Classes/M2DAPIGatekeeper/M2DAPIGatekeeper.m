//
//  M2DAPIGatekeeper.m
//  BoostMedia
//
//  Created by Akira Matsuda on 2013/01/13.
//  Copyright (c) 2013年 akira.matsuda. All rights reserved.
//

#import "M2DAPIGatekeeper.h"
#import "M2DNSURLConnectionExtension.h"
#import "M2DNSURLConnectionExtensionConstant.h"
#import "M2DURLConnectionOperation.h"

typedef NS_ENUM(NSUInteger, M2DAPIGatekeeperErrorCode) {
	M2DAPIGatekeeperResultFailure = -1,
	M2DAPIGatekeeperParseError = -2,
};

@interface M2DAPIGatekeeper ()
{
	NSMutableArray *identifiers_;
	NSOperationQueue *queue_;
}

@end

@implementation M2DAPIGatekeeper

@synthesize requestIdentifiers = identifiers_;

+ (instancetype)sharedInstance
{
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	
	return sharedInstance;
}

- (NSString *)sendRequestWithURL:(NSURL *)url method:(NSString *)method parametors:(NSDictionary *)params success:(void (^)(M2DAPIRequest *request, id parsedObject))successBlock failed:(void (^)(M2DAPIRequest *request, NSError *error))failureBlock asynchronous:(BOOL)flag
{
	M2DAPIRequest *req = nil;
	if ([method isEqualToString:M2DHTTPMethodGET]) {
		req = [M2DAPIRequest GETRequest:url];
	}
	else {
		req = [M2DAPIRequest POSTRequest:url];
	}
	[[[req parametors:params] whenSucceeded:successBlock] whenFailed:failureBlock];
	if (flag) {
		[req asynchronousRequest];
	}
	return [self sendRequest:req];
}

- (NSString *)sendRequest:(M2DAPIRequest *)request
{
	if (request.requestParametors) {
		[request m2d_setParameter:request.requestParametors method:request.httpMethod];
	}
	
	if (self.baseParameter) {
		NSMutableDictionary *p = [request.requestParametors mutableCopy];
		[p addEntriesFromDictionary:self.baseParameter];
		[request parametors:p];
	}
	
	if (request.resultConditionBlock == nil) {
		request.resultConditionBlock = _resultConditionBlock;
	}
	if (request.parseBlock == nil) {
		request.parseBlock = _parseBlock;
	}
	
	if (request.initializeBlock) {
		request.initializeBlock(request);
	}
	if (self.initializeBlock) {
		self.initializeBlock(request, request.requestParametors);
	}
	
	__block void (^finalizeBlock)(M2DAPIRequest *request, id parsedObject) = self.finalizeBlock;
	void (^f)(NSURLResponse *response, NSData *data, NSError *error) = ^(NSURLResponse *response, NSData *data, NSError *error){
		id parsedObject = nil;
		if (request.failureBlock && error) {
			request.failureBlock(request, error);
		}
		else {
			__autoreleasing NSError *e = nil;
			parsedObject = request.parseBlock(data, &e);
			NSError *e2 = nil;
			if (request.resultConditionBlock(response, parsedObject, &e2) && request.successBlock) {
				request.successBlock(request, parsedObject);
			}
			else if	(request.failureBlock) {
				if (e) {
					request.failureBlock(request, e);
				}
				else {
					request.failureBlock(request, e2);
				}
			}
		}
		
		if (request.finalizeBlock) {
			request.finalizeBlock(request, parsedObject);
		}
		if (finalizeBlock) {
			finalizeBlock(request, parsedObject);
		}
		
		if (_debugMode) {
			__autoreleasing NSString *r = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"result[%lu]:%@", (long)[(NSHTTPURLResponse *)response statusCode], [parsedObject description]);
			NSLog(@"raw result:[%lu][%@://%@%@]%@", (long)[(NSHTTPURLResponse *)response statusCode], response.URL.scheme, response.URL.host, response.URL.path, r);
		}
	};
	
	if (_debugMode) {
		NSLog(@"post:[%@://%@%@]%@", request.URL.scheme, request.URL.host, request.URL.path, [request.requestParametors description]);
	}
	
	NSString *identifier = nil;
	if (request.willSendAsynchronous) {
		M2DURLConnectionOperation *op = [[M2DURLConnectionOperation alloc] initWithRequest:request completeBlock:^(NSURLResponse *response, NSData *data, NSError *error) {
			f(response, data, error);
			[identifiers_ removeObject:identifier];
		}];
		if (request.progressBlock) {
			[op setProgressBlock:request.progressBlock];
		}
		identifier = [op sendRequest];
		[identifiers_ addObject:identifier];
		if (self.didRequestIdentifierPushBlock) {
			self.didRequestIdentifierPushBlock(identifier);
		}
	}
	else {
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)request returningResponse:&response error:&error];
		f(response, data, error);
	}
	
	return identifier;
}

- (NSString *)sendAsynchronousRequest:(M2DAPIRequest *)request
{
	[request asynchronousRequest];
	return [self sendRequest:request];
}

- (instancetype)parseBlock:(id (^)(NSData *data, NSError **error))parseBlock
{
	_parseBlock = [parseBlock copy];
	return self;
}

- (instancetype)resultConditionBlock:(BOOL (^)(NSURLResponse *response, id parsedObject, NSError **error))resultConditionBlock
{
	_resultConditionBlock = [resultConditionBlock copy];
	return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		queue_ = [[NSOperationQueue alloc] init];
		identifiers_ = [NSMutableArray new];
		_timeoutInterval = 30.0;
		_debugMode = NO;
		[self setResultConditionBlock:^BOOL(NSURLResponse *response, id parsedObject, NSError *__autoreleasing *error) {
			BOOL result = [(NSHTTPURLResponse *)response statusCode] == 200 ? YES : NO;
			if (*error != NULL && result == NO) {
				*error = [NSError errorWithDomain:@"API result failure." code:M2DAPIGatekeeperResultFailure userInfo:nil];
			}
			return result;
		}];
		[self setParseBlock:^id(NSData *data, NSError *__autoreleasing *error) {
			NSError *e = nil;
			id parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
			if (e != nil) {
				*error = [NSError errorWithDomain:@"Parse error." code:M2DAPIGatekeeperParseError userInfo:@{@"reason":[e copy]}];
			}
			return parsedObject;
		}];
	}
	
	return self;
}

- (instancetype)initializeBlock:(void (^)(M2DAPIRequest *request, NSDictionary *params))initializeBlock
{
	_initializeBlock = [initializeBlock copy];
	return self;
}

- (instancetype)finalizeBlock:(void (^)(M2DAPIRequest *request))finalizeBlock
{
	_finalizeBlock = [finalizeBlock copy];
	return self;
}

- (void)cancelAllRequest
{
	for (NSString *identifier in self.requestIdentifiers) {
		[self cancelRequestWithIdentifier:identifier];
	}
	if (self.didRequestIdentifierPopBlock) {
		self.didRequestIdentifierPopBlock(self.requestIdentifiers);
	}
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier
{
	[M2DURLConnectionOperation globalStop:identifier];
	if (self.didRequestIdentifierPopBlock) {
		self.didRequestIdentifierPopBlock(@[identifier]);
	}
}

@end
