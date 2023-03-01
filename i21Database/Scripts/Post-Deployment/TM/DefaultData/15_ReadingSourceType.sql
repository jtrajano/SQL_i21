GO
	PRINT N'BEGIN INSERT DEFAULT TM Reading Source Type'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMReadingSourceType]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMReadingSourceType WHERE strReadingSourceType COLLATE Latin1_General_CI_AS = 'Tank Monitor') INSERT INTO tblTMReadingSourceType (strReadingSourceType,ysnDefault) VALUES ('Tank Monitor', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMReadingSourceType WHERE strReadingSourceType COLLATE Latin1_General_CI_AS = 'POS') INSERT INTO tblTMReadingSourceType (strReadingSourceType,ysnDefault) VALUES ('POS', 1)
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].tblTMReadingSourceType WHERE strReadingSourceType COLLATE Latin1_General_CI_AS = 'User') INSERT INTO tblTMReadingSourceType (strReadingSourceType,ysnDefault) VALUES ('User', 1)

	UPDATE tblTMReadingSourceType
	SET ysnDefault = 1
	WHERE strReadingSourceType COLLATE Latin1_General_CI_AS  IN (
		'Tank Monitor'
		,'POS'
		,'User'
	)
END

GO
	print N'END INSERT DEFAULT TM Reading Source Type'
GO