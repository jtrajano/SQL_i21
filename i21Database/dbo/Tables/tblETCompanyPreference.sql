CREATE TABLE [dbo].[tblETCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strXMLPath] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL DEFAULT '', 
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)