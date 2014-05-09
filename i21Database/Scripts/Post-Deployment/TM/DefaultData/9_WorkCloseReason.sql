GO
	PRINT N'BEGIN INSERT DEFAULT TM WORK CLOSE REASON'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkCloseReason]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkCloseReason WHERE strCloseReason = 'CUSTOMER CANCELED' AND ysnDefault = 1) INSERT INTO tblTMWorkCloseReason (strCloseReason,ysnDefault) VALUES ('CUSTOMER CANCELED', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkCloseReason WHERE strCloseReason = 'WORK COMPLETED' AND ysnDefault = 1) INSERT INTO tblTMWorkCloseReason (strCloseReason,ysnDefault) VALUES ('WORK COMPLETED', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM WORK CLOSE REASON'
GO