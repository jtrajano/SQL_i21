GO
	PRINT N'UPDATE ORIGIN SUB MENUS SORTING'

	UPDATE RoleMenu SET intSort = MasterMenu.intSort
	FROM tblSMUserRoleMenu RoleMenu
	INNER JOIN tblSMMasterMenu MasterMenu ON RoleMenu.intMenuId = MasterMenu.intMenuID
	WHERE intParentMenuID <> 0 AND ysnIsLegacy = 1

GO