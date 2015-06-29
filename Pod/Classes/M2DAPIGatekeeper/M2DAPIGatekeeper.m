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

+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
	static NSInteger connectionCount = 0;
	if (setVisible) {
		connectionCount++;
	}
	else {
		connectionCount--;
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(connectionCount > 0)];
}

- (NSString *)sendRequestWithURL:(NSURL *)url method:(NSString *)method parametors:(NSDictionary *)params success:(void (^)(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject))successBlock failed:(void (^)(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject, NSError *error))failureBlock asynchronous:(BOOL)flag
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
	[self configureParams:request];
	[self configureHandler:request];
	
	if (self.reachabilityCondition && self.reachabilityCondition(request) == NO) {
		return nil;
	}
	
	if (self.initializeBlock) {
		self.initializeBlock(request, request.requestParametors);
	}
	
	__block void (^finalizeBlock)(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject, NSData *rawData) = self.finalizeBlock;
	void (^f)(NSURLResponse *response, NSData *data, NSError *error) = ^(NSURLResponse *response, NSData *data, NSError *error){
		request.response = response;
		NSError *finalError = error;
		id parsedObject = nil;
		if (error) {
			if (request.failureBlock) {
				request.failureBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, finalError);
			}
		}
		else {
			__autoreleasing NSError *e = nil;
			parsedObject = request.parseBlock(data, &e);
			finalError = e;
			NSError *e2 = nil;
			BOOL result = request.resultConditionBlock(request, response, parsedObject, &e2);
			finalError = e2;
			if (result && finalError == nil) {
				if (request.successBlock) {
					request.successBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject);
				}
			}
			else if (request.failureBlock) {
				request.failureBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, finalError);
			}
		}
		
		if (request.finalizeBlock) {
			request.finalizeBlock(request, parsedObject, finalError);
		}
		if (finalizeBlock) {
			finalizeBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, data);
		}
		
		if (_debugMode) {
			__autoreleasing NSString *r = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"raw result:[%lu][%@://%@%@]%@", (long)[(NSHTTPURLResponse *)response statusCode], response.URL.scheme, response.URL.host, response.URL.path, r);
			NSLog(@"result[%lu]:%@", (long)[(NSHTTPURLResponse *)response statusCode], [parsedObject description]);
		}
	};
	
	if (_debugMode) {
		NSLog(@"post:[%@]%@", [request.URL absoluteString], [request.requestParametors description]);
	}
	
	if (self.showNetworkActivityIndicator && request.showNetworkActivityIndicator) {
		[[self class] setNetworkActivityIndicatorVisible:YES];
	}
	NSString *identifier = nil;
	if (request.willSendAsynchronous) {
		__weak typeof(self) bself = self;
		__weak typeof(request) br = request;
		M2DURLConnectionOperation *op = [[M2DURLConnectionOperation alloc] initWithRequest:request completeBlock:^(NSURLResponse *response, NSData *data, NSError *error) {
			f(response, data, error);
			@synchronized(identifiers_) {
				[identifiers_ removeObject:identifier];
			}
			if (bself.showNetworkActivityIndicator && br.showNetworkActivityIndicator) {
				[[self class] setNetworkActivityIndicatorVisible:NO];
			}
		}];
		if (request.progressBlock) {
			[op setProgressBlock:request.progressBlock];
		}
		identifier = [op sendRequest];
		@synchronized(identifiers_) {
			[identifiers_ addObject:identifier];
		}
		if (self.didRequestIdentifierPushBlock) {
			self.didRequestIdentifierPushBlock(identifier);
		}
	}
	else {
		NSError *error = nil;
		NSURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)request returningResponse:&response error:&error];
		request.response = response;
		f(response, data, error);
		if (self.showNetworkActivityIndicator && request.showNetworkActivityIndicator) {
			[[self class] setNetworkActivityIndicatorVisible:NO];
		}
	}
	
	return identifier;
}

- (id)sendSynchronousRequest:(M2DAPIRequest *)request
{
	[self configureParams:request];
	[self configureHandler:request];
	if (self.initializeBlock) {
		self.initializeBlock(request, request.requestParametors);
	}
	
	if (_debugMode) {
		NSLog(@"post:[%@]%@", [request.URL absoluteString], [request.requestParametors description]);
	}

	NSError *finalError = nil;
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)request returningResponse:&response error:&error];
	request.response = response;
	finalError = error;
	id parsedObject = nil;
	if (error) {
		if (request.failureBlock) {
			request.failureBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, finalError);
		}
	}
	else {
		__autoreleasing NSError *e = nil;
		parsedObject = request.parseBlock(data, &e);
		NSError *e2 = nil;
		BOOL result = request.resultConditionBlock(request, response, parsedObject, &e2);
		finalError = e2;
		if (result && finalError == nil) {
			if (request.successBlock) {
				request.successBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject);
			}
		}
		else if (request.failureBlock) {
			request.failureBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, finalError);
		}
	}
	
	if (_debugMode) {
		__autoreleasing NSString *r = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"raw result:[%lu][%@://%@%@]%@", (long)[(NSHTTPURLResponse *)response statusCode], response.URL.scheme, response.URL.host, response.URL.path, r);
		NSLog(@"result[%lu]:%@", (long)[(NSHTTPURLResponse *)response statusCode], [parsedObject description]);
	}
	
	if (request.finalizeBlock) {
		request.finalizeBlock(request, parsedObject, finalError);
	}
	if (self.finalizeBlock) {
		self.finalizeBlock(request, [(NSHTTPURLResponse *)response allHeaderFields], parsedObject, data);
	}
	
	return parsedObject;
}

- (NSString *)sendAsynchronousRequest:(M2DAPIRequest *)request
{
	[request asynchronousRequest];
	return [self sendRequest:request];
}

- (NSData *)rawDataWithRequest:(M2DAPIRequest *)request
{
	[self configureParams:request];
	NSError *error = nil;
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:(NSURLRequest *)request returningResponse:&response error:&error];
	
	return data;
}

- (NSString *)rawDataWithAsynchronousRequest:(M2DAPIRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler
{
	[self configureParams:request];
	NSString *identifier = nil;
	M2DURLConnectionOperation *op = [[M2DURLConnectionOperation alloc] initWithRequest:request completeBlock:^(NSURLResponse *response, NSData *data, NSError *error) {
		handler(data, response, error);
		@synchronized(identifiers_) {
			[identifiers_ removeObject:identifier];
		}
	}];
	if (request.progressBlock) {
		[op setProgressBlock:request.progressBlock];
	}
	identifier = [op sendRequest];
	@synchronized(identifiers_) {
		[identifiers_ addObject:identifier];
	}
	if (self.didRequestIdentifierPushBlock) {
		self.didRequestIdentifierPushBlock(identifier);
	}
	
	return identifier;
}

- (instancetype)parseBlock:(id (^)(NSData *data, NSError **error))parseBlock
{
	_parseBlock = [parseBlock copy];
	return self;
}

- (instancetype)resultConditionBlock:(BOOL (^)(M2DAPIRequest *request, NSURLResponse *response, id parsedObject, NSError **error))resultConditionBlock
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
		[self setResultConditionBlock:^BOOL(M2DAPIRequest *request, NSURLResponse *response, id parsedObject, NSError *__autoreleasing *error) {
			BOOL result = [(NSHTTPURLResponse *)response statusCode] == 200 ? YES : NO;
			if (*error != NULL && result == NO) {
				*error = [NSError errorWithDomain:@"API result failure." code:M2DAPIGatekeeperResultFailure userInfo:nil];
			}
			return result;
		}];
		[self setParseBlock:^id(NSData *data, NSError *__autoreleasing *error) {
			NSError *e = nil;
			id parsedObject = data != nil ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e] : nil;
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

- (instancetype)finalizeBlock:(void (^)(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject))finalizeBlock
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

- (void)configureParams:(M2DAPIRequest *)request
{
	if (self.baseParameterBlock) {
		NSMutableDictionary *p = [request.requestParametors mutableCopy];
		self.baseParameterBlock(request, p);
		[request parametors:p];
	}
	if (request.requestParametors) {
		[request m2d_setParameter:request.requestParametors method:request.httpMethod];
	}
}

- (void)configureHandler:(M2DAPIRequest *)request
{
	if (request.resultConditionBlock == nil) {
		request.resultConditionBlock = _resultConditionBlock;
	}
	if (request.parseBlock == nil) {
		request.parseBlock = _parseBlock;
	}
	
	if (request.initializeBlock) {
		request.initializeBlock(request);
	}
}

@end
