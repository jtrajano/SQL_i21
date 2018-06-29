GO
	PRINT N'BEGIN INSERT DEFAULT TM DEVICE TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDeviceType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMDeviceType WHERE strDeviceType = 'Tank' AND ysnDefault = 1) INSERT INTO tblTMDeviceType (strDeviceType,ysnDefault) VALUES ('Tank', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMDeviceType WHERE strDeviceType = 'Flow Meter' AND ysnDefault = 1) INSERT INTO tblTMDeviceType (strDeviceType,ysnDefault) VALUES ('Flow Meter', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMDeviceType WHERE strDeviceType = 'Regulator' AND ysnDefault = 1) INSERT INTO tblTMDeviceType (strDeviceType,ysnDefault) VALUES ('Regulator', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMDeviceType WHERE strDeviceType = 'Tank Monitor' AND ysnDefault = 1) INSERT INTO tblTMDeviceType (strDeviceType,ysnDefault) VALUES ('Tank Monitor', 1)
END
GO
	PRINT N'END INSERT DEFAULT TM DEVICE TYPE'
GO