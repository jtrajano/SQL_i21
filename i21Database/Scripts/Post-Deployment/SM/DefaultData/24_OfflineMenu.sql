 SET IDENTITY_INSERT [dbo].[tblSMOfflineMenu] ON

 --DECLARE @intOfflineMenu INT
DECLARE @recordCount INT
SELECT @recordCount = COUNT(*) FROM tblSMOfflineMenu

BEGIN
	IF @recordCount = 0
		BEGIN
			INSERT [dbo].[tblSMOfflineMenu](
				[intOfflineMenu],
				[strModuleName],
				[strSubMenus],
				[intConcurrencyId]

			)
			VALUES
			(
				1,
				'Ticket Management',
				'Tickets',
				 0

			)

		END
		
END		 