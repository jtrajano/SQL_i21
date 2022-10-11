CREATE TABLE [dbo].[tblSMLicenseSavedFeature]
(
	[intLicenseSavedFeatureId]			INT NOT NULL IDENTITY(1,1),
	[intCustomerLicenseInformationId]	INT NOT NULL,
	[strKey]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL,
	[strValue]							NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,

	[intConcurrencyId]					INT DEFAULT ((1)) NOT NULL,

	CONSTRAINT [PK_tblSMCustomerLicenceFeature] PRIMARY KEY CLUSTERED ([intLicenseSavedFeatureId] ASC),
	CONSTRAINT [FK_tblSMCustomerLicenceFeature_tblARCustomerLicenseInformation] FOREIGN KEY ([intCustomerLicenseInformationId]) REFERENCES [dbo].[tblARCustomerLicenseInformation] ([intCustomerLicenseInformationId]) ON DELETE CASCADE,
	CONSTRAINT [UC_tblSMLicenseSavedFeature] UNIQUE (strKey)
)
