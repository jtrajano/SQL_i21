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
DECLARE @AUTO_NEGATIVE_TransactionType AS NVARCHAR(50) = 'Auto-Negative';
DECLARE @WRITEOFF_SOLD_TransactionType AS NVARCHAR(50) = 'Write-Off Sold';
DECLARE @REVALUE_SOLD_TransactionType AS NVARCHAR(50) = 'Revalue Sold';

DECLARE @GLAccounts AS dbo.ItemGLAccount; 
DECLARE @UseGLAccount_Inventory AS NVARCHAR(30) = 'Inventory';
DECLARE @UseGLAccount_AutoNegative AS NVARCHAR(30) = 'Auto-Negative';

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
			,intInventoryId = Inventory.intAccountId
			,intAutoNegativeId = AutoNegative.intAccountId
			,Query.intTransactionTypeId
	FROM	(
				SELECT DISTINCT intItemId, intItemLocationId, intTransactionTypeId 
				FROM	dbo.tblICInventoryTransaction ItemTransactions 
				WHERE	ItemTransactions.strBatchId = @strBatchId
			) Query
			OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @UseGLAccount_Inventory) Inventory
			OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @UseGLAccount_AutoNegative) AutoNegative;
END 

-- Check for missing Auto Negative Account Id
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT

BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intAutoNegativeId IS NULL 
			AND EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				WHERE	TRANS.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative 
						AND TRANS.intItemId = Item.intItemId
			)
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AUTO_NEGATIVE_TransactionType) 	
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
			,intUserId					= NULL -- @intUserId 
			,intEntityId				= @intEntityUserSecurityId -- @intUserId 
			,strTransactionId			= GLEntries.strTransactionId
			,intTransactionId			= GLEntries.intTransactionId
			,strTransactionType			= GLEntries.strTransactionType
			,strTransactionForm			= GLEntries.strTransactionForm
			,strModuleName				= GLEntries.strModuleName
			,intConcurrencyId			= 1
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
			,intUserId					= NULL -- @intUserId 
			,intEntityId				= @intEntityUserSecurityId -- @intUserId 
			,strTransactionId			= ItemTransactions.strTransactionId
			,intTransactionId			= ItemTransactions.intTransactionId
			,strTransactionType			= @AUTO_NEGATIVE_TransactionType
			,strTransactionForm			= ItemTransactions.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
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
			,intUserId					= NULL -- @intUserId 
			,intEntityId				= @intEntityUserSecurityId -- @intUserId 
			,strTransactionId			= ItemTransactions.strTransactionId
			,intTransactionId			= ItemTransactions.intTransactionId
			,strTransactionType			= @AUTO_NEGATIVE_TransactionType
			,strTransactionForm			= ItemTransactions.strTransactionForm 
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
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
			AND strTransactionType <> @AUTO_NEGATIVE_TransactionType
	;
	-- Update the ysnPostedFlag for the related transactions
	UPDATE	GLEntries
	SET		ysnIsUnposted = 1
	FROM	dbo.tblGLDetail GLEntries INNER JOIN dbo.tblICInventoryTransaction ItemTransactions 
				ON GLEntries.intJournalLineNo = ItemTransactions.intInventoryTransactionId
				AND GLEntries.intTransactionId = ItemTransactions.intRelatedTransactionId
				AND GLEntries.strTransactionId = ItemTransactions.strRelatedTransactionId
	WHERE	ItemTransactions.strBatchId = @strBatchId
			AND GLEntries.strTransactionType <> @AUTO_NEGATIVE_TransactionType
	;
END 
