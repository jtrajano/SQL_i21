CREATE PROCEDURE [dbo].[uspICCreateReversalGLEntriesForNonStockItems]
	@strBatchId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON


DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

DECLARE @GLAccounts AS dbo.ItemGLAccount; 

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_NonInventory AS NVARCHAR(30) = 'General'
	,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Inventory Adjustment' -- 'Auto-Variance'
-- Get the GL Account ids to use
BEGIN 
	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intNonInventoryId 
		,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intNonInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_NonInventory)
			,intTransactionTypeId
	FROM	(
				SELECT DISTINCT ItemTransactions.intItemId, ItemTransactions.intItemLocationId, ItemTransactions.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction ItemTransactions 
					LEFT OUTER JOIN tblICItem Item ON Item.intItemId = ItemTransactions.intItemId
				WHERE	ItemTransactions.strBatchId = @strBatchId
					AND Item.strType = 'Non-Inventory'
			) Query
END 

BEGIN 
	-------------------------------------------------------------------------------------------
	-- Reverse the G/L entries for the main transactions
	-------------------------------------------------------------------------------------------
	SELECT	
			[dtmDate]					= GLEntries.dtmDate
			,[strBatchId]				= @strBatchId
			,[intAccountId]				= GLEntries.intAccountId
			,[dblDebit]					= GLEntries.dblCredit	-- Reverse the Debit with Credit 
			,[dblCredit]				= GLEntries.dblDebit	-- Reverse the Credit with Debit 
			,[dblDebitUnit]				= GLEntries.dblCreditUnit
			,[dblCreditUnit]			= GLEntries.dblDebitUnit
			,[strDescription]			= GLEntries.strDescription
			,[strCode]					= GLEntries.strCode
			,[strReference]				= GLEntries.strReference
			,[intCurrencyId]			= GLEntries.intCurrencyId
			,[dblExchangeRate]			= GLEntries.dblExchangeRate
			,[dtmDateEntered]			= GETDATE()
			,[dtmTransactionDate]		= GLEntries.dtmDate
			,[strJournalLineDescription] = GLEntries.strJournalLineDescription
			,[intJournalLineNo]			= GLEntries.intJournalLineNo
			,[ysnIsUnposted]			= 1
			,[intUserId]				= @intEntityUserSecurityId
			,[intEntityId]				= @intEntityUserSecurityId
			,[strTransactionId]			= GLEntries.strTransactionId
			,[intTransactionId]			= GLEntries.intTransactionId
			,[strTransactionType]		= GLEntries.strTransactionType
			,[strTransactionForm]		= GLEntries.strTransactionForm
			,[strModuleName]			= GLEntries.strModuleName
			,[intConcurrencyId]			= 1
			,[dblDebitForeign]			= GLEntries.dblCreditForeign
			,[dblDebitReport]			= GLEntries.dblCreditReport
			,[dblCreditForeign]			= GLEntries.dblDebitForeign
			,[dblCreditReport]			= GLEntries.dblDebitReport
			,[dblReportingRate]			= GLEntries.dblReportingRate
			,[dblForeignRate]			= GLEntries.dblForeignRate
			,[strRateType]				= currencyRateType.strCurrencyExchangeRateType
			,[intSourceEntityId]		= GLEntries.intSourceEntityId
			,[intCommodityId]			= GLEntries.intCommodityId
	FROM	tblGLDetail GLEntries INNER JOIN (
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId	
				INNER JOIN tblICItem i 
					ON ri.intItemId = i.intItemId
			)
				ON GLEntries.intJournalLineNo = ri.intInventoryReceiptItemId
				AND GLEntries.strTransactionId = r.strReceiptNumber
				AND GLEntries.intTransactionId = r.intInventoryReceiptId				

			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = ri.intForexRateTypeId
	WHERE	
		GLEntries.strTransactionId = @strTransactionId			
		AND i.strType = 'Non-Inventory'
		AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
END
;