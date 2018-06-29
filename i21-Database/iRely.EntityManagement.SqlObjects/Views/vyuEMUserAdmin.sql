CREATE VIEW [dbo].[vyuEMUserAdmin]
	AS 

	select [intEntityId],ysnActive = ~ysnDisabled from tblSMUserSecurity a 
	  join tblSMUserRole b 
		on a.intUserRoleID = b.intUserRoleID and b.ysnAdmin = 1
	   where [intEntityId] not in (select
	 intEntityUserSecurityId from vyuSMUserLocationSubRolePermission)  
	 union 

	  SELECT Permission.intEntityUserSecurityId, ysnActive = ~ysnDisabled
	  FROM vyuSMUserLocationSubRolePermission Permission
	   INNER JOIN tblSMUserRole UserRole ON Permission.intUserRoleId = UserRole.intUserRoleID
	   join tblSMUserSecurity a
		on Permission.intEntityUserSecurityId = a.[intEntityId]
	   where UserRole.ysnAdmin = 1

	  group by Permission.intEntityUserSecurityId,a.ysnDisabled



