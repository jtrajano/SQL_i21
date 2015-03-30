GO
	PRINT N'Begin normalize Ticket Types intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intTicketTypeId
			,intSort = intSort
		from 
			[dbo].[tblHDTicketType]
		order by
			intSort
			
			
	update tblHDTicketType set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intTicketTypeId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Ticket Types intSort..'
	PRINT N'Begin normalize Ticket Statuses intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intTicketStatusId
			,intSort = intSort
		from 
			[dbo].[tblHDTicketStatus]
		order by
			intSort
			
			
	update tblHDTicketStatus set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intTicketStatusId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Ticket Statuses intSort..'
	PRINT N'Begin normalize Ticket Priorities intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intTicketPriorityId
			,intSort = intSort
		from 
			[dbo].[tblHDTicketPriority]
		order by
			intSort
			
			
	update tblHDTicketPriority set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intTicketPriorityId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Ticket Priorities intSort..'
	PRINT N'Begin normalize Job Codes intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intJobCodeId
			,intSort = intSort
		from 
			[dbo].[tblHDJobCode]
		order by
			intSort
			
			
	update tblHDJobCode set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intJobCodeId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Job Codes intSort..'
	PRINT N'Begin normalize Modules intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intModuleId
			,intSort = intSort
		from 
			[dbo].[tblHDModule]
		order by
			intSort
			
			
	update tblHDModule set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intModuleId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Modules intSort..'
	PRINT N'Begin normalize Versions intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intVersionId
			,intSort = intSort
		from 
			[dbo].[tblHDVersion]
		order by
			intSort
			
			
	update tblHDVersion set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intVersionId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Versions intSort..'
	PRINT N'Begin normalize Milestones intSort..'
GO

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

	CREATE TABLE [dbo].[tmpHDSortTable](
		[Id] [int] identity not null,
		[intId] [int] NULL,
		[intSort] [int] NULL
	)

	insert into [dbo].[tmpHDSortTable] 
		select
			intId = intMilestoneId
			,intSort = intSort
		from 
			[dbo].[tblHDMilestone]
		order by
			intSort
			
			
	update tblHDMilestone set intSort = (select Id from [dbo].[tmpHDSortTable] where intId = intMilestoneId)
	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmpHDSortTable]') AND type in (N'U'))
	DROP TABLE [dbo].[tmpHDSortTable]

GO
	PRINT N'End normalize Milestones intSort..'
	PRINT N'Begin normalize Help Desk Group and User Configuration.'
GO

	update tblHDGroupUserConfig
		set tblHDGroupUserConfig.intUserSecurityEntityId = 
			(select tblSMUserSecurity.intEntityId from tblSMUserSecurity where tblSMUserSecurity.intUserSecurityID = tblHDGroupUserConfig.intUserSecurityId)

GO
	PRINT N'End normalize Help Desk Group and User Configuration.'
	PRINT N'Begin updating tblHDTicket strJiraIssue.'
GO

	exec
		('
			declare @getid CURSOR
			declare @intTicketId INT
			declare @jiraIssues  nvarchar(max)

			SET @getid = CURSOR FOR
			SELECT distinct tblHDTicketJIRAIssue.intTicketId
			FROM   tblHDTicketJIRAIssue

			OPEN @getid
			FETCH NEXT
			FROM @getid INTO @intTicketId
			WHILE @@FETCH_STATUS = 0
			BEGIN

				set @jiraIssues = ''''
				select  @jiraIssues = COALESCE(@jiraIssues + '','', '''')  + tblHDTicketJIRAIssue.strKey from tblHDTicketJIRAIssue where tblHDTicketJIRAIssue.intTicketId = @intTicketId
				select  @jiraIssues

				update tblHDTicket set tblHDTicket.strJiraKey = SUBSTRING(@jiraIssues,2,255) where tblHDTicket.intTicketId = @intTicketId
				
				FETCH NEXT
				FROM @getid INTO @intTicketId
			END

			CLOSE @getid
			DEALLOCATE @getid
		')

GO
	PRINT N'End updating tblHDTicket strJiraIssue.'
GO