CREATE VIEW [dbo].[vyuHDProjectDetail]
	AS
	select
		a.intProjectDetailId
		,a.intProjectId
		,a.intDetailProjectId
		,a.intConcurrencyId
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
	from tblHDProjectDetail a,vyuHDProjectSearch b
	where b.intProjectId = a.intDetailProjectId
