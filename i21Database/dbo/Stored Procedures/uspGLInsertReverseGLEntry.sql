CREATE PROCEDURE [dbo].[uspGLInsertReverseGLEntry]
(
	@strTransactionId NVARCHAR(100),
	@intEntityId INT,
	@dtmDateReverse DATETIME = NULL,
	@strBatchId NVARCHAR(100) = '',
	@strCode NVARCHAR(50) = NULL,
	@ysnUseIntegerTransactionId BIT = 0
)
AS
BEGIN
	DECLARE @GLEntries RecapTableType
	DECLARE @intTransactionId INT
	DECLARE @PostResult INT

	SET @strCode = ISNULL(@strCode,'')
	IF(@ysnUseIntegerTransactionId = 0)
	BEGIN
		IF(@strCode = '') 
		BEGIN
			INSERT INTO @GLEntries (
					[strTransactionId]
					,[intTransactionId]
					,[dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[dblDebitForeign]
					,[dblCreditForeign]
					,[dblForeignRate]
					,dblReportingRate
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
					,[intConcurrencyId]
					,[intUserId]
					,[intEntityId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
			)
			SELECT	 [strTransactionId]
					,[intTransactionId]
					,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
					,[strBatchId]		= @strBatchId
					,[intAccountId]
					,[dblCredit]
					,[dblDebit]
					,[dblCreditUnit]
					,[dblDebitUnit]
					,[dblCreditForeign]
					,[dblDebitForeign]
					,dblForeignRate
					,dblReportingRate
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[intCurrencyExchangeRateTypeId]
					,[dblExchangeRate]
					,dtmDateEntered		= GETDATE()
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,ysnIsUnposted		= 1
					,[intConcurrencyId]
					,[intUserId]		= NULL
					,[intEntityId]		= @intEntityId
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
			FROM	tblGLDetail
			WHERE	strTransactionId = @strTransactionId and ysnIsUnposted = 0
			ORDER BY intGLDetailId

			
			EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = 0, @SkipICValidation = 1

			UPDATE	tblGLDetail
			SET		ysnIsUnposted = 1
			WHERE	strTransactionId = @strTransactionId
		END
		ELSE
		BEGIN
			INSERT INTO @GLEntries (
					[strTransactionId]
					,[intTransactionId]
					,[dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[dblDebitForeign]
					,[dblCreditForeign]
					,[dblForeignRate]
					,dblReportingRate
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
					,[intConcurrencyId]
					,[intUserId]
					,[intEntityId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
			)
			SELECT	 [strTransactionId]
					,[intTransactionId]
					,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
					,[strBatchId]		= @strBatchId
					,[intAccountId]
					,[dblCredit]
					,[dblDebit]
					,[dblCreditUnit]
					,[dblDebitUnit]
					,[dblCreditForeign]
					,[dblDebitForeign]
					,dblForeignRate
					,dblReportingRate
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[intCurrencyExchangeRateTypeId]
					,[dblExchangeRate]
					,dtmDateEntered		= GETDATE()
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,ysnIsUnposted		= 1
					,[intConcurrencyId]
					,[intUserId]		= NULL
					,[intEntityId]		= @intEntityId
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
			FROM	tblGLDetail
			WHERE	strTransactionId = @strTransactionId 
				AND ysnIsUnposted = 0
				AND strCode = @strCode
			ORDER BY intGLDetailId

			EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = 0, @SkipICValidation = 1

			UPDATE	tblGLDetail
			SET		ysnIsUnposted = 1
			WHERE	strTransactionId = @strTransactionId
				AND strCode = @strCode
		END
	END
	ELSE 
	BEGIN
		SET @intTransactionId = CAST(@strTransactionId AS INT)

		IF(@strCode = '')
		BEGIN
			INSERT INTO @GLEntries (
				[strTransactionId]
				,[intTransactionId]
				,[dtmDate]
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[dblDebitForeign]
				,[dblCreditForeign]
				,[dblForeignRate]
				,dblReportingRate
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
				,[intConcurrencyId]
				,[intUserId]
				,[intEntityId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
			)
			SELECT	 
				[strTransactionId]
				,[intTransactionId]
				,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
				,[strBatchId]		= @strBatchId
				,[intAccountId]
				,[dblCredit]
				,[dblDebit]
				,[dblCreditUnit]
				,[dblDebitUnit]
				,[dblCreditForeign]
				,[dblDebitForeign]
				,dblForeignRate
				,dblReportingRate
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[intCurrencyExchangeRateTypeId]
				,[dblExchangeRate]
				,dtmDateEntered		= GETDATE()
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,ysnIsUnposted		= 1
				,[intConcurrencyId]
				,[intUserId]		= NULL
				,[intEntityId]		= @intEntityId
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
			FROM	tblGLDetail
			WHERE	intTransactionId = @intTransactionId
				AND ysnIsUnposted = 0
			ORDER BY intGLDetailId

			EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = 0, @SkipICValidation = 1

			UPDATE	tblGLDetail
			SET		ysnIsUnposted = 1
			WHERE	intTransactionId = @intTransactionId
		END
		ELSE
		BEGIN
			INSERT INTO @GLEntries (
				[strTransactionId]
				,[intTransactionId]
				,[dtmDate]
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[dblDebitForeign]
				,[dblCreditForeign]
				,[dblForeignRate]
				,dblReportingRate
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
				,[intConcurrencyId]
				,[intUserId]
				,[intEntityId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
			)
			SELECT	 
				[strTransactionId]
				,[intTransactionId]
				,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
				,[strBatchId]		= @strBatchId
				,[intAccountId]
				,[dblCredit]
				,[dblDebit]
				,[dblCreditUnit]
				,[dblDebitUnit]
				,[dblCreditForeign]
				,[dblDebitForeign]
				,dblForeignRate
				,dblReportingRate
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[intCurrencyExchangeRateTypeId]
				,[dblExchangeRate]
				,dtmDateEntered		= GETDATE()
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,ysnIsUnposted		= 1
				,[intConcurrencyId]
				,[intUserId]		= NULL
				,[intEntityId]		= @intEntityId
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
			FROM	tblGLDetail
			WHERE	intTransactionId = @intTransactionId
				AND ysnIsUnposted = 0
				AND strCode = @strCode
			ORDER BY intGLDetailId

			EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = 0, @SkipICValidation = 1

			UPDATE	tblGLDetail
			SET		ysnIsUnposted = 1
			WHERE	strTransactionId = @strTransactionId
				AND strCode = @strCode
		END
	END

	
END