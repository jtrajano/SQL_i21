CREATE TABLE [dbo].[tblIPCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[strCommonDataFolderPath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	strCustomerCode nvarchar(50),
	ysnReplicationEnabled BIT CONSTRAINT [DF_ttblIPCompanyPreference_ysnReplicationEnabled] DEFAULT 1, 
    CONSTRAINT [PK_tblIPCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
