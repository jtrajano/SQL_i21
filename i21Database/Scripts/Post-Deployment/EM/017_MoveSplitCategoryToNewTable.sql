
PRINT '*** Start Moving Split Category***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplitExceptionCategory' and [COLUMN_NAME] = 'intSplitId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplitExceptionCategory' and [COLUMN_NAME] = 'intCategoryId')
	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplit' and [COLUMN_NAME] = 'intCategoryId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplit' and [COLUMN_NAME] = 'intSplitId')

	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblICCategory' and [COLUMN_NAME] = 'intCategoryId')
	
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Moving Split Category')

BEGIN
	PRINT '*** EXECUTING  Moving Split Category***'
	Exec('
			insert into tblEMEntitySplitExceptionCategory(intSplitId, intCategoryId)
			select a.intSplitId, b.intCategoryId from tblEMEntitySplit a
				join tblICCategory b
					on a.intCategoryId = b.intCategoryId
				where a.intSplitId not in (select intSplitId from tblEMEntitySplitExceptionCategory)
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Moving Split Category', 1)

END
PRINT '*** End Moving Split Category***'



