CREATE TABLE [dbo].[tblARCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL PRIMARY KEY, 
    [intARAccountId] INT NULL, 
    [intDiscountAccountId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)
