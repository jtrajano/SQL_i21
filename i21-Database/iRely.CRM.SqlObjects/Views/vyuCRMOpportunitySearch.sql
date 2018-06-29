CREATE VIEW [dbo].[vyuCRMOpportunitySearch]
	AS
		Select
					 intOpportunityId
					,intAttachment
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
					,intAttachment = (select convert(int,count(tblSMAttachment.intAttachmentId)) from tblSMAttachment where tblSMAttachment.strScreen in ('CRM.view.Opportunity','CRM.Opportunity') and ltrim(rtrim(tblSMAttachment.strRecordNo)) = convert(nvarchar(20), proj.intOpportunityId))
					,proj.strName
					,strSalesPipeStatus = pipe.strStatus
					,proj.dtmLastDescriptionModified
					,dtmExpectedCloseDate = proj.dtmSalesDate
					,strExpectedCloseDate = CONVERT(nvarchar(10),proj.dtmSalesDate,101)
					,strPipePercentage = convert(nvarchar(20), cast(round(pipe.dblProbability,2) as numeric(36,2))) + '%'
					,dblOpportunityAmmount = (sum(qs.dblSalesOrderTotal))
					,dblNetOpportunityAmmount = (cast(round(pipe.dblProbability/100,2) as numeric (36,2))*(sum(qs.dblSalesOrderTotal)))
					,dblSoftwareAmmount = sum(qs.dblSoftwareAmount)
					,dblMaintenanceAmmount = sum(qs.dblMaintenanceAmount)
					,dblOtherAmmount = sum(qs.dblOtherAmount)
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
					left join tblCRMOpportunityQuote oq on oq.intOpportunityId = proj.intOpportunityId
					left join vyuCRMOpportunityQuoteSummary qs on qs.intSalesOrderId = oq.intSalesOrderId
				group by
					proj.intOpportunityId
					,proj.strName
					,pipe.strStatus
					,proj.dtmLastDescriptionModified
					,proj.dtmSalesDate
					,pipe.dblProbability
					,proj.intOpportunityId
					,proj.intInternalSalesPerson
					,proj.strDescription
					,proj.intCustomerId
					,con.[intEntityId]
					,typ.intTypeId
					,proj.dtmGoLive
					,proj.intPercentComplete
					,proj.ysnCompleted
					,proj.intStatusId
					,proj.intInternalProjectManager
					,proj.intCustomerContactId
					,proj.intCustomerId
					,proj.dtmCreated
					,proj.dtmClose
					,[tblCRMSource].strSource
					,proj.strLinesOfBusiness
					,proj.strCurrentSolution
					,proj.strCompetitorEntity
					,proj.strCompetitorEntityId
					,proj.strCurrentSolutionId
					,proj.strLinesOfBusinessId
					,cam.strCampaignName
					,camloc.strLocationName
					,enloc.strLocationName
					,proj.strRFPRFILink

				) as query1