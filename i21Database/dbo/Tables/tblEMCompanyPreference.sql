CREATE TABLE [dbo].[tblEMCompanyPreference]
(
	[intCompanyPreferenceId]						INT NOT NULL PRIMARY KEY IDENTITY,
	[ysnShowInternationalInformation]				BIT NULL,
	[intConcurrencyId]								INT NOT NULL DEFAULT 1
)
