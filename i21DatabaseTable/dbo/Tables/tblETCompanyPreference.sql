CREATE TABLE [dbo].[tblETCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strXMLPath] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL DEFAULT '', 
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	[strBasePath] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strExportPath] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strUploadPath] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strArchivePath] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL, 
    [strIntegration] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Energy Trac',

)
