CREATE PROCEDURE uspICMonthlyCategoryStockRebuild
	@strCategoryCode AS NVARCHAR(50) 
	,@dtmCustomDate AS DATETIME = NULL 
AS 
BEGIN TRY 	

	DECLARE @dtmStartDate AS DATETIME 
	DECLARE @dtmStartMonth AS DATETIME 
	DECLARE @dtmLastRebuild AS DATETIME 	
	DECLARE @intBackupId AS INT 

	BEGIN 
		-- Get the start of previous month 
		SET @dtmStartMonth = ISNULL(
				@dtmCustomDate
				, DATEADD(month, -1, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))
			) 

		---- Get the last rebuild date for all items 
		--SELECT TOP 1 
		--	@dtmLastRebuild = dtmStart
		--	,@intBackupId = intBackupId
		--FROM 
		--	tblICBackup 
		--WHERE
		--	strItemNo IS NULL 
		--	AND strCategoryCode IS NULL 
		--ORDER BY 
		--	intBackupId DESC 	

		---- Get the last rebuild date for the category 
		--SELECT TOP 1 
		--	@dtmLastRebuild = dtmStart
		--FROM 
		--	tblICBackup 
		--WHERE
		--	(strCategoryCode = @strCategoryCode OR @strCategoryCode IS NULL)			
		--	AND (@dtmLastRebuild IS NULL OR FLOOR(CAST(dtmStart AS FLOAT)) > FLOOR(CAST(@dtmLastRebuild AS FLOAT)))			
		--	AND (intBackupId > @intBackupId OR @intBackupId IS NULL) 
		--ORDER BY 
		--	intBackupId DESC 			

		-- Find the back-dated transactions. 
		SELECT 
			@dtmStartDate = MIN(t.dtmDate)
		FROM 
			tblICInventoryTransaction t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
			INNER JOIN tblICCategory c
				ON c.intCategoryId = i.intCategoryId
		WHERE
			(c.strCategoryCode = @strCategoryCode OR @strCategoryCode IS NULL)
			AND t.dblQty <> 0 
			AND t.dblValue = 0  
			AND FLOOR(CAST(t.dtmDate AS FLOAT)) < FLOOR(CAST(@dtmStartMonth AS FLOAT))
			AND FLOOR(CAST(t.dtmCreated AS FLOAT)) >= FLOOR(CAST(@dtmStartMonth AS FLOAT))
			--AND (
			--	FLOOR(CAST(t.dtmCreated AS FLOAT)) > FLOOR(CAST(@dtmLastRebuild AS FLOAT))
			--	OR @dtmLastRebuild IS NULL 
			--)

		IF	@dtmCustomDate IS NOT NULL 
			AND @dtmStartDate IS NOT NULL 
			AND @dtmStartDate < @dtmCustomDate
		BEGIN 
			SET @dtmStartDate = @dtmCustomDate
		END 

		-- Find the out-of-sequence date within the month. 		
		BEGIN 
			SELECT 
				@dtmStartDate = MIN(tblSequenced.dtmDate) 
			FROM (
					SELECT 
						t.dtmDate
						,correctSeq = ROW_NUMBER() OVER (ORDER BY t.dtmDate, t.intInventoryTransactionId)
						,actualSeq = ROW_NUMBER() OVER (ORDER BY t.intInventoryTransactionId)
					FROM 
						tblICInventoryTransaction t INNER JOIN tblICItem i 
							ON t.intItemId = i.intItemId
						INNER JOIN tblICCategory c
							ON c.intCategoryId = i.intCategoryId
					WHERE
						(c.strCategoryCode = @strCategoryCode OR @strCategoryCode IS NULL) 
						AND t.dblQty <> 0 
						AND t.dblValue = 0  
						AND FLOOR(CAST(t.dtmDate AS FLOAT)) >= FLOOR(CAST(ISNULL(@dtmStartDate, @dtmStartMonth) AS FLOAT))
				)
				AS tblSequenced
			WHERE
				tblSequenced.correctSeq <> tblSequenced.actualSeq 
		END 
	END 

	-- Get the entity id for irely admin 
	DECLARE @intUserId AS INT
	SELECT  TOP 1 
			@intUserId = intEntityId
	FROM	tblSMUserSecurity
	WHERE	strUserName = 'irelyadmin'

	-- Exit immediately if the start date is blank. 
	IF @dtmStartDate IS NULL 
	BEGIN 
		INSERT INTO tblICBackup(dtmDate, intUserId, strOperation, strRemarks, ysnRebuilding, dtmStart, dtmEnd, strItemNo, strCategoryCode)
		SELECT dbo.fnRemoveTimeOnDate(GETDATE()), @intUserId, 'Rebuild Inventory', 'Stock is up to date.', 0, GETDATE(), GETDATE(), NULL, @strCategoryCode

		RETURN; 
	END 

	BEGIN TRANSACTION 

	-- Get all the item locations that allows negative stock. 
	SELECT	il.intItemLocationId
			,il.intAllowNegativeInventory
	INTO	#tmpAllowNegativeStockSetup
	FROM	tblICItemLocation il

	-- Allow negative stock for the stock rebuild. 
	UPDATE il
	SET il.intAllowNegativeInventory = 1
	FROM tblICItemLocation il

	-- Rebuild the stock (Incremental)
	DECLARE @intReturnValue AS INT
	EXEC @intReturnValue = uspICRebuildInventoryValuation
		@dtmStartDate = @dtmStartDate
		,@isPeriodic = 1
		,@intUserId = @intUserId
		,@strCategoryCode = @strCategoryCode

	-- Commit or Rollback the stock rebuild. 
	IF @intReturnValue <> 0 
	BEGIN 
		ROLLBACK TRANSACTION 
	END
	ELSE 
	BEGIN
		COMMIT TRANSACTION 
	END 

	-- Restore the allow negative setup
	UPDATE	il
	SET		il.intAllowNegativeInventory = bil.intAllowNegativeInventory
	FROM	tblICItemLocation il INNER JOIN #tmpAllowNegativeStockSetup bil
				ON il.intItemLocationId = bil.intItemLocationId
END TRY 
BEGIN CATCH	
	-- Rollback the stock rebuild. 
	IF @@TRANCOUNT > 0 
	BEGIN 
		PRINT 'DO ROLLBACK'
		ROLLBACK TRANSACTION 
	END	

	DECLARE @msg AS VARCHAR(MAX) = ERROR_MESSAGE()
	RAISERROR(@msg, 16, 1);

	RETURN -1;
END CATCH

IF OBJECT_ID('tempdb..#tmpAllowNegativeStockSetup') IS NOT NULL DROP TABLE #tmpAllowNegativeStockSetup

