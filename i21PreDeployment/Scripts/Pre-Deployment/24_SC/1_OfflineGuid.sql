PRINT N'***** BEGIN INSERT OFFLINE GUID (SCALE) *****'
GO
IF OBJECT_ID('dbo.[UK_tblSCTicket_strOfflineGuid]') IS NULL
BEGIN
	UPDATE [dbo].[tblSCTicket] SET strOfflineGuid = NEWID()
END
GO
PRINT N'***** END INSERT OFFLINE GUID (SCALE)*****'