CREATE PROCEDURE [dbo].[uspSMResolveContactRoleMenus]
	@userRoleId int
AS
BEGIN

	DECLARE @isContact BIT
	DECLARE @isAdmin BIT
	DECLARE @groupId INT

	-- CHECK IF ROLE IS FOR CONTACT/S
	SELECT @isContact = CASE strRoleType WHEN 'Contact Admin' THEN 1 ELSE (CASE strRoleType WHEN 'Contact' THEN 1 ELSE 0 END) END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
	-- If role is for contact
	IF @isContact = 1
	BEGIN
		-- Get Contact Admin Parent
		SELECT @groupId = intEntityId FROM tblEMEntityToRole WHERE intEntityRoleId = @userRoleId
		-- CHECK ROLE IF ADMIN
		SELECT @isAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
		IF @isAdmin = 1 -- If admin update group		
		BEGIN
			-- Get contacts only
			-- Loop and execute uspSMUpdateUserRoleMenus to add available menus
			DECLARE @currentRow INT
			DECLARE @totalRows INT

			SET @currentRow = 1
			SELECT @totalRows = Count(*) FROM [dbo].[tblEMEntityToRole] EntityToRole
			INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @groupId

			WHILE (@currentRow <= @totalRows)
			BEGIN
				DECLARE @roleId INT
				SELECT @roleId = intUserRoleID FROM (  
					SELECT UserRole.intUserRoleID,  ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID'
					FROM [dbo].[tblEMEntityToRole] EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @groupId
				) a
				WHERE ROWID = @currentRow

				PRINT N'Executing uspSMUpdateUserRoleMenus'
				Exec uspSMUpdateUserRoleMenus @roleId, 1, 0

				SET @currentRow = @currentRow + 1
			END
			-- Delete unavailable menus
            DELETE UserRoleMenu FROM tblSMUserRoleMenu UserRoleMenu
			--SELECT UserRole.strName as RoleName, MasterMenu.strMenuName, UserRoleMenu.ysnVisible FROM tblSMUserRoleMenu UserRoleMenu
			INNER JOIN tblSMUserRole UserRole ON UserRoleMenu.intUserRoleId = UserRole.intUserRoleID
			INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
			WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @groupId AND MasterMenu.intMenuID IN 
			(
				SELECT MasterMenu.intMenuID FROM tblEMEntityToRole EntityToRole
				INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
				INNER JOIN tblSMUserRoleMenu UserRoleMenu ON UserRole.intUserRoleID = UserRoleMenu.intUserRoleId
				INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
				INNER JOIN tblSMContactMenu ContactMenu ON ContactMenu.intMasterMenuId = MasterMenu.intMenuID
				WHERE UserRole.ysnAdmin = 1 AND EntityToRole.intEntityId = @groupId AND UserRoleMenu.ysnVisible = 0
			)
		END
		ELSE
		BEGIN
			-- Delete unavailable menus
            DELETE UserRoleMenu FROM tblSMUserRoleMenu UserRoleMenu
			--SELECT UserRole.strName as RoleName, MasterMenu.strMenuName, UserRoleMenu.ysnVisible FROM tblSMUserRoleMenu UserRoleMenu
			INNER JOIN tblSMUserRole UserRole ON UserRoleMenu.intUserRoleId = UserRole.intUserRoleID
			INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
			WHERE UserRole.intUserRoleID = @userRoleId AND MasterMenu.intMenuID IN 
			(
				SELECT MasterMenu.intMenuID FROM tblEMEntityToRole EntityToRole
				INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
				INNER JOIN tblSMUserRoleMenu UserRoleMenu ON UserRole.intUserRoleID = UserRoleMenu.intUserRoleId
				INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
				INNER JOIN tblSMContactMenu ContactMenu ON ContactMenu.intMasterMenuId = MasterMenu.intMenuID
				WHERE UserRole.ysnAdmin = 1 AND EntityToRole.intEntityId = @groupId AND UserRoleMenu.ysnVisible = 0
			)
		END
	END
END
