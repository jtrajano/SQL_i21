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
SET ANSI_WARNINGS OFF


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
					AND Item.strType IN ('Non-Inventory', 'Service', 'Software')
			) Query
END 



BEGIN 
	-------------------------------------------------------------------------------------------
	-- Reverse the G/L entries for the main transactions
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= GLEntries.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLEntries.intAccountId
			,dblDebit					= GLEntries.dblCredit	-- Reverse the Debit with Credit 
			,dblCredit					= GLEntries.dblDebit	-- Reverse the Credit with Debit 
			,dblDebitUnit				= 0--GLEntries.dblCreditUnit 
			,dblCreditUnit				= 0--GLEntries.dblDebitUnit 
			,strDescription				= GLEntries.strDescription
			,strCode					= GLEntries.strCode
			,strReference				= GLEntries.strReference
			,intCurrencyId				= GLEntries.intCurrencyId
			,dblExchangeRate			= GLEntries.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= GLEntries.dtmDate
			,strJournalLineDescription	= GLEntries.strJournalLineDescription
			,intJournalLineNo			= Reversal.intInventoryTransactionId
			,ysnIsUnposted				= 1
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= GLEntries.intEntityId
			,strTransactionId			= GLEntries.strTransactionId
			,intTransactionId			= GLEntries.intTransactionId
			,strTransactionType			= GLEntries.strTransactionType
			,strTransactionForm			= GLEntries.strTransactionForm
			,strModuleName				= GLEntries.strModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= GLEntries.dblCreditForeign
			,dblDebitReport				= GLEntries.dblDebitReport
			,dblCreditForeign			= GLEntries.dblDebitForeign 
			,dblCreditReport			= GLEntries.dblCreditReport
			,dblReportingRate			= GLEntries.dblReportingRate
			,dblForeignRate				= GLEntries.dblForeignRate
			,strRateType				= currencyRateType.strCurrencyExchangeRateType
	FROM	dbo.tblGLDetail GLEntries INNER JOIN dbo.tblICInventoryTransaction Reversal
				ON GLEntries.intJournalLineNo = Reversal.intRelatedInventoryTransactionId
				AND GLEntries.intTransactionId = Reversal.intTransactionId
				AND GLEntries.strTransactionId = Reversal.strTransactionId
				AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = Reversal.intForexRateTypeId
	WHERE	Reversal.strBatchId = @strBatchId			
			
	

END
;

BEGIN 
	-- Update the ysnPostedFlag for the main transaction 
	UPDATE	GLEntries
	SET		ysnIsUnposted = 1
	FROM	dbo.tblGLDetail GLEntries
	WHERE	GLEntries.intTransactionId = @intTransactionId
			AND GLEntries.strTransactionId = @strTransactionId
			AND strTransactionType <> @AccountCategory_Auto_Negative
	;
	-- Update the ysnPostedFlag for the related transactions
	UPDATE	GLEntries
	SET		ysnIsUnposted = 1
	FROM	dbo.tblGLDetail GLEntries INNER JOIN dbo.tblICInventoryTransaction ItemTransactions 
				ON GLEntries.intJournalLineNo = ItemTransactions.intInventoryTransactionId
				AND GLEntries.intTransactionId = ItemTransactions.intRelatedTransactionId
				AND GLEntries.strTransactionId = ItemTransactions.strRelatedTransactionId
	WHERE	ItemTransactions.strBatchId = @strBatchId
		AND GLEntries.strTransactionType <> @AccountCategory_Auto_Negative
	;
END 
