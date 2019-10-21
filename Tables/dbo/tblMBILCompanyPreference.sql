CREATE TABLE [dbo].[tblMBILCompanyPreference]
(
	[intCompanyPreferenceId] INT IDENTITY NOT NULL , 
    [ysnShowLogo] BIT NULL DEFAULT ((0)), 
    [intCompanyContact] INT NULL, 
    [strCompanyName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDefaultCustomerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDefaultSiteNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblMBILCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId])
)
