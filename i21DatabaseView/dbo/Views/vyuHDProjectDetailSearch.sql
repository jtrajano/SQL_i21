CREATE VIEW [dbo].[vyuHDProjectDetailSearch]
	AS
		select
			b.intProjectId
			,b.strProjectName
			,b.strDescription
			,b.strProjectManager
			,b.strProjectStatus
			,b.strType
			,b.strCustomerName
			,b.strContactName
			,b.dblQuotedHours
			,b.dblActualHours
			,b.dblOverShort
			,b.intCustomerId
			,b.intCustomerContactId
		from vyuHDProjectSearch b
		where b.intProjectId not in (select a.intDetailProjectId from tblHDProjectDetail a)
