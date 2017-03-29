CREATE TABLE [dbo].[tblARCustomerApplicatorLicense]
(
	[intCustomerApplicatorLicenseId]		INT IDENTITY(1,1) NOT NULL, 
    [intEntityCustomerId]					INT NOT NULL,
	[strLicenseNo]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpirationDate]						DATETIME NULL, 
	[ysnCustomerApplicator]					BIT, 
	[strComment]							NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]						INT             CONSTRAINT [DF_tblARCustomerApplicatorLicense_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerApplicatorLicense] PRIMARY KEY CLUSTERED ([intCustomerApplicatorLicenseId] ASC),
    CONSTRAINT [FK_tblARCustomerApplicatorLicense_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
)
