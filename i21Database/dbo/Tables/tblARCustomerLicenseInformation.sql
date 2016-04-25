﻿CREATE TABLE [dbo].[tblARCustomerLicenseInformation]
(
	[intCustomerLicenseInformationId]	INT NOT NULL IDENTITY(1,1),
	[strUniqueId]						NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL ,
	[intEntityCustomerId]				INT NOT NULL,
	[strCompanyId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL ,
	[intNumberOfUser]					INT NOT NULL,
	[intNumberOfSite]					INT NOT NULL,
	[dtmDateIssued]						DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmDateExpiration]						DATETIME NOT NULL DEFAULT(GETDATE()),
	[strLicenseKey]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL ,
	
    [intConcurrencyId]					INT CONSTRAINT [DF_tblARCustomerLicenseInformation_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	
	CONSTRAINT [PK_tblARCustomerLicenseInformation] PRIMARY KEY CLUSTERED ([intCustomerLicenseInformationId] ASC),
	CONSTRAINT [FK_tblARCustomerLicenseInformation_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]) ON DELETE CASCADE,
)
