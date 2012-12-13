//
//  GetIP.m
//  IPMenulet
//
//  Created by Andrew Pennebaker on 23 Jan 2008.
//  Copyright 2008 YelloSoft. All rights reserved.
//

#import "GetIP.h"

@implementation GetIP

+(NSString *) getExternalIP {
	NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://highearthorbit.com/service/myip.php"]];

	NSURLResponse *response=nil;
	NSError *error=nil;
	NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	if (error) {
		return @"?.?.?.?";
	}

	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(NSArray *) getLocalIPs {
    
    NSMutableArray *localIPs = [[NSMutableArray alloc] initWithCapacity:2];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", @"ifconfig |grep 'inet ' | grep -v 127", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    for (int i=0; i < [lines count]; i++) {
        NSString *line = [lines objectAtIndex:i];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line length] != 0) {
            NSArray *parts = [line componentsSeparatedByString:@" "];
            [localIPs addObject:[parts objectAtIndex:1]];
        }
    }
    
    [output release];
    [task release];
    
    return localIPs;
}
@end