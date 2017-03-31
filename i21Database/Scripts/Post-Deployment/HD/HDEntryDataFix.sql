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
	PRINT N'Begin normalize Help Desk Group and User Configuration.'
GO

	update tblHDGroupUserConfig
		set tblHDGroupUserConfig.intUserSecurityEntityId = 
			(select tblSMUserSecurity.[intEntityId] from tblSMUserSecurity where tblSMUserSecurity.[intEntityId] = tblHDGroupUserConfig.intUserSecurityId)

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
	PRINT N'Start updating tblHDTicket Customer Id.'
GO
	Update tblHDTicket set tblHDTicket.strType = 'HD' where tblHDTicket.strType is null and SUBSTRING(tblHDTicket.strTicketNumber,1,4) = 'HDTN';
	Update tblHDTicket set tblHDTicket.strType = 'CRM' where tblHDTicket.strType is null and SUBSTRING(tblHDTicket.strTicketNumber,1,4) = 'CRMN';

GO
	PRINT N'End updating tblHDTicket Customer Id.'
/*
	PRINT N'Start fixing Help Desk Settings.'
GO

	IF EXISTS(SELECT 1 FROM tblHDSetting)
	BEGIN
	
		UPDATE tblHDSetting
			SET tblHDSetting.strHelpDeskURL = 'http://fb.irely.com/iRelyi21/i21'
	END
	else
	begin
		INSERT INTO tblHDSetting
           (strHelpDeskName
           ,strHelpDeskURL
           ,strJIRAURL
           ,strTimeZone
           ,intTicketStatusId
           ,intTicketTypeId
           ,intBillingIncrement
           ,intConcurrencyId)
		 VALUES
			   ('i21 Help Desk'
			   ,'http://fb.irely.com/iRelyi21/i21'
			   ,'http://jira.irelyserver.com'
			   ,null
			   ,null
			   ,null
			   ,0
			   ,1)
	end

GO
	PRINT N'End fixing Help Desk Settings.'
*/
	PRINT N'Start fixing Milestone data.'
GO

	Update tblHDMilestone set intSort = intPriority

GO
	PRINT N'End fixing Milestone data.'
	PRINT N'Start updating HD modules with SM modules.'
GO

	Update tblHDModule set tblHDModule.intSMModuleId = (select top 1 vyuHDSMModuleMap.intSMModuleId
														from vyuHDSMModuleMap
														where vyuHDSMModuleMap.intHDModuleId = tblHDModule.intModuleId)
	where tblHDModule.intSMModuleId is null

GO
	PRINT N'End updating HD modules with SM modules.'
	PRINT N'Start updating HD ticket closed date.'
GO

	Update tblHDTicket set tblHDTicket.dtmCompleted = tblHDTicket.dtmLastModified
	where tblHDTicket.dtmCompleted is null and tblHDTicket.intTicketStatusId = 2

GO
	PRINT N'End updating HD ticket closed date.'
	PRINT N'Start updating HD ticket last commented date.'
GO

	update
		tblHDTicket 
	set
		tblHDTicket.dtmLastCommented = (select max(tblHDTicketComment.dtmLastModified) from tblHDTicketComment where tblHDTicketComment.intTicketId = tblHDTicket.intTicketId)
		,tblHDTicket.intLastCommentedByEntityId = (
													select
														top 1 tblHDTicketComment.intLastModifiedUserEntityId 
													from
														tblHDTicketComment 
													where
														tblHDTicketComment.intTicketId = tblHDTicket.intTicketId
														and tblHDTicketComment.dtmLastModified = (
																									select max(tblHDTicketComment.dtmLastModified) 
																									from tblHDTicketComment 
																									where tblHDTicketComment.intTicketId = tblHDTicket.intTicketId
																								  )
												  )
	where tblHDTicket.dtmLastCommented is null

GO
	PRINT N'End updating HD ticket last commented date.'
	PRINT N'Start updating HD ticket lines of business.'
GO

	update
		tblHDTicket 
	set
		tblHDTicket.strLineOfBusinessId = convert(nvarchar(255), (case when tblHDTicket.intLineOfBusinessId is null then 0 else tblHDTicket.intLineOfBusinessId end))
	where tblHDTicket.strLineOfBusinessId is null

GO
	PRINT N'End updating HD ticket lines of business.'
	PRINT N'Start updating HD Project Type.'
GO

	update
		tblHDProject 
	set
		tblHDProject.strType = 'HD'
	where
		tblHDProject.strType is null or tblHDProject.strType = ''

GO
	PRINT N'End updating HD Project Type.'
	PRINT N'Start updating HD Statuses.'
GO

	update
		tblHDTicketStatus
	set
		ysnUpdated = 1
		,ysnTicket = ysnSupported
	where
		ysnUpdated <> 1
		or ysnUpdated is null

GO
	PRINT N'End updating HD Statuses.'
	PRINT N'Start updating HD Priorities.'
GO

	update
		tblHDTicketPriority
	set
		ysnUpdated = 1
		,ysnTicket = 1
	where
		ysnUpdated <> 1
		or ysnUpdated is null

GO
	PRINT N'End updating HD Priorities.'
	PRINT N'Start updating HD Opportunity Campaign Image Id.'
GO

	update
		[tblCRMCampaign]
		set
			[tblCRMCampaign].strImageId = LOWER(NEWID())
	where
		[tblCRMCampaign].strImageId is null

GO
	PRINT N'End updating HD Opportunity Campaign Image Id.'
	PRINT N'Start updating HD Ticket Sequence in Project.'
GO

	DECLARE @intProjectId INT
	DECLARE @intTicketId INT
	DECLARE @queryResult CURSOR

	DECLARE @cnt INT = 0;
	DECLARE @activeProjectId INT = 0;

	SET @queryResult = CURSOR FOR
	select
		tblHDProject.intProjectId
		,tblHDTicket.intTicketId
	from
		tblHDProject
		,tblHDProjectTask
		,tblHDTicket
	where
		tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and tblHDTicket.intSequenceInProject is null
	order by
		tblHDProject.intProjectId
		,tblHDTicket.intTicketId

	OPEN @queryResult
	FETCH NEXT
	FROM @queryResult INTO @intProjectId, @intTicketId
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if (@activeProjectId <> @intProjectId)
		begin
			set @activeProjectId = @intProjectId;
			set @cnt = 0;
		end

		set @cnt = @cnt + 1;

		update tblHDTicket set tblHDTicket.intSequenceInProject = @cnt where tblHDTicket.intTicketId = @intTicketId;
				
		FETCH NEXT
		FROM @queryResult INTO @intProjectId, @intTicketId
	END

	CLOSE @queryResult
	DEALLOCATE @queryResult

GO
	PRINT N'End updating HD Ticket Sequence in Project.'
GO
