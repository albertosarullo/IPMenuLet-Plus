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
    

    NSStatusItem *statusItem2=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem2 setMenu:menu];


	timer=[NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(update) userInfo:nil repeats:YES];
	[timer fire];
}


-(void) update {
	// [statusItem setTitle:[GetIP getIP]];
    // /usr/bin/grep foo bar.txt'
    
    /*
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/sbin/ifconfig |grep 'inet '"];
    
    // ifconfig |grep "inet " | grep -v 127
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"|grep 'inet '", nil];
    // [task setArguments: arguments];
    */
    
    
    NSTask *task;
    task = [[NSTask alloc] init];
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
    
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"grep returned:\n%@", string);
    
    
    NSMenuItem *testItem = [[NSMenuItem alloc] initWithTitle:string action:NULL keyEquivalent:@""];
    [testItem setEnabled:YES];
    [menu addItem:testItem];

    
    [string release];
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