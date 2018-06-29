CREATE VIEW [dbo].[vyuHDWinLossAnalysis]
	AS
	select
		tblHDProject.dtmWinLossDate
		,tblEMEntity.strName
		,tblHDProject.strLinesOfBusiness
		,tblHDProject.strOpportunityWinLossReason
		,tblHDProject.intProjectId
		,tblHDProject.intCustomerId
	from
		tblHDProject
		,tblEMEntity
	where
		tblHDProject.dtmWinLossDate is not null
		and tblEMEntity.intEntityId = tblHDProject.intCustomerId
