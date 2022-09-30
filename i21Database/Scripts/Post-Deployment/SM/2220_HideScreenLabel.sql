

GO
PRINT (N'/******************** BEGIN ALTER tblSMUserRoleMenu SET SCREEN LABELS AVAILABILITY TO FALSE  ********************/')

DECLARE @intmenuId int;

	IF EXISTS( SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Screen Labels')
		BEGIN
			SET @intmenuId = ( SELECT intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Screen Labels')
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE tblSMUserRoleMenu
				SET ysnAvailable = 0
				WHERE intMenuId = @intmenuId

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
			END CATCH
		END

PRINT (N'/******************** END ALTER tblSMUserRoleMenu SET SCREEN LABELS AVAILABILITY TO FALSE  ********************/')
GO


