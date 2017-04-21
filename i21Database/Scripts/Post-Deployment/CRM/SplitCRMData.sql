GO
	PRINT N'Begin splitting CRM and Help Desk data..'
GO

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDSalesPipeStatus'))
BEGIN

	IF not EXISTS(SELECT * FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblHDSalesPipeStatus' AND COLUMN_NAME = 'strProjectStatus')
	begin
		exec('ALTER TABLE tblHDSalesPipeStatus ADD strProjectStatus VARCHAR(255) COLLATE Latin1_General_CI_AS null;')
	end

end

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProject'))
BEGIN

	IF not EXISTS(SELECT * FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'tblHDProject' AND COLUMN_NAME = 'strProjectStatus')
	begin
		exec('ALTER TABLE tblHDProject ADD strProjectStatus VARCHAR(255) COLLATE Latin1_General_CI_AS null;')
	end

end

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketPriority'))
BEGIN

	PRINT N'Begin splitting Priority...'

	SET IDENTITY_INSERT tblCRMPriority ON
	exec('insert into tblCRMPriority (
		intPriorityId
		,strPriority
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strJIRAPriority
		,strIcon
		,strFontColor
		,strBackColor
		,intSort
		,intTurnAroundDays
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketPriorityId
			,strPriority
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strJIRAPriority
			,strIcon
			,strFontColor
			,strBackColor
			,intSort
			,intTurnAroundDays
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketPriority
		where intTicketPriorityId in (select distinct intTicketPriorityId from tblHDTicket where strType = ''CRM'' union all select distinct intTicketPriorityId from tblHDTicketPriority where ysnActivity = 1 or ysnOpportunity = 1)
			and intTicketPriorityId not in (select intPriorityId from tblCRMPriority)
	)');
	SET IDENTITY_INSERT tblCRMPriority OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDSalesPipeStatus'))
BEGIN

	PRINT N'Begin splitting Sales Pipe Status...'

	SET IDENTITY_INSERT tblCRMSalesPipeStatus ON
	exec('insert into tblCRMSalesPipeStatus (
		intSalesPipeStatusId
		,strStatus
		,strDescription
		,strOrder
		,strProjectStatus
		,dblProbability
		,intStatusId
		,intConcurrencyId
	)(
		select
			intSalesPipeStatusId
			,strStatus
			,strDescription
			,strOrder = convert(nvarchar(20),intSalesPipeStatusId)
			,strProjectStatus
			,dblProbability
			,intStatusId = null
			,intConcurrencyId
		from tblHDSalesPipeStatus
		where intSalesPipeStatusId not in (select intSalesPipeStatusId from tblCRMSalesPipeStatus)
	)');
	SET IDENTITY_INSERT tblCRMSalesPipeStatus OFF

	--update tblCRMSalesPipeStatus set tblCRMSalesPipeStatus.intStatusId = (select tblCRMStatus.intStatusId from tblCRMStatus where tblCRMStatus.strStatus = tblCRMSalesPipeStatus.strProjectStatus)

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketType'))
BEGIN

	PRINT N'Begin splitting Type...'

	SET IDENTITY_INSERT tblCRMType ON
	exec('insert into tblCRMType (
		intTypeId
		,strType
		,strDescription
		,strJIRAType
		,strIcon
		,ysnActivity
		,ysnOpportunity
		,ysnCampaign
		,ysnSupported
		,intSort
		,intConcurrencyId
	)(
		select
			intTicketTypeId
			,strType
			,strDescription
			,strJIRAType
			,strIcon
			,ysnActivity
			,ysnOpportunity
			,ysnCampaign
			,ysnSupported
			,intSort
			,intConcurrencyId
		from tblHDTicketType
		where intTicketTypeId in (select distinct intTicketTypeId from tblHDTicket where strType = ''CRM'' union all select distinct intTicketTypeId from tblHDProject where strType = ''CRM'' union all select distinct intTicketTypeId from tblHDTicketType where ysnActivity = 1 or ysnOpportunity = 1 or ysnCampaign = 1)
			and intTicketTypeId not in (select intTypeId from tblCRMType)
	)');

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMCampaign'))
	begin
		exec('insert into tblCRMType (
		intTypeId
		,strType
		,strDescription
		,strJIRAType
		,strIcon
		,ysnActivity
		,ysnOpportunity
		,ysnCampaign
		,ysnSupported
		,intSort
		,intConcurrencyId
	)(
		select
			intTicketTypeId
			,strType
			,strDescription
			,strJIRAType
			,strIcon
			,ysnActivity
			,ysnOpportunity
			,ysnCampaign
			,ysnSupported
			,intSort
			,intConcurrencyId
		from tblHDTicketType
		where intTicketTypeId in (select distinct intTypeId from tblCRMCampaign union all select distinct intTicketTypeId from tblHDTicketType where ysnActivity = 1 or ysnOpportunity = 1 or ysnCampaign = 1)
			and intTicketTypeId not in (select intTypeId from tblCRMType)
	)');
	end

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityCampaign'))
	begin
		exec('insert into tblCRMType (
		intTypeId
		,strType
		,strDescription
		,strJIRAType
		,strIcon
		,ysnActivity
		,ysnOpportunity
		,ysnCampaign
		,ysnSupported
		,intSort
		,intConcurrencyId
	)(
		select
			intTicketTypeId
			,strType
			,strDescription
			,strJIRAType
			,strIcon
			,ysnActivity
			,ysnOpportunity
			,ysnCampaign
			,ysnSupported
			,intSort
			,intConcurrencyId
		from tblHDTicketType
		where intTicketTypeId in (select distinct intTicketTypeId from tblHDOpportunityCampaign union all select distinct intTicketTypeId from tblHDTicketType where ysnActivity = 1 or ysnOpportunity = 1 or ysnCampaign = 1)
			and intTicketTypeId not in (select intTypeId from tblCRMType)
	)');
	end

	SET IDENTITY_INSERT tblCRMType OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketStatus'))
BEGIN

	PRINT N'Begin splitting Status...'

	SET IDENTITY_INSERT tblCRMStatus ON

	exec('insert into tblCRMStatus (
		intStatusId
		,strStatus
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strIcon
		,strFontColor
		,strBackColor
		,ysnSupported
		,intSort
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketStatus
		where intTicketStatusId in (select distinct intTicketStatusId from tblHDTicketStatus where ysnActivity = 1 or ysnOpportunity = 1)
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
	)');

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicket'))
	begin
	exec('insert into tblCRMStatus (
		intStatusId
		,strStatus
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strIcon
		,strFontColor
		,strBackColor
		,ysnSupported
		,intSort
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketStatus
		where intTicketStatusId in (select distinct intTicketStatusId from tblHDTicket where strType = ''CRM'')
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
	)');
	end

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProject'))
	begin
	exec('insert into tblCRMStatus (
		intStatusId
		,strStatus
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strIcon
		,strFontColor
		,strBackColor
		,ysnSupported
		,intSort
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketStatus
		where intTicketStatusId in (select distinct intTicketStatusId from tblHDProject where strType = ''CRM'')
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
	)');
	end

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDSalesPipeStatus'))
	begin
	exec('insert into tblCRMStatus (
		intStatusId
		,strStatus
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strIcon
		,strFontColor
		,strBackColor
		,ysnSupported
		,intSort
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketStatus
		where strStatus in (select distinct strProjectStatus from tblHDSalesPipeStatus)
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
	)');
	end

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMSalesPipeStatus'))
	begin
	exec('insert into tblCRMStatus (
		intStatusId
		,strStatus
		,strDescription
		,ysnActivity
		,ysnOpportunity
		,ysnDefaultActivity
		,ysnDefaultOpportunity
		,strIcon
		,strFontColor
		,strBackColor
		,ysnSupported
		,intSort
		,ysnUpdated
		,intConcurrencyId
	)(
		select
			intTicketStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		from tblHDTicketStatus
		where intTicketStatusId in (select distinct intStatusId from tblCRMSalesPipeStatus)
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
	)');
	end

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityCampaign'))
	begin
		exec('insert into tblCRMStatus (
			intStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		)(
			select
				intTicketStatusId
				,strStatus
				,strDescription
				,ysnActivity
				,ysnOpportunity
				,ysnDefaultActivity
				,ysnDefaultOpportunity
				,strIcon
				,strFontColor
				,strBackColor
				,ysnSupported
				,intSort
				,ysnUpdated
				,intConcurrencyId
			from tblHDTicketStatus
			where intTicketStatusId in (select distinct intTicketStatusId from tblHDOpportunityCampaign)
				and intTicketStatusId not in (select intStatusId from tblCRMStatus)
		)');
	end

		IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMCampaign'))
	begin
		exec('insert into tblCRMStatus (
			intStatusId
			,strStatus
			,strDescription
			,ysnActivity
			,ysnOpportunity
			,ysnDefaultActivity
			,ysnDefaultOpportunity
			,strIcon
			,strFontColor
			,strBackColor
			,ysnSupported
			,intSort
			,ysnUpdated
			,intConcurrencyId
		)(
			select
				intTicketStatusId
				,strStatus
				,strDescription
				,ysnActivity
				,ysnOpportunity
				,ysnDefaultActivity
				,ysnDefaultOpportunity
				,strIcon
				,strFontColor
				,strBackColor
				,ysnSupported
				,intSort
				,ysnUpdated
				,intConcurrencyId
			from tblHDTicketStatus
			where intTicketStatusId in (select distinct intStatusId from tblCRMCampaign)
				and intTicketStatusId not in (select intStatusId from tblCRMStatus)
		)');
	end

	SET IDENTITY_INSERT tblCRMStatus OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityCampaign'))
BEGIN

	PRINT N'Begin splitting Campaign...'

	SET IDENTITY_INSERT tblCRMCampaign ON
	exec('insert into tblCRMCampaign (
		intCampaignId
		,strCampaignName
		,strDescription
		,intTypeId
		,intLineOfBusinessId
		,dtmStartDate
		,dtmEndDate
		,dblOpenRate
		,dblBaseCost
		,dblTotalCost
		,dblExpectedRevenue
		,dtmCreateDate
		,intStatusId
		,ysnHold
		,ysnActive
		,intEntityId
		,strRetrospective
		,strImageId
		,intConcurrencyId
	)(
		select
			intCampaignId = intOpportunityCampaignId
			,strCampaignName = strCampaignName
			,strDescription = strDescription
			,intTypeId = intTicketTypeId
			,intLineOfBusinessId = intLineOfBusinessId
			,dtmStartDate = dtmStartDate
			,dtmEndDate = dtmEndDate
			,dblOpenRate = dblOpenRate
			,dblBaseCost = dblBaseCost
			,dblTotalCost = dblTotalCost
			,dblExpectedRevenue = dblExpectedRevenue
			,dtmCreateDate = dtmCreateDate
			,intStatusId = intCampaignStatusId
			,ysnHold = ysnHold
			,ysnActive = ysnActive
			,intEntityId = intEntityId
			,strRetrospective = null
			,strImageId = null
			,intConcurrencyId = intConcurrencyId
		from tblHDOpportunityCampaign
		where intOpportunityCampaignId not in (select intCampaignId from tblCRMCampaign)
	)');
	SET IDENTITY_INSERT tblCRMCampaign OFF

	if exists (SELECT * FROM sys.columns WHERE object_id = object_id('tblHDOpportunityCampaign') and name = 'strRetrospective')
	begin
		exec('update tblCRMCampaign set tblCRMCampaign.strRetrospective = (select tblHDOpportunityCampaign.strRetrospective from tblHDOpportunityCampaign where tblHDOpportunityCampaign.intOpportunityCampaignId = tblCRMCampaign.intCampaignId)')
	end
	if exists (SELECT * FROM sys.columns WHERE object_id = object_id('tblHDOpportunityCampaign') and name = 'strImageId')
	begin
		exec('update tblCRMCampaign set tblCRMCampaign.strImageId = (select tblHDOpportunityCampaign.strImageId from tblHDOpportunityCampaign where tblHDOpportunityCampaign.intOpportunityCampaignId = tblCRMCampaign.intCampaignId)')
	end
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunitySource'))
BEGIN

	PRINT N'Begin splitting Source...'

	SET IDENTITY_INSERT tblCRMSource ON
	exec('insert tblCRMSource
	(
		intSourceId
		,strSource
		,intConcurrencyId
	)
	(
		select
			intSourceId = intOpportunitySourceId
			,strSource
			,intConcurrencyId
		from
			tblHDOpportunitySource
		where
			intOpportunitySourceId not in (select intSourceId from tblCRMSource)
	)');
	SET IDENTITY_INSERT tblCRMSource OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDMilestone'))
BEGIN
	
	IF NOT EXISTS (SELECT * FROM tblCRMMilestone)
	BEGIN
		PRINT N'Begin splitting Milestone...'
		SET IDENTITY_INSERT tblCRMMilestone ON
		exec('insert into tblCRMMilestone (
			intMilestoneId
			,strMileStone
			,strDescription
			,intPriority
			,intSort
			,intConcurrencyId
		)(
			select
				intMilestoneId
				,strMileStone
				,strDescription
				,intPriority
				,intSort
				,intConcurrencyId
			from tblHDMilestone
			where intMilestoneId not in (select intMilestoneId from tblCRMMilestone)
		)');
		SET IDENTITY_INSERT tblCRMMilestone OFF
	END

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityWinLossReason'))
BEGIN

	PRINT N'Begin splitting Win/Loss Reason...'

	SET IDENTITY_INSERT tblCRMWinLossReason ON
	exec('insert into tblCRMWinLossReason (
		intWinLossReasonId
		,strReason
		,strDescription
		,intConcurrencyId
	)(
		select
			intWinLossReasonId = intOpportunityWinLossReasonId
			,strReason
			,strDescription
			,intConcurrencyId
		from tblHDOpportunityWinLossReason
		where intOpportunityWinLossReasonId not in (select intWinLossReasonId from tblCRMWinLossReason)
	)');
	SET IDENTITY_INSERT tblCRMWinLossReason OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProject'))
BEGIN

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'CRM.view.Opportunity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnActivity], [intConcurrencyId]) 
			VALUES (N'Opportunity', N'Opportunity', N'CRM.view.Opportunity', N'CRM', N'tblCRMOpportunity',  null,  1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCRMOpportunity',
				ysnActivity = 1
			WHERE strNamespace = 'CRM.view.Opportunity'
		END

	PRINT N'Begin splitting Opportunity and Project...'

	SET IDENTITY_INSERT tblCRMOpportunity ON
	exec('insert into tblCRMOpportunity
	(
		intOpportunityId
		,strName
		,strDescription
		,intCustomerId
		,intCustomerContactId
		,intSalesPipeStatusId
		,intStatusId
		,intSourceId
		,intTypeId
		,intCampaignId
		,strCompetitorEntityId
		,strCurrentSolutionId
		,strCompetitorEntity
		,strCurrentSolution
		,intReferredByEntityId
		,dtmCreated
		,dtmClose
		,dtmGoLive
		,intPercentComplete
		,ysnCompleted
		,intSort
		,ysnActive
		,strOpportunityStatus
		,intInternalProjectManager
		,intInternalSalesPerson
		,ysnInitialDataCollectionComplete
		,dtmConfirmedKeystoneDate
		,intCustomerProjectManager
		,intCustomerLeadershipSponsor
		,strCustomerKeyProjectGoal
		,strCustomModification
		,dtmSalesDate
		,dtmSoftwareBillDate
		,strSoftwareBillDateComment
		,dtmHardwareOrderDate
		,strHardwareOrderDateComment
		,dtmInitialUserGroupDuesInvoice
		,ysnReceivedDownPayment
		,strLinesOfBusinessId
		,strLinesOfBusiness
		,strRFPRFILink
		,dtmLastDescriptionModified
		,strDirection
		,intMilestoneId
		,intCompanyLocationId
		,intEntityLocationId
		,strWinLossReasonId
		,strWinLossReason
		,dtmWinLossDate
		,intWinLossLengthOfCycle
		,strWinLossDetails
		,strWinLossDidRight
		,strWinLossDidWrong
		,strWinLossActionItem
		,intLostToCompetitorId
		,intConcurrencyId
	)
	(
		select
			intOpportunityId = intProjectId
			,strName = strProjectName
			,strDescription = strDescription
			,intCustomerId = intCustomerId
			,intCustomerContactId = intCustomerContactId
			,intSalesPipeStatusId = intSalesPipeStatusId
			,intStatusId = intTicketStatusId
			,intSourceId = intOpportunitySourceId
			,intTypeId = intTicketTypeId
			,intCampaignId = intOpportunityCampaignId
			,strCompetitorEntityId = strCompetitorEntityId
			,strCurrentSolutionId = strCurrentSolutionId
			,strCompetitorEntity = strCompetitorEntity
			,strCurrentSolution = strCurrentSolution
			,intReferredByEntityId = intReferredByEntityId
			,dtmCreated = dtmCreated
			,dtmClose = dtmClose
			,dtmGoLive = dtmGoLive
			,intPercentComplete = intPercentComplete
			,ysnCompleted = ysnCompleted
			,intSort = intSort
			,ysnActive = ysnActive
			,strOpportunityStatus = strProjectStatus
			,intInternalProjectManager = intInternalProjectManager
			,intInternalSalesPerson = intInternalSalesPerson
			,ysnInitialDataCollectionComplete = ysnInitialDataCollectionComplete
			,dtmConfirmedKeystoneDate = dtmConfirmedKeystoneDate
			,intCustomerProjectManager = intCustomerProjectManager
			,intCustomerLeadershipSponsor = intCustomerLeadershipSponsor
			,strCustomerKeyProjectGoal = strCustomerKeyProjectGoal
			,strCustomModification = strCustomModification
			,dtmSalesDate = dtmSalesDate
			,dtmSoftwareBillDate = dtmSoftwareBillDate
			,strSoftwareBillDateComment = strSoftwareBillDateComment
			,dtmHardwareOrderDate = dtmHardwareOrderDate
			,strHardwareOrderDateComment = strHardwareOrderDateComment
			,dtmInitialUserGroupDuesInvoice = dtmInitialUserGroupDuesInvoice
			,ysnReceivedDownPayment = ysnReceivedDownPayment
			,strLinesOfBusinessId = strLinesOfBusinessId
			,strLinesOfBusiness = strLinesOfBusiness
			,strRFPRFILink = strRFPRFILink
			,dtmLastDescriptionModified = dtmLastDescriptionModified
			,strDirection = strDirection
			,intMilestoneId = intMilestoneId
			,intCompanyLocationId = intCompanyLocationId
			,intEntityLocationId = intEntityLocationId
			,strWinLossReasonId = strOpportunityWinLossReasonId
			,strWinLossReason = strOpportunityWinLossReason
			,dtmWinLossDate = dtmWinLossDate
			,intWinLossLengthOfCycle = intWinLossLengthOfCycle
			,strWinLossDetails = strWinLossDetails
			,strWinLossDidRight = strWinLossDidRight
			,strWinLossDidWrong = strWinLossDidWrong
			,strWinLossActionItem = strWinLossActionItem
			,intLostToCompetitorId = intLostToCompetitorId
			,intConcurrencyId = intConcurrencyId
		from tblHDProject
		where strType = ''CRM'' and intProjectId not in (select intOpportunityId from tblCRMOpportunity)
	)');
	SET IDENTITY_INSERT tblCRMOpportunity OFF

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMStatus'))
	begin
		exec('update tblCRMOpportunity set tblCRMOpportunity.intStatusId = (select top 1 tblCRMStatus.intStatusId from tblCRMStatus where tblCRMStatus.strStatus = tblCRMOpportunity.strOpportunityStatus) where tblCRMOpportunity.intStatusId is null and tblCRMOpportunity.strOpportunityStatus is not null');
		
		IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMSalesPipeStatus'))
		begin
			exec('update tblCRMSalesPipeStatus set tblCRMSalesPipeStatus.intStatusId = (select top 1 tblCRMStatus.intStatusId from tblCRMStatus where tblCRMStatus.strStatus = tblCRMSalesPipeStatus.strProjectStatus) where tblCRMSalesPipeStatus.intStatusId is null');
		end
	end

	exec('insert into tblSMTransaction
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
			intScreenId = (select top 1 intScreenId from tblSMScreen where strNamespace = ''CRM.view.Opportunity'')
			,intRecordId = tblCRMOpportunity.intOpportunityId
			,strTransactionNo = convert(nvarchar(50), tblCRMOpportunity.intOpportunityId)--(case when len(tblCRMOpportunity.strName) > 50 THEN SUBSTRING(tblCRMOpportunity.strName, 0, 47) + ''...'' else tblCRMOpportunity.strName end)
			,intEntityId = tblCRMOpportunity.intInternalSalesPerson
			,dtmDate = tblCRMOpportunity.dtmCreated
			,strApprovalStatus = null
			,intConcurrencyId = 1
		from
			tblCRMOpportunity
		where
			tblCRMOpportunity.intOpportunityId not in (select intRecordId from tblSMTransaction where intScreenId = (select top 1 intScreenId from tblSMScreen where strNamespace = ''CRM.view.Opportunity''))
	)');

	exec('update tblSMAttachment set strScreen = ''CRM.Opportunity'' where strScreen = ''HelpDesk.Project'' and strRecordNo in (select convert(nvarchar(50),intOpportunityId) from tblCRMOpportunity)');

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverview'))
BEGIN

	PRINT N'Begin splitting Opportunity Overview...'

	SET IDENTITY_INSERT tblCRMOpportunityOverviewProblem ON
	exec('insert tblCRMOpportunityOverviewProblem
	(
		intOpportunityOverviewId
		,intOpportunityId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
	)
	(
		select
			intOpportunityOverviewId
			,intOpportunityId = intProjectId
			,strDescription
			,intEntityId
			,strOverviewType
			,intConcurrencyId
		from
			tblHDOpportunityOverview
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityOverviewId not in (select intOpportunityOverviewId from tblCRMOpportunityOverviewProblem)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityOverviewProblem OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewConcern'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewConcern ON
	exec('insert tblCRMOpportunityOverviewConcern
	(
		intOpportunityOverviewConcernId
		,intOpportunityId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
	)
	(
		select
		intOpportunityOverviewConcernId
		,intOpportunityId = intProjectId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
		from
			tblHDOpportunityOverviewConcern
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityOverviewConcernId not in (select intOpportunityOverviewConcernId from tblCRMOpportunityOverviewConcern)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityOverviewConcern OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewSolution'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewSolution ON
	exec('insert tblCRMOpportunityOverviewSolution
	(
		intOpportunityOverviewSolutionId
		,intOpportunityId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
	)
	(
		select
		intOpportunityOverviewSolutionId
		,intOpportunityId = intProjectId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
		from
			tblHDOpportunityOverviewSolution
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityOverviewSolutionId not in (select intOpportunityOverviewSolutionId from tblCRMOpportunityOverviewSolution)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityOverviewSolution OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewUniqueValue'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewUniqueValue ON
	exec('insert tblCRMOpportunityOverviewUniqueValue
	(
		intOpportunityOverviewUniqueValueId
		,intOpportunityId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
	)
	(
		select
		intOpportunityOverviewUniqueValueId
		,intOpportunityId = intProjectId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
		from
			tblHDOpportunityOverviewUniqueValue
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityOverviewUniqueValueId not in (select intOpportunityOverviewUniqueValueId from tblCRMOpportunityOverviewUniqueValue)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityOverviewUniqueValue OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewGain'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewGain ON
	exec('insert tblCRMOpportunityOverviewGain
	(
		intOpportunityOverviewGainId
		,intOpportunityId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
	)
	(
		select
		intOpportunityOverviewGainId
		,intOpportunityId = intProjectId
		,strDescription
		,intEntityId
		,strOverviewType
		,intConcurrencyId
		from
			tblHDOpportunityOverviewGain
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityOverviewGainId not in (select intOpportunityOverviewGainId from tblCRMOpportunityOverviewGain)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityOverviewGain OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityQuote'))
BEGIN

	PRINT N'Begin splitting Opportunity Quote...'

	SET IDENTITY_INSERT tblCRMOpportunityQuote ON
	exec('insert tblCRMOpportunityQuote
	(
		intOpportunityQuoteId
		,intOpportunityId
		,intSalesOrderId
		,intConcurrencyId
	)
	(
		select
		intOpportunityQuoteId = intOpportunityQuoteId
		,intOpportunityId = intProjectId
		,intSalesOrderId
		,intConcurrencyId
		from
			tblHDOpportunityQuote
		where
			intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
			and intOpportunityQuoteId not in (select intOpportunityQuoteId from tblCRMOpportunityQuote)
	)');
	SET IDENTITY_INSERT tblCRMOpportunityQuote OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityContract'))
BEGIN

	PRINT N'Begin splitting Opportunity Contract...'

	SET IDENTITY_INSERT tblCRMOpportunityContract ON
	exec('insert tblCRMOpportunityContract
	(
		intOpportunityContractId
		,intOpportunityId
		,intContractHeaderId
		,intConcurrencyId
	)
	(
		select
			intOpportunityContractId
			,intOpportunityId = intProjectId
			,intContractHeaderId
			,intConcurrencyId
		from
			tblHDOpportunityContract
		where
			intOpportunityContractId not in (select intOpportunityContractId from tblCRMOpportunityContract)
			and intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
	)');
	SET IDENTITY_INSERT tblCRMOpportunityContract OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectContactInfo'))
BEGIN

	PRINT N'Begin splitting Opportunity Contact...'

	SET IDENTITY_INSERT tblCRMOpportunityContact ON
	exec('insert tblCRMOpportunityContact
	(
		intOpportunityContactId
		,intOpportunityId
		,intEntityId
		,strDecisionRole
		,strAttitude
		,strExtent
		,strConcerns
		,strExpectations
		,intSort
		,intConcurrencyId
	)
	(
		select
			intOpportunityContactId = intProjectContactInfoId
			,intOpportunityId = intProjectId
			,intEntityId
			,strDecisionRole
			,strAttitude
			,strExtent
			,strConcerns
			,strExpectations
			,intSort
			,intConcurrencyId
		from
			tblHDProjectContactInfo
		where
			intProjectContactInfoId not in (select intOpportunityContactId from tblCRMOpportunityContact)
			and intProjectId in (select intProjectId from tblHDProject where strType = ''CRM'')
	)');
	SET IDENTITY_INSERT tblCRMOpportunityContact OFF
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMSalesPipeStatus'))
begin
	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMStatus'))
	begin
		exec('update tblCRMSalesPipeStatus set tblCRMSalesPipeStatus.intStatusId = (select top 1 intStatusId from tblCRMStatus where tblCRMStatus.strStatus = tblCRMSalesPipeStatus.strProjectStatus) where tblCRMSalesPipeStatus.intStatusId is null')
	end
end

PRINT N'Moving Opportunity activity...'

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMOpportunityActivityTmp'))
BEGIN
	CREATE TABLE [dbo].[tblCRMOpportunityActivityTmp]
	(
		[intId] [int] IDENTITY(1,1) NOT NULL,
		[intActivityId] [int] NOT NULL,
		[intTicketIdId] [int] NULL,
		[intTicketCommentId] [int] NULL,
		[intTicketNoteId] [int] NULL,
		CONSTRAINT [PK_tblCRMOpportunityActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
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

declare @intCurrentActivityNoAct int
declare @intGeneratedActivityIdentityAct int

SET @queryResultAct = CURSOR FOR

	select
		intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblHDProject.intProjectId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'CRM.view.Opportunity'))
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
	from tblHDProject, tblHDProjectTask, tblHDTicket
	where tblHDProject.strType = 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId

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
	from tblHDTicket
	where tblHDTicket.strType = 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)

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

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMOpportunityActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblCRMOpportunityActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblCRMOpportunityActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END

	IF NOT EXISTS (select * from tblCRMOpportunityActivityTmp where intTicketIdId = @intTicketIdAct)
	BEGIN
		set @intCurrentActivityNoAct = (select top 1 tblSMStartingNumber.intNumber from tblSMStartingNumber where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity');
		update tblSMStartingNumber set tblSMStartingNumber.intNumber = (@intCurrentActivityNoAct + 1) where tblSMStartingNumber.strModule = 'System Manager' and tblSMStartingNumber.strTransactionType = 'Activity';
		set @strActivityNoAct = @strActivityNoAct + convert(nvarchar(50),@intCurrentActivityNoAct);

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
				,intConcurrencyId = @intConcurrencyIdAct
		)
		
		set @intGeneratedActivityIdentityAct =  SCOPE_IDENTITY();

		insert into tblCRMOpportunityActivityTmp
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
END

CLOSE @queryResultAct
DEALLOCATE @queryResultAct

update tblSMAttachment set tblSMAttachment.strScreen = 'GlobalComponentEngine.view.Activity', tblSMAttachment.strRecordNo = (select top 1 convert(nvarchar(50),tblCRMOpportunityActivityTmp.intActivityId) from tblCRMOpportunityActivityTmp where tblCRMOpportunityActivityTmp.intTicketIdId = convert(int,tblSMAttachment.strRecordNo)) where tblSMAttachment.strScreen = 'HelpDesk.Ticket' and tblSMAttachment.strRecordNo in (select convert(nvarchar(50),tblCRMOpportunityActivityTmp.intTicketIdId) from tblCRMOpportunityActivityTmp);

PRINT N'Creating Activity Note from Activity Details...'

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
		strComment = '<p>Comment : '+(case when tblHDTicketComment.ysnSent = 1 then 'Sent' else '<font color="red">Draft</font>' end)+'</p>'+(case when tblHDTicketComment.ysnEncoded = 1 then dbo.fnHDDecodeComment(substring(tblHDTicketComment.strComment,4,len(tblHDTicketComment.strComment)-3)) else tblHDTicketComment.strComment end)+'</br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmCreated) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmLastModified) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmLastModified) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketComment.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblCRMOpportunityActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblCRMOpportunityActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketComment.intTicketCommentId
	from tblHDProject, tblHDProjectTask, tblHDTicket, tblCRMOpportunityActivityTmp, tblHDTicketComment
	where tblHDProject.strType = 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and tblCRMOpportunityActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketComment.intTicketId = tblHDTicket.intTicketId

	union all

	select
		strComment = '<p>Comment : '+(case when tblHDTicketComment.ysnSent = 1 then 'Sent' else '<font color="red">Draft</font>' end)+'</p>'+(case when tblHDTicketComment.ysnEncoded = 1 then dbo.fnHDDecodeComment(substring(tblHDTicketComment.strComment,4,len(tblHDTicketComment.strComment)-3)) else tblHDTicketComment.strComment end)+'</br>'
		,strScreen = ''
		,strRecordNo = ''
		,dtmAdded = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmCreated) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmCreated) end)
		,dtmModified = (case when @intOffset < 0 then DATEADD(hour, ABS(@intDetailsOffset), tblHDTicketComment.dtmLastModified) else DATEADD(hour, -@intDetailsOffset, tblHDTicketComment.dtmLastModified) end)
		,ysnPublic = convert(bit,1)
		,ysnEdited = null
		,intEntityId = tblHDTicketComment.intCreatedUserEntityId
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblCRMOpportunityActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblCRMOpportunityActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketComment.intTicketCommentId
	from tblHDTicket, tblCRMOpportunityActivityTmp, tblHDTicketComment
	where tblHDTicket.strType = 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)
		and tblCRMOpportunityActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketComment.intTicketId = tblHDTicket.intTicketId

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

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMOpportunityActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblCRMOpportunityActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblCRMOpportunityActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END
	IF NOT EXISTS (select * from tblCRMOpportunityActivityTmp where intTicketCommentId = @intTicketCommentIdComment)
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
		
		set @intCommentIdComment =  SCOPE_IDENTITY();

		insert into tblCRMOpportunityActivityTmp
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
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblCRMOpportunityActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblCRMOpportunityActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketNote.intTicketNoteId
	from tblHDProject, tblHDProjectTask, tblHDTicket, tblCRMOpportunityActivityTmp, tblHDTicketNote
	where tblHDProject.strType = 'CRM'
		and tblHDProjectTask.intProjectId = tblHDProject.intProjectId
		and tblHDTicket.intTicketId = tblHDProjectTask.intTicketId
		and tblCRMOpportunityActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketNote.intTicketId = tblHDTicket.intTicketId

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
		,intTransactionId = (select top 1 tblSMTransaction.intTransactionId from tblSMTransaction where tblSMTransaction.intRecordId = tblCRMOpportunityActivityTmp.intActivityId and tblSMTransaction.intScreenId = (select top 1 tblSMScreen.intScreenId from tblSMScreen where tblSMScreen.strNamespace = 'GlobalComponentEngine.view.Activity'))
		,intActivityId = tblCRMOpportunityActivityTmp.intActivityId
		,intConcurrencyId = 1
		,tblHDTicketNote.intTicketNoteId
	from tblHDTicket, tblCRMOpportunityActivityTmp, tblHDTicketNote
	where tblHDTicket.strType = 'CRM'
		and tblHDTicket.intTicketId not in (select distinct tblHDProjectTask.intTicketId from tblHDProjectTask)
		and tblCRMOpportunityActivityTmp.intTicketIdId = tblHDTicket.intTicketId
		and tblHDTicketNote.intTicketId = tblHDTicket.intTicketId

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

	IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMOpportunityActivityTmp'))
	BEGIN
		CREATE TABLE [dbo].[tblCRMOpportunityActivityTmp]
		(
			[intId] [int] IDENTITY(1,1) NOT NULL,
			[intActivityId] [int] NOT NULL,
			[intTicketIdId] [int] NULL,
			[intTicketCommentId] [int] NULL,
			[intTicketNoteId] [int] NULL,
			CONSTRAINT [PK_tblCRMOpportunityActivityTmp] PRIMARY KEY CLUSTERED ([intId] ASC)
		)
	END
	IF NOT EXISTS (select * from tblCRMOpportunityActivityTmp where intTicketNoteId = @intTicketNoteIdNote)
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

		set @intCommentIdNote =  SCOPE_IDENTITY();

		insert into tblCRMOpportunityActivityTmp
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

Print 'Fixing Opportunity Lines of Business'

DECLARE @queryResultOpportunity CURSOR;
declare @intOpportunityId int;
declare @strLinesOfBusinessId nvarchar(50);

declare @queryResultLobItem cursor;
declare @Item nvarchar(5);
declare @intItem int;

SET @queryResultOpportunity = CURSOR FOR

	select
		intOpportunityId
		,strLinesOfBusinessId = ltrim(rtrim(strLinesOfBusinessId))
	from
		tblCRMOpportunity
	where
		strLinesOfBusinessId is not null
		and ltrim(rtrim(strLinesOfBusinessId)) <> ''

OPEN @queryResultOpportunity
FETCH NEXT
FROM
	@queryResultOpportunity
INTO
	@intOpportunityId
	,@strLinesOfBusinessId

WHILE @@FETCH_STATUS = 0
BEGIN

	/*---------------------------------------------------------------*/
	SET @queryResultLobItem = CURSOR FOR

		select
			Item
		from
			dbo.fnSplitString(@strLinesOfBusinessId, ',')

	OPEN @queryResultLobItem
	FETCH NEXT
	FROM
		@queryResultLobItem
	INTO
		@Item

	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @intItem = convert(int, @Item);
		
		--Print 'Opportunity Id = ' + convert(nvarchar(50), @intOpportunityId) + ' - LOB Id = ' + convert(nvarchar(50), @intItem)

		IF NOT EXISTS (select * from tblCRMOpportunityLob where intOpportunityId = @intOpportunityId and intLineOfBusinessId = @intItem)
		begin
			IF EXISTS (select * from tblSMLineOfBusiness where intLineOfBusinessId = @intItem)
			begin
				INSERT INTO [dbo].[tblCRMOpportunityLob]
						   ([intOpportunityId]
						   ,[intLineOfBusinessId]
						   ,[intConcurrencyId])
					 VALUES
						   (@intOpportunityId
						   ,@intItem
						   ,1)
			end
		end

		FETCH NEXT
		FROM
			@queryResultLobItem
		INTO
			@Item
	END

	CLOSE @queryResultLobItem
	DEALLOCATE @queryResultLobItem
	/*---------------------------------------------------------------*/

    FETCH NEXT
    FROM
		@queryResultOpportunity
	INTO
	@intOpportunityId
	,@strLinesOfBusinessId
END

CLOSE @queryResultOpportunity
DEALLOCATE @queryResultOpportunity

Print 'End Fixing Opportunity Lines of Business'

insert into tblSMTypeValue
(
	strType, strValue, ysnDefault, intConcurrencyId
)
(
	select strType = 'Status', strValue = strStatus, ysnDefault = convert(bit, 1), intConcurrencyId = 1 from
	(
		select distinct strStatus from tblSMActivity where intTransactionId in
		(
			select intTransactionId from tblSMTransaction where intRecordId in
			(
				select intOpportunityId from tblCRMOpportunity
			)
			and intScreenId = 
			(
				select intScreenId from tblSMScreen where strModule = 'CRM' and strNamespace = 'CRM.view.Opportunity'
			)
		)
		and strStatus not in (select strValue from tblSMTypeValue where strType = 'Status')
	) as statusType
)

insert into tblSMTypeValue
(
	strType, strValue, ysnDefault, intConcurrencyId
)
(
	select strType = 'Priority', strValue = strPriority, ysnDefault = convert(bit, 1), intConcurrencyId = 1 from
	(
		select distinct strPriority from tblSMActivity where intTransactionId in
		(
			select intTransactionId from tblSMTransaction where intRecordId in
			(
				select intOpportunityId from tblCRMOpportunity
			)
			and intScreenId = 
			(
				select intScreenId from tblSMScreen where strModule = 'CRM' and strNamespace = 'CRM.view.Opportunity'
			)
		)
		and strPriority not in (select strValue from tblSMTypeValue where strType = 'Priority')
	) as priorityType
)

insert into tblSMTypeValue
(
	strType, strValue, ysnDefault, intConcurrencyId
)
(
	select strType = 'Category', strValue = strCategory, ysnDefault = convert(bit, 1), intConcurrencyId = 1 from
	(
		select distinct strCategory from tblSMActivity where intTransactionId in
		(
			select intTransactionId from tblSMTransaction where intRecordId in
			(
				select intOpportunityId from tblCRMOpportunity
			)
			and intScreenId = 
			(
				select intScreenId from tblSMScreen where strModule = 'CRM' and strNamespace = 'CRM.view.Opportunity'
			)
		)
		and strCategory not in (select strValue from tblSMTypeValue where strType = 'Category')
	) as priorityType
)

Print N'Start fixing CRM opportunity Sales Person';

exec('
	update tblCRMOpportunity set tblCRMOpportunity.intInternalSalesPerson = (select top 1 ec.intEntityId from tblEMEntityToContact ec where ec.intEntityContactId = tblCRMOpportunity.intInternalSalesPerson) where tblCRMOpportunity.intInternalSalesPerson in
		(
		select
			tblEMEntityToContact.intEntityContactId
		from tblARSalesperson, tblEMEntityToContact
		where
			tblEMEntityToContact.intEntityId = tblARSalesperson.intEntityId
		)
	');

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblSMLineOfBusiness'))
begin
	exec('
			update tblSMLineOfBusiness set tblSMLineOfBusiness.intEntityId = (select top 1 ec.intEntityId from tblEMEntityToContact ec where ec.intEntityContactId = tblSMLineOfBusiness.intEntityId) where tblSMLineOfBusiness.intEntityId in
				(
				select
					tblEMEntityToContact.intEntityContactId
				from tblARSalesperson, tblEMEntityToContact
				where
					tblEMEntityToContact.intEntityId = tblARSalesperson.intEntityId
				)
		');
end

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblCRMCampaign'))
begin
	exec('
			update tblCRMCampaign set tblCRMCampaign.intEntityId = (select top 1 ec.intEntityId from tblEMEntityToContact ec where ec.intEntityContactId = tblCRMCampaign.intEntityId) where tblCRMCampaign.intEntityId in
				(
				select
					tblEMEntityToContact.intEntityContactId
				from tblARSalesperson, tblEMEntityToContact
				where
					tblEMEntityToContact.intEntityId = tblARSalesperson.intEntityId
				)
		');
end

Print N'End fixing CRM opportunity Sales Person';

exec('update tblSMCustomTab set intScreenId = (select top 1 intScreenId from tblSMScreen where strScreenName = ''Campaign'' and strModule = ''CRM'' and strNamespace = ''CRM.view.Campaign'') where intScreenId = (select top 1 intScreenId from tblSMScreen where strScreenName = ''Campaign'' and strModule = ''Help Desk'' and strNamespace = ''HelpDesk.view.Campaign'')');

GO
	PRINT N'End splitting CRM and Help Desk data..'
GO
