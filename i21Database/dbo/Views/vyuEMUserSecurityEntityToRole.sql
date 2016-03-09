CREATE VIEW [dbo].[vyuEMUserSecurityEntityToRole]
	AS 
	select 	
	a.intUserRoleID
	,a.ysnAdmin
	,a.strRoleType
	,strRoleName			= a.strName
	,strEntityName			= c.strName
	,strEntityNo			= c.strEntityNo
	,intEntityId			= c.intEntityId

from tblSMUserRole a
	join tblEMEntityToRole b
		on a.intUserRoleID = b.intEntityRoleId
	join tblEntity c
		on c.intEntityId = b.intEntityId