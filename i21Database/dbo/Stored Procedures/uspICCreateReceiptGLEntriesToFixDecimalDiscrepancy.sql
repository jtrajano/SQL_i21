CREATE PROCEDURE [dbo].[uspICCreateReceiptGLEntriesToFixDecimalDiscrepancy]
	@strReceiptNumber AS NVARCHAR(50) = NULL 
	,@strBatchId AS NVARCHAR(50) = NULL 
	,@GLEntries RecapTableType READONLY
	,@intEntityUserSecurityId AS INT 
	,@strGLDescription AS NVARCHAR(255) = NULL 	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

DECLARE @icGLAccounts TABLE (
	intItemId INT
	,intItemLocationId INT 
	,intInventoryAccountId INT NULL 
	,intInventoryAdjustmentAccountId INT NULL 
)

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy_result') IS NOT NULL  
BEGIN 
	DROP TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy_result
END 

IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy_result') IS NULL  
BEGIN 
	CREATE TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy_result (
		intId INT IDENTITY(1, 1) 
		,strTransactionType NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblICAmount NUMERIC(18, 6) NULL 
		,dblGLAmount NUMERIC(18, 6) NULL 
		,intAccountId INT NULL 
		,strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strAccountDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	)
END 

-- Get the GL Account Id
BEGIN 
	INSERT INTO @icGLAccounts (
		intItemId
		,intItemLocationId
		,intInventoryAccountId
		,intInventoryAdjustmentAccountId 
	)
	SELECT 
		query.intItemId
		,query.intItemLocationId
		,intInventoryAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'Inventory')
		,intInventoryAdjustmentAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'Inventory Adjustment')
	FROM (
		SELECT
			DISTINCT 
			t.intItemId
			,t.intItemLocationId 
		FROM 
			tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId			
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId 
		WHERE
			t.strTransactionId = @strReceiptNumber
			AND t.strBatchId = @strBatchId			
			AND t.intInTransitSourceLocationId IS NULL 
	) query
END 

-- Get the inventory value from the Inventory Valuation 
BEGIN 
	INSERT INTO #uspICReceiptGLEntriesForDecimalDiscrepancy_result (
		strTransactionType 
		,strTransactionId
		,strBatchId
		,dblICAmount
		,intAccountId  
	)
	SELECT	
		[strTransactionType] = ty.strName
		,[strTransactionId] = t.strTransactionId
		,[strBatchId] = t.strBatchId			
		,[dblICAmount] = 
			SUM (
				ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
			)
		,[intAccountId] = icGLAccount.intInventoryAccountId
	FROM	
		tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId			
		INNER JOIN tblICItem i
			ON i.intItemId = t.intItemId 
		INNER JOIN @icGLAccounts icGLAccount
			ON icGLAccount.intItemId = t.intItemId
			AND icGLAccount.intItemLocationId = t.intItemLocationId
	WHERE	
		t.strTransactionId = @strReceiptNumber
		AND t.strBatchId = @strBatchId
		AND t.ysnIsUnposted = 0 
	GROUP BY 
		ty.strName 
		,t.strTransactionId
		,t.strBatchId
		,icGLAccount.intInventoryAccountId
END 
	
-- Get the inventory value from @GLEntries 
IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
BEGIN 		
	MERGE INTO #uspICReceiptGLEntriesForDecimalDiscrepancy_result 
	AS result
	USING (
		SELECT 
			[strTransactionType] = gd.strTransactionType
			,[strTransactionId] = gd.strTransactionId
			,[strBatchId] = gd.strBatchId
			,[intAccountId] = gd.intAccountId 
			,[dblGLAmount] = SUM(ROUND(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0),2))			
			,[strAccountDescription] = ga.strDescription
		FROM	
			@GLEntries gd INNER JOIN tblGLAccount ga
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
		WHERE 			
			ac.strAccountCategory IN ('Inventory')
		GROUP BY 				
			gd.strTransactionType
			,gd.strTransactionId
			,gd.strBatchId
			,gd.intAccountId 
			,ga.strDescription
	) AS glResult 
		ON 
			result.strTransactionId = glResult.strTransactionId
			AND result.strBatchId = glResult.strBatchId
			AND result.strTransactionType = glResult.strTransactionType
			AND result.intAccountId = glResult.intAccountId
				
	WHEN MATCHED THEN 
		UPDATE 
		SET 
			dblGLAmount = ISNULL(result.dblGLAmount, 0) + ISNULL(glResult.[dblGLAmount], 0)

	WHEN NOT MATCHED THEN
		INSERT (
			strTransactionType 
			,strTransactionId
			,dblGLAmount
			,strAccountDescription
		)	 
		VALUES (
			glResult.[strTransactionType]
			,glResult.[strTransactionId]
			,glResult.[dblGLAmount]
			,glResult.[strAccountDescription]
		)
	;		
END 



DECLARE @Threshold NUMERIC(38, 20)
DECLARE @Variance NUMERIC(38, 20)
DECLARE @OverThresholdLimit BIT
SET @Threshold = 0.05
SET @OverThresholdLimit = 0

SELECT TOP 1 @Variance = SUM(ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0))
FROM #uspICReceiptGLEntriesForDecimalDiscrepancy_result 
GROUP BY intAccountId

IF ABS(@Variance) <= @Threshold
	SET @OverThresholdLimit = 1

IF @OverThresholdLimit = 1
BEGIN
	-- Generate the G/L Entries here: 
	WITH ForGLEntries_CTE (
		strTransactionId
		,strBatchId
		,intAccountId
		,dblDiscrepancy
	)
	AS 
	(
		SELECT 
			strTransactionId
			,strBatchId
			,intAccountId
			,dblDiscrepancy = SUM(ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0))
		FROM 
			#uspICReceiptGLEntriesForDecimalDiscrepancy_result 
		GROUP BY 
			strTransactionId
			,strBatchId
			,intAccountId
		HAVING 
			SUM(ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0)) <> 0
	)
	-----------------------------------------------------------------------------------
	-- This part creates the GL entries for the decimal discrepancy. 
	-----------------------------------------------------------------------------------
	/*
		Debit ........... Inventory
		Credit .............................. COGS (Auto Variance aka Inventory Adjustment)
	*/

	SELECT 
		[dtmDate] = t.dtmDate
		,[strBatchId] = t.strBatchId
		,[intAccountId] = ga.intAccountId
		,[dblDebit] = Debit.[Value]
		,[dblCredit] = Credit.[Value]
		,[dblDebitUnit] = 0 
		,[dblCreditUnit] = 0 
		,[strDescription] = 
			ISNULL(@strGLDescription, ISNULL(ga.strDescription, '')) + ' ' 
			+ dbo.fnFormatMessage(
				'Resolve the decimal discrepancy for %s.'
				,i.strItemNo
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)
		,[strCode] = 'IC'
		,[strReference] = ''
		,[intCurrencyId] = t.intCurrencyId
		,[dblExchangeRate] = t.dblForexRate
		,[dtmDateEntered] = GETDATE()
		,[dtmTransactionDate] = t.dtmDate
		,[strJournalLineDescription] = ''
		,[intJournalLineNo] = t.intInventoryTransactionId
		,[ysnIsUnposted] = 0 
		,[intUserId] = @intEntityUserSecurityId
		,[intEntityId] = @intEntityUserSecurityId 
		,[strTransactionId] = t.strTransactionId
		,[intTransactionId] = t.intTransactionId
		,[strTransactionType] = ty.strName
		,[strTransactionForm] = ty.strTransactionForm
		,[strModuleName] = @ModuleName
		,[intConcurrencyId] = 1
		,[dblDebitForeign] = NULL 
		,[dblDebitReport] = NULL 
		,[dblCreditForeign]	= NULL 
		,[dblCreditReport] = NULL 
		,[dblReportingRate] = NULL 
		,[dblForeignRate] = t.dblForexRate
		,[strRateType] = currencyRateType.strCurrencyExchangeRateType
		,[intSourceEntityId] = t.intSourceEntityId
		,[intCommodityId] = i.intCommodityId
	FROM 
		ForGLEntries_CTE cte CROSS APPLY (
			SELECT TOP 1 
				icGLAccnts.*
			FROM 
				@icGLAccounts icGLAccnts 
			WHERE 
				icGLAccnts.intInventoryAccountId = cte.intAccountId
		) icGLAccnts
		INNER JOIN dbo.tblGLAccount ga 
			ON ga.intAccountId = icGLAccnts.intInventoryAccountId
		CROSS APPLY (
			SELECT TOP 1 
				t.*
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.strTransactionId = cte.strTransactionId
				AND t.strBatchId = cte.strBatchId
				AND t.intItemId = icGLAccnts.intItemId 
				AND t.intItemLocationId = icGLAccnts.intItemLocationId 
				AND t.dblQty <> 0 
				AND t.intInTransitSourceLocationId IS NULL 
			ORDER BY
				t.intInventoryTransactionId DESC 
		) t 
		INNER JOIN tblICItem i 
			ON i.intItemId = t.intItemId
		CROSS APPLY dbo.fnGetDebit(
			cte.dblDiscrepancy 
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			cte.dblDiscrepancy 
		) Credit
		LEFT JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId
		LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
			ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	

	UNION ALL
	SELECT 
		[dtmDate] = t.dtmDate
		,[strBatchId] = t.strBatchId
		,[intAccountId] = ga.intAccountId
		,[dblDebit] = Credit.[Value]
		,[dblCredit] = Debit.[Value]
		,[dblDebitUnit] = 0 
		,[dblCreditUnit] = 0 
		,[strDescription] = 
			ISNULL(@strGLDescription, ISNULL(ga.strDescription, '')) + ' ' 
			+ dbo.fnFormatMessage(
				'Resolve the decimal discrepancy for %s.'
				,i.strItemNo
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
				,DEFAULT 
			)
		,[strCode] = 'IC'
		,[strReference] = ''
		,[intCurrencyId] = t.intCurrencyId
		,[dblExchangeRate] = t.dblForexRate
		,[dtmDateEntered] = GETDATE()
		,[dtmTransactionDate] = t.dtmDate
		,[strJournalLineDescription] = ''
		,[intJournalLineNo] = t.intInventoryTransactionId
		,[ysnIsUnposted] = 0 
		,[intUserId] = @intEntityUserSecurityId
		,[intEntityId] = @intEntityUserSecurityId 
		,[strTransactionId] = t.strTransactionId
		,[intTransactionId] = t.intTransactionId
		,[strTransactionType] = ty.strName
		,[strTransactionForm] = ty.strTransactionForm
		,[strModuleName] = @ModuleName
		,[intConcurrencyId] = 1
		,[dblDebitForeign] = NULL 
		,[dblDebitReport] = NULL 
		,[dblCreditForeign]	= NULL 
		,[dblCreditReport] = NULL 
		,[dblReportingRate] = NULL 
		,[dblForeignRate] = t.dblForexRate
		,[strRateType] = currencyRateType.strCurrencyExchangeRateType
		,[intSourceEntityId] = t.intSourceEntityId
		,[intCommodityId] = i.intCommodityId
	FROM 
		ForGLEntries_CTE cte CROSS APPLY (
			SELECT TOP 1 
				icGLAccnts.*
			FROM 
				@icGLAccounts icGLAccnts 
			WHERE 
				icGLAccnts.intInventoryAccountId = cte.intAccountId
		) icGLAccnts
		INNER JOIN dbo.tblGLAccount ga 
			ON ga.intAccountId = icGLAccnts.intInventoryAdjustmentAccountId
		CROSS APPLY (
			SELECT TOP 1 
				t.*
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.strTransactionId = cte.strTransactionId
				AND t.strBatchId = cte.strBatchId
				AND t.intItemId = icGLAccnts.intItemId 
				AND t.intItemLocationId = icGLAccnts.intItemLocationId 
				AND t.dblQty <> 0 
				AND t.intInTransitSourceLocationId IS NULL 
			ORDER BY
				t.intInventoryTransactionId DESC 
		) t 
		INNER JOIN tblICItem i 
			ON i.intItemId = t.intItemId
		CROSS APPLY dbo.fnGetDebit(
			cte.dblDiscrepancy 
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			cte.dblDiscrepancy 
		) Credit
		LEFT JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId
		LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
			ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	
END

