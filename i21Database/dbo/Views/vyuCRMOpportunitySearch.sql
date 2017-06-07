CREATE VIEW [dbo].[vyuCRMOpportunitySearch]
	AS
		Select
					 intOpportunityId
					,strName
					,strSalesPipeStatus
					,dtmLastDescriptionModified
					,dtmExpectedCloseDate
					,strExpectedCloseDate
					,strPipePercentage
					,dblOpportunityAmmount = (case when dblOpportunityAmmount is null then 0.00 else dblOpportunityAmmount end)
					,dblNetOpportunityAmmount = (case when dblNetOpportunityAmmount is null then 0.00 else dblNetOpportunityAmmount end)
					,dblSoftwareAmmount = isnull(dblSoftwareAmmount,0)
					,dblMaintenanceAmmount = isnull(dblMaintenanceAmmount,0)
					,dblOtherAmmount = isnull(dblOtherAmmount,0)
					,dtmLastActivityDate
					,strSalesPerson
					,strDescription
					,strCustomerName
					,strContactName
					,strType
					,strGoLive
					,intPercentComplete
					,ysnCompleted
					,strOpportunityStatus 
					,strProjectManager
					,strProjectType
					,intCustomerContactId
					,strEntityType
					,dtmCreated
					,intCustomerId
					,dtmClose
					,strSource
					,strLinesOfBusiness
					,strCurrentSolution
					,strCompetitorEntity
					,strCompetitorEntityId
					,strCurrentSolutionId
					,strLinesOfBusinessId
					,strCampaignName
					,strCompanyLocation
					,strEntityLocation
					,intAge = DATEDIFF(day,dtmCreated,GETDATE())
					,strRFPRFILink
		from 
				(
				select
					proj.intOpportunityId
					,proj.strName
					,strSalesPipeStatus = pipe.strStatus
					,proj.dtmLastDescriptionModified
					,dtmExpectedCloseDate = proj.dtmSalesDate
					,strExpectedCloseDate = CONVERT(nvarchar(10),proj.dtmSalesDate,101)
					,strPipePercentage = convert(nvarchar(20), cast(round(pipe.dblProbability,2) as numeric(36,2))) + '%'
					,dblOpportunityAmmount = (select sum(distinct vyuCRMOpportunityQuoteSummary.dblSalesOrderTotal) from vyuCRMOpportunityQuoteSummary where vyuCRMOpportunityQuoteSummary.intSalesOrderId in (select tblCRMOpportunityQuote.intSalesOrderId from tblCRMOpportunityQuote where tblCRMOpportunityQuote.intOpportunityId = proj.intOpportunityId))
					,dblNetOpportunityAmmount = (cast(round(pipe.dblProbability/100,2) as numeric (36,2))*(select sum(distinct vyuCRMOpportunityQuoteSummary.dblSalesOrderTotal) from vyuCRMOpportunityQuoteSummary where vyuCRMOpportunityQuoteSummary.intSalesOrderId in (select tblCRMOpportunityQuote.intSalesOrderId from tblCRMOpportunityQuote where tblCRMOpportunityQuote.intOpportunityId = proj.intOpportunityId)))
					,dblSoftwareAmmount = (select sum(distinct vyuCRMOpportunityQuoteSummary.dblSoftwareAmount) from vyuCRMOpportunityQuoteSummary where vyuCRMOpportunityQuoteSummary.intSalesOrderId in (select tblCRMOpportunityQuote.intSalesOrderId from tblCRMOpportunityQuote where tblCRMOpportunityQuote.intOpportunityId = proj.intOpportunityId))
					,dblMaintenanceAmmount = (select sum(distinct vyuCRMOpportunityQuoteSummary.dblMaintenanceAmount) from vyuCRMOpportunityQuoteSummary where vyuCRMOpportunityQuoteSummary.intSalesOrderId in (select tblCRMOpportunityQuote.intSalesOrderId from tblCRMOpportunityQuote where tblCRMOpportunityQuote.intOpportunityId = proj.intOpportunityId))
					,dblOtherAmmount = (select sum(distinct vyuCRMOpportunityQuoteSummary.dblOtherAmount) from vyuCRMOpportunityQuoteSummary where vyuCRMOpportunityQuoteSummary.intSalesOrderId in (select tblCRMOpportunityQuote.intSalesOrderId from tblCRMOpportunityQuote where tblCRMOpportunityQuote.intOpportunityId = proj.intOpportunityId))
					,dtmLastActivityDate = (
						select
							max(tblSMActivity.dtmCreated)
						from
							tblSMActivity
						where
							tblSMActivity.intTransactionId = (
								select
									top 1 tblSMTransaction.intTransactionId 
								from
									tblSMTransaction 
								where
									tblSMTransaction.intScreenId = (
										select top 1
											tblSMScreen.intScreenId
										from
											tblSMScreen
										where
											tblSMScreen.strScreenId = 'Opportunity'
											and tblSMScreen.strNamespace = 'CRM.view.Opportunity'
									)
									and tblSMTransaction.intRecordId = proj.intOpportunityId
							)
					)
					,strSalesPerson = (select top 1 e.strName from tblEMEntity e where e.intEntityId = proj.intInternalSalesPerson)
					,proj.strDescription
					,strCustomerName = (select top 1 strName from tblEMEntity where intEntityId = proj.intCustomerId)
					,strContactName = (select top 1 strName from tblEMEntity where intEntityId = con.[intEntityId])
					,strType = (select top 1 strType from tblHDTicketType where intTicketTypeId = typ.intTypeId)
					,strGoLive = CONVERT(nvarchar(10),proj.dtmGoLive,101)
					,proj.intPercentComplete
					,proj.ysnCompleted
					,strOpportunityStatus = (select top 1 tblCRMStatus.strStatus from tblCRMStatus where tblCRMStatus.intStatusId = proj.intStatusId)
					,strProjectManager = (select top 1 e.strName from tblEMEntity e where e.intEntityId = proj.intInternalProjectManager)
					,strProjectType = 'CRM'
					,proj.intCustomerContactId
					,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = proj.intCustomerId and et.strType in ('Customer','Prospect'))--dbo.fnCRMCoalesceEntityType(proj.intCustomerId)
					,proj.dtmCreated
					,proj.intCustomerId
					,proj.dtmClose
					,[tblCRMSource].strSource
					,proj.strLinesOfBusiness
					,proj.strCurrentSolution
					,proj.strCompetitorEntity
					,proj.strCompetitorEntityId
					,proj.strCurrentSolutionId
					,proj.strLinesOfBusinessId
					,cam.strCampaignName
					,strCompanyLocation = camloc.strLocationName
					,strEntityLocation = enloc.strLocationName
					,proj.strRFPRFILink
				from
					tblCRMOpportunity proj
					left outer join tblEMEntity con on con.[intEntityId] = proj.intCustomerContactId
					left outer join tblCRMType typ on typ.intTypeId = proj.intTypeId
					left outer join [tblCRMSalesPipeStatus] pipe on pipe.intSalesPipeStatusId = proj.intSalesPipeStatusId
					left outer join [tblCRMSource]  on [tblCRMSource].intSourceId = proj.intSourceId
					left outer join [tblCRMCampaign] cam on cam.[intCampaignId] = proj.intCampaignId
					left outer join tblSMCompanyLocation camloc on camloc.intCompanyLocationId = proj.intCompanyLocationId
					left outer join tblEMEntityLocation enloc on enloc.intEntityLocationId = proj.intEntityLocationId
				) as query1