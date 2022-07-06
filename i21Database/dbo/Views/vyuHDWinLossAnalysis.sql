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
		inner join tblEMEntity on 1=1
	where
		tblHDProject.dtmWinLossDate is not null
		and tblEMEntity.intEntityId = tblHDProject.intCustomerId
