CREATE PROCEDURE [dbo].[uspARPOSPostEOD]
	 @intPOSEndOfDayId		AS INT = 0
	,@intCashOverShortId	AS INT = 0
	,@intUndepositedFundsId	AS INT = 0
	,@intCurrencyId			AS INT = 0
	,@intEntityUserId		AS INT = 0
	,@dblCashOverShort		AS DECIMAL(18,6) = 0.000000
	,@strEODNumber			AS NVARCHAR(100) = NULL
	,@strMessage			AS NVARCHAR(50)  = NULL OUTPUT
AS
BEGIN
	
	DECLARE
		 @isSuccess BIT						= 0
		,@ZeroDecimal DECIMAL(18,6)			= 0.000000
		,@DATEONLY	DATETIME				=  CAST(GETDATE() AS DATE)
		,@intStartingNumberId INT			= 0
		,@strGLEntryBatchId NVARCHAR(50)	= NULL
		,@GLEntries	AS RecapTableType

	--get batch id from startnumber
	SELECT TOP 1 @intStartingNumberId = intStartingNumberId
	FROM tblSMStartingNumber
	WHERE strTransactionType = 'Batch Post'

	IF(@intStartingNumberId <> 0)
	BEGIN
		EXEC uspSMGetStartingNumber @intStartingNumberId, @strGLEntryBatchId OUT
	END

		--INSERT GL ENTRIES TO #ARPOSGLEntries

		--Start of Cash Over/Short Undeposited Funds
		INSERT INTO @GLEntries
		(
			 [dtmDate]
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
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
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
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
		)
		SELECT
			 [dtmDate]						=	GETDATE()
			,[strBatchId]					=	@strGLEntryBatchId
			,[intAccountId]					=	@intUndepositedFundsId
			,[dblDebit]						=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN ABS(@dblCashOverShort) ELSE @ZeroDecimal END
			,[dblCredit]					=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN @ZeroDecimal ELSE ABS(@dblCashOverShort) END
			,[dblDebitUnit]					=	0
			,[dblCreditUnit]				=	0
			,[strDescription]				=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN EOD.strEODNo + ' Cash Over' ELSE EOD.strEODNo + ' Cash Short' END
			,[strCode]						=	'POS'
			,[strReference]					=	EOD.strEODNo
			,[intCurrencyId]				=	@intCurrencyId
			,[dblExchangeRate]				=	1
			,[dtmDateEntered]				=	@DATEONLY
			,[dtmTransactionDate]			=	@DATEONLY
			,[strJournalLineDescription]	=	'POS End Of Day Cash Over/Short' 
			,[intJournalLineNo]				=	2
			,[ysnIsUnposted]				=	0
			,[intUserId]					=	@intEntityUserId
			,[intEntityId]					=	@intEntityUserId
			,[strTransactionId]				=	EOD.strEODNo
			,[intTransactionId]				=	@intPOSEndOfDayId
			,[strTransactionType]			=	'POS End Of Day'
			,[strTransactionForm]			=	'POS End Of Day'
			,[strModuleName]				=	'Accounts Receivable'
			,[intConcurrencyId]				=	1
			,[dblDebitForeign]				=	0
			,[dblDebitReport]				=	0
			,[dblCreditForeign]				=	0
			,[dblCreditReport]				=	0
			,[dblReportingRate]				=	0
			,[dblForeignRate]				=	1
			,[strDocument]					=	EOD.strEODNo
			,[strComments]					=	NULL
			,[strSourceDocumentId]			=	NULL
			,[intSourceLocationId]			=	NULL
			,[intSourceUOMId]				=	NULL
			,[dblSourceUnitDebit]			=	NULL
			,[dblSourceUnitCredit]			=	NULL
			,[intCommodityId]				=	NULL
			,[intSourceEntityId]			=	NULL
		FROM (
			SELECT
				 intPOSEndOfDayId
				,strEODNo
				,dblOpeningBalance
				,dblExpectedEndingBalance
				,dblFinalEndingBalance
				,intCompanyLocationPOSDrawerId
				,intStoreId
				,intEntityId
				,dtmOpen
				,dtmClose
				,ysnClosed
			FROM tblARPOSEndOfDay
			WHERE intPOSEndOfDayId = @intPOSEndOfDayId
		) EOD
		-- End Of Cash Over/Short Undeposited Funds

		--start oF Cash Over/Short Cash Over short 
		INSERT INTO @GLEntries
		(
			[dtmDate]
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
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
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
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
		)
		SELECT
			 [dtmDate]						=	GETDATE()
			,[strBatchId]					=	@strGLEntryBatchId
			,[intAccountId]					=	@intCashOverShortId
			,[dblDebit]						=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN @ZeroDecimal ELSE ABS(@dblCashOverShort) END
			,[dblCredit]					=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN ABS(@dblCashOverShort) ELSE @ZeroDecimal END
			,[dblDebitUnit]					=	0
			,[dblCreditUnit]				=	0
			,[strDescription]				=	CASE WHEN @dblCashOverShort > @ZeroDecimal THEN EOD.strEODNo + ' Cash Over' ELSE EOD.strEODNo + ' Cash Short' END
			,[strCode]						=	'POS'
			,[strReference]					=	EOD.strEODNo
			,[intCurrencyId]				=	@intCurrencyId
			,[dblExchangeRate]				=	1
			,[dtmDateEntered]				=	@DATEONLY
			,[dtmTransactionDate]			=	@DATEONLY
			,[strJournalLineDescription]	=	'POS End Of Day Cash Over/Short' 
			,[intJournalLineNo]				=	2
			,[ysnIsUnposted]				=	0
			,[intUserId]					=	@intEntityUserId
			,[intEntityId]					=	@intEntityUserId
			,[strTransactionId]				=	EOD.strEODNo
			,[intTransactionId]				=	@intPOSEndOfDayId
			,[strTransactionType]			=	'POS End Of Day'
			,[strTransactionForm]			=	'POS End Of Day'
			,[strModuleName]				=	'Accounts Receivable'
			,[intConcurrencyId]				=	1
			,[dblDebitForeign]				=	0
			,[dblDebitReport]				=	0
			,[dblCreditForeign]				=	0
			,[dblCreditReport]				=	0
			,[dblReportingRate]				=	0
			,[dblForeignRate]				=	1
			,[strDocument]					=	EOD.strEODNo
			,[strComments]					=	NULL
			,[strSourceDocumentId]			=	NULL
			,[intSourceLocationId]			=	NULL
			,[intSourceUOMId]				=	NULL
			,[dblSourceUnitDebit]			=	NULL
			,[dblSourceUnitCredit]			=	NULL
			,[intCommodityId]				=	NULL
			,[intSourceEntityId]			=	NULL
		FROM (
			SELECT
				 intPOSEndOfDayId
				,strEODNo
				,dblOpeningBalance
				,dblExpectedEndingBalance
				,dblFinalEndingBalance
				,intCompanyLocationPOSDrawerId
				,intStoreId
				,intEntityId
				,dtmOpen
				,dtmClose
				,ysnClosed
			FROM tblARPOSEndOfDay
			WHERE intPOSEndOfDayId = @intPOSEndOfDayId
		) EOD
		--End of Cash Over/Short to Cash Over/ Account

		EXEC dbo.uspGLBookEntries	@GLEntries, 1

		SELECT TOP 1 @isSuccess = 1
		FROM tblGLDetail
		WHERE intTransactionId = @intPOSEndOfDayId
		AND	strReference = @strEODNumber

		IF(@isSuccess = 1)
		BEGIN
			SET @strMessage = NULL
		END
		ELSE
		BEGIN
			SET @strMessage = 'Posting Failed'
		END
END