CREATE TABLE [dbo].[tblSMLicenseModule]
(
	[intLicenseModuleId]	INT NOT NULL IDENTITY(1,1),
	[intLicenseId]			INT NOT NULL,
	[strModuleName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]		INT CONSTRAINT [DF_tblSMLicenseModule_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [PK_tblSMLicenseModule] PRIMARY KEY CLUSTERED ([intLicenseModuleId] ASC),
	CONSTRAINT [FK_tblSMLicenseModule_tblSMLicense] FOREIGN KEY ([intLicenseId]) REFERENCES [dbo].[tblSMLicense] ([intLicenseId]) ON DELETE CASCADE
)