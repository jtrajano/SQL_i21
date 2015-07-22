
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

------------------------------------------------------------------------------------------------------------------------------------
-- Unpost all the inventory adjustments
------------------------------------------------------------------------------------------------------------------------------------

DECLARE @intInventoryAdjustmentId AS INT
		,@strAdjustmentNo AS NVARCHAR(50)
		,@intEntityId AS INT 

DECLARE loopAdjustment CURSOR LOCAL FAST_FORWARD
FOR 
SELECT	intInventoryAdjustmentId
		,strAdjustmentNo
		,intEntityId
FROM	dbo.tblICInventoryAdjustment
WHERE	ysnPosted = 1
ORDER BY dtmPostedDate DESC 
		
OPEN loopAdjustment;

-- Initial fetch attempt
FETCH NEXT FROM loopAdjustment INTO 
		@intInventoryAdjustmentId	
		,@strAdjustmentNo
		,@intEntityId
;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustment  
			@ysnPost = 0
			,@ysnRecap = 0  
			,@strTransactionId = @strAdjustmentNo
			,@intUserId = @intEntityId
			,@intEntityId = @intEntityId
	END 

	FETCH NEXT FROM loopAdjustment INTO 
		@intInventoryAdjustmentId	
		,@strAdjustmentNo
		,@intEntityId
	;
END 

CLOSE loopAdjustment;
DEALLOCATE loopAdjustment;

GO 

------------------------------------------------------------------------------------------------------------------------------------
-- Re-post all the inventory adjustments
------------------------------------------------------------------------------------------------------------------------------------

DECLARE @intInventoryAdjustmentId AS INT
		,@strAdjustmentNo AS NVARCHAR(50)
		,@intEntityId AS INT 

DECLARE loopAdjustment CURSOR LOCAL FAST_FORWARD
FOR 
SELECT	intInventoryAdjustmentId
		,strAdjustmentNo
		,intEntityId
FROM	dbo.tblICInventoryAdjustment
WHERE	ysnPosted = 1
ORDER BY dtmPostedDate ASC 
		
OPEN loopAdjustment;

-- Initial fetch attempt
FETCH NEXT FROM loopAdjustment INTO 
		@intInventoryAdjustmentId	
		,@strAdjustmentNo
		,@intEntityId
;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	BEGIN 
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
	END 

	FETCH NEXT FROM loopAdjustment INTO 
		@intInventoryAdjustmentId	
		,@strAdjustmentNo
		,@intEntityId
	;
END 

CLOSE loopAdjustment;
DEALLOCATE loopAdjustment;

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