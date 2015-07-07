CREATE TABLE [dbo].[tblICCompanyPreference]
(
	[intCompanyPreferenceId] INT IDENTITY, 
    [intInheritSetup] INT NULL DEFAULT ((1)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCompanyPreference] PRIMARY KEY ([intCompanyPreferenceId]) 
)
