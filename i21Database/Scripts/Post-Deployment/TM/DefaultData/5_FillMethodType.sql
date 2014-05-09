GO
	PRINT N'BEGIN INSERT DEFAULT TM FILL METHOD TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMFillMethod WHERE strFillMethod = 'Julian Calendar' AND ysnDefault = 1) INSERT INTO tblTMFillMethod (strFillMethod,ysnDefault) VALUES ('Julian Calendar',1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMFillMethod WHERE strFillMethod = 'Will Call' AND ysnDefault = 1) INSERT INTO tblTMFillMethod (strFillMethod,ysnDefault) VALUES ('Will Call',1)
END

GO
	PRINT N'END INSERT DEFAULT TM FILL METHOD TYPE'
GO