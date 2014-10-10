CREATE PROCEDURE [dbo].[uspICPostCosting]
	@ItemsToProcess AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
AS

-- TODO: Loop for each item to post. 

	-- TODO: If item is for receiving, call the Process In-Stock

	-- TODO: If item is for selling or outgoing, call the Process Out-Stock

	-- TODO: If item is for cost adjustment, call Process Cost Adjustment

-- TODO: End Loop 


-- Generate the GL entries
--SELECT	[strTransactionId]		= A.strTransactionId
--		,[intTransactionId]		= A.intTransactionId
--		,[dtmDate]				= A.dtmDate
--		,[strBatchId]			= @strBatchId
--		,[intAccountId]			= 
--		,[dblDebit]				= 
--		,[dblCredit]			= 
--		,[dblDebitUnit]			= 
--		,[dblCreditUnit]		= 
--		,[strDescription]		= 
--		,[strCode]				= 
--		,[strReference]			= 
--		,[intCurrencyId]		= 
--		,[dblExchangeRate]		= 
--		,[dtmDateEntered]		= GETDATE()
--		,[dtmTransactionDate]	= A.dtmDate
--		,[strJournalLineDescription] = NULL 
--		,[ysnIsUnposted]		= 0 
--		,[intConcurrencyId]		= 1
--		,[intUserId]			= 
--		,[strTransactionForm]	= @TRANSACTION_FORM
--		,[strModuleName]		= @MODULE_NAME
--		,[intEntityId]			= A.intEntityId
--FROM	tblICInventoryTransaction A INNER JOIN @ItemsForProcessing B
--			ON A.intTransactionId = B.intTransactionId