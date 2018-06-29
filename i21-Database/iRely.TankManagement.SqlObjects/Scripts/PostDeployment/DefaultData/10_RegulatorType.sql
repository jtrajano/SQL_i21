GO
	PRINT N'BEGIN INSERT DEFAULT TM REGULATOR TYPE '
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMRegulatorType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'High Pressure' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('High Pressure', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'First Stage' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('First Stage', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'Second Stage' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('Second Stage', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'Integral Two-Stage' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('Integral Two-Stage', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'Adjustable High Pressure' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('Adjustable High Pressure', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMRegulatorType WHERE strRegulatorType = 'Automatic Changeover' AND ysnDefault = 1) INSERT INTO tblTMRegulatorType (strRegulatorType,ysnDefault) VALUES ('Automatic Changeover', 1)
END

GO
	PRINT N'END INSERT DEFAULT TM REGULATOR TYPE '
GO