IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemUOM]') AND type in (N'U')) 
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.indexes WHERE name = 'AK_tblICItemUOM_strUpcCode')
	BEGIN
		EXEC('DROP INDEX AK_tblICItemUOM_strUpcCode ON tblICItemUOM')
	END

	IF EXISTS (SELECT TOP 1 1 FROM sys.indexes WHERE name = 'AK_tblICItemUOM_strLongUPCCode')
	BEGIN
		EXEC('DROP INDEX AK_tblICItemUOM_strLongUPCCode ON tblICItemUOM')
	END
END
