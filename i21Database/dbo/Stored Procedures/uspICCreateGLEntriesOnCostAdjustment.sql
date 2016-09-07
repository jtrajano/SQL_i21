CREATE PROCEDURE [dbo].[uspICCreateGLEntriesOnCostAdjustment]
	@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		--,@AccountCategory_Write_Off_Sold AS NVARCHAR(30) = 'Write-Off Sold'
		--,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Revalue Sold'
		,@AccountCategory_Auto_Negative AS NVARCHAR(30) = 'Auto-Variance'

		,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'Auto-Variance' -- 'Cost Adjustment' -- As per Ajith, the system should re-use Auto-Negative. 
		,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Work In Progress' -- 'Revalue WIP' -- As per Ajith, we should not add another category. Thus, I'm diverting it to reuse 'Work In Progress'. 
		--,@AccountCategory_Revalue_Produced AS NVARCHAR(30) = 'Revalue Produced'
		--,@AccountCategory_Revalue_Transfer AS NVARCHAR(30) = 'Revalue Inventory Transfer'
		--,@AccountCategory_Revalue_Build_Assembly AS NVARCHAR(30) = 'Revalue Build Assembly'		

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		--,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		--,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3
		,@INV_TRANS_TYPE_Auto_Varianc_On_Sold_Or_Used_Stock AS INT = 35

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

		,@INV_TRANS_TYPE_Revalue_Item_Change AS INT = 35
		,@INV_TRANS_TYPE_Revalue_Split_Lot AS INT = 36
		,@INV_TRANS_TYPE_Revalue_Lot_Merge AS INT = 37
		,@INV_TRANS_TYPE_Revalue_Lot_Move AS INT = 38

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intInventoryId 
		--,intWriteOffSoldId 
		--,intRevalueSoldId 
		,intAutoNegativeId 
		,intCostAdjustment 
		,intRevalueWIP 
		,intRevalueProduced 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		--,intRevalueAdjItemChange 
		--,intRevalueAdjSplitLot 
		--,intRevalueAdjLotMerge
		--,intRevalueAdjLotMove
		,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		--,intWriteOffSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Write_Off_Sold) 
		--,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_Sold) 
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Negative) 
		,intCostAdjustment = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
		,intRevalueWIP = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_WIP) 

		,intRevalueProduced = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_WIP) 
		,intRevalueTransfer = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intRevalueBuildAssembly = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 

		--,intRevalueAdjItemChange = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory)
		--,intRevalueAdjSplitLot = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory)
		--,intRevalueAdjLotMerge = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory)
		--,intRevalueAdjLotMove = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory)

		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					intItemId, intItemLocationId, intTransactionTypeId
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
		) Query

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 

-- Check for missing Inventory Account Id
BEGIN 
	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Inventory) 	
		RETURN -1;
	END 
END 
;

---- Check for missing Write-Off Sold Account Id
--IF EXISTS (
--	SELECT	TOP 1 1 
--	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--	WHERE	TRANS.strBatchId = @strBatchId
--			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Write_Off_Sold 
--)
--BEGIN 
--	SET @strItemNo = NULL
--	SET @intItemId = NULL

--	SELECT	TOP 1 
--			@intItemId = Item.intItemId 
--			,@strItemNo = Item.strItemNo
--	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
--				ON Item.intItemId = ItemGLAccount.intItemId
--			INNER JOIN dbo.tblICInventoryTransaction TRANS 
--				ON TRANS.intItemId = Item.intItemId			
--			INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--				AND TRANS.intItemId = Item.intItemId
--	WHERE	ItemGLAccount.intWriteOffSoldId IS NULL 
	
--	IF @intItemId IS NOT NULL 
--	BEGIN 
--		-- {Item} is missing a GL account setup for {Account Category} account category.
--		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Write_Off_Sold) 	
--		RETURN -1;
--	END 
--END 
--;

---- Check for missing Revalue Sold Account id
--IF EXISTS (
--	SELECT	TOP 1 1 
--	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--	WHERE	TRANS.strBatchId = @strBatchId
--			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold  
--)
--BEGIN 
--	SET @strItemNo = NULL
--	SET @intItemId = NULL

--	SELECT	TOP 1 
--			@intItemId = Item.intItemId 
--			,@strItemNo = Item.strItemNo
--	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
--				ON Item.intItemId = ItemGLAccount.intItemId
--			INNER JOIN dbo.tblICInventoryTransaction TRANS 
--				ON TRANS.intItemId = Item.intItemId			
--			INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--				AND TRANS.intItemId = Item.intItemId
--	WHERE	ItemGLAccount.intRevalueSoldId IS NULL 
	
--	IF @intItemId IS NOT NULL 
--	BEGIN 
--		-- {Item} is missing a GL account setup for {Account Category} account category.
--		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Revalue_Sold) 	
--		RETURN -1;
--	END 
--END 
--;

-- Check for missing Auto Variance Account Id
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Negative 
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
				AND TRANS.intItemId = Item.intItemId
	WHERE	ItemGLAccount.intAutoNegativeId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Auto_Negative) 	
		RETURN -1;
	END 
END 
;

-- Check for missing Cost Adjustment Account Id
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
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
				AND TRANS.intItemId = Item.intItemId
	WHERE	ItemGLAccount.intCostAdjustment IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Cost Adjustment} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Cost_Adjustment) 	
		RETURN -1;
	END 
END 
;

---- Check for missing Revalue WIP account id.
--IF EXISTS (
--	SELECT	TOP 1 1 	
--	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--	WHERE	TRANS.strBatchId = @strBatchId
--			AND TRANS.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_WIP
--)
--BEGIN 
--	SET @strItemNo = NULL
--	SET @intItemId = NULL

--	SELECT	TOP 1 
--			@intItemId = Item.intItemId 
--			,@strItemNo = Item.strItemNo
--	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
--				ON Item.intItemId = ItemGLAccount.intItemId
--			INNER JOIN dbo.tblICInventoryTransaction TRANS 
--				ON TRANS.intItemId = Item.intItemId			
--			INNER JOIN dbo.tblICInventoryTransactionType TransType
--				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
--				AND TRANS.intItemId = Item.intItemId
--	WHERE	ItemGLAccount.intRevalueWIP IS NULL 
	
--	IF @intItemId IS NOT NULL 
--	BEGIN 
--		-- {Item} is missing a GL account setup for {Revalue WIP} account category.
--		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Revalue_WIP) 	
--		RETURN -1;
--	END 
--END 
;

/*-------------------------------------------------------------------------------------------
 Note:  No need to validate for the missing: 

	1. Revalue Produced account id.
	2. Revalue Inventory Transfer account id.
	3. Revalue Inventory Build Assembly account id.

The system should validate for the missing WIP and/or Inventory account in their place. 
-------------------------------------------------------------------------------------------*/

-- Log the g/l account used in this batch. 
INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId
		,intWriteOffSoldId
		,intRevalueSoldId
		,intAutoNegativeId
		,intCostAdjustment 
		,intRevalueWIP 
		,intRevalueProduced 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId
		,intWriteOffSoldId
		,intRevalueSoldId
		,intAutoNegativeId
		,intCostAdjustment 
		,intRevalueWIP 
		,intRevalueProduced 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,@strBatchId
FROM	@GLAccounts
;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intTransactionId
	,strTransactionId
	,dblQty
	,dblUOMQty
	,dblCost
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
	,intInventoryTransactionId
	,strInventoryTransactionTypeName
	,strTransactionForm
)
AS 
(
	SELECT	TRANS.dtmDate
			,TRANS.intItemId
			,TRANS.intItemLocationId
			,TRANS.intTransactionId
			,TRANS.strTransactionId
			,TRANS.dblQty
			,TRANS.dblUOMQty
			,TRANS.dblCost
			,TRANS.dblValue
			,TRANS.intTransactionTypeId
			,TRANS.intCurrencyId
			,TRANS.dblExchangeRate
			,TRANS.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,'Bill' -- TRANS.strTransactionForm 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
)

-------------------------------------------------------------------------------------
---- This part is for the Write-Off Sold 
-------------------------------------------------------------------------------------
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= GLAccounts.intInventoryId
--		,dblDebit					= Debit.Value
--		,dblCredit					= Credit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'IWS'
--		,strReference				= ''
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL 
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm 
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE 			
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
--		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
--		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Write_Off_Sold
--UNION ALL 
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= GLAccounts.intWriteOffSoldId
--		,dblDebit					= Credit.Value
--		,dblCredit					= Debit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'IWS' 
--		,strReference				= '' 
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription    = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL  
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName 
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE 
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intWriteOffSoldId
--		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
--		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Write_Off_Sold

-------------------------------------------------------------------------------------
---- This part is for the Revalue Sold 
-------------------------------------------------------------------------------------
--UNION ALL  
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= GLAccounts.intInventoryId
--		,dblDebit					= Debit.Value
--		,dblCredit					= Credit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'IRS' -- TODO
--		,strReference				= '' -- TODO
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL 
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
--		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
--		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold
--UNION ALL 
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= GLAccounts.intRevalueSoldId
--		,dblDebit					= Credit.Value
--		,dblCredit					= Debit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'IRS' 
--		,strReference				= '' 
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL 
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE 
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
--		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
--		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Revalue_Sold

-----------------------------------------------------------------------------------
-- This part is for Auto Variance on Sold or Used Stock
-----------------------------------------------------------------------------------
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Varianc_On_Sold_Or_Used_Stock
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intAutoNegativeId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Auto_Varianc_On_Sold_Or_Used_Stock

-----------------------------------------------------------------------------------
-- This part is for the Auto-Negative 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Negative
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intAutoNegativeId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Auto_Negative

-----------------------------------------------------------------------------------
-- This part is for the Cost Adjustment
-- Inventory (Asset) .............. Debit
-- Cost Adjustment (Expense) ................. Credit
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'ICA' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'ICA' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intCostAdjustment
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Cost_Adjustment


/*----------------------------------------------------------------------------------
	This part is for Revalue WIP

	If value is positive: 
	Inventory (Asset/Inventory) ........ Debit
	WIP (Asset/Inventory) ....................... Credit

	If value is negative: 
	WIP (Asset/Inventory) .............. Debit
	Inventory (Asset/Inventory) ................. Credit
-----------------------------------------------------------------------------------*/
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RWIP' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_WIP
--UNION ALL 
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= tblGLAccount.intAccountId
--		,dblDebit					= Credit.Value
--		,dblCredit					= Debit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'RWIP' 
--		,strReference				= '' 
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL  
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE 
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intRevalueWIP
--		CROSS APPLY dbo.fnGetDebit(
--			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
--		) Debit
--		CROSS APPLY dbo.fnGetCredit(
--			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
--		) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Revalue_WIP

-----------------------------------------------------------------------------------
-- This part is for Revalue Produced
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RPRD' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Produced
--UNION ALL 
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= tblGLAccount.intAccountId
--		,dblDebit					= Credit.Value
--		,dblCredit					= Debit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
--		,strCode					= 'RPRD' 
--		,strReference				= '' 
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
--		,intUserId					= NULL  
--		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,[dblDebitForeign]			= NULL
--		,[dblDebitReport]			= NULL
--		,[dblCreditForeign]			= NULL
--		,[dblCreditReport]			= NULL
--		,[dblReportingRate]			= NULL
--		,[dblForeignRate]			= NULL
--FROM	ForGLEntries_CTE 
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intRevalueProduced
--		CROSS APPLY dbo.fnGetDebit(
--			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
--		) Debit
--		CROSS APPLY dbo.fnGetCredit(
--			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
--		) Credit
--WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Revalue_Produced

-----------------------------------------------------------------------------------
-- This part is for Revalue Transfer
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RTRF' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Transfer

-----------------------------------------------------------------------------------
-- This part is for Revalue Build Assembly. 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RBLD' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Build_Assembly

-----------------------------------------------------------------------------------
-- This part is for Revalue Item Change. 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RIC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Item_Change

-----------------------------------------------------------------------------------
-- This part is for Revalue Split Lot. 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RSL' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Split_Lot

-----------------------------------------------------------------------------------
-- This part is for Revalue Lot Merge. 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RLMG' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Merge

-----------------------------------------------------------------------------------
-- This part is for Revalue Lot Move. 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'RLMV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,[dblDebitForeign]			= NULL
		,[dblDebitReport]			= NULL
		,[dblCreditForeign]			= NULL
		,[dblCreditReport]			= NULL
		,[dblReportingRate]			= NULL
		,[dblForeignRate]			= NULL
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Move


;