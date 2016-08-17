CREATE VIEW [dbo].[vyuEMUserAdmin]
	AS 

	select intEntityUserSecurityId from tblSMUserSecurity a 
		join tblSMUserRole b 
				on a.intUserRoleID = b.intUserRoleID and b.ysnAdmin = 1
			where intEntityUserSecurityId not in (select intEntityUserSecurityId from tblSMUserSecurityCompanyLocationRolePermission) 	
	union	

	select intEntityUserSecurityId from tblSMUserSecurityCompanyLocationRolePermission a 
		join tblSMUserRole b 
			on a.intUserRoleId = b.intUserRoleID and ysnAdmin = 1
		group by intEntityUserSecurityId