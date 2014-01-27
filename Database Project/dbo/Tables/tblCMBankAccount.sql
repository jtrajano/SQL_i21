CREATE TABLE [dbo].[tblCMBankAccount] (
    [intBankAccountID]                 INT            IDENTITY (1, 1) NOT NULL,
    [strBankName]                      NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnActive]                        BIT            NOT NULL,
    [intGLAccountID]                   INT            NOT NULL,
    [intCurrencyID]                    INT            NULL,
    [intBankAccountType]               INT            NOT NULL,
    [strContact]                       NVARCHAR (150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strBankAccountNo]                 NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strRTN]                           NVARCHAR (12)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]                       NVARCHAR (65)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strZipCode]                       NVARCHAR (42)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]                          NVARCHAR (85)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strState]                         NVARCHAR (60)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry]                       NVARCHAR (75)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhone]                         NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strFax]                           NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite]                       NVARCHAR (125) COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail]                         NVARCHAR (225) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCheckStartingNo]               INT            NOT NULL,
    [intCheckEndingNo]                 INT            NOT NULL,
    [intCheckNextNo]                   INT            NOT NULL,
    [ysnCheckEnableMICRPrint]          BIT            NOT NULL,
    [ysnCheckDefaultToBePrinted]       BIT            NOT NULL,
    [intBackupCheckStartingNo]         INT            NOT NULL,
    [intBackupCheckEndingNo]           INT            NOT NULL,
    [intEFTNextNo]                     INT            NOT NULL,
    [intEFTBankFileFormatID]           INT            NULL,
    [strEFTCompanyID]                  NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strEFTBankName]                   NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMICRDescription]               NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL,
    [intMICRBankAccountSpacesCount]    INT            NOT NULL,
    [intMICRBankAccountSpacesPosition] INT            NOT NULL,
    [intMICRCheckNoSpacesCount]        INT            NOT NULL,
    [intMICRCheckNoSpacesPosition]     INT            NOT NULL,
    [intMICRCheckNoLength]             INT            NOT NULL,
    [intMICRCheckNoPosition]           INT            NOT NULL,
    [strMICRLeftSymbol]                NVARCHAR (1)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strMICRRightSymbol]               NVARCHAR (1)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID]                 INT            NULL,
    [dtmCreated]                       DATETIME       NULL,
    [intLastModifiedUserID]            INT            NULL,
    [dtmLastModified]                  DATETIME       NULL,
    [strCbkNo]                         NVARCHAR (2)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID]                 INT            NULL,
    CONSTRAINT [PK_tblCMBankAccount] PRIMARY KEY CLUSTERED ([intBankAccountID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblSMCurrency] FOREIGN KEY ([intCurrencyID]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount] FOREIGN KEY ([intEFTBankFileFormatID]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatID]),
    CONSTRAINT [FK_tblCMBanktblCMBankAccount] FOREIGN KEY ([strBankName]) REFERENCES [dbo].[tblCMBank] ([strBankName]),
    CONSTRAINT [FK_tblGLAccounttblCMBankAccount] FOREIGN KEY ([intGLAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    UNIQUE NONCLUSTERED ([strCbkNo] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankFileFormattblCMBankAccount]
    ON [dbo].[tblCMBankAccount]([intEFTBankFileFormatID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBanktblCMBankAccount]
    ON [dbo].[tblCMBankAccount]([strBankName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblSMCurrency]
    ON [dbo].[tblCMBankAccount]([intCurrencyID] ASC);

