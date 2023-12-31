﻿CREATE TABLE [dbo].[tblEMEntityEFTInformation] (
    [intEntityEFTInfoId]       INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]              INT            NOT NULL,
    [intBankId]                INT            NOT NULL,
    [strBankName]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountType]           NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountClassification] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [dtmEffectiveDate]         DATETIME       NULL,
    [ysnPrintNotifications]    BIT            NULL,
    [ysnActive]                BIT            NULL,
    [strPullARBy]              NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPullTaxSeparately]     BIT            NULL,
    [ysnRefundBudgetCredits]   BIT            NULL,
    [ysnPrenoteSent]           BIT            NULL,
	[strDistributionType]	   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[dblAmount]				   NUMERIC(18, 6) NULL,
	[intOrder]				   INT			  NULL, 
	[strEFTType]				NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]         INT            NOT NULL,
    CONSTRAINT [PK_tblEMEntityEFTInformation] PRIMARY KEY CLUSTERED ([intEntityEFTInfoId] ASC)
);

