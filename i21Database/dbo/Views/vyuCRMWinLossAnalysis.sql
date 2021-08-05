CREATE VIEW [dbo].[vyuCRMWinLossAnalysis]
	AS
	select
		tblCRMOpportunity.dtmWinLossDate
		,tblEMEntity.strName
		,tblCRMOpportunity.strLinesOfBusiness
		,tblCRMOpportunity.strWinLossReason
		,tblCRMOpportunity.intOpportunityId
		,strOpportunityName = tblCRMOpportunity.strName
		,tblCRMOpportunity.intCustomerId
	from
		tblCRMOpportunity
		inner join tblEMEntity on tblEMEntity.intEntityId = tblCRMOpportunity.intCustomerId
	where
		tblCRMOpportunity.dtmWinLossDate is not null