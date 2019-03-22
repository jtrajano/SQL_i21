GO
	PRINT N'BEGIN INSERT DEFAULT TM WORK STATUS TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkStatusType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkStatusType WHERE strWorkStatus = 'Open' AND ysnDefault = 1) INSERT INTO tblTMWorkStatusType (strWorkStatus,ysnDefault) VALUES ('Open', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkStatusType WHERE strWorkStatus = 'Create Pending' AND ysnDefault = 1) INSERT INTO tblTMWorkStatusType (strWorkStatus,ysnDefault) VALUES ('Create Pending', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkStatusType WHERE strWorkStatus = 'Waiting for Parts' AND ysnDefault = 1) INSERT INTO tblTMWorkStatusType (strWorkStatus,ysnDefault) VALUES ('Waiting for Parts', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMWorkStatusType WHERE strWorkStatus = 'Closed' AND ysnDefault = 1) INSERT INTO tblTMWorkStatusType (strWorkStatus,ysnDefault) VALUES ('Closed', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM WORK STATUS TYPE'
GO