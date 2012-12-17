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
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:menu];

	[statusItem setHighlightMode:YES];
	[statusItem setTitle:@"IP"];
	[statusItem setEnabled:YES];

    [menu insertItem:[NSMenuItem separatorItem] atIndex:0];

	timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(update) userInfo:nil repeats:YES];
	[timer fire];
}

-(void) copy:(NSMenuItem*)target {
     NSArray *ip = [target.title componentsSeparatedByString:@" "];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:[ip objectAtIndex:0] forType:NSStringPboardType];
}

-(void) update {
	[self refresh:nil];
}

-(IBAction) refresh: (id) sender {
    
    int originalItemCount = 5;
    int itemCount = [menu numberOfItems] - originalItemCount;
    
    for (int j = itemCount; j > 0; j--) {
        [menu removeItemAtIndex:0];
    }
    
    NSString *externalIp = [GetIP getExternalIP];
    NSMutableArray *ips = [[NSMutableArray alloc] initWithObjects:externalIp, nil];
    
    [ips addObjectsFromArray:[GetIP getLocalIPs]];
    
    for(int i = 0; i < [ips count]; i++) {
        NSMenuItem *testItem = [[NSMenuItem alloc] initWithTitle:[ips objectAtIndex:i]
                                                      action:@selector(copy:)
                                               keyEquivalent:@""];
        [testItem setTarget:self];
        [testItem setEnabled:YES];
    
        [menu insertItem: testItem atIndex:i];
        [testItem release];
    }
    
}

-(IBAction) about: (id) sender {
	NSApplication *app = [NSApplication sharedApplication];
	[app activateIgnoringOtherApps:YES];
	[app orderFrontStandardAboutPanel:NULL];
}

@end