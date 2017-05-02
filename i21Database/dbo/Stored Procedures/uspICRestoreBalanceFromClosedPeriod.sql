/*
	uspICRestoreBalanceFromClosedPeriod
	Use this stored procedure to restore the inventory and gl balances from a closed period. 

	Pre-requisites
	1. A separate db as the source of the closed year figures. 
	
	How to use: 
	1. Determine the open period. 
	2. For example:
		2.1. Closed accounting periods are Jan 201x to September 201x. 
		2.2. This means October 201x is the next open period. 
		2.3. Specify 10/01/201x as the argument in @dtmOpenPeriod parameter. 
	3. Alter this sp and rename all instance of 'irely02_25Oct' to the name of the source db. 
*/

CREATE PROCEDURE uspICRestoreBalanceFromClosedPeriod
	@dtmOpenPeriod AS DATETIME 

AS 

DECLARE @intOpenYear AS INT = YEAR(@dtmOpenPeriod) 
DECLARE @intFirstOpenMonth AS INT = MONTH(@dtmOpenPeriod) 

DECLARE @id AS INT
		,@strOldBatchId AS NVARCHAR(50) 
		,@strNewBatchId AS NVARCHAR(50) 
		,@intTemplateInventoryTransactionId AS INT 
		,@intNewInventoryTransactionId AS INT 
		,@strTransactionType AS NVARCHAR(50) 
		,@year AS INT 
		,@month AS INT
		,@valueDifference NUMERIC(38, 20) 
		,@strOldTransactionId AS NVARCHAR(50) 
		,@strNewTransactionId AS NVARCHAR(50) 
		,@strAdjustTransactionId AS NVARCHAR(50) 


DECLARE @intItemId AS INT
		,@intItemLocationId AS INT
		,@intItemUOMId AS INT
		,@intSubLocationId AS INT 
		,@intStorageLocationId AS INT 
		,@dtmDate AS DATETIME
		,@intLotId AS INT
		,@dblQty AS NUMERIC(38,20)
		,@dblUOMQty AS NUMERIC(38,20)
		,@dblCost AS NUMERIC(38,20)
		,@dblSalesPrice AS NUMERIC(18,6)
		,@intCurrencyId AS INT
		,@dblExchangeRate AS NUMERIC(38,20)
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(20)
		,@strBatchId AS NVARCHAR(20)
		,@intTransactionTypeId AS INT
		,@strTransactionForm AS NVARCHAR(255)
		,@intEntityUserSecurityId AS INT
		,@intCostingMethod AS INT 
		,@InventoryTransactionIdentityId AS INT 
		,@intInventoryTransactionId AS INT 

DECLARE	@GLEntries AS RecapTableType 
DECLARE @GLAccounts AS dbo.ItemGLAccount
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the staging table. 
CREATE TABLE tblICFixClosedPeriodValues (
	id INT IDENTITY 
	,intItemId INT 
	,intItemLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT 
	,intLotId INT 
	,strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[year] INT
	,[month] INT
	,dblOldValue NUMERIC(38, 20) 	
	,dblNewValue NUMERIC(38, 20) 
	,dblDifference NUMERIC(38, 20) 
	,CONSTRAINT [PK_tblICFixClosedPeriodValues] PRIMARY KEY CLUSTERED ([id]) 
) 

BEGIN 
	INSERT INTO tblICFixClosedPeriodValues (
		intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,strTransactionType
		,strTransactionId
		,[year]
		,[month]
		,dblOldValue
		,dblNewValue
		,dblDifference
	)
	-- Populate the staging table. Compare the old and new valuation. 
	SELECT	intItemId = ISNULL(new.intItemId, old.intItemId)
			, intItemLocationId = ISNULL(new.intItemLocationId, old.intItemLocationId)
			, intSubLocationId = ISNULL(new.intSubLocationId, old.intSubLocationId) 
			, intStorageLocationId = ISNULL(new.intStorageLocationId, old.intStorageLocationId)
			, intLotId = ISNULL(new.intLotId, old.intLotId) 
			, strTransactionType = ISNULL(new.[strTransactionType], old.[strTransactionType])
			, strTransactionId = ISNULL(new.strTransactionId, old.strTransactionId)
			, [year] = ISNULL(new.[year], old.[year])
			, [month] = ISNULL(new.[month], old.[month])
			, [old value] = old.[value]
			, [new value] = new.[value]
			, [adjustment] = ISNULL(old.[value], 0) - ISNULL(new.[value], 0)
	FROM 
		(	
			-- Get the new valuation. 
			SELECT	t.intItemId
					, t.intItemLocationId
					, t.intSubLocationId
					, t.intStorageLocationId
					, t.intLotId					
					, [strTransactionType] = ty.strName
					, t.strTransactionId
					, [year] = YEAR(t.dtmDate)
					, [month] = MONTH(t.dtmDate) 
					, [value] = SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
			FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
					INNER JOIN dbo.tblICItem i
						ON i.intItemId = t.intItemId
			WHERE	t.ysnIsUnposted = 0 
			GROUP BY 
				t.intItemId
				, t.intItemLocationId
				, t.intSubLocationId
				, t.intStorageLocationId
				, t.intLotId
				, ty.strName
				, t.strTransactionId
				, YEAR(t.dtmDate)
				, MONTH(t.dtmDate) 
			HAVING SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2)) <> 0 
		) new 	
			FULL OUTER JOIN
		(	
			-- Get the original valuation. 
			SELECT	t.intItemId				
					, t.intItemLocationId
					, t.intSubLocationId
					, t.intStorageLocationId
					, t.intLotId					
					, [strTransactionType] = ty.strName
					, t.strTransactionId
					, [year] = YEAR(t.dtmDate)
					, [month] = MONTH(t.dtmDate) 
					, [value] = SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2))					
			FROM	irely02_25Oct.dbo.tblICInventoryTransaction t INNER JOIN irely02_25Oct.dbo.tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
					INNER JOIN irely02_25Oct.dbo.tblICItem i
						ON i.intItemId = t.intItemId
			WHERE	t.ysnIsUnposted = 0 
			GROUP BY 
				t.intItemId
				, t.intItemLocationId
				, t.intSubLocationId
				, t.intStorageLocationId
				, t.intLotId
				, ty.strName
				, t.strTransactionId
				, YEAR(t.dtmDate)
				, MONTH(t.dtmDate) 
			HAVING SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2)) <> 0 
		) old
			ON	old.intItemId = new.intItemId
				AND old.intItemLocationId = new.intItemLocationId
				AND ISNULL(old.intSubLocationId, 0) = ISNULL(new.intSubLocationId, 0)
				AND ISNULL(old.intStorageLocationId, 0) = ISNULL(new.intStorageLocationId, 0)
				AND ISNULL(old.intLotId, 0) = ISNULL(new.intLotId, 0)
				AND old.[strTransactionType] = new.[strTransactionType]
				AND old.strTransactionId = new.strTransactionId
				AND old.[year] = new.[year]
				AND old.[month] = new.[month]
	WHERE	ROUND( ISNULL(old.[value], 0) - ISNULL(new.[value], 0), 2) <> 0 
			AND (
				ISNULL(new.[year], old.[year]) <= (@intOpenYear - 1)
				OR (
					ISNULL(new.[year], old.[year]) = @intOpenYear 
					AND ISNULL(new.[month], old.[month]) < @intFirstOpenMonth
				)
			)
	ORDER BY 
		ISNULL(new.intItemId, old.intItemId)
		, ISNULL(new.[year], old.[year])
		, ISNULL(new.[month], old.[month])
END

-- Loop
BEGIN
	WHILE EXISTS (SELECT TOP 1 1 FROM tblICFixClosedPeriodValues)
	BEGIN 
		SELECT	TOP 1 
				@id = id 
				,@intItemId = intItemId
				,@intItemLocationId = intItemLocationId
				,@intSubLocationId = intSubLocationId
				,@intStorageLocationId = intStorageLocationId
				,@intLotId = intLotId
				,@strTransactionType = strTransactionType
				,@year = [year]
				,@month = [month]
				,@valueDifference = dblDifference
				,@strAdjustTransactionId = strTransactionId 
		FROM	tblICFixClosedPeriodValues
		
		-- Get a template 
		BEGIN 
			PRINT 'Get a template.'
			PRINT @strAdjustTransactionId

			SET @intTemplateInventoryTransactionId = NULL 
			SET @strOldBatchId = NULL 

			-- Get a template id from the closed period. 
			SELECT	TOP 1 
					@intTemplateInventoryTransactionId = t.intInventoryTransactionId
					,@strOldBatchId = t.strBatchId
			FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
			WHERE	t.intItemId = @intItemId
					AND t.intItemLocationId = @intItemLocationId
					AND ISNULL(t.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
					AND ISNULL(t.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0) 
					AND ISNULL(t.intLotId, 0) = ISNULL(@intLotId, 0) 
					AND ty.strName = @strTransactionType
					AND t.strTransactionId = @strAdjustTransactionId
					AND YEAR(t.dtmDate) = @year
					AND MONTH(t.dtmDate) = @month
			ORDER BY t.intInventoryTransactionId DESC 
							
			-- If there is no template id from current db, try to get from the closed year database. 
			IF @intTemplateInventoryTransactionId IS NULL 
			BEGIN
				SELECT	TOP 1 
						@intTemplateInventoryTransactionId = t.intInventoryTransactionId
				FROM	irely02_25Oct.dbo.tblICInventoryTransaction t INNER JOIN irely02_25Oct.dbo.tblICInventoryTransactionType ty
							ON t.intTransactionTypeId = ty.intTransactionTypeId
				WHERE	t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId
						AND ISNULL(t.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
						AND ISNULL(t.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0) 
						AND ISNULL(t.intLotId, 0) = ISNULL(@intLotId, 0) 
						AND ty.strName = @strTransactionType
						AND t.strTransactionId = @strAdjustTransactionId
				ORDER BY t.intInventoryTransactionId ASC 
			END 
								
			-- Raise error if template id can't be found. 
			IF @intTemplateInventoryTransactionId IS NULL 
			BEGIN 
				SELECT 'Unable to find a template.', * FROM tblICFixClosedPeriodValues WHERE id = @id				
				EXEC uspICRaiseError 80174; 
				GOTO _ExitWithError; 
			END 

			-- Get the template transaction
			SET @intInventoryTransactionId = NULL 
			SET @dtmDate = NULL 
			SELECT	TOP  1 
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId
					,@dtmDate = t.dtmDate 
					,@intLotId = @intLotId
					,@dblQty = 0
					,@dblUOMQty = 0 
					,@dblCost = 0
					,@dblSalesPrice = 0 
					,@intCurrencyId = @DefaultCurrencyId 
					,@dblExchangeRate = 1
					,@intTransactionId = t.intTransactionId
					,@intTransactionDetailId = t.intTransactionDetailId
					,@strTransactionId = t.strTransactionId
					,@strBatchId = t.strBatchId --ISNULL(@strBatchId, t.strBatchId)
					,@intTransactionTypeId = t.intTransactionTypeId
					,@strTransactionForm = t.strTransactionForm
					,@intEntityUserSecurityId = t.intCreatedEntityId
					,@intCostingMethod = t.intCostingMethod
					,@intInventoryTransactionId = t.intInventoryTransactionId
			FROM	tblICInventoryTransaction t
			WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId
		
			-- Get a template from the closed year database. 
			IF @intInventoryTransactionId IS NULL 
			BEGIN 
				SELECT	TOP  1 
						@intItemId = @intItemId
						,@intItemLocationId = @intItemLocationId
						,@intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = @intStorageLocationId
						,@dtmDate = NULL 
						,@intLotId = @intLotId
						,@dblQty = 0
						,@dblUOMQty = 0 
						,@dblCost = 0
						,@dblSalesPrice = 0 
						,@intCurrencyId = @DefaultCurrencyId 
						,@dblExchangeRate = 1
						,@intTransactionId = t.intTransactionId
						,@intTransactionDetailId = t.intTransactionDetailId
						,@strTransactionId = t.strTransactionId
						,@strBatchId = t.strBatchId --ISNULL(@strBatchId, t.strBatchId)
						,@intTransactionTypeId = t.intTransactionTypeId
						,@strTransactionForm = t.strTransactionForm
						,@intEntityUserSecurityId = t.intCreatedEntityId
						,@intCostingMethod = t.intCostingMethod
						,@intInventoryTransactionId = t.intInventoryTransactionId
				FROM	irely02_25Oct.dbo.tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId				
			END 
			
			IF @intInventoryTransactionId IS NULL 
			BEGIN 
				EXEC uspICRaiseError 80174; 
				GOTO _ExitWithError; 	
			END 
		END
	
		-- Update the closed period			
		BEGIN 
			-- Create the Inventory Transaction for the closed period
			SET @InventoryTransactionIdentityId = NULL 				
			SET @dtmDate = ISNULL(@dtmDate, DATEFROMPARTS(@year, @month, 1)) 
			EXEC [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = 0
					,@dblUOMQty = 1 
					,@dblCost = 0 
					,@dblValue = @valueDifference
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					--,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @intTransactionTypeId
					,@intLotId = @intLotId 
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL 
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@intCostingMethod = @intCostingMethod
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
			
			IF @InventoryTransactionIdentityId IS NULL 
			BEGIN 
				SELECT	'Unable to create the G/L entries'
						,t.* 
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId

				SELECT	TOP  1 
						'Unable to create the G/L entries'
						,[@intItemId] = @intItemId
						,[@intItemLocationId] = @intItemLocationId
						,[@intItemUOMId] = @intItemUOMId
						,[@intSubLocationId] = @intSubLocationId
						,[@intStorageLocationId] = @intStorageLocationId
						,[@dtmDate] = @dtmDate
						,[@intLotId] = @intLotId
						,[@dblQty] = 0
						,[@dblUOMQty] = 0 
						,[@dblCost] = 0
						,[@dblSalesPrice] = 0 
						,[@intCurrencyId] = @DefaultCurrencyId 
						,[@dblExchangeRate] = 1
						,[@intTransactionId] = t.intTransactionId
						,[@intTransactionDetailId] = t.intTransactionDetailId
						,[@strTransactionId] = t.strTransactionId
						,[@strBatchId] = ISNULL(@strBatchId, t.strBatchId)
						,[@intTransactionTypeId] = t.intTransactionTypeId
						,[@strTransactionForm] = t.strTransactionForm
						,[@intEntityUserSecurityId] = t.intCreatedEntityId
						,[@intCostingMethod] = t.intCostingMethod
						,[@intInventoryTransactionId] = t.intInventoryTransactionId
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId

				EXEC uspICRaiseError 80175; 
				GOTO _ExitWithError; 				
			END 
			
			-- Create the G/L entries for the closed period. 
			ELSE 
			BEGIN 
				PRINT 'Create the g/l entries for the closed period.'
				PRINT @strBatchId
				PRINT @InventoryTransactionIdentityId
				PRINT @intTemplateInventoryTransactionId 

				IF EXISTS (
					SELECT	TOP 1 gd.intGLDetailId 
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId
				) 
				BEGIN 
					INSERT INTO tblGLDetail (
						dtmDate
						,strBatchId
						,intAccountId
						,dblDebit
						,dblCredit
						,dblDebitUnit
						,dblCreditUnit
						,strDescription
						,strCode
						,strReference
						,intCurrencyId
						,dblExchangeRate
						,dtmDateEntered
						,dtmTransactionDate
						,strJournalLineDescription
						,intJournalLineNo
						,ysnIsUnposted
						,intUserId
						,intEntityId
						,strTransactionId
						,intTransactionId
						,strTransactionType
						,strTransactionForm
						,strModuleName
						,intConcurrencyId
						,dblDebitForeign
						,dblDebitReport
						,dblCreditForeign
						,dblCreditReport
						,dblReportingRate
						,dblForeignRate
					)	
					SELECT	TOP 1
							dtmDate = @dtmDate
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Debit.Value --CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblCredit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE()--gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory ) ia
					WHERE	--ia.intAccountId = gd.intAccountId
							t.intInventoryTransactionId = @intTemplateInventoryTransactionId
					UNION ALL 
					SELECT	TOP 1
							dtmDate = @dtmDate
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblCredit = Debit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE() -- gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit									
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory) ia
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId	
							AND gc.strAccountCategory <> 'Inventory' -- Make sure the contra account id is not 'Inventory'
				END 
				ELSE 
				-- Insert GL entries for the closed period from the closed period db. 
				BEGIN 
					INSERT INTO tblGLDetail (
						dtmDate
						,strBatchId
						,intAccountId
						,dblDebit
						,dblCredit
						,dblDebitUnit
						,dblCreditUnit
						,strDescription
						,strCode
						,strReference
						,intCurrencyId
						,dblExchangeRate
						,dtmDateEntered
						,dtmTransactionDate
						,strJournalLineDescription
						,intJournalLineNo
						,ysnIsUnposted
						,intUserId
						,intEntityId
						,strTransactionId
						,intTransactionId
						,strTransactionType
						,strTransactionForm
						,strModuleName
						,intConcurrencyId
						,dblDebitForeign
						,dblDebitReport
						,dblCreditForeign
						,dblCreditReport
						,dblReportingRate
						,dblForeignRate
					)	
					SELECT	TOP 1
							dtmDate = @dtmDate
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Debit.Value --CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblCredit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE()--gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	irely02_25Oct.dbo.tblGLDetail gd INNER JOIN irely02_25Oct.dbo.tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN irely02_25Oct.dbo.tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN irely02_25Oct.dbo.tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory ) ia
					WHERE	--ia.intAccountId = gd.intAccountId
							t.intInventoryTransactionId = @intTemplateInventoryTransactionId
					UNION ALL 
					SELECT	TOP 1
							dtmDate = @dtmDate
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblCredit = Debit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE() -- gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	irely02_25Oct.dbo.tblGLDetail gd INNER JOIN irely02_25Oct.dbo.tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN irely02_25Oct.dbo.tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN irely02_25Oct.dbo.tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit									
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory) ia
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId	
							AND gc.strAccountCategory <> 'Inventory' -- Make sure the contra account id is not 'Inventory'
				END 
			END 

			PRINT 'Updated closed period: ' + @strOldBatchId
		END 						

		-- Update the open period			
		BEGIN 
			-- Reverse the value difference 
			SET @valueDifference = -@valueDifference 

			-- Create the Inventory Transaction for the open period
			SET @InventoryTransactionIdentityId = NULL 				
			EXEC [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmOpenPeriod
					,@dblQty = 0
					,@dblUOMQty = 1 
					,@dblCost = 0 
					,@dblValue = @valueDifference
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					--,@dblExchangeRate = @dblExchangeRate
					,@intTransactionId = @intTransactionId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strTransactionId = @strTransactionId
					,@strBatchId = @strBatchId
					,@intTransactionTypeId = @intTransactionTypeId
					,@intLotId = @intLotId 
					,@intRelatedInventoryTransactionId = NULL 
					,@intRelatedTransactionId = NULL 
					,@strRelatedTransactionId = NULL 
					,@strTransactionForm = @strTransactionForm
					,@intEntityUserSecurityId = @intEntityUserSecurityId
					,@intCostingMethod = @intCostingMethod
					,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
			
			IF @InventoryTransactionIdentityId IS NULL 
			BEGIN 
				SELECT	'Unable to create the G/L entries'
						,t.* 
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId

				SELECT	TOP  1 
						'Unable to create the G/L entries'
						,[@intItemId] = @intItemId
						,[@intItemLocationId] = @intItemLocationId
						,[@intItemUOMId] = @intItemUOMId
						,[@intSubLocationId] = @intSubLocationId
						,[@intStorageLocationId] = @intStorageLocationId
						,[@dtmDate] = @dtmOpenPeriod
						,[@intLotId] = @intLotId
						,[@dblQty] = 0
						,[@dblUOMQty] = 0 
						,[@dblCost] = 0
						,[@dblSalesPrice] = 0 
						,[@intCurrencyId] = @DefaultCurrencyId 
						,[@dblExchangeRate] = 1
						,[@intTransactionId] = t.intTransactionId
						,[@intTransactionDetailId] = t.intTransactionDetailId
						,[@strTransactionId] = t.strTransactionId
						,[@strBatchId] = ISNULL(@strBatchId, t.strBatchId)
						,[@intTransactionTypeId] = t.intTransactionTypeId
						,[@strTransactionForm] = t.strTransactionForm
						,[@intEntityUserSecurityId] = t.intCreatedEntityId
						,[@intCostingMethod] = t.intCostingMethod
						,[@intInventoryTransactionId] = t.intInventoryTransactionId
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId

				EXEC uspICRaiseError 80175; 
				GOTO _ExitWithError; 				
			END 
			
			-- Create the G/L entries for the open period. 
			ELSE 
			BEGIN 
				PRINT 'create the g/l entries for the open period.'
				PRINT @strBatchId
				PRINT @InventoryTransactionIdentityId
				PRINT @intTemplateInventoryTransactionId 

				IF EXISTS (
					SELECT	TOP 1 gd.intGLDetailId 
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId
				) 
				BEGIN 

					INSERT INTO tblGLDetail (
						dtmDate
						,strBatchId
						,intAccountId
						,dblDebit
						,dblCredit
						,dblDebitUnit
						,dblCreditUnit
						,strDescription
						,strCode
						,strReference
						,intCurrencyId
						,dblExchangeRate
						,dtmDateEntered
						,dtmTransactionDate
						,strJournalLineDescription
						,intJournalLineNo
						,ysnIsUnposted
						,intUserId
						,intEntityId
						,strTransactionId
						,intTransactionId
						,strTransactionType
						,strTransactionForm
						,strModuleName
						,intConcurrencyId
						,dblDebitForeign
						,dblDebitReport
						,dblCreditForeign
						,dblCreditReport
						,dblReportingRate
						,dblForeignRate
					)	
					SELECT	TOP 1
							dtmDate = @dtmOpenPeriod
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Debit.Value --CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblCredit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE()--gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory ) ia
					WHERE	--ia.intAccountId = gd.intAccountId
							t.intInventoryTransactionId = @intTemplateInventoryTransactionId
					UNION ALL 
					SELECT	TOP 1
							dtmDate = @dtmOpenPeriod
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblCredit = Debit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE() -- gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit									
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory) ia
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId	
							AND gc.strAccountCategory <> 'Inventory' -- Make sure the contra account id is not 'Inventory'
				END
				-- Insert GL entries for the open period from the closed period db. 
				ELSE 
				BEGIN 
					INSERT INTO tblGLDetail (
						dtmDate
						,strBatchId
						,intAccountId
						,dblDebit
						,dblCredit
						,dblDebitUnit
						,dblCreditUnit
						,strDescription
						,strCode
						,strReference
						,intCurrencyId
						,dblExchangeRate
						,dtmDateEntered
						,dtmTransactionDate
						,strJournalLineDescription
						,intJournalLineNo
						,ysnIsUnposted
						,intUserId
						,intEntityId
						,strTransactionId
						,intTransactionId
						,strTransactionType
						,strTransactionForm
						,strModuleName
						,intConcurrencyId
						,dblDebitForeign
						,dblDebitReport
						,dblCreditForeign
						,dblCreditReport
						,dblReportingRate
						,dblForeignRate
					)	
					SELECT	TOP 1
							dtmDate = @dtmOpenPeriod
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Debit.Value --CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblCredit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE()--gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	irely02_25Oct.dbo.tblGLDetail gd INNER JOIN irely02_25Oct.dbo.tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN irely02_25Oct.dbo.tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN irely02_25Oct.dbo.tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory ) ia
					WHERE	--ia.intAccountId = gd.intAccountId
							t.intInventoryTransactionId = @intTemplateInventoryTransactionId
					UNION ALL 
					SELECT	TOP 1
							dtmDate = @dtmOpenPeriod
							,@strBatchId
							,ia.intAccountId
							,dblDebit = Credit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Credit.Value else Debit.Value END 
							,dblCredit = Debit.Value -- CASE WHEN gc.strAccountCategory = 'Inventory' THEN Debit.Value else Credit.Value END 
							,dblDebitUnit = 0 
							,dblCreditUnit = 0 
							,gd.strDescription
							,gd.strCode
							,gd.strReference
							,gd.intCurrencyId
							,gd.dblExchangeRate
							,GETDATE() -- gd.dtmDateEntered
							,gd.dtmTransactionDate
							,gd.strJournalLineDescription
							,intJournalLineNo = @InventoryTransactionIdentityId
							,gd.ysnIsUnposted
							,gd.intUserId
							,gd.intEntityId
							,gd.strTransactionId
							,gd.intTransactionId
							,gd.strTransactionType
							,gd.strTransactionForm
							,gd.strModuleName
							,gd.intConcurrencyId
							,dblDebitForeign = 0 
							,gd.dblDebitReport
							,dblCreditForeign = 0 
							,gd.dblCreditReport
							,dblReportingRate = 1
							,gd.dblForeignRate
					FROM	irely02_25Oct.dbo.tblGLDetail gd INNER JOIN irely02_25Oct.dbo.tblICInventoryTransaction t
								ON gd.intJournalLineNo = t.intInventoryTransactionId
								AND gd.strTransactionId = t.strTransactionId
								AND gd.strBatchId = t.strBatchId
							INNER JOIN irely02_25Oct.dbo.tblGLAccount ga
								ON ga.intAccountId = gd.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegmentMapping asm
								ON asm.intAccountId = ga.intAccountId
							INNER JOIN irely02_25Oct.dbo.tblGLAccountSegment gs
								ON gs.intAccountSegmentId = asm.intAccountSegmentId
								AND gs.intAccountStructureId = 1
							INNER JOIN irely02_25Oct.dbo.tblGLAccountCategory gc
								ON gc.intAccountCategoryId = gs.intAccountCategoryId
							CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
							CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit									
							CROSS APPLY dbo.fnGetItemGLAccountAsTable(@intItemId, @intItemLocationId, gc.strAccountCategory) ia
					WHERE	t.intInventoryTransactionId = @intTemplateInventoryTransactionId	
							AND gc.strAccountCategory <> 'Inventory' -- Make sure the contra account id is not 'Inventory'
				END 
			END 

			PRINT 'Updated open period: ' + @strBatchId
		END 	

		DELETE FROM tblICFixClosedPeriodValues WHERE @id = id
	END 
END


DROP TABLE tblICFixClosedPeriodValues
--DROP TABLE tblICUnableToFindOpenYear

-- Rebuild the G/L Summary 
BEGIN 
	DELETE [dbo].[tblGLSummary]

	INSERT INTO tblGLSummary
	SELECT
			intAccountId
			,dtmDate
			,SUM(ISNULL(dblDebit,0)) as dblDebit
			,SUM(ISNULL(dblCredit,0)) as dblCredit
			,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
			,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
			,strCode
			,0 as intConcurrencyId
	FROM
		tblGLDetail
	WHERE ysnIsUnposted = 0	
	GROUP BY intAccountId, dtmDate, strCode
END

_ExitWithError: 
_Exit: 
