PRINT N'*** BEGIN - INSERT DEFAULT OFFLINE MENU ***'

DECLARE @count INT
SELECT @count = COUNT(*) FROM tblSMOfflineMenu  

IF @count = 0
BEGIN
	

	INSERT INTO [dbo].[tblSMOfflineMenu]
           ([strModuleName]
           ,[strSubMenus]
           ,[intConcurrencyId])
     VALUES
           (N'Ticket Management',NULL,0)

    INSERT INTO [dbo].[tblSMOfflineMenu]
           ([strModuleName]
           ,[strSubMenus]
           ,[intConcurrencyId])
     VALUES
           (N'System Manager',NULL,0)


END

