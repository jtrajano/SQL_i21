PRINT N'BEGIN - Clean Short and Long UPC for tblICItemUOM'
GO
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strUpcCode')
	BEGIN
		UPDATE tblICItemUOM set strUpcCode = NULL 
		WHERE strUpcCode = '' OR strUpcCode = '0' OR
			strUpcCode IN (SELECT strUpcCode FROM tblICItemUOM GROUP BY strUpcCode HAVING (COUNT(strUpcCode) > 1))
	END
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICItemUOM' AND [COLUMN_NAME] = 'strLongUPCCode')
	BEGIN
		UPDATE tblICItemUOM set strLongUPCCode = NULL 
		WHERE strLongUPCCode = '' OR strLongUPCCode = '0' OR 
			strLongUPCCode IN (SELECT strLongUPCCode FROM tblICItemUOM GROUP BY strLongUPCCode HAVING (COUNT(strLongUPCCode) > 1))
	END
END
GO
PRINT N'END - Clean Short and Long UPC for tblICItemUOM'