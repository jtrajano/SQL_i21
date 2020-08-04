/*
	This SP will create two sets of "closing" inventory adjustments that will zero-out the stocks and re-add it back into the system. 
	It is used with uspICRebuildInventoryValuation to clear fix the bad Qty In and Qty Out in the cost buckets. 
	
	How to use it: 
	1. Call uspICFixCodeFix001 and provide the date. 
	2. After calling this sp, call uspICRebuildInventoryValuation with @ysnForceClearTheCostBuckets = 1. For example: 
		
		EXEC uspICFixCodeFix001 
			@dtmDAte = 'April 30, 2020'

		EXEC uspICRebuildInventoryValuation 
			@dtmStartDate = 'April 30, 2020'
			,@isPeriodic = 1
			,@intUserId = 1
			,@ysnForceClearTheCostBuckets = 1

	3. During the stock rebuild, the system will zero-out the stocks in the inventory transactions using the first adjustment. 
	
	4. With @ysnForceClearTheCostBuckets set to true, the system will zero out the stocks at the cost buckets. At this point, both the inventory
	transactions and cost buckets are now zero stocks. 

	5. The stock rebuild will continue and it will re-add the stocks using the 2nd inventory adjustment.
*/
CREATE PROCEDURE uspICFixCodeFix001
	@dtmDate AS DATETIME
AS

IF OBJECT_ID('tempdb..#tmpEomQty') IS NOT NULL  
	DROP TABLE #tmpEomQty

IF OBJECT_ID('tempdb..#tmpEomLocation') IS NOT NULL  
	DROP TABLE #tmpEomLocation

DECLARE 
	@INVENTORY_ADJUSTMENT AS INT = 30
	,@strAdjustmentId_1st AS NVARCHAR(50) 
	,@strAdjustmentId_2nd AS NVARCHAR(50) 
	,@intInventoryAdjustmentId_1st AS INT 
	,@intInventoryAdjustmentId_2nd AS INT 
	,@intEntityUserSecurityId AS INT 
	,@intLocationId AS INT 

SELECT @intEntityUserSecurityId = intEntityId FROM tblSMUserSecurity WHERE strUserName = 'IRELYADMIN'

BEGIN TRY

	BEGIN TRANSACTION 

	SELECT 
		i.strItemNo
		,i.intItemId
		,cl.strLocationName
		,il.intLocationId
		,il.intItemLocationId
	INTO 
		#tmpEomQty
	FROM
		tblICItem i INNER JOIN tblICItemLocation il
			ON i.intItemId = il.intItemId
		INNER JOIN tblSMCompanyLocation cl
			ON cl.intCompanyLocationId = il.intLocationId
	WHERE
		i.strStatus NOT IN ('Discontinued')
		AND i.strType IN ('Inventory', 'Finished Good', 'Raw Material') 

	SELECT 
		DISTINCT intLocationId 
	INTO #tmpEomLocation
	FROM #tmpEomQty 
	ORDER BY intLocationId

	-- Create multiple adjustment for each locations. 
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpEomLocation)
	BEGIN 
		SELECT TOP 1 
			@intLocationId = intLocationId
		FROM 
			#tmpEomLocation

		/******************************************************************************************
			Create the 1ST adjustment. 
		******************************************************************************************/

		-- Generate the 1st adjustment id 
		EXEC dbo.uspSMGetStartingNumber @INVENTORY_ADJUSTMENT, @strAdjustmentId_1st OUTPUT, DEFAULT 

		-- Insert the adjustment header. 
		INSERT INTO tblICInventoryAdjustment (
			intLocationId
			,dtmAdjustmentDate
			,intAdjustmentType
			,strAdjustmentNo
			,strDescription
			,ysnPosted
			,intEntityId
			,intConcurrencyId
			,intCompanyId
			,dtmCreated
			,dtmDateCreated
			,intCreatedByUserId
		)
		SELECT 
			intLocationId = @intLocationId
			,dtmAdjustmentDate = @dtmDate
			,intAdjustmentType = 10 -- Opening Inventory 
			,strAdjustmentNo = @strAdjustmentId_1st
			,strDescription = 'Opening Balance. Inventory Fix code: 001-A'
			,ysnPosted = 0 
			,intEntityId = @intEntityUserSecurityId
			,intConcurrencyId = 1
			,intCompanyId = 0 
			,dtmCreated = GETDATE()
			,dtmDateCreated = GETDATE() 
			,intCreatedByUserId = @intEntityUserSecurityId

		SET @intInventoryAdjustmentId_1st = SCOPE_IDENTITY() 

		-- Insert the details 
		INSERT INTO tblICInventoryAdjustmentDetail (
			intInventoryAdjustmentId 
			,intSubLocationId
			,intStorageLocationId
			,intNewSubLocationId 
			,intNewStorageLocationId 
			,intItemId
			,dblQuantity
			,dblNewQuantity
			,dblAdjustByQuantity
			,intItemUOMId
			,intNewItemUOMId
			,dblCost
			,dblNewCost
			,dblLineTotal
			,intCostingMethod
			,intSort
			,intConcurrencyId
			,dtmDateCreated
			,intCreatedByUserId
		)
		SELECT 
			intInventoryAdjustmentId = @intInventoryAdjustmentId_1st
			,intSubLocationId = t.intSubLocationId
			,intStorageLocationId = t.intStorageLocationId
			,intNewSubLocationId = t.intSubLocationId
			,intNewStorageLocationId = t.intStorageLocationId
			,intItemId = eom.intItemId
			,dblQuantity = ROUND(ISNULL(t.dblQty, 0), 6) 
			,dblNewQuantity = -ROUND(ISNULL(t.dblQty, 0), 6) 
			,dblAdjustByQuantity = -ROUND(ISNULL(t.dblQty, 0), 6) 
			,intItemUOMId = ISNULL(t.intItemUOMId, iu.intItemUOMId) 
			,intNewItemUOMId = ISNULL(t.intItemUOMId, iu.intItemUOMId) 
			,dblCost = ISNULL(lastCost.dblCost, lastCost2.dblCost) 
			,dblNewCost = ISNULL(lastCost.dblCost, lastCost2.dblCost) 
			,dblLineTotal = ROUND(dbo.fnMultiply(-ISNULL(t.dblQty, 0), lastCost.dblCost), 2) 
			,intCostingMethod = il.intCostingMethod
			,intSort = CAST(ROW_NUMBER() OVER (ORDER BY eom.strItemNo, t.intSubLocationId, t.intStorageLocationId) AS INT) 
			,intConcurrencyId = 1
			,dtmDateCreated = GETDATE()
			,intCreatedByUserId = @intEntityUserSecurityId
		FROM 
			#tmpEomQty eom INNER JOIN tblICItemLocation il
				ON eom.intItemLocationId = il.intItemLocationId
			INNER JOIN tblICItemUOM iu
				ON iu.intItemId = eom.intItemId
				AND iu.ysnStockUnit = 1
			CROSS APPLY (
				SELECT 
					t.intItemUOMId
					,t.intItemLocationId
					,t.intSubLocationId
					,t.intStorageLocationId
					,dblQty = SUM(ISNULL(t.dblQty, 0)) 
				FROM 
					tblICInventoryTransaction t 
				WHERE
					t.intItemId = eom.intItemId
					AND t.intItemLocationId = eom.intItemLocationId
					AND FLOOR(CAST(t.dtmDate AS FLOAT)) < FLOOR(CAST(@dtmDate AS FLOAT))
				GROUP BY
					t.intItemUOMId
					,t.intItemLocationId
					,t.intSubLocationId
					,t.intStorageLocationId
				--HAVING 
				--	SUM(ISNULL(t.dblQty, 0)) <> 0 
			) t 
			OUTER APPLY (
				SELECT TOP 1 
					t2.dblCost
				FROM 
					tblICInventoryTransaction t2
				WHERE
					t2.intItemId = eom.intItemId
					AND t2.intItemLocationId = eom.intItemLocationId
					AND t2.intItemUOMId = t.intItemUOMId
					AND FLOOR(CAST(t2.dtmDate AS FLOAT)) < FLOOR(CAST(@dtmDate AS FLOAT))
					AND t2.dblQty > 0 
					AND t2.intItemUOMId = t.intItemUOMId
				ORDER BY
					t2.intInventoryTransactionId DESC 
			) lastCost 
			OUTER APPLY (
				SELECT TOP 1 
					t2.dblCost
				FROM 
					tblICInventoryTransaction t2
				WHERE
					t2.intItemId = eom.intItemId
					AND t2.intItemLocationId = eom.intItemLocationId
					AND t2.intItemUOMId = t.intItemUOMId
					AND FLOOR(CAST(t2.dtmDate AS FLOAT)) < FLOOR(CAST(@dtmDate AS FLOAT))
					AND t2.dblQty < 0 
					AND t2.intItemUOMId = t.intItemUOMId
				ORDER BY
					t2.intInventoryTransactionId DESC 
			) lastCost2 

		WHERE
			eom.intLocationId = @intLocationId 
			--AND ROUND(t.dblQty, 6) <> 0
		ORDER BY 
			eom.strItemNo
			, t.intSubLocationId
			, t.intStorageLocationId

		-- Post the first Adjustment
		EXEC uspICPostInventoryAdjustment
			@ysnPost = 1
			,@ysnRecap = 0 
			,@strTransactionId = @strAdjustmentId_1st
			,@intEntityUserSecurityId = @intEntityUserSecurityId
	
		/******************************************************************************************
			Create the 2nd adjustment. 
		******************************************************************************************/

		-- Generate the 2nd adjustment id 
		EXEC dbo.uspSMGetStartingNumber @INVENTORY_ADJUSTMENT, @strAdjustmentId_2nd OUTPUT, DEFAULT 
	
		-- Insert the adjustment header. 
		INSERT INTO tblICInventoryAdjustment (
			intLocationId
			,dtmAdjustmentDate
			,intAdjustmentType 
			,strAdjustmentNo
			,strDescription
			,ysnPosted
			,intEntityId
			,intConcurrencyId
			,intCompanyId
			,dtmCreated
			,dtmDateCreated
			,intCreatedByUserId
			,strDataSource
		)
		SELECT 
			intLocationId = @intLocationId
			,dtmAdjustmentDate = @dtmDate
			,intAdjustmentType = 10 -- Opening Inventory
			,strAdjustmentNo = @strAdjustmentId_2nd
			,strDescription = 'Opening Balance. Inventory Fix code: 001-B'
			,ysnPosted = 0 
			,intEntityId = @intEntityUserSecurityId
			,intConcurrencyId = 1
			,intCompanyId = 0 
			,dtmCreated = GETDATE()
			,dtmDateCreated = GETDATE() 
			,intCreatedByUserId = @intEntityUserSecurityId	
			,strDataSource = @strAdjustmentId_1st

		SET @intInventoryAdjustmentId_2nd = SCOPE_IDENTITY() 

		-- Insert the adjustment detail
		INSERT INTO tblICInventoryAdjustmentDetail (
			intInventoryAdjustmentId 
			,intSubLocationId
			,intStorageLocationId
			,intNewSubLocationId 
			,intNewStorageLocationId 
			,intItemId
			,dblQuantity
			,dblNewQuantity
			,dblAdjustByQuantity
			,intItemUOMId
			,intNewItemUOMId
			,dblCost
			,dblNewCost
			,dblLineTotal
			,intCostingMethod
			,intSort
			,intConcurrencyId
			,dtmDateCreated
			,intCreatedByUserId
		)
		SELECT 
			intInventoryAdjustmentId = @intInventoryAdjustmentId_2nd
			,intSubLocationId = adj.intSubLocationId
			,intStorageLocationId = adj.intStorageLocationId
			,intNewSubLocationId = adj.intNewSubLocationId
			,intNewStorageLocationId = adj.intNewStorageLocationId
			,intItemId = adj.intItemId
			,dblQuantity = 0
			,dblNewQuantity = adj.dblQuantity
			,dblAdjustByQuantity = adj.dblQuantity
			,intItemUOMId = adj.intItemUOMId
			,intNewItemUOMId = adj.intNewItemUOMId
			,dblCost = adj.dblCost
			,dblNewCost = adj.dblCost 
			,dblLineTotal = -adj.dblLineTotal
			,intCostingMethod = adj.intCostingMethod
			,intSort = adj.intSort
			,intConcurrencyId = 1
			,dtmDateCreated = GETDATE()
			,intCreatedByUserId = @intEntityUserSecurityId
		FROM 
			tblICInventoryAdjustmentDetail adj
		WHERE
			adj.intInventoryAdjustmentId = @intInventoryAdjustmentId_1st
		ORDER BY
			adj.intInventoryAdjustmentDetailId

		-- Post the 2nd Adjustment
		EXEC uspICPostInventoryAdjustment
			@ysnPost = 1
			,@ysnRecap = 0 
			,@strTransactionId = @strAdjustmentId_2nd
			,@intEntityUserSecurityId = @intEntityUserSecurityId
		
		DELETE FROM #tmpEomLocation	WHERE @intLocationId = intLocationId
	END 

	COMMIT TRANSACTION 
END TRY 
BEGIN CATCH 
	DECLARE @msg AS VARCHAR(MAX) = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 
	RAISERROR(@msg, 11, 1) 
END CATCH 