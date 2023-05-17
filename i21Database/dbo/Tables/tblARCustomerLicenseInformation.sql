﻿CREATE TABLE [dbo].[tblARCustomerLicenseInformation]
(
	[intCustomerLicenseInformationId]	INT NOT NULL IDENTITY(1,1),
	[strVersion]						NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[strUniqueId]						NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityCustomerId]				INT NOT NULL,
	[strCompanyId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intNumberOfUser]					INT NOT NULL,
	[intNumberOfAdmin]					INT NOT NULL DEFAULT(1),
	[intMaxStores]						INT NOT NULL DEFAULT 0,
	[intMaxConsignmentStores]			INT NOT NULL DEFAULT 0,
	[strDescription]					NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strURL]							NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[ysnExternalAccess]					BIT NOT NULL DEFAULT 0,
	[strType]							NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
	[intNumberOfSite]					INT NOT NULL,
	[dtmDateIssued]						DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmDateExpiration]					DATETIME NOT NULL DEFAULT(GETDATE()),
	[dtmSupportExpiration]				DATETIME NOT NULL DEFAULT(GETDATE()),
	[strLicenseKey]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnNew]							BIT NOT NULL DEFAULT 0,
	[intCompanyId]						INT NULL,
	[intPowerBIRefreshes]				INT NULL,
    [intConcurrencyId]					INT CONSTRAINT [DF_tblARCustomerLicenseInformation_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblARCustomerLicenseInformation] PRIMARY KEY CLUSTERED ([intCustomerLicenseInformationId] ASC),
	CONSTRAINT [FK_tblARCustomerLicenseInformation_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
)
