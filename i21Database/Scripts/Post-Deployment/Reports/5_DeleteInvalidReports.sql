PRINT('Clean Invalid Archived Reports - Start')
IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSRARCHIVE') 
BEGIN
	CREATE TABLE [dbo].[tblSRArchiveTemp](
	[intArchiveId] [int] IDENTITY(1,1) NOT NULL,
	[dtmDateTime] [datetime] NOT NULL,
	[intUserId] [int] NOT NULL,
	[strUserName] [nvarchar](max) NULL,
	[strDocumentKey] [nvarchar](max) NULL,
	[strName] [nvarchar](max) NULL,
	[strDisplayName] [nvarchar](max) NULL,
	[strDescription] [nvarchar](max) NULL,
	[strModule] [nvarchar](100) NULL,
	[blbReport] [varbinary](max) NULL,
	[ysnIsActive] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL)
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSRARCHIVE' AND [COLUMN_NAME] = 'strModule') 
BEGIN
	EXEC ('INSERT INTO tblSRArchiveTemp SELECT dtmDateTime, intUserId, strUserName, strDocumentKey, strName, strDisplayName, strDescription, strModule, blbReport, ysnIsActive, intConcurrencyId FROM tblSRArchive WHERE strModule = '''' OR strModule IS NULL')
	EXEC ('DELETE FROM tblSRArchive WHERE strModule = '''' OR strModule IS NULL')
END
GO
PRINT('Clean Invalid Archived Reports - End')