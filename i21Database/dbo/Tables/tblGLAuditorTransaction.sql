﻿CREATE TABLE [dbo].[tblGLAuditorTransaction]
(
	[intAuditorTransactionId] INT IDENTITY (1, 1) NOT NULL,
	[intType] INT DEFAULT 0 NOT NULL,
	[intGeneratedBy] INT NULL,
	[dtmDateGenerated] DATETIME,
	[intEntityId] INT NULL,
	[strGroupTitle] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
	[strTotalTitle] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
	[intAccountId] INT NULL,
	[intTransactionId] INT NULL,
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL,
	[strAccountId] NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL,
	[dtmDate] DATETIME NULL,
	[dblDebit] NUMERIC(18, 6) NULL,
	[dblCredit] NUMERIC(18, 6) NULL,
	[dblDebitForeign] NUMERIC(18, 6) NULL,
	[dblCreditForeign] NUMERIC(18, 6) NULL,
	[dblBeginningBalance] NUMERIC(18, 6) NULL,
	[dblEndingBalance] NUMERIC(18, 6) NULL,
	[dblBeginningBalanceForeign] NUMERIC(18, 6) NULL,
	[dblEndingBalanceForeign] NUMERIC(18, 6) NULL,
	[dblExchangeRate] NUMERIC(18, 6) NULL,
	[intCurrencyId] INT NULL,
	[strBatchId] NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered] DATETIME NULL,
	[intCreatedBy] INT NULL,
	[strCode] NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL, -- Source System
    [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strReference] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strDocument] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strComments] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strPeriod]	NVARCHAR (30) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[dblSourceUnitDebit] NUMERIC(18, 6) NULL,
	[dblSourceUnitCredit] NUMERIC(18, 6) NULL,
	[dblDebitUnit] NUMERIC(18, 6) NULL,
	[dblCreditUnit] NUMERIC(18, 6) NULL,
	[dblDebitReport] NUMERIC(18, 6) NULL,
	[dblCreditReport] NUMERIC(18, 6) NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceUOMId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strJournalLineDescription] NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intJournalId] INT NULL,
	[strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intSourceEntityId] INT NULL,
	[strSourceEntity] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strSourceEntityNo] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[dblTotal] NUMERIC(18, 6) NULL,
	[dblTotalForeign] NUMERIC(18, 6) NULL,
	[intConcurrencyId] INT DEFAULT 1 NOT NULL,
	[strUserName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
	[strLOBSegmentDescription] NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblGLAuditorTransaction] PRIMARY KEY CLUSTERED ([intAuditorTransactionId] ASC)
)
