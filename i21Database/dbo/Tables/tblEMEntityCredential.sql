﻿CREATE TABLE [dbo].[tblEMEntityCredential] (
    [intEntityCredentialId]				INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]						INT            NOT NULL,
    [strUserName]						NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPassword]						NVARCHAR(1000)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strAzureADUserName]                NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [strADUserName]                     NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [strApiKey]							NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [strApiSecret]						NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [ysnApiDisabled]					BIT NULL,
    [strTFASecretKey]					NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [strTFACurrentCode]					NVARCHAR(500)  COLLATE Latin1_General_CI_AS NULL,
    [strTFACodeNotifMedium]				NVARCHAR(50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnTFAEnabled]						BIT            DEFAULT ((0)) NULL,
    [ysnNotEncrypted]					BIT            DEFAULT ((1)) NOT NULL,
    [strEmail]							NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnEmailConfirmed]					BIT            DEFAULT ((1)) NOT NULL,
    [strPhone]							NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPhoneConfirmed]					BIT            DEFAULT ((1)) NOT NULL,
    [strSecurityStamp]					NVARCHAR(250)  COLLATE Latin1_General_CI_AS DEFAULT NEWID(),
    [ysnTwoFactorEnabled]				BIT            DEFAULT ((0)) NOT NULL,
    [dtmLockoutEndDateUtc]				DATETIMEOFFSET(7)       NULL,
    [ysnLockoutEnabled]					BIT            DEFAULT ((0)) NOT NULL,
    [intAccessFailedCount]				INT            DEFAULT ((0)) NOT NULL,
	[intGridLayoutConcurrencyId]		INT			   DEFAULT ((1)) NOT NULL,
	[intCompanyGridLayoutConcurrencyId]	INT			   DEFAULT ((1)) NOT NULL,
    [intConcurrencyId]					INT            DEFAULT ((1)) NOT NULL
    CONSTRAINT [PK_tblEMEntityCredential] PRIMARY KEY CLUSTERED ([intEntityCredentialId] ASC),
    CONSTRAINT [FK_tblEMEntityCredential_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [AK_tblEMEntityCredential_strUserName] UNIQUE NONCLUSTERED ([strUserName] ASC)
);




