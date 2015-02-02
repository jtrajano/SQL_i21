GO
	PRINT 'BEGIN FRD UPDATE FIELD TYPE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strSegmentUsed' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign') AND max_length != -1) 
BEGIN
    ALTER TABLE [dbo].[tblFRColumnDesign]
    ALTER COLUMN strSegmentUsed NVARCHAR(MAX) NULL
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAction' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesignCalculation') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRColumnDesignCalculation]
    ALTER COLUMN strAction NVARCHAR(50)

	UPDATE tblFRColumnDesignCalculation SET strAction = RTRIM(LTRIM(strAction))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontName' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRRowDesign]
    ALTER COLUMN strFontName NVARCHAR(50)

	UPDATE tblFRRowDesign SET strFontName = RTRIM(LTRIM(strFontName))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontStyle' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRRowDesign]
    ALTER COLUMN strFontStyle NVARCHAR(50)

	UPDATE tblFRRowDesign SET strFontStyle = RTRIM(LTRIM(strFontStyle))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontColor' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRRowDesign]
    ALTER COLUMN strFontColor NVARCHAR(50)

	UPDATE tblFRRowDesign SET strFontColor = RTRIM(LTRIM(strFontColor))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strAction' AND OBJECT_ID = OBJECT_ID(N'tblFRRowDesignCalculation') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRRowDesignCalculation]
    ALTER COLUMN strAction NVARCHAR(50)

	UPDATE tblFRRowDesignCalculation SET strAction = RTRIM(LTRIM(strAction))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontName' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRHeaderDesign]
    ALTER COLUMN strFontName NVARCHAR(50)

	UPDATE tblFRHeaderDesign SET strFontName = RTRIM(LTRIM(strFontName))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontStyle' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRHeaderDesign]
    ALTER COLUMN strFontStyle NVARCHAR(50)

	UPDATE tblFRHeaderDesign SET strFontStyle = RTRIM(LTRIM(strFontStyle))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFontColor' AND OBJECT_ID = OBJECT_ID(N'tblFRHeaderDesign') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRHeaderDesign]
    ALTER COLUMN strFontColor NVARCHAR(50)

	UPDATE tblFRHeaderDesign SET strFontColor = RTRIM(LTRIM(strFontColor))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strOrientation' AND OBJECT_ID = OBJECT_ID(N'tblFRReport') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRReport]
    ALTER COLUMN strOrientation NVARCHAR(50)

	UPDATE tblFRReport SET strOrientation = RTRIM(LTRIM(strOrientation))
END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strColumnType' AND OBJECT_ID = OBJECT_ID(N'tblFRMappingDetail') AND system_type_id = 239) 
BEGIN
    ALTER TABLE [dbo].[tblFRMappingDetail]
    ALTER COLUMN strColumnType NVARCHAR(50)

	UPDATE tblFRMappingDetail SET strColumnType = RTRIM(LTRIM(strColumnType))
END
GO

GO
	PRINT 'END FRD UPDATE FIELD TYPE'
GO