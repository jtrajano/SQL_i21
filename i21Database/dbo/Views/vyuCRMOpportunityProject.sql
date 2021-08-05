﻿CREATE VIEW [dbo].[vyuCRMOpportunityProject]
	AS
	select
		a.intOpportunityProjectId
		,a.intOpportunityId
		,a.intConcurrencyId
		,b.intProjectId
		,b.strProjectName
		,b.strSalesPipeStatus
		,b.dtmLastDescriptionModified
		,b.dtmExpectedCloseDate
		,b.strExpectedCloseDate
		,b.strPipePercentage
		,b.dblOpportunityAmmount
		,b.dblNetOpportunityAmmount
		,b.dtmLastActivityDate
		,b.strSalesPerson
		,b.intInternalSalesPerson
		,b.strDescription
		,b.strCustomerName
		,b.strContactName
		,b.strType
		,b.strGoLive
		,b.intPercentComplete
		,b.ysnCompleted
		,b.strProjectStatus
		,b.strProjectManager
		,b.strProjectType
		,b.intCustomerContactId
		,b.strEntityType
		,b.dtmCreated
		,b.intCustomerId
		,b.dtmClose
		,b.strSource
		,b.strLinesOfBusiness
		,b.strCurrentSolution
		,b.strCompetitorEntity
		,b.strCompetitorEntityId
		,b.strCurrentSolutionId
		,b.strLinesOfBusinessId
		,b.strCampaignName
		,b.strCompanyLocation
		,b.strEntityLocation
		,b.dblActualHours
		,b.dblQuotedHours
		,b.dblOverShort
		,b.intParentProjectId
		,b.strParentProjectName
		,b.dblNonBillableHours
		,b.ysnReceivedDownPayment
		,b.dblTotalOverShort
		,b.ysnEmailAlert
		,b.strPhone
		,b.intTargetVersionId
		,b.strVersionNo
		,b.strProduct
		,b.intProductId
		,b.dtmGoLive
		,strOpportunityName = c.strName
	from 
		tblCRMOpportunityProject a
		inner join vyuHDProjectSearch b on b.intProjectId = a.intProjectId
		inner join tblCRMOpportunity c on c.intOpportunityId = a.intOpportunityId

