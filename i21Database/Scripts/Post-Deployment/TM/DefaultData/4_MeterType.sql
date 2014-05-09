GO
	PRINT N'BEGIN INSERT DEFAULT TM METER TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMMeterType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMMeterType WHERE strMeterType = '11" Water Column Cu Meter' AND ysnDefault = 1) INSERT INTO tblTMMeterType (strMeterType,dblConversionFactor,ysnDefault) VALUES ('11" Water Column Cu Meter',0.97639230,1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMMeterType WHERE strMeterType = '11" Water Column Gallon' AND ysnDefault = 1) INSERT INTO tblTMMeterType (strMeterType,dblConversionFactor,ysnDefault) VALUES ('11" Water Column Gallon',1.00659000,1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMMeterType WHERE strMeterType = '2 lb Cu Foot x 100' AND ysnDefault = 1) INSERT INTO tblTMMeterType (strMeterType,dblConversionFactor,ysnDefault) VALUES ('2 lb Cu Foot x 100',3.06040132,1)
END

GO
	PRINT N'END INSERT DEFAULT TM METER TYPE'
GO