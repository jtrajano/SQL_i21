PRINT N'***** BEGIN UPDATE Tickets with Zero intSplitId *****'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicket')
BEGIN
    UPDATE tblSCTicket
    SET intSplitId = NULL
    WHERE intSplitId = 0
END

GO
PRINT N'***** END UPDATE Tickets with Zero intSplitId*****'