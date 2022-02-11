CREATE PROCEDURE [dbo].[uspICPostStockDailyQuantity]
	@intInventoryTransactionId AS INT = NULL 
	,@strBatchId AS NVARCHAR(50) = NULL 
	,@strTransactionId AS NVARCHAR(50) = NULL 
	,@ysnRebuild AS BIT = 0 
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
				,[dblValue] = SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0))
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
				,[dblValue] = SUM(ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
				,[dblValueRounded] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.intInventoryTransactionId = @intInventoryTransactionId			
				OR (
					t.strBatchId = @strBatchId
					AND t.strTransactionId = @strTransactionId 
				)
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
		,[dtmDate] 
		,[dblQty] = SUM(dblQty) 
	FROM 
		tblICInventoryTransaction t 
	WHERE
		(
			t.intInventoryTransactionId = @intInventoryTransactionId			
			OR (
				t.strBatchId = @strBatchId
				AND t.strTransactionId = @strTransactionId 
			)
		)
		AND t.intItemUOMId IS NOT NULL 
	GROUP BY
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 

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
		 
	DECLARE 
		@intItemId INT
		,@intItemLocation INT
		,@intItemUOMId INT
		,@dtmDate DATETIME 
		,@dblQty NUMERIC(38, 20)
	
	WHILE EXISTS (SELECT TOP 1 1 FROM @stock)
	BEGIN 
		SELECT TOP 1 
			@intItemId = s.intItemId
			,@intItemLocation = s.intItemLocationId
			,@intItemUOMId = s.intItemUOMId
			,@dtmDate = s.dtmDate
			,@dblQty = s.dblQty
		FROM @stock s

		UPDATE asOfDate
		SET
			asOfDate.dblQty = ISNULL(asOfDate.dblQty, 0) + ISNULL(@dblQty, 0)
		FROM 
			tblICInventoryStockAsOfDate asOfDate 			
		WHERE
			asOfDate.intItemId = @intItemId
			AND asOfDate.intItemLocationId = @intItemLocation
			AND asOfDate.intItemUOMId = @intItemUOMId
			AND asOfDate.dtmDate >= @dtmDate

		DELETE @stock
		WHERE
			@intItemId = intItemId
			AND @intItemLocation = intItemLocationId
			AND @intItemUOMId = intItemUOMId
			AND @dtmDate = dtmDate
			AND @dblQty = dblQty

		SELECT 
			@intItemId = NULL
			,@intItemLocation = NULL
			,@intItemUOMId = NULL
			,@dtmDate = NULL
			,@dblQty = NULL
	END 
END 

RETURN 0