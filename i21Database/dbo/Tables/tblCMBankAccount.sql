CREATE TABLE [dbo].[tblCMBankAccount] (
    [intBankAccountId]                 INT            IDENTITY (1, 1) NOT NULL,
    [intBankId]                        INT            NOT NULL,
    [ysnActive]                        BIT            DEFAULT 1 NOT NULL,
    [intGLAccountId]                   INT            NOT NULL,
    [intCurrencyId]                    INT            NULL,
    [intBankAccountType]               INT            DEFAULT 1 NOT NULL,
    [strContact]                       NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strBankAccountNo]                 NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strRTN]                           NVARCHAR (12)  COLLATE Latin1_General_CI_AS NULL,
    [strAddress]                       NVARCHAR (65)  COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]                       NVARCHAR (42)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]                          NVARCHAR (85)  COLLATE Latin1_General_CI_AS NULL,
    [strState]                         NVARCHAR (60)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]                       NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]                         NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]                           NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strWebsite]                       NVARCHAR (125) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]                         NVARCHAR (225) COLLATE Latin1_General_CI_AS NULL,
    [intCheckStartingNo]               INT            DEFAULT 0 NOT NULL,
    [intCheckEndingNo]                 INT            DEFAULT 0 NOT NULL,
    [intCheckNextNo]                   INT            DEFAULT 0 NOT NULL,
    [ysnCheckEnableMICRPrint]          BIT            DEFAULT 1 NOT NULL,
    [ysnCheckDefaultToBePrinted]       BIT            DEFAULT 1 NOT NULL,
    [intBackupCheckStartingNo]         INT            DEFAULT 0 NOT NULL,
    [intBackupCheckEndingNo]           INT            DEFAULT 0 NOT NULL,
    [intEFTNextNo]                     INT            DEFAULT 0 NOT NULL,
    [intEFTBankFileFormatId]           INT            NULL,
	[intBankStatementImportId]		   INT            NULL,
    [strEFTCompanyId]                  NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strEFTBankName]                   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strMICRDescription]               NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [intMICRBankAccountSpacesCount]    INT            DEFAULT 0 NOT NULL,
    [intMICRBankAccountSpacesPosition] INT            DEFAULT 1 NOT NULL,
    [intMICRCheckNoSpacesCount]        INT            DEFAULT 0 NOT NULL,
    [intMICRCheckNoSpacesPosition]     INT            DEFAULT 1 NOT NULL,
    [intMICRCheckNoLength]             INT            DEFAULT 6 NOT NULL,
    [intMICRCheckNoPosition]           INT            DEFAULT 1 NOT NULL,
    [strMICRLeftSymbol]                NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [strMICRRightSymbol]               NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]                 INT            NULL,
    [dtmCreated]                       DATETIME       NULL,
    [intLastModifiedUserId]            INT            NULL,
    [dtmLastModified]                  DATETIME       NULL,
    [strCbkNo]                         NVARCHAR (2)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]                 INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankAccount] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyId]),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount_EFT] FOREIGN KEY ([intEFTBankFileFormatId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]),
	CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount_BankStatement] FOREIGN KEY ([intBankStatementImportId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]),
    CONSTRAINT [FK_tblCMBanktblCMBankAccount] FOREIGN KEY ([intBankId]) REFERENCES [dbo].[tblCMBank] ([intBankId]),
    CONSTRAINT [FK_tblGLAccounttblCMBankAccount] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    UNIQUE NONCLUSTERED ([strCbkNo] ASC)
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
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_strCbkNo]
    ON [dbo].[tblCMBankAccount]([strCbkNo] ASC);

