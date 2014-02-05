
/*----------------------*/
/* CREATE THE PROCEDURE */
/*----------------------*/
CREATE PROCEDURE usp_BuildMenuPermissions 
AS
SET NOCOUNT ON

INSERT INTO tblSMUserRoleMenu(intUserRoleID, intMenuID,ysnVisible,intSort)
SELECT tblMenus.* FROM (
SELECT Role.intUserRoleID, Menu.intMenuID, Role.ysnAdmin, Menu.intSort FROM tblSMUserRole Role
INNER JOIN tblSMMasterMenu Menu ON Role.intUserRoleID > 0) tblMenus
FULL OUTER JOIN tblSMUserRoleMenu RoleMenus ON RoleMenus.intUserRoleID = tblMenus.intUserRoleID AND RoleMenus.intMenuID = tblMenus.intMenuID
WHERE ISNULL(RoleMenus.intUserRoleID, '') = ''

UPDATE tblSMUserRoleMenu
SET intParentMenuID = tblPatch.newParent
FROM (
SELECT (SELECT intUserRoleMenuID FROM tblSMUserRoleMenu tmp WHERE tmp.intMenuID = mst.intParentMenuID AND tmp.intUserRoleID = mnu.intUserRoleID) AS newParent, mnu.* FROM tblSMUserRoleMenu mnu
LEFT JOIN tblSMMasterMenu mst ON mnu.intMenuID = mst.intMenuID
)tblPatch
WHERE tblPatch.intUserRoleMenuID = tblSMUserRoleMenu.intUserRoleMenuID