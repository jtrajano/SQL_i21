CREATE PROCEDURE [dbo].[uspSMResolveContactRoleMenus]
	@userRoleId int
AS
BEGIN

	DECLARE @isContact BIT
	DECLARE @isAdmin BIT
	DECLARE @groupId INT
	DECLARE @IsDefaultPortal BIT
	DECLARE @isDuplicateUR BIT

	-- CHECK IF ROLE IS FOR CONTACT/S
	SELECT @isContact = CASE strRoleType WHEN 'Contact Admin' THEN 1 ELSE (CASE strRoleType WHEN 'Contact' THEN 1 ELSE 0 END) END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
	SELECT @IsDefaultPortal = CASE strRoleType WHEN 'Portal Default' THEN 1 ELSE 0 END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId
	SELECT @isDuplicateUR = CASE SUBSTRING(UPPER(strName),1,3) WHEN 'DUP' THEN 1 ELSE 0 END FROM tblSMUserRole WHERE intUserRoleID = @userRoleId

	IF @IsDefaultPortal = 1
	BEGIN
		-- Get all contact admins
		-- Loop through it
		DECLARE @currentRow1 INT
		DECLARE @totalRows1 INT

		SET @currentRow1 = 1
		SELECT @totalRows1 = Count(*) FROM [dbo].[tblSMUserRole] WHERE strRoleType = 'Contact Admin'

		WHILE (@currentRow1 <= @totalRows1)
		BEGIN
			DECLARE @roleId1 INT
			SELECT @roleId1 = intUserRoleID FROM (  
				SELECT UserRole.intUserRoleID,  ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID'
				FROM [dbo].[tblSMUserRole] UserRole WHERE strRoleType = 'Contact Admin'
			) a
			WHERE ROWID = @currentRow1

			-- Add all menus by executing uspSMUpdateUserRoleMenus
			PRINT N'Executing uspSMUpdateUserRoleMenus'
			Exec uspSMUpdateUserRoleMenus @roleId1, 1, 0

			SET @currentRow1 = @currentRow1 + 1
		END	
	END
	-- If role is for contact
	ELSE IF @isContact = 1
	BEGIN
		-- Get Contact Admin Parent
		SELECT @groupId = intEntityId FROM tblEMEntityToRole WHERE intEntityRoleId = @userRoleId
		-- CHECK ROLE IF ADMIN
		SELECT @isAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @userRoleId

		IF @isAdmin = 1 -- If admin update self first then the group		
		BEGIN
			DELETE FROM tblSMUserRoleMenu
			WHERE intUserRoleId = @userRoleId AND intMenuId IN
			(
				-- Default Portal Menu
				SELECT intMenuId FROM tblSMUserRoleMenu WHERE intUserRoleId = 999 AND ysnVisible = 0
			)
			--DELETE UserRoleMenu FROM tblSMUserRoleMenu UserRoleMenu
			----SELECT UserRole.intUserRoleID, UserRole.strName as RoleName, UserRole.strRoleType, EntityToRole.intEntityId, MasterMenu.strMenuName, UserRoleMenu.ysnVisible FROM tblSMUserRoleMenu UserRoleMenu
			--INNER JOIN tblSMUserRole UserRole ON UserRoleMenu.intUserRoleId = UserRole.intUserRoleID
			--INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			--INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
			--WHERE UserRole.ysnAdmin = 0 AND MasterMenu.intMenuID IN
			--(
			--	-- Default Portal Menu
			--	SELECT intMenuId FROM tblSMUserRoleMenu WHERE intUserRoleId = 999 AND ysnVisible = 0
			--)

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
		END
		ELSE IF @isDuplicateUR = 1 
		BEGIN
		DECLARE @currentRow2 INT
			DECLARE @totalRows2 INT

			SET @currentRow2 = 1
			SELECT @totalRows2 = Count(*) FROM [dbo].[tblEMEntityToRole] EntityToRole
			INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @groupId

			WHILE (@currentRow2 <= @totalRows2)
			BEGIN
				DECLARE @roleId2 INT
				SELECT @roleId2 = intUserRoleID FROM (  
					SELECT UserRole.intUserRoleID,  ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID'
					FROM [dbo].[tblEMEntityToRole] EntityToRole
					INNER JOIN tblSMUserRole UserRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
					WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @groupId
				) a
				WHERE ROWID = @currentRow2

				PRINT N'Executing uspSMUpdateUserRoleMenus'
				Exec uspSMUpdateUserRoleMenus @roleId2, 1, 0

				SET @currentRow2 = @currentRow2 + 1
			END	
		END
		ELSE
		BEGIN
			-- Delete unavailable menus
			DELETE FROM tblSMUserRoleMenu
			WHERE intUserRoleId = @userRoleId AND intMenuId IN 
			(
				-- Contact Admin Menu
				SELECT ContactMenu.intMasterMenuId FROM tblSMContactMenu ContactMenu 
				LEFT JOIN 
				(
						SELECT * FROM tblSMUserRoleMenu WHERE intUserRoleId = 
						(
							SELECT UR.intUserRoleID FROM tblSMUserRole UR 
							INNER JOIN tblEMEntityToRole ETR ON ETR.intEntityRoleId = UR.intUserRoleID 
							WHERE UR.ysnAdmin = 1 AND ETR.intEntityId = @groupId
						)
				) RoleMenu ON ContactMenu.intMasterMenuId = RoleMenu.intMenuId
				WHERE ISNULL(RoleMenu.ysnVisible, 0) = 0	
			)

			--DELETE UserRoleMenu FROM tblSMUserRoleMenu UserRoleMenu
			----SELECT UserRole.strName as RoleName, MasterMenu.strMenuName, UserRoleMenu.ysnVisible FROM tblSMUserRoleMenu UserRoleMenu
			--INNER JOIN tblSMUserRole UserRole ON UserRoleMenu.intUserRoleId = UserRole.intUserRoleID
			--INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
			--INNER JOIN tblSMMasterMenu MasterMenu ON UserRoleMenu.intMenuId = MasterMenu.intMenuID
			--WHERE UserRole.intUserRoleID = @userRoleId AND MasterMenu.intMenuID IN 
			--(
			--	-- Contact Admin Menu
			--	SELECT ContactMenu.intMasterMenuId FROM tblSMContactMenu ContactMenu 
			--	LEFT JOIN 
			--	(
			--			SELECT * FROM tblSMUserRoleMenu WHERE intUserRoleId = 
			--			(
			--				SELECT UR.intUserRoleID FROM tblSMUserRole UR 
			--				INNER JOIN tblEMEntityToRole ETR ON ETR.intEntityRoleId = UR.intUserRoleID 
			--				WHERE UR.ysnAdmin = 1 AND ETR.intEntityId = @groupId
			--			)
			--	) RoleMenu ON ContactMenu.intMasterMenuId = RoleMenu.intMenuId
			--	WHERE ISNULL(RoleMenu.ysnVisible, 0) = 0	
			--)
		END
	END
END
