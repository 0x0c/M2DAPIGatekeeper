# M2DAPIGatekeeper

[![CI Status](http://img.shields.io/travis/Akira Matsuda/M2DAPIGatekeeper.svg?style=flat)](https://travis-ci.org/Akira Matsuda/M2DAPIGatekeeper)
[![Version](https://img.shields.io/cocoapods/v/M2DAPIGatekeeper.svg?style=flat)](http://cocoadocs.org/docsets/M2DAPIGatekeeper)
[![License](https://img.shields.io/cocoapods/l/M2DAPIGatekeeper.svg?style=flat)](http://cocoadocs.org/docsets/M2DAPIGatekeeper)
[![Platform](https://img.shields.io/cocoapods/p/M2DAPIGatekeeper.svg?style=flat)](http://cocoadocs.org/docsets/M2DAPIGatekeeper)

## Requirements

- Runs on iOS 6.0 or later.

## Installation

M2DAPIGatekeeper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "M2DAPIGatekeeper"

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Only two steps to send request like this.

	// Send asynchronous request
	M2DAPIRequest *request = [[[[M2DAPIRequest POSTRequest:[NSURL URLWithString:...]] parametors:@{...}]  whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderField, id parsedObject) {
		//When result condition is true
	}] whenFailed:^(M2DAPIRequest *request, NSDictionary *httpHeaderField, id parsedObject, NSError *error) {
		//When result condition is false
	}];
	[[M2DAPIGatekeeper sharedInstance] sendRequest:request];

A lot of methods to control each sequences.
For example,

	M2DAPIGatekeeper *gatekeeper = [M2DAPIGatekeeper sharedInstance];
	[gatekeeper parseBlock:^id(NSData *data, NSError *__autoreleasing *error) {
		// parse data
		id parsedObject = nil;
		NSError *e = nil;
		if (error == nil && data != nil) {
			parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
			*error = [NSError errorWithDomain:@"Parse error." code:M2DAPIGatekeeperParseError userInfo:@{@"reason":[e copy]}];
		}
		return parsedObject;
	}];
	[gatekeeper resultConditionBlock:^BOOL(NSURLResponse *response, id parsedObject, NSError *__autoreleasing *error) {
		return [(NSHTTPURLResponse *)response statusCode] == 200;
	}];

	[gatekeeper initializeBlock:^(M2DAPIRequest *request, NSDictionary *params) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// Show hud when start request
		});
	}];
	[gatekeeper finalizeBlock:^(M2DAPIRequest *request, NSDictionary *httpHeaderField, id parsedObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// Dismiss hud when finish request
		});
	}];

and so more.

When start connection, unique identifier is generated.
You can use the identifier to cancel request .

	NSString *identifier = [gatekeeper sendRequest:...];
	[gatekeeper cancelRequestWithIdentifier:identifier];

Please see also M2DAPIGatekeeper.h or M2DAPIRequest.h.

## Author

Akira Matsuda, akira.m.itachi@gmail.com

## License

M2DAPIGatekeeper is available under the MIT license. See the LICENSE file for more info.
