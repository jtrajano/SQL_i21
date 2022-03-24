CREATE PROCEDURE uspICRebuildStocksWithCategoryChange
	@dtmStartDate AS DATETIME 
	,@intUserId AS INT 
AS 

BEGIN 
	DECLARE @rebuildList AS TABLE (
		intItemId INT
		,intNewCategoryId INT 
	)

	DECLARE @strItemNo AS NVARCHAR(50)

	INSERT INTO @rebuildList (
		intItemId 
		,intNewCategoryId 
	)
	SELECT 
		i.intItemId 
		,COALESCE(changeLog.intNewCategoryId, i.intCategoryId, 0) 
	FROM 
		tblICItem i 
		CROSS APPLY (
			SELECT TOP 1 
				l.intNewCategoryId
			FROM 
				tblICItemCategoryChangeLog l
			WHERE 
				l.intItemId = i.intItemId
				AND FLOOR(CAST(dtmDateChanged AS FLOAT)) >= FLOOR(CAST(@dtmStartDate AS FLOAT))
			ORDER BY
				l.dtmDateChanged DESC 
		) changeLog

	-- Remove it from the list if the categories is already changed. 
	DELETE l
	FROM 
		@rebuildList l 
		OUTER APPLY (
			SELECT TOP 1 
				t.intInventoryTransactionId 
					
			FROM 
				tblICInventoryTransaction t
			WHERE
				t.intItemId = l.intItemId
				AND FLOOR(CAST(t.dtmDate AS FLOAT)) >= FLOOR(CAST(@dtmStartDate AS FLOAT))
				AND ISNULL(t.intCategoryId, 0) <> ISNULL(l.intNewCategoryId, 0) 
				AND t.dblQty <> 0 
		) t
	WHERE
		t.intInventoryTransactionId IS NULL 

	-- Create the temp table for the specific items/categories to rebuild
	IF OBJECT_ID('tempdb..#tmpRebuildList') IS NULL  
	BEGIN 
		CREATE TABLE #tmpRebuildList (
			intItemId INT NULL 
			,intCategoryId INT NULL 
		)
	END 

	INSERT INTO #tmpRebuildList (
		intItemId
	)
	SELECT 
		intItemId
	FROM 
		@rebuildList

	IF EXISTS (SELECT TOP 1 1 FROM #tmpRebuildList) 
	BEGIN 
		EXEC uspICRebuildInventoryValuation
			@dtmStartDate = @dtmStartDate
			,@isPeriodic = 1
			,@intUserId = @intUserId
	END 
END