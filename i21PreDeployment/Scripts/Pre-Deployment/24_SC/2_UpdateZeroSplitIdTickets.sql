PRINT N'***** BEGIN UPDATE Tickets with Zero intSplitId *****'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicket' AND [COLUMN_NAME] = 'intSplitId') 
and EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntitySplit'  AND [COLUMN_NAME] = 'intSplitId') 
BEGIN
    exec('UPDATE tblSCTicket
    SET intSplitId = NULL
    WHERE intSplitId is not null 
		and intSplitId not in (select intSplitId from tblEMEntitySplit)')
END

GO
PRINT N'***** END UPDATE Tickets with Zero intSplitId*****'