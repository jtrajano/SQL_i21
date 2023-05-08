CREATE VIEW [dbo].[vyuCRMOpportunityLink]
	AS
		with closed as (
			select b.intRecordId, intClosed = convert(numeric(16,8),count(c.intActivityId))
			from tblSMScreen a
				inner join tblSMTransaction b on b.intScreenId = a.intScreenId
				inner join tblSMActivity c on c.intTransactionId = b.intTransactionId
			where 
				a.strNamespace = 'CRM.view.Opportunity'
				and c.strStatus = 'Closed'
			group by b.intRecordId
		),
		notclosed as (
			select b.intRecordId, intOpen = convert(numeric(16,8),count(c.intActivityId))
			from 
				tblSMScreen a
				inner join tblSMTransaction b on b.intScreenId = a.intScreenId
				inner join tblSMActivity c on c.intTransactionId = b.intTransactionId
			where a.strNamespace = 'CRM.view.Opportunity'
			group by b.intRecordId
		)
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
			,intPercentComplete = case when s.intOpen = 0 then 0.00 when s.intOpen is null then 0.00 else isnull(isnull(r.intClosed, 0.00) / isnull(s.intOpen, 0.00),0.00) end
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
			,strEntityType = CASE WHEN w.strType IS NOT NULL
											THEN 'Customer'
											ELSE 'Vendor'
									  END COLLATE Latin1_General_CI_AS --(case when a.strDirection = 'Purchase' then 'Vendor' else 'Customer' end) COLLATE Latin1_General_CI_AS
			,strDirectionEntityType = (case when a.strDirection = 'Purchase' then 'Vendor' else 'Customer' end) COLLATE Latin1_General_CI_AS
			,strLOBType = (select top 1 r.strType from tblSMLineOfBusiness r, tblCRMOpportunityLob s where r.strType = 'Software' and r.intLineOfBusinessId = s.intLineOfBusinessId and s.intOpportunityId = a.intOpportunityId)
			,a.intIndustrySegmentId
			,a.intOpportunityTypeId
			,a.intVolume
			,a.intGrossProfit
			,a.intGrossRevenue
			,a.strOpportunityDescription
			,a.intBrandMaintenanceId
			,t.strIndustrySegment
			,u.strOpportunityType
			,v.strBrand
			,a.strOpportunityNumber
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
			left join closed r on r.intRecordId = a.intOpportunityId
			left join notclosed s on s.intRecordId = a.intOpportunityId
			left join tblCRMIndustrySegment t on t.intIndustrySegmentId = a.intIndustrySegmentId
			left join tblCRMOpportunityType u on u.intOpportunityTypeId = a.intOpportunityTypeId
			left join tblCRMBrandMaintenance v on v.intBrandMaintenanceId = a.intBrandMaintenanceId
			outer apply 
			(
				select top 1 strType
				from tblEMEntityType
				where intEntityId = a.intCustomerId and
					  strType in ('Customer', 'Prospect')
			) w
GO
