//
//  Command.h
//  PinboardReader
//
//  Created by Matt on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommandDelegate <NSObject>
- (void)handleError:(NSError *)error;
- (void)handleResponseCode:(int)responseCode;
@end

@interface Command : NSObject <NSXMLParserDelegate> {
    
@private
    id <CommandDelegate> delegate;
    
    // for downloading the xml data
    NSMutableData *receivedData;
    
    // these variables are used during parsing
    NSMutableString *currentParsedCharacterData;
    BOOL accumulatingParsedCharacterData;
    BOOL debug;
}

@property (assign) id <CommandDelegate> delegate;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

- (BOOL)send:(NSString*)commandName withMethod:(NSString *)method withCommandString:(NSString *)commandString, ...;
- (BOOL)sendURL:(NSURL*)url withMethod:(NSString *)method withCommandString:(NSString *)commandString, ...;
- (BOOL)sendURL:(NSURL*)url withMethod:(NSString *)method withCommandString:(NSString *)commandString withVaList:(va_list) args;
- (void)parseElement:(NSString *)elementName elementValue:(NSMutableString *)elementValue;
- (void)handleSuccessfulConnection;
- (void)handleError:(NSError *)error;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)parseData:(NSData *)data;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
- (void)parserDidEndDocument:(NSXMLParser *)parser;

@end