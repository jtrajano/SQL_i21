﻿/*
	This stored procedure will reduce the stock for the specified missing lots. 
*/

CREATE PROCEDURE [dbo].[uspICPostMissingLot]
	@MissingLotsToPost AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@strRebuildTransactionId AS NVARCHAR(50) = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@ysnRebuild AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#tmpRebuildList') IS NULL  
BEGIN 
	CREATE TABLE #tmpRebuildList (
		intItemId INT NULL 
		,intCategoryId INT NULL 
	)	
END 

IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpRebuildList)
BEGIN 
	INSERT INTO #tmpRebuildList VALUES (@intRebuildItemId, @intRebuildCategoryId) 
END 

-- Auto reduce the stock for missing lots
BEGIN 
	DECLARE @intReturnValue AS INT = 0 
	DECLARE @strBatchIdForMissingLots AS NVARCHAR(50) = @strBatchId + '2'

	IF @strGLDescription IS NOT NULL 
		SET @strGLDescription =  'Missing Lot. ' + @strGLDescription
	ELSE 
		SET @strGLDescription =  'Missing Lot.'

	EXEC @intReturnValue = dbo.uspICPostCosting  
			@MissingLotsToPost  
			,@strBatchIdForMissingLots  
			,NULL
			,@intEntityUserSecurityId
			,@strGLDescription

	-- On error, exit immediately
	IF @intReturnValue < 0 RETURN @intReturnValue
END

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
DECLARE @AccountCategory_Adjustment AS NVARCHAR(30) = 'Inventory Adjustment' 

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
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
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Adjustment) 
		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					t.intItemId
					, t.intItemLocationId 
					, t.intTransactionTypeId
			FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
						ON t.intItemId = i.intItemId
					INNER JOIN #tmpRebuildList list	
						ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
						AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
					INNER JOIN tblICLot lot
						ON lot.intLotId = t.intLotId
			WHERE	t.strBatchId = @strBatchIdForMissingLots
					AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
		) Query
			
-- Generate the G/L Entries here: 
;WITH MissingLotsCTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intInTransitSourceLocationId
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
	,strDescription
	,dblForexRate
	,strItemNo
	,strRateType
	,intSourceEntityId
	,intCommodityId	
	,strLotNumber 
	,intReference
)
AS 
(
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId 
			,t.intInTransitSourceLocationId
			,t.intTransactionId
			,t.strTransactionId
			,t.dblQty
			,t.dblUOMQty
			,t.dblCost
			,dblValue = ROUND(t.dblValue, 2) 
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) intCurrencyId
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,t.strTransactionForm 
			,t.strDescription
			,t.dblForexRate	
			,i.strItemNo
			,strRateType = currencyRateType.strCurrencyExchangeRateType			
			,t.intSourceEntityId
			,i.intCommodityId			
			,lot.strLotNumber
			,intReference = CAST(1 AS TINYINT)
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)		
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
			LEFT JOIN tblICLot lot
				ON lot.intLotId = t.intLotId
	WHERE	t.strBatchId = @strBatchIdForMissingLots
) 
----------------------------------------------------------------------------------------------
-- GL entries for the missing lots. 
----------------------------------------------------------------------------------------------
/*
	Debit ........... Inventory Adjustment 
	Credit .............................. Inventory 
*/
SELECT	
		dtmDate						= MissingLotsCTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value 
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= 
			ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
			+ ' ' 
			+ dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost, strLotNumber) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= MissingLotsCTE.intCurrencyId
		,dblExchangeRate			= MissingLotsCTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= MissingLotsCTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= MissingLotsCTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= MissingLotsCTE.strTransactionId
		,intTransactionId			= MissingLotsCTE.intTransactionId
		,strTransactionType			= MissingLotsCTE.strInventoryTransactionTypeName
		,strTransactionForm			= MissingLotsCTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= MissingLotsCTE.dblForexRate 
		,strRateType				= MissingLotsCTE.strRateType 
		,intSourceEntityId			= MissingLotsCTE.intSourceEntityId 
		,intCommodityId				= MissingLotsCTE.intCommodityId 
FROM	MissingLotsCTE  
		INNER JOIN @GLAccounts GLAccounts
			ON MissingLotsCTE.intItemId = GLAccounts.intItemId
			AND MissingLotsCTE.intItemLocationId = GLAccounts.intItemLocationId
			AND MissingLotsCTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 
WHERE	
	MissingLotsCTE.intTransactionTypeId NOT IN (
		@InventoryTransactionTypeId_WriteOffSold
		, @InventoryTransactionTypeId_RevalueSold
		, @InventoryTransactionTypeId_AutoNegative
		, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
	)

UNION ALL 
SELECT	
		dtmDate						= MissingLotsCTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.[Value]
		,dblCredit					= Debit.[Value]
		,dblDebitUnit				= CreditUnit.[Value]
		,dblCreditUnit				= DebitUnit.[Value]
		,strDescription				= 
			ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
			+ ' ' 
			+ dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost, strLotNumber) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= MissingLotsCTE.intCurrencyId
		,dblExchangeRate			= MissingLotsCTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= MissingLotsCTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= MissingLotsCTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= MissingLotsCTE.strTransactionId
		,intTransactionId			= MissingLotsCTE.intTransactionId
		,strTransactionType			= MissingLotsCTE.strInventoryTransactionTypeName
		,strTransactionForm			= MissingLotsCTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.[Value] END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.[Value] END
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= MissingLotsCTE.dblForexRate 
		,strRateType				= MissingLotsCTE.strRateType 
		,intSourceEntityId			= MissingLotsCTE.intSourceEntityId 
		,intCommodityId				= MissingLotsCTE.intCommodityId 
FROM	MissingLotsCTE  
		INNER JOIN @GLAccounts GLAccounts
			ON MissingLotsCTE.intItemId = GLAccounts.intItemId
			AND MissingLotsCTE.intItemLocationId = GLAccounts.intItemLocationId
			AND MissingLotsCTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 
WHERE	
	MissingLotsCTE.intTransactionTypeId NOT IN (
		@InventoryTransactionTypeId_WriteOffSold
		, @InventoryTransactionTypeId_RevalueSold
		, @InventoryTransactionTypeId_AutoNegative
		, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
	)
-----------------------------------------------------------------------------------
-- GL entries for Auto Variance 
-----------------------------------------------------------------------------------
/*
	Debit ........... Inventory 
	Credit .............................. Inventory Adjustment 
*/
UNION ALL  
SELECT	
		dtmDate						= MissingLotsCTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value 
		,dblCreditUnit				= CreditUnit.Value 
		,strDescription				= 
			ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
			+ ' ' 
			+ dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost, strLotNumber) 
		,strCode					= 
			CASE 
				WHEN MissingLotsCTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock THEN 'IAV'
				WHEN MissingLotsCTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative THEN 'IAN'
				ELSE 'IC'
			END 
		,strReference				= ''
		,intCurrencyId				= MissingLotsCTE.intCurrencyId
		,dblExchangeRate			= MissingLotsCTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= MissingLotsCTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= MissingLotsCTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= MissingLotsCTE.strTransactionId
		,intTransactionId			= MissingLotsCTE.intTransactionId
		,strTransactionType			= MissingLotsCTE.strInventoryTransactionTypeName
		,strTransactionForm			= MissingLotsCTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= MissingLotsCTE.dblForexRate 
		,strRateType				= MissingLotsCTE.strRateType 
		,intSourceEntityId			= MissingLotsCTE.intSourceEntityId
		,intCommodityId				= MissingLotsCTE.intCommodityId
FROM	MissingLotsCTE 
		INNER JOIN @GLAccounts GLAccounts
			ON MissingLotsCTE.intItemId = GLAccounts.intItemId
			AND MissingLotsCTE.intItemLocationId = GLAccounts.intItemLocationId
			AND MissingLotsCTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	MissingLotsCTE.intTransactionTypeId IN (
			@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			, @InventoryTransactionTypeId_AutoNegative
		) 
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

UNION ALL 
SELECT	
		dtmDate						= MissingLotsCTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value 
		,dblCreditUnit				= DebitUnit.Value 
		,strDescription				= 
			ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
			+ ' ' 
			+ dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost, strLotNumber) 
		,strCode					= 
			CASE 
				WHEN MissingLotsCTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock THEN 'IAV'
				WHEN MissingLotsCTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative THEN 'IAN'
				ELSE 'IC'
			END 
		,strReference				= '' 
		,intCurrencyId				= MissingLotsCTE.intCurrencyId
		,dblExchangeRate			= MissingLotsCTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= MissingLotsCTE.dtmDate
        ,strJournalLineDescription    = '' 
		,intJournalLineNo			= MissingLotsCTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= MissingLotsCTE.strTransactionId
		,intTransactionId			= MissingLotsCTE.intTransactionId
		,strTransactionType			= MissingLotsCTE.strInventoryTransactionTypeName 
		,strTransactionForm			= MissingLotsCTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CreditForeign.Value
		,dblDebitReport				= NULL 
		,dblCreditForeign			= DebitForeign.Value 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= MissingLotsCTE.dblForexRate 
		,strRateType				= MissingLotsCTE.strRateType 
		,intSourceEntityId			= MissingLotsCTE.intSourceEntityId
		,intCommodityId				= MissingLotsCTE.intCommodityId
FROM	MissingLotsCTE 
		INNER JOIN @GLAccounts GLAccounts
			ON MissingLotsCTE.intItemId = GLAccounts.intItemId
			AND MissingLotsCTE.intItemLocationId = GLAccounts.intItemLocationId
			AND MissingLotsCTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
			,MissingLotsCTE.intCurrencyId
			,@intFunctionalCurrencyId
			,MissingLotsCTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	MissingLotsCTE.intTransactionTypeId IN (
			@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			, @InventoryTransactionTypeId_AutoNegative
		) 
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 


-- Update the Lot's Qty and Weights. 
-- The Lot Qty should not be zero for Missing Lots so that it can be used to track insurance claims. 
BEGIN 
	UPDATE	Lot 
	SET		Lot.dblQty =	
				dbo.fnCalculateLotQty(
					Lot.intItemUOMId
					, missingLots.intItemUOMId
					, Lot.dblQty
					, Lot.dblWeight
					, -missingLots.dblQty
					, Lot.dblWeightPerQty
				)
			,Lot.dblWeight = 
				dbo.fnCalculateLotWeight(
					Lot.intItemUOMId
					, Lot.intWeightUOMId
					, missingLots.intItemUOMId
					, Lot.dblWeight
					, -missingLots.dblQty
					, Lot.dblWeightPerQty
				)						
	FROM	dbo.tblICLot Lot INNER JOIN @MissingLotsToPost missingLots
				ON Lot.intLotId = missingLots.intLotId
				AND Lot.intItemId = missingLots.intItemId
				AND Lot.intItemLocationId = missingLots.intItemLocationId

	UPDATE	Lot 
	SET		Lot.dblTare = dbo.fnMultiply(Lot.dblQty, Lot.dblTarePerQty) 
			,Lot.dblGrossWeight = dbo.fnMultiply(Lot.dblQty, Lot.dblTarePerQty) + Lot.dblWeight
	FROM	dbo.tblICLot Lot INNER JOIN @MissingLotsToPost missingLots
				ON Lot.intLotId = missingLots.intLotId
				AND Lot.intItemId = missingLots.intItemId
				AND Lot.intItemLocationId = missingLots.intItemLocationId
				AND ISNULL(Lot.dblTarePerQty, 0) <> 0 				
END 

-- Fix the batch ids
BEGIN 
	UPDATE t
	SET
		t.strBatchId = @strBatchId
	FROM tblICInventoryTransaction t 
	WHERE 
		t.strBatchId = @strBatchIdForMissingLots	
END 

RETURN 0; 
_Exit:
