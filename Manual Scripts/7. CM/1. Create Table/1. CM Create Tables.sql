
SET QUOTED_IDENTIFIER OFF;

GO
IF SCHEMA_ID(N'dbo') IS NULL EXECUTE(N'CREATE SCHEMA [dbo]');
GO

-- --------------------------------------------------
-- Dropping existing FOREIGN KEY constraints
-- --------------------------------------------------

IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMBankReconciliation]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankReconciliation] DROP CONSTRAINT [FK_tblCMBankAccounttblCMBankReconciliation];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMBankTransaction]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankTransaction] DROP CONSTRAINT [FK_tblCMBankAccounttblCMBankTransaction];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMBankTransfer_From]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankTransfer] DROP CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_From];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMBankTransfer_To]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankTransfer] DROP CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_To];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMCheckNumberAudit]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMCheckNumberAudit] DROP CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMCreditCardBatchEntry]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMCreditCardBatchEntry] DROP CONSTRAINT [FK_tblCMBankAccounttblCMCreditCardBatchEntry];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblCMEFTACHAudit]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMEFTACHAudit] DROP CONSTRAINT [FK_tblCMBankAccounttblCMEFTACHAudit];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankAccounttblSMCurrency]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankAccount] DROP CONSTRAINT [FK_tblCMBankAccounttblSMCurrency];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankFileFormattblCMBankAccount]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankAccount] DROP CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankFileFormattblCMBankFileFormatDetail]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankFileFormatDetail] DROP CONSTRAINT [FK_tblCMBankFileFormattblCMBankFileFormatDetail];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBanktblCMBankAccount]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankAccount] DROP CONSTRAINT [FK_tblCMBanktblCMBankAccount];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankTransactiontblCMBankTransactionDetail]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankTransactionDetail] DROP CONSTRAINT [FK_tblCMBankTransactiontblCMBankTransactionDetail];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMBankTransactiontblSMCurrency]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMBankTransaction] DROP CONSTRAINT [FK_tblCMBankTransactiontblSMCurrency];
GO
IF OBJECT_ID(N'[dbo].[FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail]', 'F') IS NOT NULL
    ALTER TABLE [dbo].[tblCMCreditCardBatchEntryDetail] DROP CONSTRAINT [FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail];
GO

-- --------------------------------------------------
-- Dropping existing tables
-- --------------------------------------------------

IF OBJECT_ID(N'[dbo].[tblCMBank]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBank];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankAccount]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankAccount];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankFileFormat]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankFileFormat];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankFileFormatDetail]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankFileFormatDetail];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankReconciliation]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankReconciliation];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankTransaction]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankTransaction];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankTransactionDetail]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankTransactionDetail];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankTransactionType]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankTransactionType];
GO
IF OBJECT_ID(N'[dbo].[tblCMBankTransfer]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMBankTransfer];
GO
IF OBJECT_ID(N'[dbo].[tblCMCheckNumberAudit]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMCheckNumberAudit];
GO
IF OBJECT_ID(N'[dbo].[tblCMCreditCardBatchEntry]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMCreditCardBatchEntry];
GO
IF OBJECT_ID(N'[dbo].[tblCMCreditCardBatchEntryDetail]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMCreditCardBatchEntryDetail];
GO
IF OBJECT_ID(N'[dbo].[tblCMCurrentBankReconciliation]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMCurrentBankReconciliation];
GO
IF OBJECT_ID(N'[dbo].[tblCMEFTACHAudit]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMEFTACHAudit];
GO
IF OBJECT_ID(N'[dbo].[tblCMUndepositedFund]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblCMUndepositedFund];
GO

-- --------------------------------------------------
-- Creating all tables
-- --------------------------------------------------

-- Creating table 'tblCMBankAccount'
CREATE TABLE [dbo].[tblCMBankAccount] (
    [intBankAccountID] int IDENTITY(1,1) NOT NULL,
    [strBankName] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnActive] bit  NOT NULL,
    [intGLAccountID] int  NOT NULL,
    [intCurrencyID] int  NULL,
    [intBankAccountType] int  NOT NULL,
    [strContact] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strBankAccountNo] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [strRTN] nvarchar(12) COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress] nvarchar(60) COLLATE Latin1_General_CI_AS NOT NULL,
    [strZipCode] nvarchar(42) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity] nvarchar(85) COLLATE Latin1_General_CI_AS NOT NULL,
    [strState] nvarchar(60) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry] nvarchar(75) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhone] nvarchar(30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFax] nvarchar(30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite] nvarchar(125) COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail] nvarchar(225) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCheckStartingNo] int  NOT NULL,
    [intCheckEndingNo] int  NOT NULL,
    [intCheckNextNo] int  NOT NULL,
    [ysnCheckEnableMICRPrint] bit  NOT NULL,
    [ysnCheckDefaultToBePrinted] bit  NOT NULL,
    [intBackupCheckStartingNo] int  NOT NULL,
    [intBackupCheckEndingNo] int  NOT NULL,
    [intEFTNextNo] int  NOT NULL,
    [intEFTBankFileFormatID] int  NULL,
    [strEFTCompanyID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [strEFTBankName] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMICRDescription] nvarchar(500) COLLATE Latin1_General_CI_AS NOT NULL,
    [intMICRBankAccountSpacesCount] int  NOT NULL,
    [intMICRBankAccountSpacesPosition] int  NOT NULL,
    [intMICRCheckNoSpacesCount] int  NOT NULL,
    [intMICRCheckNoSpacesPosition] int  NOT NULL,
    [intMICRCheckNoLength] int  NOT NULL,
    [intMICRCheckNoPosition] int  NOT NULL,
    [strMICRLeftSymbol] nvarchar(1) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMICRRightSymbol] nvarchar(1) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [strCbkNo] nvarchar(2) COLLATE Latin1_General_CI_AS UNIQUE NOT NULL, 
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankFileFormat'
CREATE TABLE [dbo].[tblCMBankFileFormat] (
    [intBankFileFormatID] int IDENTITY(1,1) NOT NULL,
    [strName] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankFileType] int  NOT NULL,
    [intFileFormat] int  NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankFileFormatDetail'
CREATE TABLE [dbo].[tblCMBankFileFormatDetail] (
    [intBankFileFormatDetailID] int IDENTITY(1,1) NOT NULL,
    [intBankFileFormatID] int  NOT NULL,
    [intRecordType] int  NOT NULL,
    [intFieldNo] int  NOT NULL,
    [intFieldLength] int  NOT NULL,
    [intFieldType] int  NOT NULL,
    [strFieldDescription] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldName] nvarchar(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldFormat] nvarchar(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intFieldFillerSide] int  NOT NULL,
    [ysnFieldActive] bit  NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMCheckNumberAudit'
CREATE TABLE [dbo].[tblCMCheckNumberAudit] (
    [intCheckNo] int  NOT NULL,
    [intBankAccountID] int  NOT NULL,
    [intCheckNumberStatus] int  NOT NULL,
    [strRemarks] nvarchar(200) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMEFTACHAudit'
CREATE TABLE [dbo].[tblCMEFTACHAudit] (
    [intEFTACHNo] int  NOT NULL,
    [intBankAccountID] int  NOT NULL,
    [intEFTACHStatus] int  NOT NULL,
    [strRemarks] nvarchar(200) COLLATE Latin1_General_CI_AS  NOT NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankTransactionType'
CREATE TABLE [dbo].[tblCMBankTransactionType] (
    [intBankTransactionTypeID] int  NOT NULL,
    [strBankTransactionTypeName] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionPrefix] nvarchar(5) COLLATE Latin1_General_CI_AS NOT NULL,
    [intTransactionNo] int  NOT NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankTransaction'
CREATE TABLE [dbo].[tblCMBankTransaction] (
    [cntID] int IDENTITY(1,1) NOT NULL,
    [strTransactionID] nvarchar(20) COLLATE Latin1_General_CI_AS  NOT NULL,
    [intBankTransactionTypeID] int  NOT NULL,
    [intBankAccountID] int  NOT NULL,
    [intCurrencyID] int  NULL,
    [dblExchangeRate] decimal(38,20)  NOT NULL,
    [dtmDate] datetime  NOT NULL,
    [strPayee] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [intPayeeID] int  NULL,
    [strAddress] nvarchar(60) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode] nvarchar(42) COLLATE Latin1_General_CI_AS NULL,
    [strCity] nvarchar(85) COLLATE Latin1_General_CI_AS NULL,
    [strState] nvarchar(60) COLLATE Latin1_General_CI_AS NULL,
    [strCountry] nvarchar(75) COLLATE Latin1_General_CI_AS NULL,
    [dblAmount] decimal(18,6)  NOT NULL,
    [strAmountInWords] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMemo] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intReferenceNo] int  NULL,
    [ysnCheckPrinted] bit  NOT NULL,
    [ysnCheckToBePrinted] bit  NOT NULL,
    [ysnCheckVoid] bit  NOT NULL,
    [ysnPosted] bit  NOT NULL,
    [strLink] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
    [ysnClr] bit  NOT NULL,
    [dtmDateReconciled] datetime  NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankTransactionDetail'
CREATE TABLE [dbo].[tblCMBankTransactionDetail] (
    [intBankTransactionDetailID] int IDENTITY(1,1) NOT NULL,
    [strTransactionID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate] datetime  NULL,
    [intGLAccountID] int  NOT NULL,
    [strDescription] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit] decimal(18,6)  NOT NULL,
    [dblCredit] decimal(18,6)  NOT NULL,
    [intUndepositedFundID] int  NULL,
    [intEntityID] int  NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMCreditCardBatchEntry'
CREATE TABLE [dbo].[tblCMCreditCardBatchEntry] (
    [cntID] int IDENTITY(1,1) NOT NULL,
    [strBatchID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountID] int  NOT NULL,
    [dblTotal] decimal(18,6)  NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMCreditCardBatchEntryDetail'
CREATE TABLE [dbo].[tblCMCreditCardBatchEntryDetail] (
    [intCreditCardBatchEntryDetailID] int IDENTITY(1,1) NOT NULL,
    [strBatchID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate] datetime  NOT NULL,
    [strPayee] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [intPayeeID] int  NULL,
    [intGLAccountID] int  NOT NULL,
    [strMemo] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankTransfer'
CREATE TABLE [dbo].[tblCMBankTransfer] (
    [cntID] int IDENTITY(1,1) NOT NULL,
    [strTransactionID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate] datetime  NOT NULL,
    [intBankTransactionTypeID] int  NOT NULL,
    [dblAmount] decimal(18,6)  NOT NULL,
    [strDescription] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountIDFrom] int  NOT NULL,
    [intGLAccountIDFrom] int  NOT NULL,
    [strReferenceFrom] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountIDTo] int  NOT NULL,
    [intGLAccountIDTo] int  NOT NULL,
    [strReferenceTo] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnPosted] bit  NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBankReconciliation'
CREATE TABLE [dbo].[tblCMBankReconciliation] (
    [intBankAccountID] int  NOT NULL,
    [dtmDateReconciled] datetime  NOT NULL,
    [dblStatementOpeningBalance] decimal(18,6)  NOT NULL,
    [dblDebitCleared] decimal(18,6)  NOT NULL,
    [dblCreditCleared] decimal(18,6)  NOT NULL,
    [dblBankAccountBalance] decimal(18,6)  NOT NULL,
    [dblStatementEndingBalance] decimal(18,6)  NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMUndepositedFund'
CREATE TABLE [dbo].[tblCMUndepositedFund] (
    [intUndepositedFundID] int IDENTITY(1,1) NOT NULL,
    [strTransactionID] nvarchar(40) COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit] decimal(18,6)  NOT NULL,
    [strBankTransactionID] nvarchar(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMBank'
CREATE TABLE [dbo].[tblCMBank] (
    [strBankName] nvarchar(250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strContact] nvarchar(150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress] nvarchar(60) COLLATE Latin1_General_CI_AS NOT NULL,
    [strZipCode] nvarchar(42) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity] nvarchar(85) COLLATE Latin1_General_CI_AS NOT NULL,
    [strState] nvarchar(60) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry] nvarchar(75) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhone] nvarchar(30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFax] nvarchar(30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite] nvarchar(125) COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail] nvarchar(225) COLLATE Latin1_General_CI_AS NOT NULL,
    [strRTN] nvarchar(12) COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID] int  NULL,
    [dtmCreated] datetime  NULL,
    [intLastModifiedUserID] int  NULL,
    [dtmLastModified] datetime  NULL,
    [intConcurrencyID] int  NOT NULL
);
GO

-- Creating table 'tblCMCurrentBankReconciliation'
CREATE TABLE [dbo].[tblCMCurrentBankReconciliation] (
    [intBankAccountID] int  NOT NULL,
    [dblStatementOpeningBalance] decimal(18,0)  NULL,
    [dblStatementEndingBalance] decimal(18,0)  NULL,
    [intLastModifiedUserID] int  NOT NULL,
    [dtmLastModified] datetime  NOT NULL,
    [intConcurrencyID] int  NULL
);
GO

-- --------------------------------------------------
-- Creating all PRIMARY KEY constraints
-- --------------------------------------------------

-- Creating primary key on [intBankAccountID] in table 'tblCMBankAccount'
ALTER TABLE [dbo].[tblCMBankAccount]
ADD CONSTRAINT [PK_tblCMBankAccount]
    PRIMARY KEY CLUSTERED ([intBankAccountID] ASC);
GO

-- Creating primary key on [intBankFileFormatID] in table 'tblCMBankFileFormat'
ALTER TABLE [dbo].[tblCMBankFileFormat]
ADD CONSTRAINT [PK_tblCMBankFileFormat]
    PRIMARY KEY CLUSTERED ([intBankFileFormatID] ASC);
GO

-- Creating primary key on [intBankFileFormatDetailID] in table 'tblCMBankFileFormatDetail'
ALTER TABLE [dbo].[tblCMBankFileFormatDetail]
ADD CONSTRAINT [PK_tblCMBankFileFormatDetail]
    PRIMARY KEY CLUSTERED ([intBankFileFormatDetailID] ASC);
GO

-- Creating primary key on [intCheckNo], [intBankAccountID] in table 'tblCMCheckNumberAudit'
ALTER TABLE [dbo].[tblCMCheckNumberAudit]
ADD CONSTRAINT [PK_tblCMCheckNumberAudit]
    PRIMARY KEY CLUSTERED ([intCheckNo], [intBankAccountID] ASC);
GO

-- Creating primary key on [intEFTACHNo], [intBankAccountID] in table 'tblCMEFTACHAudit'
ALTER TABLE [dbo].[tblCMEFTACHAudit]
ADD CONSTRAINT [PK_tblCMEFTACHAudit]
    PRIMARY KEY CLUSTERED ([intEFTACHNo], [intBankAccountID] ASC);
GO

-- Creating primary key on [intBankTransactionTypeID] in table 'tblCMBankTransactionType'
ALTER TABLE [dbo].[tblCMBankTransactionType]
ADD CONSTRAINT [PK_tblCMBankTransactionType]
    PRIMARY KEY CLUSTERED ([intBankTransactionTypeID] ASC);
GO

-- Creating primary key on [strTransactionID] in table 'tblCMBankTransaction'
ALTER TABLE [dbo].[tblCMBankTransaction]
ADD CONSTRAINT [PK_tblCMBankTransaction]
    PRIMARY KEY CLUSTERED ([strTransactionID] ASC);
GO

-- Creating primary key on [intBankTransactionDetailID] in table 'tblCMBankTransactionDetail'
ALTER TABLE [dbo].[tblCMBankTransactionDetail]
ADD CONSTRAINT [PK_tblCMBankTransactionDetail]
    PRIMARY KEY CLUSTERED ([intBankTransactionDetailID] ASC);
GO

-- Creating primary key on [strBatchID] in table 'tblCMCreditCardBatchEntry'
ALTER TABLE [dbo].[tblCMCreditCardBatchEntry]
ADD CONSTRAINT [PK_tblCMCreditCardBatchEntry]
    PRIMARY KEY CLUSTERED ([strBatchID] ASC);
GO

-- Creating primary key on [intCreditCardBatchEntryDetailID] in table 'tblCMCreditCardBatchEntryDetail'
ALTER TABLE [dbo].[tblCMCreditCardBatchEntryDetail]
ADD CONSTRAINT [PK_tblCMCreditCardBatchEntryDetail]
    PRIMARY KEY CLUSTERED ([intCreditCardBatchEntryDetailID] ASC);
GO

-- Creating primary key on [strTransactionID] in table 'tblCMBankTransfer'
ALTER TABLE [dbo].[tblCMBankTransfer]
ADD CONSTRAINT [PK_tblCMBankTransfer]
    PRIMARY KEY CLUSTERED ([strTransactionID] ASC);
GO

-- Creating primary key on [intBankAccountID], [dtmDateReconciled] in table 'tblCMBankReconciliation'
ALTER TABLE [dbo].[tblCMBankReconciliation]
ADD CONSTRAINT [PK_tblCMBankReconciliation]
    PRIMARY KEY CLUSTERED ([intBankAccountID], [dtmDateReconciled] ASC);
GO

-- Creating primary key on [intUndepositedFundID] in table 'tblCMUndepositedFund'
ALTER TABLE [dbo].[tblCMUndepositedFund]
ADD CONSTRAINT [PK_tblCMUndepositedFund]
    PRIMARY KEY CLUSTERED ([intUndepositedFundID] ASC);
GO

-- Creating primary key on [strBankName] in table 'tblCMBank'
ALTER TABLE [dbo].[tblCMBank]
ADD CONSTRAINT [PK_tblCMBank]
    PRIMARY KEY CLUSTERED ([strBankName] ASC);
GO

-- Creating primary key on [intBankAccountID] in table 'tblCMCurrentBankReconciliation'
ALTER TABLE [dbo].[tblCMCurrentBankReconciliation]
ADD CONSTRAINT [PK_tblCMCurrentBankReconciliation]
    PRIMARY KEY CLUSTERED ([intBankAccountID] ASC);
GO

-- --------------------------------------------------
-- Creating all FOREIGN KEY constraints
-- --------------------------------------------------

-- Creating foreign key on [intBankAccountID] in table 'tblCMCheckNumberAudit'
ALTER TABLE [dbo].[tblCMCheckNumberAudit]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit]
    FOREIGN KEY ([intBankAccountID])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMCheckNumberAudit'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMCheckNumberAudit]
ON [dbo].[tblCMCheckNumberAudit]
    ([intBankAccountID]);
GO

-- Creating foreign key on [intBankAccountID] in table 'tblCMEFTACHAudit'
ALTER TABLE [dbo].[tblCMEFTACHAudit]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMEFTACHAudit]
    FOREIGN KEY ([intBankAccountID])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMEFTACHAudit'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMEFTACHAudit]
ON [dbo].[tblCMEFTACHAudit]
    ([intBankAccountID]);
GO

-- Creating foreign key on [intEFTBankFileFormatID] in table 'tblCMBankAccount'
ALTER TABLE [dbo].[tblCMBankAccount]
ADD CONSTRAINT [FK_tblCMBankFileFormattblCMBankAccount]
    FOREIGN KEY ([intEFTBankFileFormatID])
    REFERENCES [dbo].[tblCMBankFileFormat]
        ([intBankFileFormatID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankFileFormattblCMBankAccount'
CREATE INDEX [IX_FK_tblCMBankFileFormattblCMBankAccount]
ON [dbo].[tblCMBankAccount]
    ([intEFTBankFileFormatID]);
GO

-- Creating foreign key on [intBankFileFormatID] in table 'tblCMBankFileFormatDetail'
ALTER TABLE [dbo].[tblCMBankFileFormatDetail]
ADD CONSTRAINT [FK_tblCMBankFileFormattblCMBankFileFormatDetail]
    FOREIGN KEY ([intBankFileFormatID])
    REFERENCES [dbo].[tblCMBankFileFormat]
        ([intBankFileFormatID])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankFileFormattblCMBankFileFormatDetail'
CREATE INDEX [IX_FK_tblCMBankFileFormattblCMBankFileFormatDetail]
ON [dbo].[tblCMBankFileFormatDetail]
    ([intBankFileFormatID]);
GO

-- Creating foreign key on [intBankAccountID] in table 'tblCMBankTransaction'
ALTER TABLE [dbo].[tblCMBankTransaction]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMBankTransaction]
    FOREIGN KEY ([intBankAccountID])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMBankTransaction'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMBankTransaction]
ON [dbo].[tblCMBankTransaction]
    ([intBankAccountID]);
GO

-- Creating foreign key on [intBankAccountID] in table 'tblCMCreditCardBatchEntry'
ALTER TABLE [dbo].[tblCMCreditCardBatchEntry]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMCreditCardBatchEntry]
    FOREIGN KEY ([intBankAccountID])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMCreditCardBatchEntry'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMCreditCardBatchEntry]
ON [dbo].[tblCMCreditCardBatchEntry]
    ([intBankAccountID]);
GO

-- Creating foreign key on [strTransactionID] in table 'tblCMBankTransactionDetail'
ALTER TABLE [dbo].[tblCMBankTransactionDetail]
ADD CONSTRAINT [FK_tblCMBankTransactiontblCMBankTransactionDetail]
    FOREIGN KEY ([strTransactionID])
    REFERENCES [dbo].[tblCMBankTransaction]
        ([strTransactionID])
    ON DELETE CASCADE ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankTransactiontblCMBankTransactionDetail'
CREATE INDEX [IX_FK_tblCMBankTransactiontblCMBankTransactionDetail]
ON [dbo].[tblCMBankTransactionDetail]
    ([strTransactionID]);
GO

-- Creating foreign key on [intBankAccountIDTo] in table 'tblCMBankTransfer'
ALTER TABLE [dbo].[tblCMBankTransfer]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_To]
    FOREIGN KEY ([intBankAccountIDTo])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMBankTransfer_To'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMBankTransfer_To]
ON [dbo].[tblCMBankTransfer]
    ([intBankAccountIDTo]);
GO

-- Creating foreign key on [intBankAccountID] in table 'tblCMBankReconciliation'
ALTER TABLE [dbo].[tblCMBankReconciliation]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMBankReconciliation]
    FOREIGN KEY ([intBankAccountID])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

-- Creating foreign key on [intBankAccountIDFrom] in table 'tblCMBankTransfer'
ALTER TABLE [dbo].[tblCMBankTransfer]
ADD CONSTRAINT [FK_tblCMBankAccounttblCMBankTransfer_From]
    FOREIGN KEY ([intBankAccountIDFrom])
    REFERENCES [dbo].[tblCMBankAccount]
        ([intBankAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblCMBankTransfer_From'
CREATE INDEX [IX_FK_tblCMBankAccounttblCMBankTransfer_From]
ON [dbo].[tblCMBankTransfer]
    ([intBankAccountIDFrom]);
GO

-- Creating foreign key on [strBatchID] in table 'tblCMCreditCardBatchEntryDetail'
ALTER TABLE [dbo].[tblCMCreditCardBatchEntryDetail]
ADD CONSTRAINT [FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail]
    FOREIGN KEY ([strBatchID])
    REFERENCES [dbo].[tblCMCreditCardBatchEntry]
        ([strBatchID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail'
CREATE INDEX [IX_FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail]
ON [dbo].[tblCMCreditCardBatchEntryDetail]
    ([strBatchID]);
GO

-- Creating foreign key on [intGLAccountID] in table 'tblCMBankAccount'
ALTER TABLE [dbo].[tblCMBankAccount]
ADD CONSTRAINT [FK_tblGLAccounttblCMBankAccount]
    FOREIGN KEY ([intGLAccountID])
    REFERENCES [dbo].[tblGLAccount]
        ([intAccountID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating foreign key on [strBankName] in table 'tblCMBankAccount'
ALTER TABLE [dbo].[tblCMBankAccount]
ADD CONSTRAINT [FK_tblCMBanktblCMBankAccount]
    FOREIGN KEY ([strBankName])
    REFERENCES [dbo].[tblCMBank]
        ([strBankName])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBanktblCMBankAccount'
CREATE INDEX [IX_FK_tblCMBanktblCMBankAccount]
ON [dbo].[tblCMBankAccount]
    ([strBankName]);
GO

-- Creating foreign key on [intCurrencyID] in table 'tblCMBankAccount'
ALTER TABLE [dbo].[tblCMBankAccount]
ADD CONSTRAINT [FK_tblCMBankAccounttblSMCurrency]
    FOREIGN KEY ([intCurrencyID])
    REFERENCES [dbo].[tblSMCurrency]
        ([intCurrencyID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankAccounttblSMCurrency'
CREATE INDEX [IX_FK_tblCMBankAccounttblSMCurrency]
ON [dbo].[tblCMBankAccount]
    ([intCurrencyID]);
GO

-- Creating foreign key on [intCurrencyID] in table 'tblCMBankTransaction'
ALTER TABLE [dbo].[tblCMBankTransaction]
ADD CONSTRAINT [FK_tblCMBankTransactiontblSMCurrency]
    FOREIGN KEY ([intCurrencyID])
    REFERENCES [dbo].[tblSMCurrency]
        ([intCurrencyID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_tblCMBankTransactiontblSMCurrency'
CREATE INDEX [IX_FK_tblCMBankTransactiontblSMCurrency]
ON [dbo].[tblCMBankTransaction]
    ([intCurrencyID]);
GO

-- --------------------------------------------------
-- Script has ended
-- --------------------------------------------------