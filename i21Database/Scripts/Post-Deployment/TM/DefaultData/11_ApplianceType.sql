GO
	PRINT N'BEGIN INSERT DEFAULT TM Appliance TYPE '
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMApplianceType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMApplianceType WHERE strApplianceType COLLATE Latin1_General_CI_AS = 'Furnace') INSERT INTO tblTMApplianceType (strApplianceType,ysnDefault) VALUES ('Furnace', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMApplianceType WHERE strApplianceType COLLATE Latin1_General_CI_AS = 'Stove') INSERT INTO tblTMApplianceType (strApplianceType,ysnDefault) VALUES ('Stove', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMApplianceType WHERE strApplianceType COLLATE Latin1_General_CI_AS = 'Hot Water Heater') INSERT INTO tblTMApplianceType (strApplianceType,ysnDefault) VALUES ('Hot Water Heater', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMApplianceType WHERE strApplianceType COLLATE Latin1_General_CI_AS = 'Dryer') INSERT INTO tblTMApplianceType (strApplianceType,ysnDefault) VALUES ('Dryer', 1)

	UPDATE tblTMApplianceType
	SET ysnDefault = 1
	WHERE strApplianceType COLLATE Latin1_General_CI_AS  IN (
		'Furnace'
		,'Stove'
		,'Hot Water Heater'
		,'Dryer'
	)
END

GO
	PRINT N'END INSERT DEFAULT TM Appliance TYPE '
GO