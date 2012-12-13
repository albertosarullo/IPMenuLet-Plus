//
//  IPMenulet.m
//  IPMenulet
//
//  Created by Andrew Pennebaker on 13 Dec 2007.
//  Copyright 2007 YelloSoft. All rights reserved.
//

#import "IPMenulet.h"
#import "GetIP.h"

@implementation IPMenulet

-(void) dealloc {
	[timer release];
	[refreshMenuItem release];
	[aboutMenuItem release];
	[quitMenuItem release];
	[statusItem release];
	[menu release];

	[super dealloc];
}

-(void) awakeFromNib {
	statusItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:menu];

	[statusItem setHighlightMode:YES];
	[statusItem setTitle:@"IP"];
	[statusItem setEnabled:YES];

    NSMenuItem *testItem = [[NSMenuItem alloc] initWithTitle:@"Test" action:@selector(copy:) keyEquivalent:@""];
    [testItem setTarget:self];
    [testItem setEnabled:true];
    [menu addItem:testItem];
    [testItem release];


	timer=[NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(update) userInfo:nil repeats:YES];
	[timer fire];
}


-(void) copy:(NSMenuItem*)target {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:target.title forType:NSStringPboardType];
}

-(void) update {
	
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"-c",
                 @"ifconfig |grep 'inet ' | grep -v 127", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    for (int i=0; i < [lines count]; i++) {
        NSString *line = [lines objectAtIndex:i];
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([line length] != 0) {
            NSArray *parts = [line componentsSeparatedByString:@" "];
            NSMenuItem *testItem = [[NSMenuItem alloc] initWithTitle:[parts objectAtIndex:1]
                                                              action:@selector(copy:)
                                                       keyEquivalent:@""];
            [testItem setTarget:self];
            [testItem setEnabled:YES];
            [menu addItem:testItem];
            [testItem release];
        }

    }
    
    [output release];
    [task release];
}

-(IBAction) refresh: (id) sender {
    
	[self update];
}

-(IBAction) about: (id) sender {
	NSApplication *app=[NSApplication sharedApplication];
	[app activateIgnoringOtherApps:YES];
	[app orderFrontStandardAboutPanel:NULL];
}

@end