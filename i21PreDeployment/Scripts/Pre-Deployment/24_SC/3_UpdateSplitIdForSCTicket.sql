PRINT N'***** BEGIN UPDATE Update split that does not exist in the entity split table *****'
GO


IF OBJECT_ID('FK_tblSCTicket_tblEMEntitySplit_intSplitId') IS NULL
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplit' and [COLUMN_NAME] = 'intSplitId')
		 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicket' and [COLUMN_NAME] = 'intSplitId')
		BEGIN
			PRINT 'Start - Update split that does not exist in the entity split table'
			EXEC('update tblSCTicket set intSplitId = null where intSplitId not in (select intSplitId from tblEMEntitySplit) ')
		END

	
	END



GO
PRINT N'***** END UPDATE Update split that does not exist in the entity split table*****'