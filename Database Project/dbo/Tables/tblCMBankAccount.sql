CREATE TABLE [dbo].[tblCMBankAccount] (
    [intBankAccountId]                 INT            IDENTITY (1, 1) NOT NULL,
	[intBankId]						   INT			  NOT NULL,
    [ysnActive]                        BIT            NOT NULL DEFAULT 1,
    [intGLAccountId]                   INT            NOT NULL,
    [intCurrencyId]                    INT            NULL,
    [intBankAccountType]               INT            NOT NULL DEFAULT 1,
    [strContact]                       NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strBankAccountNo]                 NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL ,
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
    [intCheckStartingNo]               INT            NOT NULL DEFAULT 0,
    [intCheckEndingNo]                 INT            NOT NULL DEFAULT 0,
    [intCheckNextNo]                   INT            NOT NULL DEFAULT 0,
    [ysnCheckEnableMICRPrint]          BIT            NOT NULL DEFAULT 1,
    [ysnCheckDefaultToBePrinted]       BIT            NOT NULL DEFAULT 1,
    [intBackupCheckStartingNo]         INT            NOT NULL DEFAULT 0,
    [intBackupCheckEndingNo]           INT            NOT NULL DEFAULT 0,
    [intEFTNextNo]                     INT            NOT NULL DEFAULT 0,
    [intEFTBankFileFormatId]           INT            NULL,
    [strEFTCompanyId]                  NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strEFTBankName]                   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strMICRDescription]               NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [intMICRBankAccountSpacesCount]    INT            NOT NULL DEFAULT 0,
    [intMICRBankAccountSpacesPosition] INT            NOT NULL DEFAULT 1,
    [intMICRCheckNoSpacesCount]        INT            NOT NULL DEFAULT 0,
    [intMICRCheckNoSpacesPosition]     INT            NOT NULL DEFAULT 1,
    [intMICRCheckNoLength]             INT            NOT NULL DEFAULT 6,
    [intMICRCheckNoPosition]           INT            NOT NULL DEFAULT 1,
    [strMICRLeftSymbol]                NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [strMICRRightSymbol]               NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]                 INT            NULL,
    [dtmCreated]                       DATETIME       NULL,
    [intLastModifiedUserId]            INT            NULL,
    [dtmLastModified]                  DATETIME       NULL,
    [strCbkNo]                         NVARCHAR (2)   COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [intConcurrencyId]                 INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankAccount] PRIMARY KEY CLUSTERED ([intBankAccountId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount] FOREIGN KEY ([intEFTBankFileFormatId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]),
    CONSTRAINT [FK_tblCMBanktblCMBankAccount] FOREIGN KEY ([intBankId]) REFERENCES [dbo].[tblCMBank] ([intBankId]),
    CONSTRAINT [FK_tblGLAccounttblCMBankAccount] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountID])
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intEFTBankFileFormatId]
    ON [dbo].[tblCMBankAccount]([intEFTBankFileFormatId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intBankId]
    ON [dbo].[tblCMBankAccount]([intBankId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intCurrencyId]
    ON [dbo].[tblCMBankAccount]([intCurrencyId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_intGLAccountId]
    ON [dbo].[tblCMBankAccount]([intGLAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankAccount_strCbkNo]
    ON [dbo].[tblCMBankAccount]([strCbkNo] ASC);


GO

