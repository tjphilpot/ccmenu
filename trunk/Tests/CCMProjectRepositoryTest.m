
#import "CCMProjectRepositoryTest.h"
#import "CCMProject.h"


@implementation CCMProjectRepositoryTest

- (void)setUp
{
	NSArray *projects = [NSArray arrayWithObject:@"connectfour"];
	repository = [[[CCMProjectRepository alloc] initWithConnection:(id)self andProjects:projects] autorelease];
	[repository setNotificationCenter:(id)self];
	postedNotifications = [NSMutableArray array];
}

- (NSMutableDictionary *)createProjectInfoWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:@"connectfour" forKey:@"name"];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	return info;
}

- (void)testCreatesProjects
{	
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	
	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
	STAssertEqualObjects(CCMSuccessStatus, [project valueForKey:@"lastBuildStatus"], @"Should have set up project projectInfo."); 
}

- (void)testIgnoresProjectsNotInInitialList
{	
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[projectInfo setObject:@"foo" forKey:@"name"];
	[repository pollServer];
	
	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have ignored additional project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have kept project with right name."); 
	STAssertEqualObjects(CCMSuccessStatus, [project valueForKey:@"lastBuildStatus"], @"Should have kept right status."); 
}

- (void)testUpdatesProjects
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	
	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have created only one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(CCMFailedStatus, [project valueForKey:@"lastBuildStatus"], @"Should have updated project projectInfo."); 
}

- (void)testSendsSuccessfulBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	
	STAssertTrue([postedNotifications count] > 0, @"Should have posted notification.");
	NSNotification *notification = [postedNotifications objectAtIndex:0];
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have posted correct notification.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(@"connectfour", [userInfo objectForKey:@"projectName"], @"Should have set project name.");
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsFixedBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsStillFailingBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testSendsFixenBuildCompletionNotificationEvenIfBuildWasMissed
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[repository pollServer];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[repository pollServer];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}


// connection stub

- (NSArray *)getProjectInfos
{
	return [NSArray arrayWithObject:projectInfo];
}

// notification center stub

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[postedNotifications addObject:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
