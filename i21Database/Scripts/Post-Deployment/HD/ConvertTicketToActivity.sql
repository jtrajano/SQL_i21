GO
	PRINT N'Begin converting Ticket to Activity...'
GO

/*
alter table tblHDTicket add ysnConvertedToActivity bit null;
alter table tblHDTicketComment add ysnConvertedToActivity bit null;
alter table tblHDTicketNote add ysnConvertedToActivity bit null;
alter table tblHDTicketParticipant add ysnConvertedToActivity bit null;
alter table tblHDTicketJIRAIssue add ysnConvertedToActivity bit null;
alter table tblHDTicketHoursWorked add ysnConvertedToActivity bit null;

*/


/*Insert missing priority to tblSMTypeValue with type='Priority'*/

print 'Merging priority and activity priority';

insert into tblSMTypeValue (strType,strValue,ysnDefault,intConcurrencyId)
select strType = 'Priority', strValue = ticketpriority.strValue, ysnDefault = convert(bit,1), intConcurrencyId = 1 from
(
select
	distinct strValue = (case b.strPriority when 'Sev 1 - Blocker' then 'High' when 'Sev 2 - Major' then 'Normal' when 'Sev 3 - Standard' then 'Low' else b.strPriority end)
from
	tblHDTicket a
	,tblHDTicketPriority b
where
	b.intTicketPriorityId = a.intTicketPriorityId
) as ticketpriority where ticketpriority.strValue not in (select sm.strValue from tblSMTypeValue sm where sm.strType = 'Priority')

/*Query to create View*/
select
	distinct b.intTicketPriorityId
	,b.strPriority
	,strValue = (case b.strPriority when 'Sev 1 - Blocker' then 'High' when 'Sev 2 - Major' then 'Normal' when 'Sev 3 - Standard' then 'Low' else b.strPriority end)
	,c.intTypeValueId
from
	tblHDTicket a
	,tblHDTicketPriority b
	,tblSMTypeValue c
where
	b.intTicketPriorityId = a.intTicketPriorityId
	and c.strType = 'Priority' and c.strValue = (case b.strPriority when 'Sev 1 - Blocker' then 'High' when 'Sev 2 - Major' then 'Normal' when 'Sev 3 - Standard' then 'Low' else b.strPriority end)

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*Insert missing type to tblSMTypeValue with type='Category'*/
print 'Merging ticket type and activity category';
insert into tblSMTypeValue (strType,strValue,ysnDefault,intConcurrencyId)
select strType = 'Category', strValue = tickettype.strValue, ysnDefault = convert(bit,1), intConcurrencyId = 1 from
(
select
	distinct strValue = b.strType
from
	tblHDTicket a
	,tblHDTicketType b
where
	b.intTicketTypeId = a.intTicketTypeId
) as tickettype where tickettype.strValue not in (select sm.strValue from tblSMTypeValue sm where sm.strType = 'Category')

/*Query to create View*/
select
	distinct b.intTicketTypeId
	,b.strType
	,strValue = b.strType
	,c.intTypeValueId 
from
	tblHDTicket a
	,tblHDTicketType b
	,tblSMTypeValue c
where
	b.intTicketTypeId = a.intTicketTypeId
	and c.strType = 'Category' and c.strValue = b.strType
	
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	
/*Insert missing status to tblSMTypeValue with type='Status'*/
print 'Merging ticket status and activity status';
insert into tblSMTypeValue (strType,strValue,ysnDefault,intConcurrencyId)
select strType = 'Status', strValue = ticketstatus.strValue, ysnDefault = convert(bit,1), intConcurrencyId = 1 from
(
select
	distinct strValue = b.strStatus
from
	tblHDTicket a
	,tblHDTicketStatus b
where
	b.intTicketStatusId = a.intTicketStatusId
) as ticketstatus where ticketstatus.strValue not in (select sm.strValue from tblSMTypeValue sm where sm.strType = 'Status')

/*Query to create View*/
select
	distinct b.intTicketStatusId
	,b.strStatus
	,strValue = b.strStatus
	,c.intTypeValueId 
from
	tblHDTicket a
	,tblHDTicketStatus b
	,tblSMTypeValue c
where
	b.intTicketStatusId = a.intTicketStatusId
	and c.strType = 'Status' and c.strValue = b.strStatus

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/	

/*Create transaction for all Help Desk Project*/
print 'Creating project transaction';
insert into tblSMTransaction (intScreenId, strTransactionNo, intRecordId, intConcurrencyId)
select
	intScreenId = (select intScreenId from tblSMScreen where strModule = 'Help Desk' and strNamespace = 'HelpDesk.view.Project')
	,strTransactionNo = convert(nvarchar(20), c.intProjectId)
	,intRecordId = c.intProjectId
	,intConcurrencyId = 1
from
	tblHDProject c
where
	c.intProjectId not in
		(
		select
			distinct b.intRecordId
		from
			tblSMScreen a
			,tblSMTransaction b
		where
			a.strModule = 'Help Desk'
			and a.strNamespace = 'HelpDesk.view.Project'
			and b.intScreenId = a.intScreenId
		)
		
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


PRINT N'Converting Ticket to Activity...'

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectActivityTmp'))
BEGIN
	CREATE TABLE [dbo].[tblHDProjectActivityTmp]
	(
		[intId] [int] IDENTITY(1,1) NOT NULL,
		[intActivityId] [int] NOT NULL,
		[intTicketIdId] [int] NULL,
		[intTicketCommentId] [int] NULL,
		[intTicketNoteId] [int] NULL,
		CONSTRAINT [PK_tblHDProjectActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
	)
END

DECLARE @queryResultAct CURSOR

declare @intOffset int = (SELECT datediff(hour,GETUTCDATE(), getdate()));

declare @intTransactionIdAct int
declare @strTypeAct nvarchar(50)
declare @strSubjectAct nvarchar(100)
declare @intEntityContactIdAct int
declare @intEntityIdAct int
declare @intCompanyLocationIdAct int
declare @dtmStartDateAct datetime
declare @dtmEndDateAct datetime
declare @dtmStartTimeAct datetime
declare @dtmEndTimeAct datetime
declare @strStatusAct nvarchar(50)
declare @strPriorityAct nvarchar(50)
declare @strCategoryAct nvarchar(50)
declare @intAssignedToAct int
declare @strActivityNoAct nvarchar(50)
declare @strDetailsAct nvarchar(max)
declare @ysnPublicAct bit
declare @dtmCreatedAct datetime
declare @dtmModifiedAct datetime
declare @intCreatedByAct int
declare @intConcurrencyIdAct int
declare @intTicketIdAct int
declare @strTicketNumber nvarchar(50)
declare @intActivitySourceId int

declare @intCurrentActivityNoAct int
declare @intGeneratedActivityIdentityAct int
declare @intGeneratedActivityTransactionIdentity int

SET @queryResultAct = CURSOR FOR
	select
		intTransactionId
		,strType
		,strSubject
		,intEntityContactId
		,intEntityId
		,intCompanyLocationId
		,dtmStartDate
		,dtmEndDate
		,dtmStartTime
		,dtmEndTime
		,strStatus
		,strPriority
		,strCategory
		,intAssignedTo
		,strActivityNo
		,strDetails
		,ysnPublic
		,dtmCreated
		,dtmModified
		,intCreatedBy
		,intConcurrencyId
		,intTicketId
		,strTicketNumber
	from
	(
	select
		intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProject.intProjectId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'HelpDesk.view.Project'))
		,strType = 'Task'
		,strSubject = tblHDTicket.strTicketNumber + ' - ' + tblHDTicket.strSubject
		,intEntityContactId = tblHDTicket.intCustomerContactId
		,intEntityId = tblHDTicket.intCustomerId
		,intCompanyLocationId = tblHDTicket.intCompanyLocationId
		,dtmStartDate = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmEndDate = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmStartTime = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmEndTime = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,strStatus = (select top 1 tblHDTicketStatus.strStatus from tblHDTicketStatus where tblHDTicketStatus.intTicketStatusId = tblHDTicket.intTicketStatusId)
		,strPriority = (select top 1 (case when tblHDTicketPriority.strPriority = 'Sev 1 - Blocker' then 'High' when tblHDTicketPriority.strPriority = 'Sev 2 - Major' then 'High' else 'Normal' end) from tblHDTicketPriority where tblHDTicketPriority.intTicketPriorityId = tblHDTicket.intTicketPriorityId)
		,strCategory = (select top 1 tblHDTicketType.strType from tblHDTicketType where tblHDTicketType.intTicketTypeId = tblHDTicket.intTicketTypeId)
		,intAssignedTo = tblHDTicket.intAssignedToEntity
		,strActivityNo = (select top 1 tblSMStartingNumber.strPrefix from tblSMStartingNumber where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity')
		,strDetails = '<p>'+tblHDTicket.strSubject+'</p>'
		,ysnPublic = 1
		,dtmCreated = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmCreated) else DATEADD(hour, -@intOffset, tblHDTicket.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmLastModified) else DATEADD(hour, -@intOffset, tblHDTicket.dtmLastModified) end)
		,intCreatedBy = tblHDTicket.intCreatedUserEntityId
		,intConcurrencyId = 1
		,intTicketId = tblHDTicket.intTicketId
		,strTicketNumber = tblHDTicket.strTicketNumber
	from tblHDProject, tblHDProjectTask, tblHDTicket
	where tblHDProject.strType <> 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and isnull(tblHDTicket.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

	union all

		select
		intTransactionId = null
		,strType = 'Task'
		,strSubject = (case when len(tblHDTicket.strTicketNumber + ' - ' + tblHDTicket.strSubject) > 100 then SUBSTRING(tblHDTicket.strTicketNumber + ' - ' + tblHDTicket.strSubject, 1, 97) + '...' else tblHDTicket.strTicketNumber + ' - ' + tblHDTicket.strSubject end)
		,intEntityContactId = tblHDTicket.intCustomerContactId
		,intEntityId = tblHDTicket.intCustomerId
		,intCompanyLocationId = tblHDTicket.intCompanyLocationId
		,dtmStartDate = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmEndDate = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmStartTime = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,dtmEndTime = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmDueDate) else DATEADD(hour, -@intOffset, tblHDTicket.dtmDueDate) end)
		,strStatus = (select top 1 tblHDTicketStatus.strStatus from tblHDTicketStatus where tblHDTicketStatus.intTicketStatusId = tblHDTicket.intTicketStatusId)
		,strPriority = (select top 1 (case when tblHDTicketPriority.strPriority = 'Sev 1 - Blocker' then 'High' when tblHDTicketPriority.strPriority = 'Sev 2 - Major' then 'High' else 'Normal' end) from tblHDTicketPriority where tblHDTicketPriority.intTicketPriorityId = tblHDTicket.intTicketPriorityId)
		,strCategory = (select top 1 tblHDTicketType.strType from tblHDTicketType where tblHDTicketType.intTicketTypeId = tblHDTicket.intTicketTypeId)
		,intAssignedTo = tblHDTicket.intAssignedToEntity
		,strActivityNo = (select top 1 tblSMStartingNumber.strPrefix from tblSMStartingNumber where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity')
		,strDetails = '<p>'+tblHDTicket.strSubject+'</p>'
		,ysnPublic = 1
		,dtmCreated = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmCreated) else DATEADD(hour, -@intOffset, tblHDTicket.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intOffset), tblHDTicket.dtmLastModified) else DATEADD(hour, -@intOffset, tblHDTicket.dtmLastModified) end)
		,intCreatedBy = tblHDTicket.intCreatedUserEntityId
		,intConcurrencyId = 1
		,intTicketId = tblHDTicket.intTicketId
		,strTicketNumber = tblHDTicket.strTicketNumber
	from tblHDTicket
	where tblHDTicket.strType <> 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)
		and isnull(tblHDTicket.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)
	) as queryresult
	ORDER BY intTicketId

OPEN @queryResultAct
FETCH NEXT
FROM
	@queryResultAct
INTO
	@intTransactionIdAct
	,@strTypeAct
	,@strSubjectAct
	,@intEntityContactIdAct
	,@intEntityIdAct
	,@intCompanyLocationIdAct
	,@dtmStartDateAct
	,@dtmEndDateAct
	,@dtmStartTimeAct
	,@dtmEndTimeAct
	,@strStatusAct
	,@strPriorityAct
	,@strCategoryAct
	,@intAssignedToAct
	,@strActivityNoAct
	,@strDetailsAct
	,@ysnPublicAct
	,@dtmCreatedAct
	,@dtmModifiedAct
	,@intCreatedByAct
	,@intConcurrencyIdAct
	,@intTicketIdAct
	,@strTicketNumber

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblHDProjectActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblHDProjectActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END

	IF NOT EXISTS (select * from tblHDProjectActivityTmp where intTicketIdId = @intTicketIdAct)
	BEGIN
		set @intCurrentActivityNoAct = (select top 1 tblSMStartingNumber.intNumber from tblSMStartingNumber where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity');
		update tblSMStartingNumber set tblSMStartingNumber.intNumber = (@intCurrentActivityNoAct + 1) where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity';
		set @strActivityNoAct = @strActivityNoAct + convert(nvarchar(50),@intCurrentActivityNoAct);
		set @intActivitySourceId = (select top 1 intActivitySourceId from tblSMActivitySource where strActivitySource = 'Help Desk');

		Insert into tblSMActivity
		(
			intTransactionId
			,strType
			,strSubject
			,intEntityContactId
			,intEntityId
			,intCompanyLocationId
			,dtmStartDate
			,dtmEndDate
			,dtmStartTime
			,dtmEndTime
			,strStatus
			,strPriority
			,strCategory
			,intAssignedTo
			,strActivityNo
			,strDetails
			,ysnPublic
			,dtmCreated
			,dtmModified
			,intCreatedBy
			,intActivitySourceId
			,intConcurrencyId
		)
		(
			select 
				intTransactionId = @intTransactionIdAct
				,strType = @strTypeAct
				,strSubject = @strSubjectAct
				,intEntityContactId = @intEntityContactIdAct
				,intEntityId = @intEntityIdAct
				,intCompanyLocationId = @intCompanyLocationIdAct
				,dtmStartDate = @dtmEndDateAct
				,dtmEndDate = @dtmEndDateAct
				,dtmStartTime = @dtmEndDateAct
				,dtmEndTime = @dtmEndTimeAct
				,strStatus = @strStatusAct
				,strPriority = (case when @strPriorityAct is null then 'Normal' else @strPriorityAct end)
				,strCategory = @strCategoryAct
				,intAssignedTo = @intAssignedToAct
				,strActivityNo = @strActivityNoAct
				,strDetails = @strDetailsAct
				,ysnPublic = @ysnPublicAct
				,dtmCreated = @dtmCreatedAct
				,dtmModified = @dtmModifiedAct
				,intCreatedBy = @intCreatedByAct
				,intActivitySourceId = @intActivitySourceId
				,intConcurrencyId = @intConcurrencyIdAct
		)

		
		set @intGeneratedActivityIdentityAct =  SCOPE_IDENTITY();
		update tblHDTicket set ysnConvertedToActivity = convert(bit,1) where intTicketId = @intTicketIdAct;
		insert into tblHDTicketToActivity
		(
			intTicketId
			,intActivityId
			,strTicketNumber
			,strActivityNo
			,strActivityType
			,intConcurrencyId
		)
		(
		select
			intTicketId = @intTicketIdAct
			,intActivityId = @intGeneratedActivityIdentityAct
			,strTicketNumber = @strTicketNumber
			,strActivityNo = @strActivityNoAct
			,strActivityType = 'Task'
			,intConcurrencyId = 1
		)

		insert into tblHDProjectActivityTmp
		(
			intActivityId
			,intTicketIdId
		)
		(
			select
				intActivityId = @intGeneratedActivityIdentityAct
				,intTicketIdId = @intTicketIdAct
		)

		insert into tblSMTransaction
		(
			intScreenId
			,intRecordId
			,strTransactionNo
			,intEntityId
			,dtmDate
			,strApprovalStatus
			,intConcurrencyId
		)
		(
			select
				intScreenId = (select top 1 intScreenId from tblSMScreen where strNamespace = 'GlobalComponentEngine.view.Activity' and strScreenName = 'Activity')
				,intRecordId =  @intGeneratedActivityIdentityAct
				,strTransactionNo = @strActivityNoAct
				,intEntityId = @intEntityIdAct
				,dtmDate = @dtmCreatedAct
				,strApprovalStatus = null
				,intConcurrencyId = 1
		)

		set @intGeneratedActivityTransactionIdentity = SCOPE_IDENTITY();

		insert into tblCRMJiraIssue
		(
			strJiraKey
			,intTransactionId
			,intConcurrencyId
		)
		select distinct
			strJiraKey = strKey
			,intTransactionId = @intGeneratedActivityTransactionIdentity
			,intConcurrencyId = 1
		from tblHDTicketJIRAIssue where intTicketId = @intTicketIdAct and strKey is not null and isnull(ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

		update tblHDTicketJIRAIssue set ysnConvertedToActivity = convert(bit,1) where intTicketId = @intTicketIdAct;

		INSERT INTO tblCRMHoursWorked (
				   intTransactionId
				   ,intEntityId
				   ,dblHours
				   ,dtmDate
				   ,intItemId
				   ,ysnBillable
				   ,dblRate
				   ,intInvoiceId
				   ,strJiraKey
				   ,strDescription
				   ,intCreatedByEntityId
				   ,dtmCreatedDate
				   ,intCurrencyId
				   ,intCurrencyExchangeRateId
				   ,intCurrencyExchangeRateTypeId
				   ,intConcurrencyId
				   )
		select
				   intTransactionId = @intGeneratedActivityTransactionIdentity
				   ,intEntityId = a.intAgentEntityId
				   ,dblHours = a.intHours
				   ,dtmDate = a.dtmDate
				   ,intItemId = b.intItemId
				   ,ysnBillable = a.ysnBillable
				   ,dblRate = a.dblRate
				   ,intInvoiceId = a.intInvoiceId
				   ,strJiraKey = replace(a.strJIRALink, 'http://jira.irelyserver.com/browse/', '')
				   ,strDescription = a.strDescription
				   ,intCreatedByEntityId = a.intCreatedUserEntityId
				   ,dtmCreatedDate = (case when a.dtmCreated is null then a.dtmDate else a.dtmCreated end)
				   ,intCurrencyId = c.intCurrencyId
				   ,intCurrencyExchangeRateId = c.intCurrencyExchangeRateId
				   ,intCurrencyExchangeRateTypeId = c.intCurrencyExchangeRateTypeId
				   ,intConcurrencyId = a.intConcurrencyId
		from tblHDTicketHoursWorked a, tblHDJobCode b, tblHDTicket c
		where
			b.intJobCodeId = a.intJobCodeId
			and a.intTicketId = @intTicketIdAct
			and c.intTicketId = a.intTicketId
			and isnull(a.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)
			and a.intAgentEntityId is not null

		update tblHDTicketHoursWorked set ysnConvertedToActivity = convert(bit,1) where intTicketId = @intTicketIdAct;

		insert into tblSMActivityAttendee
		(
			intEntityId
			,intActivityId
			,intConcurrencyId
			,ysnAddCalendarEvent
		)
		select
			a.intEntityId
			,intActivityId = @intGeneratedActivityIdentityAct
			,a.intConcurrencyId
			,a.ysnAddCalendarEvent
		from
			tblHDTicketParticipant a
		where
			a.intTicketId = @intTicketIdAct
			and isnull(a.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)
			
		update tblHDTicketParticipant set ysnConvertedToActivity = convert(bit,1) where intTicketId = @intTicketIdAct;

	END
				
    FETCH NEXT
    FROM
		@queryResultAct
	INTO
		@intTransactionIdAct
		,@strTypeAct
		,@strSubjectAct
		,@intEntityContactIdAct
		,@intEntityIdAct
		,@intCompanyLocationIdAct
		,@dtmStartDateAct
		,@dtmEndDateAct
		,@dtmStartTimeAct
		,@dtmEndTimeAct
		,@strStatusAct
		,@strPriorityAct
		,@strCategoryAct
		,@intAssignedToAct
		,@strActivityNoAct
		,@strDetailsAct
		,@ysnPublicAct
		,@dtmCreatedAct
		,@dtmModifiedAct
		,@intCreatedByAct
		,@intConcurrencyIdAct
		,@intTicketIdAct
		,@strTicketNumber
END

CLOSE @queryResultAct
DEALLOCATE @queryResultAct

update tblSMAttachment set tblSMAttachment.strScreen = 'GlobalComponentEngine.view.Activity', tblSMAttachment.strRecordNo = (select top 1 convert(nvarchar(50),tblHDProjectActivityTmp.intActivityId) from tblHDProjectActivityTmp where tblHDProjectActivityTmp.intTicketIdId = convert(int,tblSMAttachment.strRecordNo)) where tblSMAttachment.strScreen = 'HelpDesk.Ticket' and tblSMAttachment.strRecordNo in (select convert(nvarchar(50),tblHDProjectActivityTmp.intTicketIdId) from tblHDProjectActivityTmp);

PRINT N'Creating Activity Note from Ticket Details...'

DECLARE @queryResultComment CURSOR

declare @intDetailsOffset int = (SELECT datediff(hour,GETUTCDATE(), getdate()));

declare @strCommentComment nvarchar(max);
declare @strScreenComment nvarchar(50);
declare @strRecordNoComment nvarchar(50);
declare @dtmAddedComment datetime;
declare @dtmModifiedComment datetime;
declare @ysnPublicComment bit;
declare @ysnEditedComment bit;
declare @intEntityIdComment int;
declare @intTransactionIdComment int;
declare @intActivityIdComment int;
declare @intConcurrencyIdComment int;
declare @intTicketCommentIdComment int;
declare @intTicketNoteIdComment int;

declare @intCommentIdComment int;

SET @queryResultComment = CURSOR FOR

	select
		strComment = '<p>Comment : '+(case when tblHDTicketComment.ysnSent = 1 then 'Sent' else '<font color="red">Draft</font>' end)+'</p>'+(case when tblHDTicketComment.ysnEncoded = 1 and len(tblHDTicketComment.strComment) > 3 then dbo.fnHDDecodeComment(substring(tblHDTicketComment.strComment,4,len(tblHDTicketComment.strComment)-3)) else tblHDTicketComment.strComment end)+'</br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmCreated) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmLastModified) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmLastModified) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketComment.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProjectActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblHDProjectActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketComment.intTicketCommentId
	from tblHDProject, tblHDProjectTask, tblHDTicket, tblHDProjectActivityTmp, tblHDTicketComment
	where tblHDProject.strType <> 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and tblHDProjectActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketComment.intTicketId = tblHDTicket.intTicketId
		and isnull(tblHDTicketComment.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

	union all

	select
		strComment = '<p>Comment : '+(case when tblHDTicketComment.ysnSent = 1 then 'Sent' else '<font color="red">Draft</font>' end)+'</p>'+(case when tblHDTicketComment.ysnEncoded = 1 and len(tblHDTicketComment.strComment) > 3 then dbo.fnHDDecodeComment(substring(tblHDTicketComment.strComment,4,len(tblHDTicketComment.strComment)-3)) else tblHDTicketComment.strComment end)+'</br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmCreated) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmLastModified) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmLastModified) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketComment.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProjectActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblHDProjectActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketComment.intTicketCommentId
	from tblHDTicket, tblHDProjectActivityTmp, tblHDTicketComment
	where tblHDTicket.strType <> 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)
		and tblHDProjectActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketComment.intTicketId = tblHDTicket.intTicketId
		and isnull(tblHDTicketComment.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

OPEN @queryResultComment
FETCH NEXT
FROM
	@queryResultComment
INTO
	@strCommentComment
	,@strScreenComment
	,@strRecordNoComment
	,@dtmAddedComment
	,@dtmModifiedComment
	,@ysnPublicComment
	,@ysnEditedComment
	,@intEntityIdComment
	,@intTransactionIdComment
	,@intActivityIdComment
	,@intConcurrencyIdComment
	,@intTicketCommentIdComment

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblHDProjectActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblHDProjectActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END
	IF NOT EXISTS (select * from tblHDProjectActivityTmp where intTicketCommentId = @intTicketCommentIdComment)
	BEGIN

		Insert into tblSMComment
		(
			strComment
			,strScreen
			,strRecordNo
			,dtmAdded
			,dtmModified
			,ysnPublic
			,ysnEdited
			,intEntityId
			,intTransactionId
			,intActivityId
			,intConcurrencyId
		)
		(
			select 
				strComment = @strCommentComment
				,strScreen = @strScreenComment
				,strRecordNo = @strRecordNoComment
				,dtmAdded = @dtmAddedComment
				,dtmModified = @dtmModifiedComment
				,ysnPublic = @ysnPublicComment
				,ysnEdited = @ysnEditedComment
				,intEntityId = @intEntityIdComment
				,intTransactionId = @intTransactionIdComment
				,intActivityId = @intActivityIdComment
				,intConcurrencyId = @intConcurrencyIdComment
		)

		update tblHDTicketComment set ysnConvertedToActivity = convert(bit,1) where intTicketCommentId = @intTicketCommentIdComment;
		
		set @intCommentIdComment =  SCOPE_IDENTITY();

		insert into tblHDProjectActivityTmp
		(
			intActivityId
			,intTicketCommentId
		)
		(
			select
				intActivityId = @intCommentIdComment
				,intTicketCommentId = @intTicketCommentIdComment
		)

	END
				
    FETCH NEXT
    FROM
		@queryResultComment
	INTO
		@strCommentComment
		,@strScreenComment
		,@strRecordNoComment
		,@dtmAddedComment
		,@dtmModifiedComment
		,@ysnPublicComment
		,@ysnEditedComment
		,@intEntityIdComment
		,@intTransactionIdComment
		,@intActivityIdComment
		,@intConcurrencyIdComment
		,@intTicketCommentIdComment
END

CLOSE @queryResultComment
DEALLOCATE @queryResultComment


PRINT N'Creating Activity Note from Activity Internal Note...'

DECLARE @queryResultNote CURSOR

declare @intNotesOffset int = (SELECT datediff(hour,GETUTCDATE(), getdate()));

declare @strCommentNote nvarchar(max);
declare @strScreenNote nvarchar(50);
declare @strRecordNoNote nvarchar(50);
declare @dtmAddedNote datetime;
declare @dtmModifiedNote datetime;
declare @ysnPublicNote bit;
declare @ysnEditedNote bit;
declare @intEntityIdNote int;
declare @intTransactionIdNote int;
declare @intActivityIdNote int;
declare @intConcurrencyIdNote int;
declare @intTicketCommentIdNote int;
declare @intTicketNoteIdNote int;

declare @intCommentIdNote int;

SET @queryResultNote = CURSOR FOR

	select
		strComment = '<p>Internal Note:</p><p>'+tblHDTicketNote.strNote+'</p></br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intNotesOffset), tblHDTicketNote.dtmCreated) else DATEADD(hour, -@intNotesOffset, tblHDTicketNote.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intNotesOffset), tblHDTicketNote.dtmCreated) else DATEADD(hour, -@intNotesOffset, tblHDTicketNote.dtmCreated) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketNote.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProjectActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblHDProjectActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketNote.intTicketNoteId
	from tblHDProject, tblHDProjectTask, tblHDTicket, tblHDProjectActivityTmp, tblHDTicketNote
	where tblHDProject.strType <> 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and tblHDProjectActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketNote.intTicketId = tblHDTicket.intTicketId
		and isnull(tblHDTicketNote.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

	union all

	select
		strComment = '<p>Internal Note:</p><p>'+tblHDTicketNote.strNote+'</p></br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intNotesOffset), tblHDTicketNote.dtmCreated) else DATEADD(hour, -@intNotesOffset, tblHDTicketNote.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intNotesOffset), tblHDTicketNote.dtmCreated) else DATEADD(hour, -@intNotesOffset, tblHDTicketNote.dtmCreated) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketNote.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProjectActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblHDProjectActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketNote.intTicketNoteId
	from tblHDTicket, tblHDProjectActivityTmp, tblHDTicketNote
	where tblHDTicket.strType <> 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)
		and tblHDProjectActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketNote.intTicketId = tblHDTicket.intTicketId
		and isnull(tblHDTicketNote.ysnConvertedToActivity, convert(bit,0)) <> convert(bit,1)

OPEN @queryResultNote
FETCH NEXT
FROM
	@queryResultNote
INTO
	@strCommentNote
	,@strScreenNote
	,@strRecordNoNote
	,@dtmAddedNote
	,@dtmModifiedNote
	,@ysnPublicNote
	,@ysnEditedNote
	,@intEntityIdNote
	,@intTransactionIdNote
	,@intActivityIdNote
	,@intConcurrencyIdNote
	,@intTicketNoteIdNote

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblHDProjectActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblHDProjectActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END
	IF NOT EXISTS (select * from tblHDProjectActivityTmp where intTicketNoteId = @intTicketNoteIdNote)
	BEGIN

		Insert into tblSMComment
		(
			strComment
			,strScreen
			,strRecordNo
			,dtmAdded
			,dtmModified
			,ysnPublic
			,ysnEdited
			,intEntityId
			,intTransactionId
			,intActivityId
			,intConcurrencyId
		)
		(
			select 
				strComment = @strCommentNote
				,strScreen = @strScreenNote
				,strRecordNo = @strRecordNoNote
				,dtmAdded = @dtmAddedNote
				,dtmModified = @dtmModifiedNote
				,ysnPublic = @ysnPublicNote
				,ysnEdited = @ysnEditedNote
				,intEntityId = @intEntityIdNote
				,intTransactionId = @intTransactionIdNote
				,intActivityId = @intActivityIdNote
				,intConcurrencyId = @intConcurrencyIdNote
		)

		update tblHDTicketNote set ysnConvertedToActivity = convert(bit,1) where intTicketNoteId = @intTicketNoteIdNote;

		set @intCommentIdNote =  SCOPE_IDENTITY();

		insert into tblHDProjectActivityTmp
		(
			intActivityId
			,intTicketNoteId
		)
		(
			select
				intActivityId = @intCommentIdNote
				,intTicketNoteId = @intTicketNoteIdNote
		)

	END
				
    FETCH NEXT
    FROM
		@queryResultNote
	INTO
		@strCommentNote
		,@strScreenNote
		,@strRecordNoNote
		,@dtmAddedNote
		,@dtmModifiedNote
		,@ysnPublicNote
		,@ysnEditedNote
		,@intEntityIdNote
		,@intTransactionIdNote
		,@intActivityIdNote
		,@intConcurrencyIdNote
		,@intTicketNoteIdNote
END

CLOSE @queryResultNote
DEALLOCATE @queryResultNote

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectActivityTmp'))
BEGIN
	exec('drop table tblHDProjectActivityTmp');
END

GO
	PRINT N'End converting Ticket to Activity...'
GO
