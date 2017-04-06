CREATE VIEW [dbo].[vyuCRMOpportunityLink]
	AS
		select
			a.intOpportunityId
			,a.strName
			,a.strDescription
			,a.intCustomerId
			,a.intCustomerContactId
			,a.intSalesPipeStatusId
			,a.intStatusId
			,a.intSourceId
			,a.intTypeId
			,a.intCampaignId
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
			,a.strOpportunityStatus
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
			,a.strLinesOfBusinessId
			,a.strLinesOfBusiness
			,a.strRFPRFILink
			,a.dtmLastDescriptionModified
			,a.strDirection
			,a.intMilestoneId
			,a.intCompanyLocationId
			,a.intEntityLocationId
			,a.strWinLossReasonId
			,a.strWinLossReason
			,a.dtmWinLossDate
			,a.intWinLossLengthOfCycle
			,a.strWinLossDetails
			,a.strWinLossDidRight
			,a.strWinLossDidWrong
			,a.strWinLossActionItem
			,a.intLostToCompetitorId
			,a.intConcurrencyId

			,strEntityName = b.strName
			,strContactName = c.strName
			,strSalesPipeStatus = d.strStatus
			,e.strStatus
			,f.strSource
			,g.strType
			,h.strCampaignName
			,strReferredBy = i.strName
			,strInternalProjectManager = j.strName
			,strInternalSalesPerson = k.strName
			,strCustomerProjectManager = l.strName
			,strCustomerLeadershipSponsor = m.strName
			,n.strMileStone
			,o.strLocationName
			,strEntityLocation = p.strLocationName
			,strLostToCompetitor = q.strName
		from
			tblCRMOpportunity a
			left join tblEMEntity b on b.intEntityId = a.intCustomerId
			left join tblEMEntity c on c.intEntityId = a.intCustomerContactId
			left join tblCRMSalesPipeStatus d on d.intSalesPipeStatusId = a.intSalesPipeStatusId
			left join tblCRMStatus e on e.intStatusId = a.intStatusId
			left join tblCRMSource f on f.intSourceId = a.intSourceId
			left join tblCRMType g on g.intTypeId = a.intTypeId
			left join tblCRMCampaign h on h.intCampaignId = a.intCampaignId
			left join tblEMEntity i on i.intEntityId = a.intReferredByEntityId
			left join tblEMEntity j on j.intEntityId = a.intInternalProjectManager
			left join tblEMEntity k on k.intEntityId = a.intInternalSalesPerson
			left join tblEMEntity l on l.intEntityId = a.intCustomerProjectManager
			left join tblEMEntity m on m.intEntityId = a.intCustomerLeadershipSponsor
			left join tblCRMMilestone n on n.intMilestoneId = a.intMilestoneId
			left join tblSMCompanyLocation o on o.intCompanyLocationId = a.intCompanyLocationId
			left join tblEMEntityLocation p on p.intEntityLocationId = a.intEntityLocationId
			left join tblEMEntity q on q.intEntityId = a.intLostToCompetitorId
