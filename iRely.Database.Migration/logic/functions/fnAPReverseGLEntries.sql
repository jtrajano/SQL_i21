--liquibase formatted sql

-- changeset Von:fnAPReverseGLEntries.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPReverseGLEntries]
(
		@transactionIds		Id READONLY
		,@transactionType	NVARCHAR(50)
		,@dtmDateReverse	DATETIME = NULL 
		,@intUserId			INT
		,@batchId			NVARCHAR(50)
		
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[dblSourceUnitCredit]		NUMERIC(18, 9)	NULL,
	[dblSourceUnitDebit]		NUMERIC(18, 9)	NULL,
	[intCommodityId]			INT				NULL,
	[intSourceLocationId]		INT				NULL
)
AS
BEGIN

	--DECLARE @tmpTransacions TABLE (
	--	[intTransactionId] [int] PRIMARY KEY,
	--	UNIQUE (intTransactionId)
	--);
	--INSERT INTO @tmpTransacions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@transactionIds)

	INSERT INTO @returntable(
		[strTransactionId]
		,[intTransactionId]
		,[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[intCurrencyExchangeRateTypeId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]           
		,[dblDebitReport]            
		,[dblCreditForeign]          
		,[dblCreditReport]           
		,[dblReportingRate]          
		,[dblForeignRate]            
		,[intEntityId]
		,[strRateType]
		,[strDocument]
		,[strComments]
		,[dblSourceUnitCredit]
		,[dblSourceUnitDebit]
		,[intCommodityId]
		,[intSourceLocationId]
	)
	SELECT	
		[strTransactionId]
		,[intTransactionId]
		,dtmDate = ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
		,ISNULL(@batchId, strBatchId)--[strBatchId]
		,[intAccountId]
		,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
		,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
		,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[intCurrencyExchangeRateTypeId]
		,[dblExchangeRate]
		,dtmDateEntered = GETDATE()
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,ysnIsUnposted = 1
		,intUserId = @intUserId
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign] =  [dblCreditForeign]  -- (Debit -> Credit)   
		,[dblDebitReport]            
		,[dblCreditForeign] = [dblDebitForeign]   -- (Debit <- Credit)          
		,[dblCreditReport]           
		,[dblReportingRate]          
		,[dblForeignRate]  
		,[intEntityId] = @intUserId
		,NULL
		,strDocument
		,strComments
		,dblSourceUnitCredit
		,dblSourceUnitDebit
		,intCommodityId
		,intSourceLocationId
	FROM	tblGLDetail 
	WHERE	intTransactionId IN (SELECT intId FROM @transactionIds)
	AND strTransactionForm = @transactionType
	AND strModuleName = 'Accounts Payable'
	AND ysnIsUnposted = 0
	--ORDER BY intGLDetailId

	RETURN
END



