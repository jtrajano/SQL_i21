CREATE PROCEDURE [dbo].[uspICCreateReceiptGLEntriesToFixDecimalDiscrepancy]
	@strReceiptNumber AS NVARCHAR(50) = NULL 
	,@strBatchId AS NVARCHAR(50) = NULL 
	,@GLEntries RecapTableType READONLY
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

DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
DECLARE @ysnIsUnposted AS BIT = 0; 
DECLARE @GLEntriesForTheDiscrepancy AS RecapTableType

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

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

DECLARE @icGLAccounts TABLE (
	intItemId INT
	,intItemLocationId INT 
	,intInventoryAccountId INT NULL 
	,intInTransitAccountId INT NULL 
	,intInventoryAdjustmentAccountId INT NULL 
	,intAPClearingAccountId INT NULL
)

-- Get the GL Account Id
BEGIN 
	INSERT INTO @icGLAccounts (
		intItemId
		,intItemLocationId
		,intInventoryAccountId
		,intInTransitAccountId 
		,intInventoryAdjustmentAccountId 
		,intAPClearingAccountId
	)
	SELECT 
		query.intItemId
		,query.intItemLocationId
		,intInventoryAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'Inventory')
		,intInTransitAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'Inventory In-Transit')
		,intInventoryAdjustmentAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'Inventory Adjustment')
		,intAPClearingAccountId = dbo.fnGetItemGLAccount(query.intItemId, query.intItemLocationId, 'AP Clearing')
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
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
		WHERE
			t.strBatchId = @strBatchId			
			AND t.strTransactionId = @strReceiptNumber
			--AND t.intInTransitSourceLocationId IS NULL 
	) query
END 


DECLARE @threshold NUMERIC(38, 20) = 0.05

-- Fix the discrepancy for the In-Transit
BEGIN

	--IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy') IS NOT NULL  
	--BEGIN 
	--	DROP TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy
	--END 

	--IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy') IS NULL  
	--BEGIN 
	--	CREATE TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy (
	--		intId INT IDENTITY(1, 1) 
	--		,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,intInventoryReceiptId INT NULL
	--		,intInventoryReceiptItemId INT NULL
	--		,strReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,intSourceType INT NULL 
	--		,intFreightTermId INT NULL 
	--		,strFobPoint NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,dblDebit NUMERIC(18, 6) NULL 
	--		,dblCredit NUMERIC(18, 6) NULL 
	--		,dblDebitForeign NUMERIC(18, 6) NULL 
	--		,dblCreditForeign NUMERIC(18, 6) NULL 
	--		,dblForexRate NUMERIC(18, 6) NULL 
	--		,intItemId INT 
	--	)
	--END 

	DECLARE @uspICReceiptGLEntriesForDecimalDiscrepancy TABLE (
			--intId INT IDENTITY(1, 1) 
			strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,intInventoryReceiptId INT NULL
			,intInventoryReceiptItemId INT NULL
			,strReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,intSourceType INT NULL 
			,intFreightTermId INT NULL 
			,strFobPoint NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			,dblDebit NUMERIC(18, 6) NULL 
			,dblCredit NUMERIC(18, 6) NULL 
			,dblDebitForeign NUMERIC(18, 6) NULL 
			,dblCreditForeign NUMERIC(18, 6) NULL 
			,dblForexRate NUMERIC(18, 6) NULL 
			,intItemId INT 	
	)
	
	-- Get the discrepancy per receipt line item
	BEGIN 
		INSERT INTO @uspICReceiptGLEntriesForDecimalDiscrepancy (
			strReceiptNumber 
			,strBatchId 
			,intInventoryReceiptId
			,intInventoryReceiptItemId 
			,strReceiptType 
			,intSourceType 
			,intFreightTermId 
			,strFobPoint 
			,intItemId 
			,dblForexRate 
			,dblDebit 
			,dblCredit 
			,dblDebitForeign 
			,dblCreditForeign 
		)
		SELECT 
			t.strTransactionId
			,t.strBatchId 
			,t.intTransactionId
			,t.intTransactionDetailId
			,r.strReceiptType 
			,r.intSourceType 
			,r.intFreightTermId 
			,ft.strFobPoint 		
			,t.intItemId
			,dblForexRate = t.dblForexRate
			,dblDebit = SUM(ISNULL(dblDebit, 0))
			,dblCredit = SUM(ISNULL(dblCredit, 0)) 
			,dblDebitForeign = SUM(ISNULL(dblDebitForeign, 0))
			,dblCreditForeign = SUM(ISNULL(dblCreditForeign, 0))				
		FROM 
			tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblICItem i 
				ON ri.intItemId = i.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			INNER JOIN tblICInventoryTransaction t 
				ON t.strTransactionId = r.strReceiptNumber
				AND t.intTransactionId = r.intInventoryReceiptId
				AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
			INNER JOIN @GLEntries gd
				ON gd.strTransactionId = t.strTransactionId
				AND gd.strBatchId = t.strBatchId
				AND gd.intJournalLineNo = t.intInventoryTransactionId
				AND (gd.strJournalLineDescription = '' OR gd.strJournalLineDescription IS NULL)
			LEFT JOIN tblSMFreightTerms ft
				ON r.intFreightTermId = ft.intFreightTermId
		WHERE
			t.strTransactionId = @strReceiptNumber
			AND t.strBatchId = @strBatchId
			AND t.ysnIsUnposted = 0 
		GROUP BY
			t.strTransactionId
			,t.strBatchId 
			,t.intTransactionId
			,t.intTransactionDetailId
			,r.strReceiptType 
			,r.intSourceType 
			,r.intFreightTermId 
			,ft.strFobPoint 		
			,t.intItemId
			,t.dblForexRate
	END 

	IF EXISTS (SELECT TOP 1 1 FROM @uspICReceiptGLEntriesForDecimalDiscrepancy) 
	BEGIN 
		-------------------------------------------------------------------------------------
		---- 1. Add GL entry to correct discrepancy in the foreign currency during In-Transit
		-------------------------------------------------------------------------------------
		--/*
		--	Debit or Credit ........... Inventory Adjustment 
		--*/
		INSERT INTO @GLEntriesForTheDiscrepancy (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
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
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]	
		) 
		SELECT 
			[dtmDate] = t.dtmDate
			,[strBatchId] = t.strBatchId
			,[intAccountId] = ga.intAccountId
			,[dblDebit] = 0
			,[dblCredit] = 0
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
			,[dblDebitForeign] = CreditForeign.[Value]	
			,[dblDebitReport] = NULL 
			,[dblCreditForeign]	= DebitForeign.[Value]
			,[dblCreditReport]	= NULL
			,[dblReportingRate]	= t.dblForexRate
			,[dblForeignRate] = t.dblForexRate
			,[strRateType] = currencyRateType.strCurrencyExchangeRateType
			,[intSourceEntityId] = t.intSourceEntityId
			,[intCommodityId] = i.intCommodityId
		FROM 
			@uspICReceiptGLEntriesForDecimalDiscrepancy d
			INNER JOIN tblICItem i 
				ON d.intItemId = i.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			CROSS APPLY (
				SELECT TOP 1 
					ga.* 
				FROM 
					@icGLAccounts ga
				WHERE 
					ga.intItemId = d.intItemId 
			) glAccnt 
			CROSS APPLY (
				SELECT TOP 1 
					t.*
				FROM 
					tblICInventoryTransaction t INNER JOIN @GLEntries gd
						ON gd.strTransactionId = t.strTransactionId
						AND gd.strBatchId = t.strBatchId
						AND gd.intJournalLineNo = t.intInventoryTransactionId
						AND gd.intAccountId = glAccnt.intInTransitAccountId
						AND (gd.strJournalLineDescription = '' OR gd.strJournalLineDescription IS NULL)
				WHERE
					t.strBatchId = d.strBatchId
					AND t.intItemId = d.intItemId
					AND t.strTransactionId = d.strReceiptNumber					
					AND t.intTransactionId = d.intInventoryReceiptId
					AND t.intTransactionDetailId = d.intInventoryReceiptItemId					
					AND t.intCurrencyId IS NOT NULL 
			) t
			CROSS APPLY dbo.fnGetDebit(
				ISNULL(dblDebitForeign, 0) - ISNULL(dblCreditForeign, 0)
			) DebitForeign
			CROSS APPLY dbo.fnGetCredit(
				ISNULL(dblDebitForeign, 0) - ISNULL(dblCreditForeign, 0)
			) CreditForeign
			INNER JOIN tblGLAccount ga 
				ON ga.intAccountId = glAccnt.intInventoryAdjustmentAccountId
			LEFT JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	
		WHERE
			ABS(ISNULL(dblDebitForeign, 0) - ISNULL(dblCreditForeign, 0) ) <> 0 
			AND ABS(ISNULL(dblDebitForeign, 0) - ISNULL(dblCreditForeign, 0)) BETWEEN 0.01 AND @threshold

		------------------------------------------------------------------------------------------
		---- 2. Add GL entry to correct discrepancy in the functional currency during In-Transit
		------------------------------------------------------------------------------------------
		--/*
		--	Debit or Credit ........... Inventory Adjustment 
		--*/	
		INSERT INTO @GLEntriesForTheDiscrepancy (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
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
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]	
		) 
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
			,[dblCreditReport]	= NULL
			,[dblReportingRate]	= t.dblForexRate
			,[dblForeignRate] = t.dblForexRate
			,[strRateType] = currencyRateType.strCurrencyExchangeRateType
			,[intSourceEntityId] = t.intSourceEntityId
			,[intCommodityId] = i.intCommodityId
		FROM 
			@uspICReceiptGLEntriesForDecimalDiscrepancy d
			INNER JOIN tblICItem i 
				ON d.intItemId = i.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			CROSS APPLY (
				SELECT TOP 1 
					ga.* 
				FROM 
					@icGLAccounts ga
				WHERE 
					ga.intItemId = d.intItemId 
			) glAccnt 
			CROSS APPLY (
				SELECT TOP 1 
					t.*
				FROM 
					tblICInventoryTransaction t INNER JOIN @GLEntries gd
						ON gd.strTransactionId = t.strTransactionId
						AND gd.strBatchId = t.strBatchId
						AND gd.intJournalLineNo = t.intInventoryTransactionId
						AND gd.intAccountId = glAccnt.intInTransitAccountId
						AND (gd.strJournalLineDescription = '' OR gd.strJournalLineDescription IS NULL)
				WHERE
					t.strBatchId = d.strBatchId
					AND t.intItemId = d.intItemId
					AND t.strTransactionId = d.strReceiptNumber					
					AND t.intTransactionId = d.intInventoryReceiptId
					AND t.intTransactionDetailId = d.intInventoryReceiptItemId					
			) t
			CROSS APPLY dbo.fnGetDebit(
				ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0)
			) Debit
			CROSS APPLY dbo.fnGetCredit(
				ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0)
			) Credit
			INNER JOIN tblGLAccount ga 
				ON ga.intAccountId = glAccnt.intInventoryAdjustmentAccountId
			LEFT JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	
		WHERE
			ABS(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0) ) <> 0 
			AND ABS(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0)) BETWEEN 0.01 AND @threshold	
	END 
END 

-- Fix the discrepancy for the AP Clearing
BEGIN

	--IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing') IS NOT NULL  
	--BEGIN 
	--	DROP TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing
	--END 

	--IF OBJECT_ID('tempdb..#uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing') IS NULL  
	--BEGIN 
	--	CREATE TABLE #uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing (
	--		intId INT IDENTITY(1, 1) 
	--		,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,intInventoryReceiptId INT NULL
	--		,intInventoryReceiptItemId INT NULL
	--		,strReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,intSourceType INT NULL 
	--		,intFreightTermId INT NULL 
	--		,strFobPoint NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--		,dblGLAPClearing NUMERIC(18, 6) NULL 
	--		,dblGLAPClearingForeign NUMERIC(18, 6) NULL 
	--		,dblAPClearing NUMERIC(18, 6) NULL 
	--		,dblAPClearingForeign NUMERIC(18, 6) NULL 
	--		,dblForexRate NUMERIC(18, 6) NULL 
	--		,intItemId INT 
	--	)

	--	CREATE NONCLUSTERED INDEX [IX_ICReceiptGLEntriesForDecimalDiscrepancy_APClearing] ON #uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing (intInventoryReceiptItemId ASC)
	--END 

	DECLARE @uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing TABLE (
		strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intInventoryReceiptId INT NULL
		,intInventoryReceiptItemId INT NULL
		,strReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intSourceType INT NULL 
		,intFreightTermId INT NULL 
		,strFobPoint NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblGLAPClearing NUMERIC(18, 6) NULL 
		,dblGLAPClearingForeign NUMERIC(18, 6) NULL 
		,dblAPClearing NUMERIC(18, 6) NULL 
		,dblAPClearingForeign NUMERIC(18, 6) NULL 
		,dblForexRate NUMERIC(18, 6) NULL 
		,intItemId INT 	
	)

	-- Get the discrepancy per receipt line item
	BEGIN 
		INSERT INTO @uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing (
			strReceiptNumber 
			,strBatchId 
			,intInventoryReceiptId
			,intInventoryReceiptItemId 
			,strReceiptType 
			,intSourceType 
			,intFreightTermId 
			,strFobPoint 
			,intItemId 
			,dblForexRate 
			,dblGLAPClearing 
			,dblGLAPClearingForeign 
			,dblAPClearing 
			,dblAPClearingForeign 
		)
		SELECT 
			r.strReceiptNumber
			,@strBatchId 
			,r.intInventoryReceiptId
			,ri.intInventoryReceiptItemId
			,r.strReceiptType 
			,r.intSourceType 
			,r.intFreightTermId 
			,ft.strFobPoint 		
			,i.intItemId
			,dblForexRate = ri.dblForexRate
			,dblGLAPClearing = gd.dblGLAPClearing  --SUM(ISNULL(dblCredit, 0) - ISNULL(dblDebit, 0))
			,dblGLAPClearingForeign = gd.dblGLAPClearingForeign --SUM(ISNULL(dblCreditForeign, 0) - ISNULL(dblDebitForeign, 0)) 
			,dblAPClearing = 
				CASE 
					WHEN r.intCurrencyId <> @intFunctionalCurrencyId THEN ROUND(dbo.fnMultiply(ri.dblLineTotal, ri.dblForexRate), 2) 
					ELSE ri.dblLineTotal
				END
			,dblAPClearingForeign = 
				CASE 
					WHEN r.intCurrencyId = @intFunctionalCurrencyId THEN ri.dblLineTotal
					ELSE NULL 
				END
		FROM 
			tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblICItem i 
				ON ri.intItemId = i.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			CROSS APPLY (
				SELECT 
					dblGLAPClearing = SUM(ISNULL(dblCredit, 0) - ISNULL(dblDebit, 0))
					,dblGLAPClearingForeign = SUM(ISNULL(dblCreditForeign, 0) - ISNULL(dblDebitForeign, 0)) 
				FROM 
					tblICInventoryTransaction t 
					INNER JOIN @GLEntries gd
						ON gd.strTransactionId = t.strTransactionId
						AND gd.strBatchId = t.strBatchId
						AND gd.intJournalLineNo = t.intInventoryTransactionId
					INNER JOIN @icGLAccounts ga 
						ON ga.intItemId = ri.intItemId
						AND ga.intAPClearingAccountId = gd.intAccountId
				WHERE
					t.strBatchId = @strBatchId
					AND t.strTransactionId = r.strReceiptNumber
					AND t.intItemId = i.intItemId 
					AND t.intTransactionId = r.intInventoryReceiptId
					AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
			) gd
			LEFT JOIN tblSMFreightTerms ft
				ON r.intFreightTermId = ft.intFreightTermId
		WHERE
			r.strReceiptNumber = @strReceiptNumber
		--GROUP BY
		--	t.strTransactionId
		--	,t.strBatchId 
		--	,t.intTransactionId
		--	,t.intTransactionDetailId
		--	,r.strReceiptType 
		--	,r.intSourceType 
		--	,r.intFreightTermId 
		--	,ft.strFobPoint 		
		--	,t.intItemId
		--	,t.dblForexRate
		--	,r.intCurrencyId

		---- Recompute the expected AP Clearing amount. 
		--UPDATE ap
		--SET
		--	dblAPClearing = ROUND(dbo.fnMultiply(ri.dblLineTotal, ap.dblForexRate), 2) 
		--	,dblAPClearingForeign = ri.dblLineTotal
		--FROM
		--	(
		--		tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r		
		--			ON 
		--			r.strReceiptNumber = @strReceiptNumber
		--			AND ri.intInventoryReceiptId = r.intInventoryReceiptId					
		--			AND r.intCurrencyId <> @intFunctionalCurrencyId
		--	)
		--	INNER JOIN @uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing ap 
		--		ON ap.intInventoryReceiptItemId = ri.intInventoryReceiptItemId 			

		---- Recompute the expected AP Clearing amount. 
		--UPDATE ap
		--SET
		--	dblAPClearing = ri.dblLineTotal
		--	,dblAPClearingForeign = NULL 
		--FROM (
		--	tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r 
		--		ON r.strReceiptNumber = @strReceiptNumber
		--		AND r.intCurrencyId = @intFunctionalCurrencyId			
		--		AND ri.intInventoryReceiptId = r.intInventoryReceiptId				
		--	)
		--	INNER JOIN @uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing ap 
		--		ON ap.intInventoryReceiptItemId = ri.intInventoryReceiptItemId 
			
	END 


	IF EXISTS (SELECT TOP 1 1 FROM @uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing)
	BEGIN 
		----------------------------------------------------------------------------------------
		-- 3. Add GL entry to correct discrepancy in the foreign currency during AP Clearing
		----------------------------------------------------------------------------------------
		--	Debit ........... AP Clearing
		--  Credit ........................... Inventory Adjustment 

		;WITH ForGLEntries_CTE (
				[dtmDate] 
				,[strBatchId] 
				,[intAccountId] 
				,[dblDebit] 
				,[dblCredit] 
				,[dblDebitUnit] 
				,[dblCreditUnit]
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
				,[intUserId] 
				,[intEntityId] 
				,[strTransactionId] 
				,[intTransactionId] 
				,[strTransactionType] 
				,[strTransactionForm] 
				,[strModuleName] 
				,[dblDebitForeign] 
				,[dblDebitReport] 
				,[dblCreditForeign]	
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]
				,[strRateType]
				,[intSourceEntityId]
				,[intCommodityId]
				,intAPClearingAccountId
				,intInventoryAdjustmentAccountId
		)
		AS (
			SELECT 
				[dtmDate] = t.dtmDate
				,[strBatchId] = t.strBatchId
				,[intAccountId] = NULL 
				,[dblDebit] = 0
				,[dblCredit] = 0
				,[dblDebitUnit] = 0
				,[dblCreditUnit] = 0 
				,[strDescription] = 
					ISNULL(@strGLDescription, '%s') + ' ' 
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
				,[dblDebitForeign] = Debit.[Value]	
				,[dblDebitReport] = NULL 
				,[dblCreditForeign]	= Credit.[Value]
				,[dblCreditReport]	= NULL
				,[dblReportingRate]	= t.dblForexRate
				,[dblForeignRate] = t.dblForexRate
				,[strRateType] = currencyRateType.strCurrencyExchangeRateType
				,[intSourceEntityId] = t.intSourceEntityId
				,[intCommodityId] = i.intCommodityId
				,glAccnt.intAPClearingAccountId
				,glAccnt.intInventoryAdjustmentAccountId
			FROM 
				@uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing d
				INNER JOIN tblICItem i 
					ON d.intItemId = i.intItemId
				INNER JOIN #tmpRebuildList list	
					ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
					AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				CROSS APPLY (
					SELECT TOP 1 
						ga.* 
					FROM 
						@icGLAccounts ga
					WHERE 
						ga.intItemId = d.intItemId 
				) glAccnt 
				CROSS APPLY (
					SELECT TOP 1 
						t.*
					FROM 
						tblICInventoryTransaction t INNER JOIN @GLEntries gd
							ON gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
							AND gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.intAccountId = glAccnt.intAPClearingAccountId
							AND (gd.strJournalLineDescription = '' OR gd.strJournalLineDescription IS NULL)
					WHERE
						t.strBatchId = d.strBatchId
						AND t.intItemId = d.intItemId
						AND t.strTransactionId = d.strReceiptNumber						
						AND t.intTransactionId = d.intInventoryReceiptId
						AND t.intTransactionDetailId = d.intInventoryReceiptItemId						
				) t
				CROSS APPLY dbo.fnGetDebit(
					ISNULL(dblGLAPClearingForeign, 0) - ISNULL(d.dblAPClearingForeign , 0)
				) Debit
				CROSS APPLY dbo.fnGetCredit(
					ISNULL(dblGLAPClearingForeign, 0) - ISNULL(d.dblAPClearingForeign , 0)
				) Credit
				LEFT JOIN tblICInventoryTransactionType ty
					ON t.intTransactionTypeId = ty.intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	
			WHERE
				ABS(ISNULL(dblGLAPClearingForeign, 0) - ISNULL(d.dblAPClearingForeign , 0)) <> 0 
				AND ABS(ISNULL(dblGLAPClearingForeign, 0) - ISNULL(dblAPClearingForeign, 0)) BETWEEN 0.01 AND @threshold	
		)
		INSERT INTO @GLEntriesForTheDiscrepancy (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
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
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]	
		) 
		SELECT
			[dtmDate] 
			,[strBatchId] 
			,[intAccountId] = ga.intAccountId
			,[dblDebit] 
			,[dblCredit] 
			,[dblDebitUnit] 
			,[dblCreditUnit]
			,[strDescription] = 
				dbo.fnFormatMessage(
					cte.strDescription
					,ga.strDescription
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
			,[strCode]
			,[strReference] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[dtmDateEntered] 
			,[dtmTransactionDate] 
			,[strJournalLineDescription] 
			,[intJournalLineNo] 
			,[ysnIsUnposted] 
			,[intUserId] 
			,[intEntityId] 
			,[strTransactionId] 
			,[intTransactionId] 
			,[strTransactionType] 
			,[strTransactionForm] 
			,[strModuleName] 
			,[intConcurrencyId] = 1
			,[dblDebitForeign] 
			,[dblDebitReport] 
			,[dblCreditForeign]	
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
		FROM 
			ForGLEntries_CTE cte INNER JOIN tblGLAccount ga
				ON cte.intAPClearingAccountId = ga.intAccountId
		UNION ALL
		SELECT
			[dtmDate] 
			,[strBatchId] 
			,[intAccountId] = ga.intAccountId
			,[dblDebit] = [dblCredit] 
			,[dblCredit] = [dblDebit]
			,[dblDebitUnit] 
			,[dblCreditUnit]
			,[strDescription] = 
				dbo.fnFormatMessage(
					cte.strDescription
					,ga.strDescription
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
			,[strCode]
			,[strReference] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[dtmDateEntered] 
			,[dtmTransactionDate] 
			,[strJournalLineDescription] 
			,[intJournalLineNo] 
			,[ysnIsUnposted] 
			,[intUserId] 
			,[intEntityId] 
			,[strTransactionId] 
			,[intTransactionId] 
			,[strTransactionType] 
			,[strTransactionForm] 
			,[strModuleName] 
			,[intConcurrencyId] = 1
			,[dblDebitForeign] = [dblCreditForeign] 
			,[dblDebitReport] = [dblCreditReport]
			,[dblCreditForeign]	= [dblDebitForeign]
			,[dblCreditReport] = [dblDebitReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
		FROM 
			ForGLEntries_CTE cte INNER JOIN tblGLAccount ga
				ON cte.intInventoryAdjustmentAccountId = ga.intAccountId



		----------------------------------------------------------------------------------------
		-- 4. Add GL entry to correct discrepancy in the functional currency during AP clearing
		----------------------------------------------------------------------------------------
		--	Debit ........... AP Clearing
		--  Credit ........................... Inventory Adjustment 	

		;WITH ForGLEntries_CTE (
				[dtmDate] 
				,[strBatchId] 
				,[intAccountId] 
				,[dblDebit] 
				,[dblCredit] 
				,[dblDebitUnit] 
				,[dblCreditUnit]
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
				,[intUserId] 
				,[intEntityId] 
				,[strTransactionId] 
				,[intTransactionId] 
				,[strTransactionType] 
				,[strTransactionForm] 
				,[strModuleName] 
				,[dblDebitForeign] 
				,[dblDebitReport] 
				,[dblCreditForeign]	
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]
				,[strRateType]
				,[intSourceEntityId]
				,[intCommodityId]
				,intAPClearingAccountId
				,intInventoryAdjustmentAccountId
		)
		AS (
			SELECT 
				[dtmDate] = t.dtmDate
				,[strBatchId] = t.strBatchId
				,[intAccountId] = NULL 
				,[dblDebit] = Debit.[Value]
				,[dblCredit] = Credit.[Value]
				,[dblDebitUnit] = 0
				,[dblCreditUnit] = 0 
				,[strDescription] = 
					ISNULL(@strGLDescription, '%s') + ' ' 
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
				,[dblDebitForeign] = NULL 
				,[dblDebitReport] = NULL 
				,[dblCreditForeign]	= NULL 
				,[dblCreditReport]	= NULL
				,[dblReportingRate]	= t.dblForexRate
				,[dblForeignRate] = t.dblForexRate
				,[strRateType] = currencyRateType.strCurrencyExchangeRateType
				,[intSourceEntityId] = t.intSourceEntityId
				,[intCommodityId] = i.intCommodityId
				,glAccnt.intAPClearingAccountId
				,glAccnt.intInventoryAdjustmentAccountId
			FROM 
				@uspICReceiptGLEntriesForDecimalDiscrepancy_APClearing d
				INNER JOIN tblICItem i 
					ON d.intItemId = i.intItemId
				INNER JOIN #tmpRebuildList list	
					ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
					AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				CROSS APPLY (
					SELECT TOP 1 
						ga.* 
					FROM 
						@icGLAccounts ga
					WHERE 
						ga.intItemId = d.intItemId 
				) glAccnt 
				CROSS APPLY (
					SELECT TOP 1 
						t.*
					FROM 
						tblICInventoryTransaction t INNER JOIN @GLEntries gd
							ON gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
							AND gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.intAccountId = glAccnt.intAPClearingAccountId
							AND (gd.strJournalLineDescription = '' OR gd.strJournalLineDescription IS NULL)
					WHERE						
						t.strBatchId = d.strBatchId
						AND t.intItemId = d.intItemId
						AND t.strTransactionId = d.strReceiptNumber
						AND t.intTransactionId = d.intInventoryReceiptId
						AND t.intTransactionDetailId = d.intInventoryReceiptItemId						
				) t
				CROSS APPLY dbo.fnGetDebit(
					ISNULL(dblGLAPClearing, 0) - ISNULL(d.dblAPClearing, 0)
				) Debit
				CROSS APPLY dbo.fnGetCredit(
					ISNULL(dblGLAPClearing, 0) - ISNULL(d.dblAPClearing, 0)
				) Credit
				LEFT JOIN tblICInventoryTransactionType ty
					ON t.intTransactionTypeId = ty.intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId	
			WHERE
				ABS(ISNULL(dblGLAPClearing, 0) - ISNULL(d.dblAPClearing, 0)) <> 0 
				AND ABS(ISNULL(dblGLAPClearing, 0) - ISNULL(dblAPClearing, 0)) BETWEEN 0.01 AND @threshold	
		)
		INSERT INTO @GLEntriesForTheDiscrepancy (
			[dtmDate] 
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
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
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]	
		) 
		SELECT
			[dtmDate] 
			,[strBatchId] 
			,[intAccountId] = ga.intAccountId
			,[dblDebit] 
			,[dblCredit] 
			,[dblDebitUnit] 
			,[dblCreditUnit]
			,[strDescription] = 
				dbo.fnFormatMessage(
					cte.strDescription
					,ga.strDescription
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
			,[strCode]
			,[strReference] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[dtmDateEntered] 
			,[dtmTransactionDate] 
			,[strJournalLineDescription] 
			,[intJournalLineNo] 
			,[ysnIsUnposted] 
			,[intUserId] 
			,[intEntityId] 
			,[strTransactionId] 
			,[intTransactionId] 
			,[strTransactionType] 
			,[strTransactionForm] 
			,[strModuleName] 
			,[intConcurrencyId] = 1
			,[dblDebitForeign] 
			,[dblDebitReport] 
			,[dblCreditForeign]	
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
		FROM 
			ForGLEntries_CTE cte INNER JOIN tblGLAccount ga
				ON cte.intAPClearingAccountId = ga.intAccountId
		UNION ALL
		SELECT
			[dtmDate] 
			,[strBatchId] 
			,[intAccountId] = ga.intAccountId
			,[dblDebit] = [dblCredit] 
			,[dblCredit] = [dblDebit]
			,[dblDebitUnit] 
			,[dblCreditUnit]
			,[strDescription] = 
				dbo.fnFormatMessage(
					cte.strDescription
					,ga.strDescription
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
			,[strCode]
			,[strReference] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[dtmDateEntered] 
			,[dtmTransactionDate] 
			,[strJournalLineDescription] 
			,[intJournalLineNo] 
			,[ysnIsUnposted] 
			,[intUserId] 
			,[intEntityId] 
			,[strTransactionId] 
			,[intTransactionId] 
			,[strTransactionType] 
			,[strTransactionForm] 
			,[strModuleName] 
			,[intConcurrencyId] = 1
			,[dblDebitForeign] = [dblCreditForeign] 
			,[dblDebitReport] = [dblCreditReport]
			,[dblCreditForeign]	= [dblDebitForeign]
			,[dblCreditReport] = [dblDebitReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
		FROM 
			ForGLEntries_CTE cte INNER JOIN tblGLAccount ga
				ON cte.intInventoryAdjustmentAccountId = ga.intAccountId
	END 
END

-- Return the GL entries to correct the discrepancy back to the caller. 
SELECT 
	[dtmDate] 
	,[strBatchId]
	,[intAccountId]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
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
	,[intUserId]
	,[intEntityId]
	,[strTransactionId]
	,[intTransactionId]
	,[strTransactionType]
	,[strTransactionForm]
	,[strModuleName]
	,[intConcurrencyId]
	,[dblDebitForeign]	
	,[dblDebitReport]	
	,[dblCreditForeign]	
	,[dblCreditReport]	
	,[dblReportingRate]	
	,[dblForeignRate]
	,[strRateType]
	,[intSourceEntityId]
	,[intCommodityId]	
FROM 
	@GLEntriesForTheDiscrepancy
