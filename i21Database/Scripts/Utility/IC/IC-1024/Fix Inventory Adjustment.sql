
------------------------------------------------------------------------------------------------------------------------------------
-- Update the dtmPostedDate
------------------------------------------------------------------------------------------------------------------------------------
UPDATE	Adj
SET		dtmPostedDate = (SELECT TOP 1 dtmCreated FROM tblICInventoryTransaction WHERE strTransactionId = Adj.strAdjustmentNo AND ysnIsUnposted = 0)
FROM	dbo.tblICInventoryAdjustment Adj
WHERE	dtmPostedDate IS NULL 

GO

------------------------------------------------------------------------------------------------------------------------------------
-- Open the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
SELECT	* 
INTO	tblGLFiscalYearPeriodOriginal
FROM	tblGLFiscalYearPeriod

UPDATE tblGLFiscalYearPeriod
SET ysnOpen = 1

GO

BEGIN TRY 
	BEGIN TRANSACTION

	DECLARE @intInventoryAdjustmentId AS INT
			,@strAdjustmentNo AS NVARCHAR(50)
			,@intEntityId AS INT 
			,@ysnPosted AS BIT
			,@dtmUnpostedDate AS DATETIME 

	DECLARE loopAdjustment CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	intInventoryAdjustmentId
			,strAdjustmentNo
			,intEntityId
			,ysnPosted
			,dtmUnpostedDate
	FROM	dbo.tblICInventoryAdjustment
	WHERE	ysnPosted = 1
			OR dbo.fnRemoveTimeOnDate(dtmUnpostedDate) = CAST('2015-07-23' AS DATETIME)
	ORDER BY dtmPostedDate DESC 
		
	OPEN loopAdjustment;

	-- Initial fetch attempt
	FETCH NEXT FROM loopAdjustment INTO 
			@intInventoryAdjustmentId	
			,@strAdjustmentNo
			,@intEntityId
			,@ysnPosted
			,@dtmUnpostedDate
	;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Processing ' + @strAdjustmentNo


		-- Unpost 
		IF ISNULL(@ysnPosted, 0) = 1
		BEGIN 
			PRINT 'Unposting ' + @strAdjustmentNo

			EXEC dbo.uspICPostInventoryAdjustment  
				@ysnPost = 0
				,@ysnRecap = 0  
				,@strTransactionId = @strAdjustmentNo
				,@intUserId = @intEntityId
				,@intEntityId = @intEntityId

			IF @@ERROR <> 0
				PRINT ERROR_MESSAGE()  
		END 

		-- Repost 
		BEGIN 
			PRINT 'Reposting ' + @strAdjustmentNo

			-- Update the original costs in the adjustment detail. 
			UPDATE	AdjDetail
			SET		AdjDetail.dblCost = Lot.dblLastCost
			FROM	dbo.tblICInventoryAdjustmentDetail AdjDetail INNER JOIN dbo.tblICLot Lot
						ON AdjDetail.intLotId = Lot.intLotId
			WHERE	AdjDetail.intInventoryAdjustmentId = @intInventoryAdjustmentId

			-- Repost all the inventory adjustments 
			EXEC dbo.uspICPostInventoryAdjustment  
				@ysnPost = 1
				,@ysnRecap = 0  
				,@strTransactionId = @strAdjustmentNo
				,@intUserId = @intEntityId
				,@intEntityId = @intEntityId

			IF @@ERROR <> 0
				PRINT ERROR_MESSAGE()  
		END 

		FETCH NEXT FROM loopAdjustment INTO 
			@intInventoryAdjustmentId	
			,@strAdjustmentNo
			,@intEntityId
			,@ysnPosted
			,@dtmUnpostedDate
		;
	END 

	CLOSE loopAdjustment;
	DEALLOCATE loopAdjustment;

	COMMIT TRANSACTION 
END TRY 
BEGIN CATCH 

	PRINT 'Error found in ' + @strAdjustmentNo
	PRINT ERROR_MESSAGE()           
	
	ROLLBACK TRANSACTION 
END CATCH 

GO

------------------------------------------------------------------------------------------------------------------------------------
-- Re-close the fiscal year periods
------------------------------------------------------------------------------------------------------------------------------------
UPDATE FYPeriod
SET ysnOpen = FYPeriodOriginal.ysnOpen
FROM	tblGLFiscalYearPeriod FYPeriod INNER JOIN tblGLFiscalYearPeriodOriginal FYPeriodOriginal
			ON FYPeriod.intGLFiscalYearPeriodId = FYPeriodOriginal.intGLFiscalYearPeriodId

DROP TABLE tblGLFiscalYearPeriodOriginal

GO

-- Update the On-hand
EXEC dbo.uspICFixStockQuantities