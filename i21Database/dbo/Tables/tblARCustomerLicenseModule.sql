CREATE TABLE [dbo].[tblARCustomerLicenseModule]
(
	[intCustomerLicenseModuleId]			INT NOT NULL,
	[intCustomerLicenseInformationId]		INT NOT NULL,
	[strModuleName]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL ,

    [intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomerLicenseModule_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [PK_tblARCustomerLicenseModule] PRIMARY KEY CLUSTERED ([intCustomerLicenseModuleId] ASC),
	CONSTRAINT [FK_tblARCustomerLicenseModule_tblARCustomerLicenseInformation] FOREIGN KEY ([intCustomerLicenseInformationId]) REFERENCES [dbo].[tblARCustomerLicenseInformation] ([intCustomerLicenseInformationId]) ON DELETE CASCADE,
)
