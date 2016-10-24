CREATE VIEW [dbo].[vyuCRMWinLossAnalysis]
	AS
	select
		tblCRMOpportunity.dtmWinLossDate
		,tblEMEntity.strName
		,tblCRMOpportunity.strLinesOfBusiness
		,tblCRMOpportunity.strWinLossReason
		,tblCRMOpportunity.intOpportunityId
		,tblCRMOpportunity.intCustomerId
	from
		tblCRMOpportunity
		,tblEMEntity
	where
		tblCRMOpportunity.dtmWinLossDate is not null
		and tblEMEntity.intEntityId = tblCRMOpportunity.intCustomerId
