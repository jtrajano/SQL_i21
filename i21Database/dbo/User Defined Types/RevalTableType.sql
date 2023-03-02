CREATE TYPE [dbo].[RevalTableType] AS TABLE (
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblExchangeRate]           NUMERIC (38, 20) NULL,
	[dblDebitForeign]           NUMERIC (18, 6)  NULL,
	[dblCreditForeign]          NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL, 
	[intCurrencyId]             INT              NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[strJournalLineDescription] NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
    intAccountIdOverride INT NULL,
    intLocationSegmentOverrideId INT NULL,
    intLOBSegmentOverrideId INT NULL,
    intCompanySegmentOverrideId INT NULL,
    strNewAccountIdOverride NVARCHAR(40) Collate Latin1_General_CI_AS NULL,
    intNewAccountIdOverride INT NULL,
    strOverrideAccountError NVARCHAR(800) Collate Latin1_General_CI_AS NULL
)
