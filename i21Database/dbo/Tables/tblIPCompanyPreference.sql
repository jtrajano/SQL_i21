CREATE TABLE [dbo].[tblIPCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[strCommonDataFolderPath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblIPCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
