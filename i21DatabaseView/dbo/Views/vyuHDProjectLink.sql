CREATE VIEW [dbo].[vyuHDProjectLink]
	AS
		with parentproject as (
			select intProjectId = a.intDetailProjectId, intParentProjectId = a.intProjectId, strParentProjectName = b.strProjectName from tblHDProjectDetail a, tblHDProject b where b.intProjectId = a.intProjectId
		)
		select
			a.intProjectId
			,a.strProjectName
			,a.strDescription
			,a.intCustomerId
			,a.intCustomerContactId
			,a.intSalesPipeStatusId
			,a.intTicketStatusId
			,a.intOpportunitySourceId
			,a.intTicketTypeId
			,a.intOpportunityCampaignId
			,a.strCompetitorEntityId
			,a.strCurrentSolutionId
			,a.strCompetitorEntity
			,a.strCurrentSolution
			,a.intReferredByEntityId
			,a.dtmCreated
			,a.dtmClose
			,a.dtmGoLive
			,a.intPercentComplete
			,a.ysnCompleted
			,a.intSort
			,a.ysnActive
			,a.strProjectStatus
			,a.intInternalProjectManager
			,a.intInternalSalesPerson
			,a.ysnInitialDataCollectionComplete
			,a.dtmConfirmedKeystoneDate
			,a.intCustomerProjectManager
			,a.intCustomerLeadershipSponsor
			,a.strCustomerKeyProjectGoal
			,a.strCustomModification
			,a.dtmSalesDate
			,a.dtmSoftwareBillDate
			,a.strSoftwareBillDateComment
			,a.dtmHardwareOrderDate
			,a.strHardwareOrderDateComment
			,a.dtmInitialUserGroupDuesInvoice
			,a.ysnReceivedDownPayment
			,a.ysnGenerateTicket
			,a.strType
			,a.strLinesOfBusinessId
			,a.strLinesOfBusiness
			,a.strRFPRFILink
			,a.dtmLastDescriptionModified
			,a.strDirection
			,a.intMilestoneId
			,a.intCompanyLocationId
			,a.intEntityLocationId
			,a.strOpportunityWinLossReasonId
			,a.strOpportunityWinLossReason
			,a.dtmWinLossDate
			,a.intWinLossLengthOfCycle
			,a.strWinLossDetails
			,a.strWinLossDidRight
			,a.strWinLossDidWrong
			,a.strWinLossActionItem
			,a.intLostToCompetitorId
			,a.ysnEmailAlert
			,a.ysnMultipleCustomer
			,a.intTargetVersionId
			,a.strProjectImageId
			,a.intConcurrencyId
			,strEntityName = b.strName
			,strContactName = c.strName
			,strTicketStatus = e.strStatus
			,strTicketType = g.strType
			,strInternalProjectManager = j.strName
			,strInternalSalesPerson = k.strName
			,strCustomerProjectManager = l.strName
			,strCustomerLeadershipSponsor = m.strName
			,strTargetVersion = n.strVersionNo
			,intTicketProductId = (select top 1 o.intProductId from tblARCustomerProductVersion o where o.intCustomerId = a.intCustomerId)
			,intParentProjectId = (select top 1 intParentProjectId from parentproject where intProjectId = a.intProjectId)
			,strParentProjectName = (select top 1 strParentProjectName from parentproject where intProjectId = a.intProjectId)
			,p.intOpportunityId
			,strOpportunityName = p.strName
		from
			tblHDProject a
			left join tblEMEntity b on b.intEntityId = a.intCustomerId
			left join tblEMEntity c on c.intEntityId = a.intCustomerContactId
			left join tblHDTicketStatus e on e.intTicketStatusId = a.intTicketStatusId
			left join tblHDTicketType g on g.intTicketTypeId = a.intTicketTypeId
			left join tblEMEntity j on j.intEntityId = a.intInternalProjectManager
			left join tblEMEntity k on k.intEntityId = a.intInternalSalesPerson
			left join tblEMEntity l on l.intEntityId = a.intCustomerProjectManager
			left join tblEMEntity m on m.intEntityId = a.intCustomerLeadershipSponsor
			left join tblHDVersion n on n.intVersionId = a.intTargetVersionId
			left join tblCRMOpportunityProject o on o.intProjectId = a.intProjectId
			left join tblCRMOpportunity p on p.intOpportunityId = o.intOpportunityId