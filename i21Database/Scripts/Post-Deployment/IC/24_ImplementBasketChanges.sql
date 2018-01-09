PRINT N'BEGIN - Migration for Bundle Type Items'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICItem')
BEGIN

	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICItem' AND [COLUMN_NAME] = N'ysnIsBasket_TEMP')
	BEGIN
		EXEC('
			UPDATE [dbo].[tblICItem] SET [strBundleType] = N''Bundle''
			WHERE [strType] = N''Bundle'' AND ysnIsBasket_TEMP != 1;

			UPDATE [dbo].[tblICItem] SET [strBundleType] = N''Basket''
			WHERE [strType] = N''Bundle'' AND ysnIsBasket_TEMP = 1;

			ALTER TABLE [dbo].[tblICItem] 
				DROP COLUMN [ysnIsBasket_TEMP]
		')
	END

	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICItem' AND [COLUMN_NAME] = N'strBundleType')
	EXEC('
		UPDATE [dbo].[tblICItem] SET [strType] = N''Inventory''
		WHERE [strBundleType] = N''Bundle'' OR [strBundleType] = N''Basket'';
	')
END
GO
PRINT N'END - Migration for Bundle Type Items'