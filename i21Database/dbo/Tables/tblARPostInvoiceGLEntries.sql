CREATE TABLE tblARPostInvoiceGLEntries (
	  [dtmDate]							DATETIME         NOT NULL
	, [strBatchId]						NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL
	, [intAccountId]					INT              NULL
	, [dblDebit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCredit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblDebitUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCreditUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [strDescription]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [strCode]							NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL 
	, [strReference]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [intCurrencyId]					INT              NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
	, [dtmDateEntered]					DATETIME         NOT NULL
	, [dtmTransactionDate]				DATETIME         NULL
	, [strJournalLineDescription]		NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
	, [intJournalLineNo]				INT              NULL
	, [ysnIsUnposted]					BIT              NOT NULL DEFAULT 0
	, [intUserId]						INT              NULL
	, [intEntityId]						INT              NULL
	, [strTransactionId]				NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	, [intTransactionId]				INT              NULL
	, [strTransactionType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strTransactionForm]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strModuleName]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [intConcurrencyId]				INT              DEFAULT 1 NOT NULL
	, [dblDebitForeign]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblDebitReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditForeign]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblReportingRate]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblForeignRate]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [intCurrencyExchangeRateTypeId]	INT NULL
	, [strRateType]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [strDocument]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strComments]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strSourceDocumentId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [intSourceLocationId]				INT NULL
	, [intSourceUOMId]					INT NULL
	, [dblSourceUnitDebit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblSourceUnitCredit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [intCommodityId]					INT NULL
	, [intSourceEntityId]				INT NULL
	, [ysnRebuild]						BIT				 NULL DEFAULT 0
    , [strSessionId]                    NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
);
GO
CREATE INDEX [idx_tblARPostInvoiceGLEntries_strSessionId] ON [dbo].[tblARPostInvoiceGLEntries] (strSessionId)
GO