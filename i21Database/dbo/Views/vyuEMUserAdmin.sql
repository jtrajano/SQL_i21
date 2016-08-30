CREATE VIEW [dbo].[vyuEMUserAdmin]
	AS 

	select intEntityUserSecurityId,ysnActive = ~ysnDisabled from tblSMUserSecurity a 
		join tblSMUserRole b 
				on a.intUserRoleID = b.intUserRoleID and b.ysnAdmin = 1
			where intEntityUserSecurityId not in (select intEntityUserSecurityId from tblSMUserSecurityCompanyLocationRolePermission) 	
	union	

	select a.intEntityUserSecurityId, ysnActive = ~ysnDisabled from tblSMUserSecurityCompanyLocationRolePermission a 
		join tblSMUserRole b 
			on a.intUserRoleId = b.intUserRoleID and ysnAdmin = 1
		join tblSMUserSecurity c
			on a.intEntityUserSecurityId = c.intEntityUserSecurityId
		group by a.intEntityUserSecurityId,c.ysnDisabled