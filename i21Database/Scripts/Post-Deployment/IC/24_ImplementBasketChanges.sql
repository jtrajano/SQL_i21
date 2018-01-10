﻿PRINT N'BEGIN - Migration for Bundle Type Items'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tmptblICItem' )
BEGIN
	EXEC('
			UPDATE [dbo].[tblICItem] SET [strBundleType] = N''Bundle''
			FROM [dbo].[tblICItem] IC
			INNER JOIN [tmptblICItem] tmpIC ON [IC].[intItemId] = [tmpIC].[intItemId]
			WHERE [IC].[strType] = N''Bundle'' AND [tmpIC].[ysnIsBasket] != 1;

			UPDATE [dbo].[tblICItem] SET [strBundleType] = N''Basket''
			FROM [dbo].[tblICItem] IC
			INNER JOIN [tmptblICItem] tmpIC ON [IC].[intItemId] = [tmpIC].[intItemId]
			WHERE [IC].[strType] = N''Bundle'' AND [tmpIC].[ysnIsBasket] = 1;

			DROP TABLE tmptblICItem
		')
END

IF EXISTS(SELECT  TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICItem' AND [COLUMN_NAME] = N'strBundleType')
BEGIN
	EXEC('
		UPDATE [dbo].[tblICItem] SET [strType] = N''Inventory''
		WHERE [strBundleType] = N''Bundle'' OR [strBundleType] = N''Basket'';
	')
END
GO
PRINT N'END - Migration for Bundle Type Items'