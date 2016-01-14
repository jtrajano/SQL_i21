﻿CREATE PROCEDURE [dbo].[uspICCreateReversalGLEntries]
	@strBatchId AS NVARCHAR(20)
	,@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;

--1	Inventory Auto Negative
--2	Inventory Write-Off Sold
--3	Inventory Revalue Sold
--4	Inventory Receipt
--5	Inventory Shipment

DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

DECLARE @GLAccounts AS dbo.ItemGLAccount; 

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_Write_Off_Sold AS NVARCHAR(30) = 'Write-Off Sold'
		,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Revalue Sold'
		,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Auto-Negative'

		,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'Cost Adjustment'
		,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Revalue WIP'
		,@AccountCategory_Revalue_Produced AS NVARCHAR(30) = 'Revalue Produced'
		,@AccountCategory_Revalue_Transfer AS NVARCHAR(30) = 'Revalue Inventory Transfer'
		,@AccountCategory_Revalue_Build_Assembly AS NVARCHAR(30) = 'Revalue Build Assembly'		

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 22
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 24
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 25
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 26
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 27


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

-- Check for missing Auto Negative Account Id
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT

IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative 
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
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Auto_Negative) 	
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
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
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
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= GLEntries.strTransactionId
			,intTransactionId			= GLEntries.intTransactionId
			,strTransactionType			= GLEntries.strTransactionType
			,strTransactionForm			= GLEntries.strTransactionForm
			,strModuleName				= GLEntries.strModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= GLEntries.dblDebitForeign 
			,dblDebitReport				= GLEntries.dblDebitReport
			,dblCreditForeign			= GLEntries.dblCreditForeign
			,dblCreditReport			= GLEntries.dblCreditReport
			,dblReportingRate			= GLEntries.dblReportingRate
			,dblForeignRate				= GLEntries.dblForeignRate
	FROM	dbo.tblGLDetail GLEntries INNER JOIN dbo.tblICInventoryTransaction Reversal
				ON GLEntries.intJournalLineNo = Reversal.intRelatedInventoryTransactionId
				AND (
						(
							GLEntries.intTransactionId = Reversal.intTransactionId
							AND GLEntries.strTransactionId = Reversal.strTransactionId
						)
						OR (
							GLEntries.intTransactionId = Reversal.intRelatedTransactionId
							AND GLEntries.strTransactionId = Reversal.strRelatedTransactionId					
						)					
				)
	WHERE	Reversal.strBatchId = @strBatchId
			AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
			AND Reversal.intTransactionTypeId <> @InventoryTransactionTypeId_AutoNegative
			
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
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
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
			,intUserId					= NULL 
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
	FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN @GLAccounts GLAccounts
				ON ItemTransactions.intItemId = GLAccounts.intItemId
				AND ItemTransactions.intItemLocationId = GLAccounts.intItemLocationId
				AND ItemTransactions.intTransactionTypeId = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount	
				ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
			CROSS APPLY dbo.fnGetDebit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Credit
	WHERE	ItemTransactions.strBatchId = @strBatchId
			AND ItemTransactions.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative

	UNION ALL 
	SELECT	
			dtmDate						= ItemTransactions.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccounts.intAutoNegativeId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
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
			,intUserId					= NULL 
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
	FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN @GLAccounts GLAccounts
				ON ItemTransactions.intItemId = GLAccounts.intItemId
				AND ItemTransactions.intItemLocationId = GLAccounts.intItemLocationId
				AND ItemTransactions.intTransactionTypeId = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount	
				ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
			CROSS APPLY dbo.fnGetDebit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Debit
			CROSS APPLY dbo.fnGetCredit(ISNULL(ItemTransactions.dblQty, 0) * ISNULL(ItemTransactions.dblUOMQty, 0) * ISNULL(ItemTransactions.dblCost, 0) + ISNULL(ItemTransactions.dblValue, 0)) Credit
	WHERE	ItemTransactions.strBatchId = @strBatchId
			AND ItemTransactions.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative
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
