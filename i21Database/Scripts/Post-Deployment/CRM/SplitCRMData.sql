GO
	PRINT N'Begin splitting CRM and Help Desk data..'
GO

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketPriority'))
BEGIN
	SET IDENTITY_INSERT tblCRMPriority ON
	insert into tblCRMPriority (
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
		where intTicketPriorityId in (select distinct intTicketPriorityId from tblHDTicket where strType = 'CRM')
			and intTicketPriorityId not in (select intPriorityId from tblCRMPriority)
			and (ysnActivity = 1 or ysnOpportunity = 1)
	)
	SET IDENTITY_INSERT tblCRMPriority OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketStatus'))
BEGIN
	SET IDENTITY_INSERT tblCRMStatus ON
	insert into tblCRMStatus (
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
		where intTicketStatusId in (select distinct intTicketStatusId from tblHDTicket where strType = 'CRM' union all select distinct intTicketStatusId from tblHDProject where strType = 'CRM')
			and intTicketStatusId not in (select intStatusId from tblCRMStatus)
			--and (ysnActivity = 1 or ysnOpportunity = 1)
	)

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDSalesPipeStatus'))
	BEGIN
		insert into tblCRMStatus (
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
			where intTicketStatusId in (select distinct intTicketStatusId from tblHDTicket where strType = 'CRM' union all select distinct intTicketStatusId from tblHDProject where strType = 'CRM' union all select distinct intTicketStatusId from tblHDSalesPipeStatus)
				and intTicketStatusId not in (select intStatusId from tblCRMStatus)
				--and (ysnActivity = 1 or ysnOpportunity = 1)
		)
	END

	IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityCampaign'))
	BEGIN
		insert into tblCRMStatus (
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
			where intTicketStatusId in (select distinct intTicketStatusId from tblHDTicket where strType = 'CRM' union all select distinct intTicketStatusId from tblHDProject where strType = 'CRM' union all select distinct intCampaignStatusId from tblHDOpportunityCampaign)
				and intTicketStatusId not in (select intStatusId from tblCRMStatus)
				--and (ysnActivity = 1 or ysnOpportunity = 1)
		)
	END

	SET IDENTITY_INSERT tblCRMStatus OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDSalesPipeStatus'))
BEGIN
	SET IDENTITY_INSERT tblCRMSalesPipeStatus ON
	insert into tblCRMSalesPipeStatus (
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
			,strOrder
			,strProjectStatus
			,dblProbability
			,intStatusId = intTicketStatusId
			,intConcurrencyId
		from tblHDSalesPipeStatus
		where intSalesPipeStatusId not in (select intSalesPipeStatusId from tblCRMSalesPipeStatus)
	)
	SET IDENTITY_INSERT tblCRMSalesPipeStatus OFF

	--update tblCRMSalesPipeStatus set tblCRMSalesPipeStatus.intStatusId = (select tblCRMStatus.intStatusId from tblCRMStatus where tblCRMStatus.strStatus = tblCRMSalesPipeStatus.strProjectStatus)

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunitySource'))
BEGIN
	SET IDENTITY_INSERT tblCRMSource ON
	insert tblCRMSource
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
	)
	SET IDENTITY_INSERT tblCRMSource OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDTicketType'))
BEGIN
	SET IDENTITY_INSERT tblCRMType ON
	insert into tblCRMType (
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
		where intTicketTypeId in (select distinct intTicketTypeId from tblHDTicket where strType = 'CRM' union all select distinct intTicketTypeId from tblHDProject where strType = 'CRM' union all select distinct intTicketTypeId from tblHDOpportunityCampaign)
			and intTicketTypeId not in (select intTypeId from tblCRMType)
			and (ysnActivity = 1 or ysnOpportunity = 1 or ysnCampaign = 1)
	)
	SET IDENTITY_INSERT tblCRMType OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityCampaign'))
BEGIN
	SET IDENTITY_INSERT tblCRMCampaign ON
	insert into tblCRMCampaign (
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
			,strRetrospective = strRetrospective
			,strImageId = strImageId
			,intConcurrencyId = intConcurrencyId
		from tblHDOpportunityCampaign
		where intOpportunityCampaignId not in (select intCampaignId from tblCRMCampaign)
	)
	SET IDENTITY_INSERT tblCRMCampaign OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDMilestone'))
BEGIN
	SET IDENTITY_INSERT tblCRMMilestone ON
	insert into tblCRMMilestone (
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
	)
	SET IDENTITY_INSERT tblCRMMilestone OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityWinLossReason'))
BEGIN
	SET IDENTITY_INSERT tblCRMWinLossReason ON
	insert into tblCRMWinLossReason (
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
	)
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

	SET IDENTITY_INSERT tblCRMOpportunity ON
	insert into tblCRMOpportunity
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
		where strType = 'CRM' and intProjectId not in (select intOpportunityId from tblCRMOpportunity)
	)
	SET IDENTITY_INSERT tblCRMOpportunity OFF

	insert into tblSMTransaction
	(
		intScreenId
		,strRecordNo
		,strTransactionNo
		,intEntityId
		,dtmDate
		,strApprovalStatus
		,intConcurrencyId
	)
	(
		select
			intScreenId = (select top 1 intScreenId from tblSMScreen where strNamespace = 'CRM.view.Opportunity')
			,strRecordNo = convert(nvarchar(50), tblCRMOpportunity.intOpportunityId)
			,strTransactionNo = SUBSTRING(tblCRMOpportunity.strName, 0, 47) + '...'
			,intEntityId = tblCRMOpportunity.intInternalSalesPerson
			,dtmDate = tblCRMOpportunity.dtmCreated
			,strApprovalStatus = null
			,intConcurrencyId = 1
		from
			tblCRMOpportunity
		where
			convert(nvarchar(50), tblCRMOpportunity.intOpportunityId) not in (select strRecordNo from tblSMTransaction where intScreenId = (select top 1 intScreenId from tblSMScreen where strNamespace = 'CRM.view.Opportunity'))
	)

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverview'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewProblem ON
	insert tblCRMOpportunityOverviewProblem
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityOverviewId not in (select intOpportunityOverviewId from tblCRMOpportunityOverviewProblem)
	)
	SET IDENTITY_INSERT tblCRMOpportunityOverviewProblem OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewConcern'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewConcern ON
	insert tblCRMOpportunityOverviewConcern
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityOverviewConcernId not in (select intOpportunityOverviewConcernId from tblCRMOpportunityOverviewConcern)
	)
	SET IDENTITY_INSERT tblCRMOpportunityOverviewConcern OFF
END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewSolution'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewSolution ON
	insert tblCRMOpportunityOverviewSolution
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityOverviewSolutionId not in (select intOpportunityOverviewSolutionId from tblCRMOpportunityOverviewSolution)
	)
	SET IDENTITY_INSERT tblCRMOpportunityOverviewSolution OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewUniqueValue'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewUniqueValue ON
	insert tblCRMOpportunityOverviewUniqueValue
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityOverviewUniqueValueId not in (select intOpportunityOverviewUniqueValueId from tblCRMOpportunityOverviewUniqueValue)
	)
	SET IDENTITY_INSERT tblCRMOpportunityOverviewUniqueValue OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityOverviewGain'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityOverviewGain ON
	insert tblCRMOpportunityOverviewGain
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityOverviewGainId not in (select intOpportunityOverviewGainId from tblCRMOpportunityOverviewGain)
	)
	SET IDENTITY_INSERT tblCRMOpportunityOverviewGain OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityQuote'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityQuote ON
	insert tblCRMOpportunityQuote
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
			intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
			and intOpportunityQuoteId not in (select intOpportunityQuoteId from tblCRMOpportunityQuote)
	)
	SET IDENTITY_INSERT tblCRMOpportunityQuote OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDOpportunityContract'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityContract ON
	insert tblCRMOpportunityContract
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
			and intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
	)
	SET IDENTITY_INSERT tblCRMOpportunityContract OFF

END

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblHDProjectContactInfo'))
BEGIN
	SET IDENTITY_INSERT tblCRMOpportunityContact ON
	insert tblCRMOpportunityContact
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
			and intProjectId in (select intProjectId from tblHDProject where strType = 'CRM')
	)
	SET IDENTITY_INSERT tblCRMOpportunityContact OFF
END


GO
	PRINT N'End splitting CRM and Help Desk data..'
GO