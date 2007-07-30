
#import "CCMStatusBarMenuControllerTest.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProjectInfo.h"

@implementation CCMStatusBarMenuControllerTest

- (void)setUp
{
    menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	NSMenuItem *sepItem = [[[NSMenuItem separatorItem] copy] autorelease];
	[sepItem setTag:7];
	[menu addItem:sepItem];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *openItem = [[[NSMenuItem alloc] initWithTitle:@"Open..." action:NULL keyEquivalent:@""] autorelease];
	[openItem setTag:8];
	[openItem setTarget:self];
	[menu addItem:openItem];
}

- (void)testAddsProjects
{
	CCMProjectInfo *info1 = [[[CCMProjectInfo alloc] initWithProjectName:@"connectfour" buildStatus:CCMFailedStatus 
														   lastBuildDate:[NSCalendarDate calendarDate]] autorelease];
	NSArray *infoList = [NSArray arrayWithObjects:info1, nil];
	
	CCMStatusBarMenuController *controller = [[[CCMStatusBarMenuController alloc] init] autorelease];
	[controller setMenu:menu];
	NSStatusItem *statusItem = [controller createStatusItem];
	[controller displayProjectInfos:infoList];
	
	STAssertEqualObjects([controller getImageForStatus:CCMFailedStatus], [statusItem image], @"Should have set right image.");
	STAssertEqualObjects(@"1", [statusItem title], @"Should have added title with number of failed projects.");
	
	NSArray *items = [[statusItem menu] itemArray];
	STAssertEqualObjects(@"connectfour (less than a minute ago)", [[items objectAtIndex:1] title], @"Should have set right project name with build interval.");
	STAssertEquals(controller, [[items objectAtIndex:1] target], @"Should have set right target.");
	STAssertTrue([[items objectAtIndex:2] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(4u, [items count], @"Should have created right number of items.");
}

@end