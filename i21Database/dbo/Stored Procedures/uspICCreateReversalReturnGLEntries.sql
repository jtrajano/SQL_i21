﻿CREATE PROCEDURE [dbo].[uspICCreateReversalReturnGLEntries]
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

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoVariance AS INT = 1;
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
DECLARE @GLAccounts AS dbo.ItemGLAccount; 

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_Write_Off_Sold AS NVARCHAR(30) = 'Write-Off Sold'
		,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Revalue Sold'
		,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Inventory Adjustment' -- 'Auto-Variance'

		,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'Inventory Adjustment' -- 'Auto-Variance' -- 'Cost Adjustment' -- As per Ajith, the system should re-use Auto-Negative. 
		,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Work In Progress' -- 'Revalue WIP' -- As per Ajith, we should not add another category. Thus, I'm diverting it to reuse 'Work In Progress'. 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

		,@INV_TRANS_TYPE_Inventory_Adjustment_Qty_Change AS INT = 10
		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31
		

-- Get the GL Account ids to use
BEGIN 
	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intInventoryId 
		,intAutoNegativeId 
		,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
			,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Negative) 
			,intTransactionTypeId
	FROM	(
				SELECT DISTINCT intItemId, intItemLocationId, intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction ItemTransactions 
				WHERE	ItemTransactions.strBatchId = @strBatchId
			) Query
END 

-- Check for missing Auto Variance Account Id
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT
DECLARE @strLocationName AS NVARCHAR(50)

IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_AutoVariance 
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
			INNER JOIN dbo.tblICInventoryTransaction TRANS 
				ON TRANS.intItemId = Item.intItemId			
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	ItemGLAccount.intAutoNegativeId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intAutoNegativeId IS NULL 				 			
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Auto_Negative;
		RETURN;
	END 
END 
;

BEGIN 
	-------------------------------------------------------------------------------------------
	-- Reverse the G/L entries for the main and related transactions
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= GLEntries.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLEntries.intAccountId
			,dblDebit					= GLEntries.dblCredit	-- Reverse the Debit with Credit 
			,dblCredit					= GLEntries.dblDebit	-- Reverse the Credit with Debit 
			,dblDebitUnit				= GLEntries.dblCreditUnit 
			,dblCreditUnit				= GLEntries.dblDebitUnit 
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
			,intEntityId				= @intEntityUserSecurityId
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
			,intSourceEntityId			= GLEntries.intSourceEntityId
			,intCommodityId				= GLEntries.intCommodityId
	FROM	dbo.tblGLDetail GLEntries INNER JOIN dbo.tblICInventoryTransaction Reversal
                ON GLEntries.intJournalLineNo = Reversal.intRelatedInventoryTransactionId
				AND GLEntries.intTransactionId = Reversal.intTransactionId
				AND GLEntries.strTransactionId = Reversal.strTransactionId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = Reversal.intForexRateTypeId
	WHERE	Reversal.strBatchId = @strBatchId
			AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
			AND Reversal.intTransactionTypeId <> @InventoryTransactionTypeId_AutoVariance
			
	-------------------------------------------------------------------------------------------
	-- Reverse the G/L entries INVENTORY RETURN related to Inventory Adjustment - Qty Change
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= GLEntries.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLEntries.intAccountId
			,dblDebit					= GLEntries.dblCredit	-- Reverse the Debit with Credit 
			,dblCredit					= GLEntries.dblDebit	-- Reverse the Credit with Debit 
			,dblDebitUnit				= GLEntries.dblCreditUnit 
			,dblCreditUnit				= GLEntries.dblDebitUnit 
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
			,intEntityId				= @intEntityUserSecurityId 
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
			,intSourceEntityId			= GLEntries.intSourceEntityId
			,intCommodityId				= GLEntries.intCommodityId
	FROM	tblGLDetail GLEntries INNER JOIN (	
				tblICInventoryTransaction Reversal INNER JOIN tblICInventoryReturned rtn
					ON Reversal.intInventoryTransactionId = rtn.intInventoryTransactionId
					AND rtn.intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Adjustment_Qty_Change
			)
				ON GLEntries.intJournalLineNo = Reversal.intInventoryTransactionId
				AND GLEntries.intTransactionId = rtn.intTransactionId
				AND GLEntries.strTransactionId = rtn.strTransactionId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = Reversal.intForexRateTypeId

	WHERE	rtn.intTransactionId = @intTransactionId
			AND rtn.strTransactionId = @strTransactionId
			AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
			AND Reversal.intTransactionTypeId <> @InventoryTransactionTypeId_AutoVariance

	-----------------------------------------------------------------------------------
	-- Create the Auto-Negative G/L Entries
	-----------------------------------------------------------------------------------
	UNION ALL  
	SELECT	
			dtmDate						= ItemTransactions.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccounts.intInventoryId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= DebitUnit.Value 
			,dblCreditUnit				= CreditUnit.Value 
			,strDescription				= tblGLAccount.strDescription
			,strCode					= 'IAN' 
			,strReference				= '' 
			,intCurrencyId				= ItemTransactions.intCurrencyId
			,dblExchangeRate			= ItemTransactions.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ItemTransactions.dtmDate
			,strJournalLineDescription	= '' 
			,intJournalLineNo			= ItemTransactions.intInventoryTransactionId
			,ysnIsUnposted				= 1
			,intUserId					= @intEntityUserSecurityId
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ItemTransactions.strTransactionId
			,intTransactionId			= ItemTransactions.intTransactionId
			,strTransactionType			= @AccountCategory_Auto_Negative
			,strTransactionForm			= ItemTransactions.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL 
			,strRateType				= NULL 
			,intSourceEntityId			= ItemTransactions.intSourceEntityId
			,i.intCommodityId
	FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN tblICItem i
				ON ItemTransactions.intItemId = i.intItemId
			INNER JOIN @GLAccounts GLAccounts
				ON ItemTransactions.intItemId = GLAccounts.intItemId
				AND ItemTransactions.intItemLocationId = GLAccounts.intItemLocationId
				AND ItemTransactions.intTransactionTypeId = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount	
				ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
			CROSS APPLY dbo.fnGetDebit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Credit
			CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ItemTransactions.dblQty, 0), ISNULL(ItemTransactions.dblUOMQty, 0))) DebitUnit 
			CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ItemTransactions.dblQty, 0), ISNULL(ItemTransactions.dblUOMQty, 0))) CreditUnit 

	WHERE	ItemTransactions.strBatchId = @strBatchId
			AND ItemTransactions.intTransactionTypeId = @InventoryTransactionTypeId_AutoVariance
			AND ROUND(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0), 2) <> 0

	UNION ALL 
	SELECT	
			dtmDate						= ItemTransactions.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccounts.intAutoNegativeId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= CreditUnit.Value 
			,dblCreditUnit				= DebitUnit.Value 
			,strDescription				= tblGLAccount.strDescription
			,strCode					= 'IAN' 
			,strReference				= '' 
			,intCurrencyId				= ItemTransactions.intCurrencyId
			,dblExchangeRate			= ItemTransactions.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ItemTransactions.dtmDate
			,strJournalLineDescription	= '' 
			,intJournalLineNo			= ItemTransactions.intInventoryTransactionId
			,ysnIsUnposted				= 1
			,intUserId					= @intEntityUserSecurityId
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ItemTransactions.strTransactionId
			,intTransactionId			= ItemTransactions.intTransactionId
			,strTransactionType			= @AccountCategory_Auto_Negative
			,strTransactionForm			= ItemTransactions.strTransactionForm 
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL 
			,strRateType				= NULL 
			,intSourceEntityId			= ItemTransactions.intSourceEntityId
			,i.intCommodityId
	FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN tblICItem i
				ON ItemTransactions.intItemId = i.intItemId
			INNER JOIN @GLAccounts GLAccounts
				ON ItemTransactions.intItemId = GLAccounts.intItemId
				AND ItemTransactions.intItemLocationId = GLAccounts.intItemLocationId
				AND ItemTransactions.intTransactionTypeId = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount	
				ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
			CROSS APPLY dbo.fnGetDebit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Credit
			CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ItemTransactions.dblQty, 0), ISNULL(ItemTransactions.dblUOMQty, 0))) DebitUnit 
			CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ItemTransactions.dblQty, 0), ISNULL(ItemTransactions.dblUOMQty, 0))) CreditUnit 

	WHERE	ItemTransactions.strBatchId = @strBatchId
			AND ItemTransactions.intTransactionTypeId = @InventoryTransactionTypeId_AutoVariance
			AND ROUND(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0), 2) <> 0
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
