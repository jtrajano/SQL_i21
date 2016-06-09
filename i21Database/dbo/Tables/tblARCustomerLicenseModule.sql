CREATE TABLE [dbo].[tblARCustomerLicenseModule]
(
	[intCustomerLicenseModuleId]			INT NOT NULL IDENTITY(1,1),
	[intCustomerLicenseInformationId]		INT NOT NULL,
	[intModuleId]							INT NOT NULL,
	[strModuleName]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnEnabled]							BIT NOT NULL DEFAULT 0, 	
    [intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomerLicenseModule_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [PK_tblARCustomerLicenseModule] PRIMARY KEY CLUSTERED ([intCustomerLicenseModuleId] ASC),
	CONSTRAINT [FK_tblARCustomerLicenseModule_tblARCustomerLicenseInformation] FOREIGN KEY ([intCustomerLicenseInformationId]) REFERENCES [dbo].[tblARCustomerLicenseInformation] ([intCustomerLicenseInformationId]) ON DELETE CASCADE,	
	CONSTRAINT [UK_tblARCustomerLicenseModule_strModuleName_intCustomerLicenseInformationId] UNIQUE NONCLUSTERED ([strModuleName] ASC, [intCustomerLicenseInformationId] ASC), 
    CONSTRAINT [FK_tblARCustomerLicenseModule_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [tblSMModule]([intModuleId])	
)
