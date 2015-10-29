CREATE TABLE [dbo].[tblQMCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMCompanyPreference_intConcurrencyId] DEFAULT 0,
    [intNumberofDecimalPlaces] INT NOT NULL,
    CONSTRAINT [PK_tblQMCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId])
)
