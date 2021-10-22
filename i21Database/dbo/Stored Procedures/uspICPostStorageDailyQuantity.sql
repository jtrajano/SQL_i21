CREATE PROCEDURE [dbo].[uspICPostStorageDailyQuantity]
	@intInventoryTransactionStorageId AS INT = NULL 
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
	TRUNCATE TABLE tblICInventoryStorageAsOfDate;
	
	INSERT INTO @stock
	SELECT	
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,dtmDate = dbo.fnRemoveTimeOnDate(t.dtmDate) 
		,[dblQty] = SUM(dblQty) 
	FROM 
		tblICInventoryTransactionStorage t 				
	WHERE
		t.intItemUOMId IS NOT NULL 				
	GROUP BY
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,dbo.fnRemoveTimeOnDate(t.dtmDate) 
	ORDER BY
		dbo.fnRemoveTimeOnDate(t.dtmDate)  DESC 

	-- insert as zero record. 
	INSERT INTO tblICInventoryStorageAsOfDate 
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
		 
	UPDATE asOfDate
	SET
		asOfDate.dblQty = ISNULL(asOfDate.dblQty, 0) + ISNULL(s.dblQty, 0)
	FROM 
		tblICInventoryStorageAsOfDate asOfDate 
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
	INSERT INTO @stock
	SELECT	
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] = SUM(dblQty) 
	FROM 
		tblICInventoryTransactionStorage t 
	WHERE
		(
			t.intInventoryTransactionStorageId = @intInventoryTransactionStorageId
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

	-- insert as zero record. 
	INSERT INTO tblICInventoryStorageAsOfDate 
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
		,[dblQty] = 0 
	FROM 
		tblICInventoryStorageAsOfDate asOfDate RIGHT JOIN @stock s
			ON asOfDate.[intItemId] = s.intItemId 
			AND asOfDate.[intItemLocationId] = s.intItemLocationId 
			AND asOfDate.[intItemUOMId] = s.intItemUOMId 
			AND asOfDate.[dtmDate] = s.dtmDate 
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
			tblICInventoryStorageAsOfDate asOfDate 			
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

		SELECT 
			@intItemId = NULL
			,@intItemLocation = NULL
			,@intItemUOMId = NULL
			,@dtmDate = NULL
			,@dblQty = NULL
	END 
END 

RETURN 0
