﻿CREATE TABLE [dbo].[tblCMBankAccount] (
    [intBankAccountId]                 INT            IDENTITY (1, 1) NOT NULL,
    [intBankId]                        INT            NOT NULL,
    [ysnActive]                        BIT            DEFAULT 1 NOT NULL,
    [intGLAccountId]                   INT            NOT NULL,
    [intCurrencyId]                    INT            NULL,
    [intBankAccountTypeId]             INT            DEFAULT 1 NOT NULL,
    [intBrokerageAccountId]            INT            NULL,
    [strContact]                       NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
	[strBankAccountHolder]             NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strBankAccountNo]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strRTN]                           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAddress]                       NVARCHAR (65)  COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]                       NVARCHAR (42)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]                          NVARCHAR (85)  COLLATE Latin1_General_CI_AS NULL,
    [strState]                         NVARCHAR (60)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]                       NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]                         NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]                           NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strWebsite]                       NVARCHAR (125) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]                         NVARCHAR (225) COLLATE Latin1_General_CI_AS NULL,
	[strIBAN]                          NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[strSWIFT]                         NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
    [strBICCode]                       NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
	[strBranchCode]                    NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
    [intCheckStartingNo]               INT            DEFAULT 0 NOT NULL,
    [intCheckEndingNo]                 INT            DEFAULT 0 NOT NULL,
    [intCheckNextNo]                   INT            DEFAULT 0 NOT NULL,
	[intCheckNoLength]                 INT            DEFAULT 8 NOT NULL,
    [ysnCheckEnableMICRPrint]          BIT            DEFAULT 1 NOT NULL,
    [ysnCheckDefaultToBePrinted]       BIT            DEFAULT 1 NOT NULL,
    [intBackupCheckStartingNo]         INT            DEFAULT 0 NOT NULL,
    [intBackupCheckEndingNo]           INT            DEFAULT 0 NOT NULL,
    [intEFTNextNo]                     INT            DEFAULT 0 NOT NULL,
    [intEFTBankFileFormatId]           INT            NULL,
	[intPositivePayBankFileFormatId]   INT            NULL,
	[intBankStatementImportId]		   INT            NULL,
	[intEFTARFileFormatId]			   INT            NULL,
	[intEFTPRFileFormatId]             INT            NULL,
    [strEFTCompanyId]                  NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strEFTBankName]                   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strMICRDescription]               NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
	[strMICRBankAccountNo]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strMICRRoutingNo]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strMICRRoutingPrefix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRRoutingSuffix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRBankAccountPrefix]         NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRBankAccountSuffix]         NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [intMICRBankAccountSpacesCount]    INT            DEFAULT 0 NOT NULL,
    [intMICRBankAccountSpacesPosition] INT            DEFAULT 1 NOT NULL,
    [intMICRCheckNoSpacesCount]        INT            DEFAULT 0 NOT NULL,
    [intMICRCheckNoSpacesPosition]     INT            DEFAULT 1 NOT NULL,
    [intMICRCheckNoLength]             INT            DEFAULT 6 NOT NULL,
    [intMICRCheckNoPosition]           INT            DEFAULT 1 NOT NULL,
    [strMICRLeftSymbol]                NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [strMICRRightSymbol]               NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRFinancialInstitutionPrefix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRFinancialInstitution]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRFinancialInstitutionSuffix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[intMICRFinancialInstitutionSpacesCount]    INT            DEFAULT 0 NOT NULL,
    [intMICRFinancialInstitutionSpacesPosition] INT            DEFAULT 1 NOT NULL,
	[strMICRDesignationPrefix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRDesignation]             NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strMICRDesignationSuffix]             NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
	[intMICRDesignationSpacesCount]    INT            DEFAULT 0 NOT NULL,
    [intMICRDesignationSpacesPosition] INT            DEFAULT 1 NOT NULL,
	[strFractionalRoutingNumber]       NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
	[strUserDefineMessage]             NVARCHAR (60)  COLLATE Latin1_General_CI_AS NULL,
	[strSignatureLineCaption]          NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
	[ysnShowTwoSignatureLine]          BIT            NULL,
	[dblGreaterThanAmount]			   NUMERIC(18,6)  NULL,
	[ysnShowFirstSignature]            BIT            NULL,
	[dblFirstAmountIsOver]			   NUMERIC(18,6)  NULL,
	[intFirstUserId]                   INT            NULL,
	[intFirstSignatureId]              INT            NULL,
	[ysnShowSecondSignature]           BIT            NULL,
	[dblSecondAmountIsOver]			   NUMERIC(18,6)  NULL,
	[intSecondUserId]                  INT            NULL,
	[intSecondSignatureId]             INT            NULL,
    [intCreatedUserId]                 INT            NULL,
    [dtmCreated]                       DATETIME       NULL,
    [intLastModifiedUserId]            INT            NULL,
    [dtmLastModified]                  DATETIME       NULL,
	[ysnDelete]						   BIT            NULL,
	[dtmDateDeleted]				   DATETIME		  NULL,
    [strCbkNo]                         NVARCHAR (2)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]                 INT            DEFAULT 1 NOT NULL,
    [intPayToDown]                     INT            DEFAULT 0 NULL,
    [strACHClientId]                   NVARCHAR(30)   COLLATE Latin1_General_CI_AS NULL,
    [intResponsibleEntityId]           INT            NULL,
    [strPaymentInstructions]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCorrespondingBank]             NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL,
    --Advance Bank Recon fields
    [ysnABREnable]                     BIT            NULL,
    [intABRDaysNoRef]                  INT            NULL,
    --Advance Bank Recon fields
    CONSTRAINT [PK_tblCMBankAccount] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount_EFT] FOREIGN KEY ([intEFTBankFileFormatId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]),
	CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount_BankStatement] FOREIGN KEY ([intBankStatementImportId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]),
    CONSTRAINT [FK_tblCMBanktblCMBankAccount] FOREIGN KEY ([intBankId]) REFERENCES [dbo].[tblCMBank] ([intBankId]),
    CONSTRAINT [FK_tblGLAccounttblCMBankAccount] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblCMBankAccount_tblRKBrokerageAccount] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [dbo].[tblRKBrokerageAccount]([intBrokerageAccountId])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intBankId]
    ON [dbo].[tblCMBankAccount]([intBankId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intCurrencyId]
    ON [dbo].[tblCMBankAccount]([intCurrencyId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intEFTBankFileFormatId]
    ON [dbo].[tblCMBankAccount]([intEFTBankFileFormatId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intGLAccountId]
    ON [dbo].[tblCMBankAccount]([intGLAccountId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCMBankAccount_strCbkNo]
	ON tblCMBankAccount(strCbkNo)
WHERE strCbkNo IS NOT NULL AND strCbkNo <> '';

