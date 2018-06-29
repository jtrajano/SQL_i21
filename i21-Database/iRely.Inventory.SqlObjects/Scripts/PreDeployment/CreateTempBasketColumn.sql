PRINT N'BEGIN - Add TEMP ysnIsBasket to tblICItem'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblICItem' AND [COLUMN_NAME] = N'ysnIsBasket')
BEGIN
	EXEC('
		IF EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strType = ''Bundle'' AND ysnIsBasket = 1)
		BEGIN
			IF EXISTS(SELECT 1 FROM sys.tables WHERE name = ''tmptblICItem'') DROP TABLE tmptblICItem

			CREATE TABLE tmptblICItem (
				[inttmptblICItemId] [INT] IDENTITY(1,1) NOT NULL,
				[intItemId] [INT] NULL,
				[ysnIsBasket] [BIT] NULL
			)

			INSERT INTO tmptblICItem(
				[intItemId],
				[ysnIsBasket]
			)
			SELECT intItemId,
					ysnIsBasket
			FROM tblICItem
			WHERE strType = ''Bundle''
		END
		')
END
PRINT N'END - Add TEMP ysnIsBasket to tblICItem'