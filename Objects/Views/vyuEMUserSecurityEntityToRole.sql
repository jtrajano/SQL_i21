CREATE VIEW [dbo].[vyuEMUserSecurityEntityToRole]
	AS 
select distinct b.intUserRoleID
	,b.ysnAdmin
	,a.ysnPortalAdmin
	,b.strRoleType
	,strRoleName			= b.strName
	,strEntityName			= d.strName
	,strEntityNo			= d.strEntityNo
	,intEntityId			= d.intEntityId
	,intEntityContactId			= a.intEntityContactId
from tblEMEntityToContact a
join tblSMUserRole b
	on a.intEntityRoleId = b.intUserRoleID
join tblEMEntityToContact c
	on a.intEntityId = c.intEntityId
join tblEMEntity d
	on c.intEntityId = d.intEntityId
where strRoleType in ('Portal Admin', 'Portal Admin')
