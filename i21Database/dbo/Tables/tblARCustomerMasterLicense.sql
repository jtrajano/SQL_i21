CREATE TABLE [dbo].[tblARCustomerMasterLicense]
(
	[intCustomerMasterLicenseId]	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityCustomerId]			INT NOT NULL,
	[intLicenseTypeId]				INT NOT NULL,
	[dtmBeginDate]					DATETIME NULL,
	[dtmEndDate]					DATETIME NULL,
	[strComment]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnAcvite]						BIT DEFAULT(0),
	[intCompanyId]					INT NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT(0),
    CONSTRAINT [FK_tblARCustomerMasterLicense_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARCustomerMasterLicense_tblSMLicenseType] FOREIGN KEY ([intLicenseTypeId]) REFERENCES [dbo].[tblSMLicenseType] ([intLicenseTypeId]),
	CONSTRAINT [UNQ_ARMasterLicense] UNIQUE (intEntityCustomerId,intLicenseTypeId)
)
