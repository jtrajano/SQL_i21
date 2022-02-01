CREATE VIEW [dbo].[vyuHDProjectSearch]
    AS
		with projectnonbillable as (
			select aa.intProjectId, dblNonBillableHours = isnull(sum(ad.intHours),0)
			from 
				tblHDProject aa
				inner join tblHDProjectTask ab on ab.intProjectId = aa.intProjectId
				inner join tblHDTicketHoursWorked ad on ad.intTicketId = ab.intTicketId
			where ad.ysnBillable = convert(bit,0)
			group by aa.intProjectId
		),
		projecthours as (
			select intProjectId,dblQuotedHours= sum(isnull(dblQuotedHours,0.00)),dblActualHours= sum(isnull(dblActualHours,0.00))
			from
			(
			select aa.intProjectId, dblQuotedHours = (select sum(ae.dblEstimatedHours) from tblHDTicketHoursWorked ae where ae.intTicketId = ab.intTicketId), dblActualHours = (select sum(af.dblActualHours) from tblHDTicket af where af.intTicketId = ab.intTicketId)
			from 
				tblHDProject aa
				inner join tblHDProjectTask ab on ab.intProjectId = aa.intProjectId
			group by aa.intProjectId,ab.intTicketId
			) as projecthoursraw
			group by intProjectId
		)
		Select
					 intProjectId
					,strProjectName
					,strSalesPipeStatus
					,dtmLastDescriptionModified
					,dtmExpectedCloseDate
					,strExpectedCloseDate
					,strPipePercentage
					,dblOpportunityAmmount = (case when dblOpportunityAmmount is null then 0.00 else dblOpportunityAmmount end)
					,dblNetOpportunityAmmount = (case when dblNetOpportunityAmmount is null then 0.00 else dblNetOpportunityAmmount end)
					,dtmLastActivityDate
					,strSalesPerson
					,intInternalSalesPerson
					,strDescription
					,strCustomerName
					,strContactName
					,strType
					,strGoLive
					,intPercentComplete
					,ysnCompleted
					,strProjectStatus
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
					,dblActualHours
					,dblQuotedHours
					,dblOverShort = (dblQuotedHours-dblActualHours)
					,intParentProjectId
					,strParentProjectName
					,dblNonBillableHours
					,ysnReceivedDownPayment
					,dblTotalOverShort = (dblQuotedHours - (dblActualHours + dblNonBillableHours))
					,ysnEmailAlert
					,strPhone
					,intTargetVersionId
					,strVersionNo
					,strProduct
					,intProductId
					,dtmGoLive
					,strStatusFontColor
					,strStatusBackColor
		from 
				(
				select
					proj.intProjectId
					,proj.strProjectName
					,strSalesPipeStatus = pipe.strStatus
					,proj.dtmLastDescriptionModified
					,dtmExpectedCloseDate = proj.dtmSalesDate
					,strExpectedCloseDate = CONVERT(nvarchar(10),proj.dtmSalesDate,101) COLLATE Latin1_General_CI_AS
					,strPipePercentage = convert(nvarchar(20), cast(round(pipe.dblProbability,2) as numeric(36,2))) + '%' COLLATE Latin1_General_CI_AS
					,dblOpportunityAmmount = (select sum(vyuSOSalesOrderSearch.dblAmountDue) from vyuSOSalesOrderSearch where vyuSOSalesOrderSearch.strTransactionType = 'Quote' and vyuSOSalesOrderSearch.intSalesOrderId in (select tblHDOpportunityQuote.intSalesOrderId from tblHDOpportunityQuote where tblHDOpportunityQuote.intProjectId = proj.intProjectId))
					,dblNetOpportunityAmmount = (cast(round(pipe.dblProbability/100,2) as numeric (36,2))*(select sum(vyuSOSalesOrderSearch.dblAmountDue) from vyuSOSalesOrderSearch where vyuSOSalesOrderSearch.strTransactionType = 'Quote' and vyuSOSalesOrderSearch.intSalesOrderId in (select tblHDOpportunityQuote.intSalesOrderId from tblHDOpportunityQuote where tblHDOpportunityQuote.intProjectId = proj.intProjectId)))
					,dtmLastActivityDate = (select max(tblHDTicket.dtmCreated) from tblHDTicket where tblHDTicket.intTicketId in (select tblHDProjectTask.intTicketId from tblHDProjectTask where tblHDProjectTask.intProjectId = proj.intProjectId))
					,strSalesPerson = salesrep.strName
					,proj.intInternalSalesPerson
					,proj.strDescription
					,strCustomerName = (select top 1 strName from tblEMEntity where intEntityId = cus.[intEntityId])
					,strContactName = (select top 1 strName from tblEMEntity where intEntityId = con.[intEntityId])
					,strType = (select top 1 strType from tblHDTicketType where intTicketTypeId = typ.intTicketTypeId)
					,strGoLive = CONVERT(nvarchar(10),proj.dtmGoLive,101) COLLATE Latin1_General_CI_AS
					,proj.intPercentComplete
					,proj.ysnCompleted
					,proj.strProjectStatus
					,strProjectManager = (select top 1 e.strName from tblEMEntity e where e.intEntityId = proj.intInternalProjectManager)
					,strProjectType = proj.strType
					,proj.intCustomerContactId
					,strEntityType = (select top 1 et.strType from [tblEMEntityType] et where et.intEntityId = cus.[intEntityId] and et.strType in ('Customer','Prospect'))
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
					,dblActualHours = (select ph.dblActualHours from projecthours ph where ph.intProjectId = proj.intProjectId)
					,dblQuotedHours = (select ph.dblQuotedHours from projecthours ph where ph.intProjectId = proj.intProjectId)
					,dblOverShort = 0.00
					,intParentProjectId = pp.intProjectId
					,strParentProjectName = pp.strProjectName
					,pnb.dblNonBillableHours
					,proj.ysnReceivedDownPayment
					,proj.ysnEmailAlert
					,strPhone = (select top 1 cp.strPhone from tblEMEntityPhoneNumber cp where cp.intEntityId = proj.intCustomerContactId)
					,proj.intTargetVersionId
					,tv.strVersionNo
					,strProduct = (select prod.strProduct from tblHDTicketProduct prod where prod.intTicketProductId = (select top 1 prodver.intProductId from tblARCustomerProductVersion prodver where prodver.intCustomerId = proj.intCustomerId))
					,intProductId = (select top 1 prodver.intProductId from tblARCustomerProductVersion prodver where prodver.intCustomerId = proj.intCustomerId)
					,proj.dtmGoLive
					,strStatusFontColor = sta.strFontColor
					,strStatusBackColor = sta.strBackColor
				from
					tblHDProject proj
					left outer join tblARCustomer cus on cus.[intEntityId] = proj.intCustomerId
					left outer join tblEMEntity con on con.[intEntityId] = proj.intCustomerContactId
					left outer join tblHDTicketType typ on typ.intTicketTypeId = proj.intTicketTypeId
					left outer join [tblCRMSalesPipeStatus] pipe on pipe.intSalesPipeStatusId = proj.intSalesPipeStatusId
					left outer join [tblCRMSource]  on [tblCRMSource].intSourceId = proj.intOpportunitySourceId
					left outer join [tblCRMCampaign] cam on cam.[intCampaignId] = proj.intOpportunityCampaignId
					left outer join tblSMCompanyLocation camloc on camloc.intCompanyLocationId = proj.intCompanyLocationId
					left outer join tblEMEntityLocation enloc on enloc.intEntityLocationId = proj.intEntityLocationId
					--left join projecthours ph on ph.intProjectId = proj.intProjectId
					left join projectnonbillable pnb on pnb.intProjectId = proj.intProjectId
					left join tblHDProjectDetail pd on pd.intDetailProjectId = proj.intProjectId
					left join tblHDProject pp on pp.intProjectId = pd.intProjectId
					left join tblEMEntity salesrep on salesrep.intEntityId = proj.intInternalSalesPerson
					left join tblHDVersion tv on tv.intVersionId = proj.intTargetVersionId
					left join tblHDTicketStatus sta on sta.intTicketStatusId = proj.intTicketStatusId
				) as query1
