CREATE VIEW [dbo].[vyuHDProjectParentSearch]
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
