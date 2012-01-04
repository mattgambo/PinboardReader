//
//  Command.m
//  PinboardReader
//
//  Created by Matt on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Command.h"
#import "Constants.h"
#include <stdarg.h>

// Import CFNetwork for CFNetworkUrlError conditions
#import <CFNetwork/CFNetwork.h>

@implementation Command

@synthesize receivedData, currentParsedCharacterData;

-(id)init
{
    return [super init];
}

// Method to send a HTTP request to the QThru service endpoint with the command name used to identify which API method to call.
- (BOOL)send:(NSString*)commandName withMethod:(NSString *)method withCommandString:(NSString *)commandString, ...
{
    BOOL success;
    
    NSString *serviceEndpoint = [[NSUserDefaults standardUserDefaults] stringForKey:SERVICE_ENDPOINT];
    
    NSString *url = [NSString stringWithFormat:serviceEndpoint, commandName];
    va_list args;
    va_start(args, commandString);
    success = [self sendURL:[NSURL URLWithString:url] withMethod:method withCommandString:commandString withVaList:args];
	va_end(args);
    
    return success;
}

// Method to send a HTTP request using any URL specified, not limiting to just the QThru API Service endpoint.
- (BOOL)sendURL:(NSURL*)url withMethod:(NSString *)method withCommandString:(NSString *)commandString, ...
{
    BOOL success;
    
    va_list args;
    va_start(args, commandString);
    success = [self sendURL:url withMethod:method withCommandString:commandString withVaList:args];
	va_end(args);
    
    return success;
}

- (BOOL)sendURL:(NSURL*)url withMethod:(NSString *)method withCommandString:(NSString *)commandString withVaList:(va_list)args
{
	NSLog(@"Command: sending [%@] with [%@]", [url description], commandString);
	BOOL success;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:SERVICE_TIMEOUT];
	NSString *reqBodyStr = [[NSString alloc] initWithFormat:commandString arguments:args];
    
	NSLog(@"Command::send: final requestStr is %@", reqBodyStr);
	
	NSData *requestData = [NSData dataWithBytes: [ reqBodyStr UTF8String ] length: [ reqBodyStr length ]];
	[request setHTTPMethod:method];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
	[request setHTTPBody:requestData];
	
	NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (urlConnection) {
		success = YES;
	}
	else {
		success = NO;
		NSLog(@"Connection failed! Error - failed to establish connection");
	}
    
	return success;
}

//TODO fix this
- (void)handleSuccessfulConnection
{
	NSLog(@"Command: handleSuccessfulConnection");
}

- (void)handleError:(NSError *)error {
    
    // delegate should handle all errors and UI components
    
    [self.delegate handleError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	int responseCode = [httpResponse statusCode];
    NSString *mimeType = [response MIMEType];
	NSLog(@"Command: didReceiveResponse: statusCode=%d, mimeType=%@", responseCode, mimeType);
    
	[self.delegate handleResponseCode:responseCode];
    
    if ((responseCode/100) == 2) {
		[self handleSuccessfulConnection];
		if ([@"application/xml" isEqualToString:mimeType] || [@"text/xml" isEqualToString:mimeType]) {
			self.receivedData = [NSMutableData data];
		}
    }
	else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
								  NSLocalizedString(@"HTTP Error",
													@"Error message displayed when receving a connection error.")
															 forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:responseCode userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
    // Append the new data to receivedData.
    int receivedBytes = [data length];
	NSLog(@"didReceiveData: %d bytes", receivedBytes);
	if (debug) {
		NSString *logstr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		NSLog(@"xml=%@", logstr);
	}
    if (receivedData != nil && receivedBytes > 0) {
        [receivedData appendData:data];
        NSLog(@"didReceiveData: appended data");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
	
    // Check for CFNetworkError conditions
	if ([error code] == kCFURLErrorNotConnectedToInternet || [error code] == kCFURLErrorCannotConnectToHost) {
        NSDictionary *userInfo =
		[NSDictionary dictionaryWithObject:
		 NSLocalizedString(@"No Connection Error",
						   @"Error message displayed when not connected to the Internet.")
									forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else {
        // handle the error generically
        [self handleError:error];
    }
	
    NSLog(@"Connection failed! Error - %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    int totalReceivedBytes = [receivedData length];
    NSLog(@"connectionDidFinishLoading: received %d bytes of data", totalReceivedBytes);
	
    if (receivedData != nil && totalReceivedBytes > 0) {
        // log the xml
        NSString *xml = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
        NSLog(@"xml=%@", xml);
        
        [self parseData:receivedData];
    }
}

- (void)parseData:(NSData *)data
{
	NSLog(@"Command: parsing data...");
	currentParsedCharacterData = [NSMutableString string];
	
	// parse the xml
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	[parser setDelegate:self];
	BOOL success = [parser parse]; // return value not used
	NSLog(@"Command: xml parsed, success=%d", (int)success);
	
	currentParsedCharacterData = nil;
}

- (void)parseElement:(NSString *)elementName elementValue:(NSMutableString *)elementValue
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if (debug)
		NSLog(@"Command: didStartElement, elementName=%@", elementName);
	
	accumulatingParsedCharacterData = YES;
	// The mutable string needs to be reset to empty.
	[currentParsedCharacterData setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if (debug)
		NSLog(@"Command: didEndElement, elementName=%@, parsing=%d", elementName, (int)accumulatingParsedCharacterData);
	
	if (accumulatingParsedCharacterData) {
		[self parseElement:(NSString *)elementName elementValue:currentParsedCharacterData];
		accumulatingParsedCharacterData = NO;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	NSLog(@"foundCharacters: %@, accumulatingParsedData=%d", string, (int)accumulatingParsedCharacterData);
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self.delegate handleError:parseError];
}


@end