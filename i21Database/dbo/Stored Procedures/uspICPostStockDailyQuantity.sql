CREATE PROCEDURE [dbo].[uspICPostStockDailyQuantity]
	@intInventoryTransactionId AS INT = NULL 
	,@ysnRebuild AS BIT = 0 
	,@intItemId INT = NULL 
	,@intItemLocationId INT = NULL 
	,@intItemUOMId INT = NULL 
	,@intSubLocationId INT = NULL 
	,@intStorageLocationId INT = NULL 
	,@dtmDate DATETIME = NULL 
	,@dblQty NUMERIC(38,20) = NULL 
	,@dblUOMQty NUMERIC(38,20) = NULL 
	,@dblCost NUMERIC(38,20) = NULL 
	,@dblValue NUMERIC(38,20) = NULL 
	,@dblSalesPrice NUMERIC(18, 6)= NULL 
	,@intCurrencyId INT = NULL 
	,@intTransactionId INT = NULL 
	,@intTransactionDetailId INT = NULL 
	,@strTransactionId NVARCHAR(40) = NULL 
	,@strBatchId NVARCHAR(40) = NULL 
	,@intTransactionTypeId INT = NULL 
	,@intLotId INT = NULL 
	,@intRelatedInventoryTransactionId INT = NULL 
	,@intRelatedTransactionId INT = NULL 
	,@strRelatedTransactionId NVARCHAR(40) = NULL 
	,@strTransactionForm NVARCHAR (255) = NULL 
	,@intEntityUserSecurityId INT = NULL 
	,@intCostingMethod INT = NULL 
	,@intFobPointId TINYINT = NULL 
	,@intInTransitSourceLocationId INT = NULL 
	,@intForexRateTypeId INT = NULL
	,@dblForexRate NUMERIC(38, 20) = 1
	,@strDescription NVARCHAR(255) = NULL 
	,@strActualCostId NVARCHAR(50) = NULL  
	,@dblUnitRetail NUMERIC(38,20) = NULL  
	,@dblCategoryCostValue NUMERIC(38,20) = NULL  
	,@dblCategoryRetailValue NUMERIC(38,20) = NULL  
	,@intSourceEntityId INT = NULL  
	,@intTransactionItemUOMId INT = NULL 
	,@strSourceType NVARCHAR(100) = NULL 
	,@strSourceNumber NVARCHAR(100) = NULL 
	,@strBOLNumber NVARCHAR(100) = NULL 
	,@intTicketId INT = NULL 
AS

DECLARE @stock AS TABLE(
	[intItemId] INT
	,[intItemLocationId] INT
	,[intItemUOMId] INT
	,[dtmDate] DATETIME
	,[dblQty] NUMERIC(38, 17)
)

-----------------------------------
-- Rebuild the Daily Quantity
-----------------------------------
IF @ysnRebuild = 1 
BEGIN 
	TRUNCATE TABLE tblICInventoryDailyTransaction;
	TRUNCATE TABLE tblICInventoryStockAsOfDate;

	MERGE	
	INTO	dbo.tblICInventoryDailyTransaction 
	WITH	(HOLDLOCK) 
	AS		DailyTransaction	
	USING (
			SELECT	
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
				,[dblQty] = SUM(dblQty) 
				,[dblValue] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
				,[dblValueRounded] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
			FROM 
				tblICInventoryTransaction t
			GROUP BY
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
	) AS StockToUpdate
		ON 
			DailyTransaction.[intItemId] = StockToUpdate.intItemId 
			AND DailyTransaction.[intItemLocationId] = StockToUpdate.intItemLocationId 
			AND DailyTransaction.[intInTransitSourceLocationId] = StockToUpdate.intInTransitSourceLocationId 
			AND DailyTransaction.[intCompanyLocationId] = StockToUpdate.intCompanyLocationId
			AND DailyTransaction.[intSubLocationId] = StockToUpdate.intSubLocationId 
			AND DailyTransaction.[intStorageLocationId] = StockToUpdate.intStorageLocationId 
			AND DailyTransaction.[intItemUOMId] = StockToUpdate.intItemUOMId 
			AND DailyTransaction.[intCompanyId] = StockToUpdate.intCompanyId 
			AND DailyTransaction.[dtmDate] = StockToUpdate.dtmDate 

	-- If matched, update daily qty and value
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			DailyTransaction.dblQty = ISNULL(DailyTransaction.dblQty, 0) + ISNULL(StockToUpdate.dblQty, 0)
			,DailyTransaction.dblValue = ISNULL(DailyTransaction.dblValue, 0) + ISNULL(StockToUpdate.dblValue, 0)
			,DailyTransaction.dblValueRounded = ISNULL(DailyTransaction.dblValueRounded, 0) + ISNULL(StockToUpdate.dblValueRounded, 0)

	-- If none found, insert a new record
	WHEN NOT MATCHED THEN 
		INSERT (
			[intItemId]
			,[intItemLocationId] 
			,[intInTransitSourceLocationId] 
			,[intCompanyLocationId]
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intCompanyId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblValue] 
			,[dblValueRounded]
		)
		VALUES (
			StockToUpdate.[intItemId]
			,StockToUpdate.[intItemLocationId] 
			,StockToUpdate.[intInTransitSourceLocationId] 
			,StockToUpdate.[intCompanyLocationId]
			,StockToUpdate.[intSubLocationId] 
			,StockToUpdate.[intStorageLocationId] 
			,StockToUpdate.[intItemUOMId] 
			,StockToUpdate.[intCompanyId] 
			,StockToUpdate.[dtmDate] 
			,StockToUpdate.[dblQty] 
			,StockToUpdate.[dblValue] 
			,StockToUpdate.[dblValueRounded] 
		)
	;

	INSERT INTO @stock
	SELECT	
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,dtmDate = dbo.fnRemoveTimeOnDate(t.dtmDate) 
		,[dblQty] = SUM(dblQty) 
	FROM 
		tblICInventoryTransaction t 				
	WHERE
		t.intItemUOMId IS NOT NULL 				
	GROUP BY
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,dbo.fnRemoveTimeOnDate(t.dtmDate) 
	ORDER BY
		dbo.fnRemoveTimeOnDate(t.dtmDate) ASC

	-- insert as zero record. 
	INSERT INTO tblICInventoryStockAsOfDate 
	(
		[intItemId]
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
	)
	SELECT 
		[intItemId]
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] = 0 
	FROM 
		@stock
	ORDER BY
		[intItemId] ASC 
		,[intItemLocationId] ASC 
		,[intItemUOMId] ASC 
		,[dtmDate] ASC 
		 
	UPDATE asOfDate
	SET
		asOfDate.dblQty = ISNULL(asOfDate.dblQty, 0) + ISNULL(s.dblQty, 0)
	FROM 
		tblICInventoryStockAsOfDate asOfDate 
		OUTER APPLY (
			SELECT 
				dblQty = SUM(ISNULL(s.dblQty, 0)) 
			FROM 
				@stock s
			WHERE 
				s.intItemId = asOfDate.[intItemId]
				AND s.intItemLocationId = asOfDate.[intItemLocationId]
				AND s.intItemUOMId = asOfDate.[intItemUOMId]
				AND s.dtmDate <= asOfDate.[dtmDate] 
		) s
END
ELSE 
BEGIN 
	MERGE	
	INTO	dbo.tblICInventoryDailyTransaction 
	WITH	(HOLDLOCK) 
	AS		DailyTransaction	
	USING (
			SELECT	
				[intItemId] = @intItemId 
				,[intItemLocationId] = @intItemLocationId 
				,[intInTransitSourceLocationId] = @intInTransitSourceLocationId
				,[intCompanyLocationId] = [location].intCompanyLocationId
				,[intSubLocationId] = @intSubLocationId
				,[intStorageLocationId] = @intStorageLocationId
				,[intItemUOMId] = @intItemUOMId
				,[intCompanyId] = NULL 
				,[dtmDate] = @dtmDate
				,[dblQty] = @dblQty 
				,[dblValue] = ROUND(dbo.fnMultiply(@dblQty, @dblCost) + @dblValue, 2)
				,[dblValueRounded] = ROUND(dbo.fnMultiply(@dblQty, @dblCost) + @dblValue, 2)
			FROM
				[dbo].[fnICGetCompanyLocation](@intItemLocationId, @intInTransitSourceLocationId) [location]
			--SELECT	
			--	[intItemId] 
			--	,[intItemLocationId] 
			--	,[intInTransitSourceLocationId] 
			--	,[intCompanyLocationId]
			--	,[intSubLocationId] 
			--	,[intStorageLocationId] 
			--	,[intItemUOMId] 
			--	,[intCompanyId] 
			--	,[dtmDate] 
			--	,[dblQty] = SUM(dblQty) 
			--	,[dblValue] = SUM(ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
			--	,[dblValueRounded] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
			--FROM 
			--	tblICInventoryTransaction t 
			--WHERE
			--	(
			--		t.intInventoryTransactionId = @intInventoryTransactionId			
			--		OR (
			--			t.strBatchId = @strBatchId
			--			AND t.strTransactionId = @strTransactionId 
			--		)
			--	)
			--	-- Do not read the inventory transaction if it will not reduce the stock. 
			--	AND ISNULL(t.dblQty, 0) >= 0 
			--GROUP BY
			--	[intItemId] 
			--	,[intItemLocationId] 
			--	,[intInTransitSourceLocationId] 
			--	,[intCompanyLocationId]
			--	,[intSubLocationId] 
			--	,[intStorageLocationId] 
			--	,[intItemUOMId] 
			--	,[intCompanyId] 
			--	,[dtmDate] 
			--UNION ALL 
			---- Read the reduce stock separately in case the reduce stock is merged as one record in the valuation.
			--SELECT	
			--	[intItemId] 
			--	,[intItemLocationId] 
			--	,[intInTransitSourceLocationId] 
			--	,[intCompanyLocationId]
			--	,[intSubLocationId] 
			--	,[intStorageLocationId] 
			--	,[intItemUOMId] 
			--	,[intCompanyId] 
			--	,[dtmDate] 
			--	,[dblQty] = ISNULL(@dblQty, t.dblQty)
			--	,[dblValue] = ROUND(dbo.fnMultiply(ISNULL(@dblQty, t.dblQty), t.dblCost) + t.dblValue, 2)
			--	,[dblValueRounded] = ROUND(dbo.fnMultiply(ISNULL(@dblQty, t.dblQty), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2)
			--FROM 
			--	tblICInventoryTransaction t 
			--WHERE
			--	(
			--		t.intInventoryTransactionId = @intInventoryTransactionId			
			--		OR (
			--			t.strBatchId = @strBatchId
			--			AND t.strTransactionId = @strTransactionId 
			--		)
			--	)
			--	AND ISNULL(t.dblQty, 0) < 0  
	) AS StockToUpdate
		ON 
			DailyTransaction.[intItemId] = StockToUpdate.intItemId 
			AND DailyTransaction.[intItemLocationId] = StockToUpdate.intItemLocationId 
			AND DailyTransaction.[intInTransitSourceLocationId] = StockToUpdate.intInTransitSourceLocationId 
			AND DailyTransaction.[intCompanyLocationId] = StockToUpdate.intCompanyLocationId 
			AND DailyTransaction.[intSubLocationId] = StockToUpdate.intSubLocationId 
			AND DailyTransaction.[intStorageLocationId] = StockToUpdate.intStorageLocationId 
			AND DailyTransaction.[intItemUOMId] = StockToUpdate.intItemUOMId 
			AND DailyTransaction.[intCompanyId] = StockToUpdate.intCompanyId 
			AND DailyTransaction.[dtmDate] = StockToUpdate.dtmDate 

	-- If matched, update daily qty and value
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			DailyTransaction.dblQty = ISNULL(DailyTransaction.dblQty, 0) + ISNULL(StockToUpdate.dblQty, 0)
			,DailyTransaction.dblValue = ISNULL(DailyTransaction.dblValue, 0) + ISNULL(StockToUpdate.dblValue, 0)
			,DailyTransaction.dblValueRounded = ISNULL(DailyTransaction.dblValueRounded, 0) + ISNULL(StockToUpdate.dblValueRounded, 0)

	-- If none found, insert a new record
	WHEN NOT MATCHED THEN 
		INSERT (
			[intItemId]
			,[intItemLocationId] 
			,[intInTransitSourceLocationId] 
			,[intCompanyLocationId]
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intCompanyId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblValue] 
			,[dblValueRounded]
		)
		VALUES (
			StockToUpdate.[intItemId]
			,StockToUpdate.[intItemLocationId] 
			,StockToUpdate.[intInTransitSourceLocationId] 
			,StockToUpdate.[intCompanyLocationId]
			,StockToUpdate.[intSubLocationId] 
			,StockToUpdate.[intStorageLocationId] 
			,StockToUpdate.[intItemUOMId] 
			,StockToUpdate.[intCompanyId] 
			,StockToUpdate.[dtmDate] 
			,StockToUpdate.[dblQty] 
			,StockToUpdate.[dblValue] 
			,StockToUpdate.[dblValueRounded] 
		)
	;

	--INSERT INTO @stock
	--SELECT	
	--	[intItemId] 
	--	,[intItemLocationId] 
	--	,[intItemUOMId] 
	--	,[dtmDate] 
	--	,[dblQty] = SUM(dblQty) 
	--FROM 
	--	tblICInventoryTransaction t 
	--WHERE
	--	(
	--		t.intInventoryTransactionId = @intInventoryTransactionId			
	--		OR (
	--			(t.strBatchId = @strBatchId AND @strBatchId IS NOT NULL)
	--			AND (t.strTransactionId = @strTransactionId AND @strTransactionId IS NOT NULL) 
	--		)
	--	)
	--	AND t.intItemUOMId IS NOT NULL 
	--GROUP BY
	--	[intItemId] 
	--	,[intItemLocationId] 
	--	,[intItemUOMId] 
	--	,[dtmDate] 

	INSERT INTO @stock
	SELECT	
		[intItemId] = @intItemId
		,[intItemLocationId] = @intItemLocationId
		,[intItemUOMId] = @intItemUOMId
		,[dtmDate] = @dtmDate
		,[dblQty] = @dblQty 	

	-- insert a new record if it does not exists. 
	INSERT INTO tblICInventoryStockAsOfDate 
	(
		[intItemId]
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
	)
	SELECT 
		s.intItemId
		,s.intItemLocationId
		,s.intItemUOMId
		,s.dtmDate
		,[dblQty] = ISNULL(carryOverStock.dblQty, 0)  
	FROM 
		tblICInventoryStockAsOfDate asOfDate RIGHT JOIN @stock s
			ON asOfDate.[intItemId] = s.intItemId 
			AND asOfDate.[intItemLocationId] = s.intItemLocationId 
			AND asOfDate.[intItemUOMId] = s.intItemUOMId 
			AND asOfDate.[dtmDate] = s.dtmDate 
		OUTER APPLY (
			SELECT TOP 1
				t.dblQty
			FROM 
				tblICInventoryStockAsOfDate t
			WHERE
				t.intItemId = s.intItemId
				AND t.intItemLocationId = s.intItemLocationId
				AND t.intItemUOMId = s.intItemUOMId	
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) < FLOOR(CAST(s.dtmDate AS FLOAT))
			ORDER BY
				t.dtmDate DESC 
		) carryOverStock
	WHERE
		asOfDate.intId IS NULL 
		 
	--DECLARE 
	--	@stock_intItemId INT
	--	,@stock_intItemLocation INT
	--	,@stock_intItemUOMId INT
	--	,@stock_dtmDate DATETIME 
	--	,@stock_dblQty NUMERIC(38, 20)
	
	--WHILE EXISTS (SELECT TOP 1 1 FROM @stock)
	--BEGIN 
	--	SELECT TOP 1 
	--		@stock_intItemId = s.intItemId
	--		,@stock_intItemLocation = s.intItemLocationId
	--		,@stock_intItemUOMId = s.intItemUOMId
	--		,@stock_dtmDate = s.dtmDate
	--		,@stock_dblQty = s.dblQty
	--	FROM @stock s	

	--	UPDATE asOfDate
	--	SET
	--		asOfDate.dblQty = ISNULL(asOfDate.dblQty, 0) + ISNULL(@dblQty, 0)
	--	FROM 
	--		tblICInventoryStockAsOfDate asOfDate 			
	--	WHERE
	--		asOfDate.intItemId = @stock_intItemId
	--		AND asOfDate.intItemLocationId = @stock_intItemLocation
	--		AND asOfDate.intItemUOMId = @stock_intItemUOMId
	--		AND asOfDate.dtmDate >= @stock_dtmDate

	--	DELETE @stock
	--	WHERE
	--		@stock_intItemId = intItemId
	--		AND @stock_intItemLocation = intItemLocationId
	--		AND @stock_intItemUOMId = intItemUOMId
	--		AND @stock_dtmDate = dtmDate
	--		AND @stock_dblQty = dblQty

	--	SELECT 
	--		@stock_intItemId = NULL
	--		,@stock_intItemLocation = NULL
	--		,@stock_intItemUOMId = NULL
	--		,@stock_dtmDate = NULL
	--		,@stock_dblQty = NULL
	--END 

	UPDATE asOfDate
	SET
		asOfDate.dblQty = ISNULL(asOfDate.dblQty, 0) + ISNULL(@dblQty, 0)
	FROM 
		tblICInventoryStockAsOfDate asOfDate 			
	WHERE
		asOfDate.intItemId = @intItemId
		AND asOfDate.intItemLocationId = @intItemLocationId
		AND asOfDate.intItemUOMId = @intItemUOMId
		AND asOfDate.dtmDate >= @dtmDate
END 

RETURN 0