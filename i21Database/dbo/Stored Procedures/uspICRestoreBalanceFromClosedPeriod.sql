/*
	uspICRestoreBalanceFromClosedPeriod
	Use this stored procedure to restore the 

	How to use: 
	1. Determine the open period. 
	2. For example:
		2.1. Closed accounting periods are Jan 201x to September 201x. 
		2.2. This means October 201x is the next open period. 
		2.3. Specify 10/01/201x as the argument in @dtmOpenPeriod parameter. 
*/

CREATE PROCEDURE uspICRestoreBalanceFromClosedPeriod
	@dtmOpenPeriod AS DATETIME 

AS 

DECLARE @intOpenYear AS INT = YEAR(@dtmOpenPeriod) 
DECLARE @intFirstOpenMonth AS INT = MONTH(@dtmOpenPeriod) 

DECLARE @id AS INT
		,@strOldBatchId AS NVARCHAR(50) 
		,@strNewBatchId AS NVARCHAR(50) 
		,@intOldInventoryTransactionId AS INT 
		,@intNewInventoryTransactionId AS INT 
		,@strTransactionType AS NVARCHAR(50) 
		,@year AS INT 
		,@month AS INT
		,@valueDifference NUMERIC(38, 20) 
		,@strOldTransactionId AS NVARCHAR(50) 
		,@strNewTransactionId AS NVARCHAR(50) 

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
	--,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[year] INT
	,[month] INT
	,dblOldValue NUMERIC(38, 20) 	
	,dblNewValue NUMERIC(38, 20) 
	,dblDifference NUMERIC(38, 20) 
	,CONSTRAINT [PK_tblICFixClosedPeriodValues] PRIMARY KEY CLUSTERED ([id]) 
) 

CREATE TABLE tblICUnableToFindOpenYear (
	[intItemId] INT 
	,[intItemLocationId] INT 
	,[intSubLocationId] INT 
	,[intStorageLocationId] INT
	,[intLotId] INT
	,[value]  NUMERIC(38, 20) 
	,[type] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,[intOldInventoryTransactionId] INT 
)

BEGIN 
	INSERT INTO tblICFixClosedPeriodValues (
		intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,strTransactionType
		--,strTransactionId
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
					, [year] = YEAR(t.dtmDate)
					, [month] = MONTH(t.dtmDate) 
					, [value] = SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2))
			FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
					INNER JOIN dbo.tblICItem i
						ON i.intItemId = t.intItemId
			GROUP BY 
				t.intItemId
				, t.intItemLocationId
				, t.intSubLocationId
				, t.intStorageLocationId
				, t.intLotId
				, ty.strName
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
					, [year] = YEAR(t.dtmDate)
					, [month] = MONTH(t.dtmDate) 
					, [value] = SUM(ROUND(t.dblQty * t.dblCost + t.dblValue, 2))					
			FROM	irely02_25Oct.dbo.tblICInventoryTransaction t INNER JOIN irely02_25Oct.dbo.tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
					INNER JOIN irely02_25Oct.dbo.tblICItem i
						ON i.intItemId = t.intItemId
			GROUP BY 
				t.intItemId
				, t.intItemLocationId
				, t.intSubLocationId
				, t.intStorageLocationId
				, t.intLotId
				, ty.strName	
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
		FROM	tblICFixClosedPeriodValues
	
		-- Update the closed period	
		BEGIN 
			PRINT 'Get the closed period.'

			SET @intOldInventoryTransactionId = NULL 
			SET @strOldBatchId = NULL 

			-- Get the last transaction record for the Item, Lot Id, Location Set, Transaction Type, Year, and Month from the closed year period.
			SELECT	TOP 1 
					@intOldInventoryTransactionId = t.intInventoryTransactionId
					,@strOldBatchId = t.strBatchId
			FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
			WHERE	t.intItemId = @intItemId
					AND t.intItemLocationId = @intItemLocationId
					AND ISNULL(t.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
					AND ISNULL(t.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0) 
					AND ISNULL(t.intLotId, 0) = ISNULL(@intLotId, 0) 
					AND ty.strName = @strTransactionType
					AND YEAR(t.dtmDate) = @year
					AND MONTH(t.dtmDate) = @month
			ORDER BY t.intInventoryTransactionId DESC 

			--SELECT	'DEBUG old transaction id'
			--		,t.dblQty
			--		,t.dblCost
			--		,t.dblValue
			--		,t.intItemId
			--		,t.intItemLocationId
			--		,t.intStorageLocationId
			--		,t.intLotId 
			--FROM	tblICInventoryTransaction t
			--WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

			-- If there is no old transaction, try to create a new record. 
			IF @intOldInventoryTransactionId IS NULL 
			BEGIN 
				PRINT 'Create a new closed period.'

				-- Try to get the first transaction from the open period. 
				SELECT	TOP 1 
						@intOldInventoryTransactionId = t.intInventoryTransactionId
				FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
							ON t.intTransactionTypeId = ty.intTransactionTypeId
				WHERE	t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId
						AND ISNULL(t.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
						AND ISNULL(t.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0) 
						AND ISNULL(t.intLotId, 0) = ISNULL(@intLotId, 0) 
						AND ty.strName = @strTransactionType
						AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1 
				ORDER BY t.intInventoryTransactionId ASC 

				-- Try again 
				IF @intOldInventoryTransactionId IS NULL 
				BEGIN 
					-- By the item, location, and type. 
					SELECT	TOP 1 
							@intOldInventoryTransactionId = t.intInventoryTransactionId
					FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
								ON t.intTransactionTypeId = ty.intTransactionTypeId
					WHERE	t.intItemId = @intItemId
							AND t.intItemLocationId = @intItemLocationId
							AND ty.strName = @strTransactionType
							AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1 
					ORDER BY t.intInventoryTransactionId ASC 
				END 

				-- Try again 
				IF @intOldInventoryTransactionId IS NULL 
				BEGIN 
					-- By Item Location and Type
					SELECT	TOP 1 
							@intOldInventoryTransactionId = t.intInventoryTransactionId
					FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
								ON t.intTransactionTypeId = ty.intTransactionTypeId
					WHERE	t.intItemLocationId = @intItemLocationId
							AND ty.strName = @strTransactionType
							AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1 
					ORDER BY t.intInventoryTransactionId ASC 
				END 

				-- Try again 
				IF @intOldInventoryTransactionId IS NULL 
				BEGIN 
					-- By the transaction type
					SELECT	TOP 1 
							@intOldInventoryTransactionId = t.intInventoryTransactionId
					FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
								ON t.intTransactionTypeId = ty.intTransactionTypeId
					WHERE	ty.strName = @strTransactionType
							AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1 
					ORDER BY t.intInventoryTransactionId ASC 
				END 

				-- Last Attempt failed. Raise the error. 
				IF @intOldInventoryTransactionId IS NULL 
				BEGIN 
					SELECT 'Unable to find a closed period.', * FROM tblICFixClosedPeriodValues WHERE id = @id
					
					RAISERROR('Unable to find a closed period record.', 16, 1);
					GOTO _ExitWithError; 
				END 
				ELSE 
				-- Create a closed year record. 
				BEGIN 
					-- Get a template transaction from the open period. 
					SET @intInventoryTransactionId = NULL 
					SELECT	TOP  1 
							@intItemId = @intItemId
							,@intItemLocationId = @intItemLocationId
							,@intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
							,@intSubLocationId = @intSubLocationId
							,@intStorageLocationId = @intStorageLocationId
							,@dtmDate = DATEFROMPARTS(@year, @month, 1)
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
					WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId
		
					IF @intInventoryTransactionId IS NULL 
					BEGIN 
						RAISERROR('Unable to find a template.', 16, 1);
						GOTO _ExitWithError; 	
					END 
					ELSE 
					BEGIN 
						SET @InventoryTransactionIdentityId = NULL 
						-- Create the Inventory Transaction 
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
								,@dblExchangeRate = @dblExchangeRate
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
							WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

							SELECT	TOP  1 
									'Unable to create the G/L entries'
									,[@intItemId] = @intItemId
									,[@intItemLocationId] = @intItemLocationId
									,[@intItemUOMId] = @intItemUOMId
									,[@intSubLocationId] = @intSubLocationId
									,[@intStorageLocationId] = @intStorageLocationId
									,[@dtmDate] = DATEFROMPARTS(@year, @month, 1)
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
							WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

							RAISERROR('Unable to create the G/L entries', 16, 1);
							GOTO _ExitWithError; 				
						END 
			
						-- Create the G/L entries 
						ELSE 
						BEGIN 
							PRINT 'create the g/l entries for the closed period.'
							PRINT @strBatchId
							PRINT @InventoryTransactionIdentityId
							PRINT @intOldInventoryTransactionId 

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
									dtmDate = DATEFROMPARTS(@year, @month, 1)
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
									t.intInventoryTransactionId = @intOldInventoryTransactionId
							UNION ALL 
							SELECT	TOP 1
									dtmDate = DATEFROMPARTS(@year, @month, 1)
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
							WHERE	--ia.intAccountId <> gd.intAccountId
									t.intInventoryTransactionId = @intOldInventoryTransactionId	
									AND gc.strAccountCategory <> 'Inventory' -- Make sure the contra account id is not 'Inventory'
									--AND @strTransactionType NOT IN ('Revalue WIP')			
						END 
					END 
				END 
			END  
			ELSE 
			BEGIN 
				PRINT 'Update a closed period.'				

				--select 'before update t', [@valueDifference] = @valueDifference, t.dblValue, t.intInventoryTransactionId, t.dtmDate, t.strBatchId, t.strTransactionId, t.dblQty * t.dblCost + t.dblValue, @valueDifference
				--FROM	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
				--			on t.intTransactionTypeId = ty.intTransactionTypeId
				--WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

				-- Add the value to the closed period transaction. 
				UPDATE	t
				SET		t.dblValue = ISNULL(t.dblValue, 0) + @valueDifference
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

				--select 'after update t', [@valueDifference] = @valueDifference, t.dblValue, t.intInventoryTransactionId, t.dtmDate, t.strBatchId, t.strTransactionId, t.dblQty * t.dblCost + t.dblValue, @valueDifference
				--FROM	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
				--			on t.intTransactionTypeId = ty.intTransactionTypeId
				--WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

				--select 'before gl update', gd.strTransactionId, gd.strBatchId, gd.intAccountId, gd.dblDebit, gd.dblCredit, gd.dtmDate, gd.ysnIsUnposted
				--FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
				--			ON gd.intJournalLineNo = t.intInventoryTransactionId
				--			AND gd.strTransactionId = t.strTransactionId
				--			AND gd.strBatchId = t.strBatchId						
				--WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

				-- Update the g/l entries for the closed period. 							
				-- Update the Inventory account
				UPDATE	gd 
				SET		dblDebit = Debit.Value 
						,dblCredit = Credit.Value 
				FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId					
						CROSS APPLY dbo.fnGetDebit(
							--dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0)		
							ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)
						) Debit
						CROSS APPLY dbo.fnGetCredit(
							--dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0)
							ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)
						) Credit					
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia 			
				WHERE	ia.intAccountId = gd.intAccountId
						AND t.intInventoryTransactionId = @intOldInventoryTransactionId

				-- Update the Contra Account 
				UPDATE	gd 
				SET		dblDebit = Credit.Value
						,dblCredit =  Debit.Value 
				FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId					
						CROSS APPLY dbo.fnGetDebit(
							--dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0)		
							ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)	
						) Debit
						CROSS APPLY dbo.fnGetCredit(
							--dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0) 
							ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)			
						) Credit					
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia 			
				WHERE	ia.intAccountId <> gd.intAccountId
						AND t.intInventoryTransactionId = @intOldInventoryTransactionId

				--select 'after gl update', gd.strTransactionId, gd.strBatchId, gd.intAccountId, gd.dblDebit, gd.dblCredit, gd.dtmDate, gd.ysnIsUnposted
				--FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
				--			ON gd.intJournalLineNo = t.intInventoryTransactionId
				--			AND gd.strTransactionId = t.strTransactionId
				--			AND gd.strBatchId = t.strBatchId						
				--WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

			END 
			PRINT 'Updated closed period: ' + @strOldBatchId
		END

		-- Upate the Open period. 
		BEGIN 
			PRINT 'Update the open period.'

			SET @intNewInventoryTransactionId = NULL 
			SET @strNewBatchId = NULL 

			-- Get the last transaction record for the Item, Location Set, Transaction Type, Year, and Month on the open year period.
			SELECT	TOP 1 
					@intNewInventoryTransactionId = t.intInventoryTransactionId
					,@strNewBatchId = t.strBatchId
			FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
			WHERE	t.intItemId = @intItemId
					AND t.intItemLocationId = @intItemLocationId
					AND ISNULL(t.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
					AND ISNULL(t.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0) 
					AND ISNULL(t.intLotId, 0) = ISNULL(@intLotId, 0) 
					AND ty.strName = @strTransactionType
					AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1
			ORDER BY t.intInventoryTransactionId ASC

			-- If we can't find a suitable open period record with lot id in it, then pick a record by the item id and location only.  
			IF @intNewInventoryTransactionId IS NULL 
			BEGIN 
				SELECT	TOP 1 
						@intNewInventoryTransactionId = t.intInventoryTransactionId
						,@strNewBatchId = t.strBatchId
				FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
							ON t.intTransactionTypeId = ty.intTransactionTypeId
				WHERE	t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId
						AND ty.strName = @strTransactionType
						AND dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmOpenPeriod) = 1
				ORDER BY t.intInventoryTransactionId ASC
			END

			IF @intNewInventoryTransactionId IS NOT NULL
			BEGIN 
				-- Add the difference in the open year period. 
				UPDATE	t
				SET		dblValue -= @valueDifference
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @intNewInventoryTransactionId

				-- Update the g/l entries for the OPEN period. 
				-- Update the INVENTORY g/l account
				UPDATE	gd
				SET		dblDebit = Debit.Value
						,dblCredit = Credit.Value
				FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
						CROSS APPLY dbo.fnGetDebit(
							dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0)			
						) Debit
						CROSS APPLY dbo.fnGetCredit(
							dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0) 			
						) Credit
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia
				WHERE	ia.intAccountId = gd.intAccountId
						AND t.intInventoryTransactionId = @intNewInventoryTransactionId

				-- Update the contra-account
				UPDATE	gd
				SET		dblDebit = Credit.Value
						,dblCredit = Debit.Value
				FROM	tblGLDetail gd INNER JOIN tblICInventoryTransaction t
							ON gd.intJournalLineNo = t.intInventoryTransactionId
							AND gd.strTransactionId = t.strTransactionId
							AND gd.strBatchId = t.strBatchId
						CROSS APPLY dbo.fnGetDebit(
							dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0)			
						) Debit
						CROSS APPLY dbo.fnGetCredit(
							dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0) 			
						) Credit
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia
				WHERE	ia.intAccountId <> gd.intAccountId
						AND t.intInventoryTransactionId = @intNewInventoryTransactionId

				PRINT 'Updated open period: ' + @strNewBatchId
			END 
			ELSE 
			BEGIN 
				-- Keep track of those adjustments that does not have records in the FY open period. 
				INSERT INTO tblICUnableToFindOpenYear (
					[intItemId] 
					,[intItemLocationId] 
					,[intSubLocationId] 
					,[intStorageLocationId] 
					,[intLotId] 
					,[value] 
					,[type] 
					,[intOldInventoryTransactionId]
				)
				SELECT 
					[intItemId] = @intItemId
					,[intItemLocationId] = @intItemLocationId
					,[intSubLocationId] = @intSubLocationId
					,[intStorageLocationId] = @intStorageLocationId
					,[intLotId] = @intLotId 
					,[value] = @valueDifference
					,[type] = @strTransactionType
					,[intOldInventoryTransactionId] = @intOldInventoryTransactionId
			END 
		END 

		DELETE FROM tblICFixClosedPeriodValues WHERE @id = id
	END 
END

-- Create new Inventory Transaction records 
-- If it does not exsits in the open year. 
IF EXISTS (SELECT TOP 1 1 FROM tblICUnableToFindOpenYear) 
BEGIN 
	SELECT	[Reason] = 'For the FY Open Period.'
			,* 
	FROM	tblICUnableToFindOpenYear
	
	DECLARE loopMissingOpenPeriod CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intOldInventoryTransactionId
			,-[value]
	FROM	tblICUnableToFindOpenYear
		
	OPEN loopMissingOpenPeriod;

	-- Initial fetch attempt
	FETCH NEXT FROM loopMissingOpenPeriod INTO 
		@intOldInventoryTransactionId
		,@valueDifference;
	
	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @intInventoryTransactionId = NULL 
		SELECT	TOP  1 
				@intItemId = t.intItemId
				,@intItemLocationId = t.intItemLocationId
				,@intItemUOMId = t.intItemUOMId
				,@intSubLocationId = t.intSubLocationId
				,@intStorageLocationId = t.intStorageLocationId
				,@dtmDate = @dtmOpenPeriod
				,@intLotId = t.intLotId
				,@dblQty = 0
				,@dblUOMQty = 0 
				,@dblCost = 0
				,@dblSalesPrice = 0 
				,@intCurrencyId = @DefaultCurrencyId 
				,@dblExchangeRate = 1
				,@intTransactionId = t.intTransactionId
				,@intTransactionDetailId = t.intTransactionDetailId
				,@strTransactionId = t.strTransactionId
				,@strBatchId = t.strBatchId
				,@intTransactionTypeId = t.intTransactionTypeId
				,@strTransactionForm = t.strTransactionForm
				,@intEntityUserSecurityId = t.intCreatedEntityId
				,@intCostingMethod = t.intCostingMethod
				,@intInventoryTransactionId = t.intInventoryTransactionId
		FROM	tblICInventoryTransaction t
		WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId
		
		IF @intInventoryTransactionId IS NOT NULL
		BEGIN 
			SET @InventoryTransactionIdentityId = NULL 
			-- Create the Inventory Transaction 
			EXEC [dbo].[uspICPostInventoryTransaction]
					@intItemId = @intItemId
					,@intItemLocationId = @intItemLocationId
					,@intItemUOMId = @intItemUOMId
					,@intSubLocationId = @intSubLocationId
					,@intStorageLocationId = @intStorageLocationId					 
					,@dtmDate = @dtmDate
					,@dblQty = 0
					,@dblUOMQty = @dblUOMQty 
					,@dblCost = 0 
					,@dblValue = @valueDifference
					,@dblSalesPrice = @dblSalesPrice
					,@intCurrencyId = @intCurrencyId
					,@dblExchangeRate = @dblExchangeRate
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
				WHERE	t.intInventoryTransactionId = @intOldInventoryTransactionId

				RAISERROR('Unable to create the G/L entries', 16, 1);
				GOTO _ExitWithError; 				
			END 
			
			-- Create the G/L entries 
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
				SELECT	dtmDate = @dtmOpenPeriod
						,gd.strBatchId
						,gd.intAccountId
						,dblDebit = Debit.Value
						,dblCredit = Credit.Value
						,gd.dblDebitUnit
						,gd.dblCreditUnit
						,gd.strDescription
						,gd.strCode
						,gd.strReference
						,gd.intCurrencyId
						,gd.dblExchangeRate
						,gd.dtmDateEntered
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
						CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
						CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia
				WHERE	ia.intAccountId = gd.intAccountId
						AND t.intInventoryTransactionId = @intOldInventoryTransactionId
				UNION ALL 
				SELECT	dtmDate = @dtmOpenPeriod
						,gd.strBatchId
						,gd.intAccountId
						,dblDebit = Credit.Value
						,dblCredit = Debit.Value
						,gd.dblDebitUnit
						,gd.dblCreditUnit
						,gd.strDescription
						,gd.strCode
						,gd.strReference
						,gd.intCurrencyId
						,gd.dblExchangeRate
						,gd.dtmDateEntered
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
						CROSS APPLY dbo.fnGetDebit(@valueDifference) Debit
						CROSS APPLY dbo.fnGetCredit(@valueDifference) Credit											
						CROSS APPLY dbo.fnGetItemGLAccountAsTable(t.intItemId, t.intItemLocationId, 'Inventory') ia
				WHERE	ia.intAccountId <> gd.intAccountId
						AND t.intInventoryTransactionId = @intOldInventoryTransactionId				
			END 
		END 

		FETCH NEXT FROM loopMissingOpenPeriod INTO 
			@intOldInventoryTransactionId
			,@valueDifference;
	END 

	CLOSE loopMissingOpenPeriod;
	DEALLOCATE loopMissingOpenPeriod;
END 

DROP TABLE tblICFixClosedPeriodValues
DROP TABLE tblICUnableToFindOpenYear

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