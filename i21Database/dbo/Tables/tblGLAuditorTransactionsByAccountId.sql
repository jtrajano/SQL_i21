CREATE TABLE [dbo].[tblGLAuditorTransactionsByAccountId]
(
	[intAuditorTransactionId] INT IDENTITY (1, 1) NOT NULL,
	[intGeneratedBy] INT NULL,
	[dtmDateGenerated] DATETIME,
	[intEntityId] INT NULL,
	[strGroupTitle] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
	[strTotalTitle] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL,
	[intAccountId] INT NULL,
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL,
	[dtmDate] DATETIME NULL,
	[dblDebit] NUMERIC(18, 6) NULL,
	[dblCredit] NUMERIC(18, 6) NULL,
	[dblDebitForeign] NUMERIC(18, 6) NULL,
	[dblCreditForeign] NUMERIC(18, 6) NULL,
	[dblBeginningBalance] NUMERIC(18, 6) NULL,
	[dblEndingBalance] NUMERIC(18, 6) NULL,
	[dblBeginningBalanceForeign] NUMERIC(18, 6) NULL,
	[dblEndingBalanceForeign] NUMERIC(18, 6) NULL,
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

	[intConcurrencyId] INT DEFAULT 1 NOT NULL,
	
	CONSTRAINT [PK_tblGLAuditorTransactionsByAccountId] PRIMARY KEY CLUSTERED ([intAuditorTransactionId] ASC)
)
