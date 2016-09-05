CREATE PROCEDURE uspGLInsertReverseGLEntry
(
	@strTransactionId NVARCHAR(100),
	@intEntityId INT,
	@dtmDateReverse DATETIME = NULL
)
AS
BEGIN
	DECLARE @GLEntries RecapTableType
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
				--,[dblDebitForeign]
				--,[dblCreditForeign]
				--,[dblForeignRate]
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
				,[strBatchId]
				,[intAccountId]
				,dblDebit			= [dblCredit]		-- (Debit -> Credit)
				,dblCredit			= [dblDebit]		-- (Debit <- Credit)
				,dblDebitUnit		= [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
				,dblCreditUnit		= [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
				--,dblDebitForeign	= [dblCreditForeign]
				--,dblCreditForeign	= [dblDebitForeign]
				--,dblForeignRate
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
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

		EXEC uspGLBookEntries @GLEntries, 0

		UPDATE	tblGLDetail
		SET		ysnIsUnposted = 1
		WHERE	strTransactionId = @strTransactionId
END
