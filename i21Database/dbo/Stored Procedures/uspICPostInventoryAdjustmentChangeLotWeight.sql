CREATE PROCEDURE uspICPostInventoryAdjustmentChangeLotWeight
	@intTransactionId INT = NULL  
	,@ysnPost BIT
	,@strBatchId NVARCHAR(40)
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50)
	,@intEntityUserSecurityId INT 
	,@strAdjustmentDescription AS NVARCHAR(255)   
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


DECLARE @INVENTORY_ADJUSTMENT_ChangeLotWeight AS INT = 48
		,@ReduceFromSource AS ItemCostingTableType
		,@ReduceFromSourceStorage AS ItemCostingTableType
		,@AddToTarget AS ItemCostingTableType
		,@AddToTargetStorage AS ItemCostingTableType;

DECLARE @OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2;

-- Create the temp table to skip a batch id from logging into the summary log. 
IF OBJECT_ID('tempdb..#tmpICLogRiskPositionFromOnHandSkipList') IS NULL  
BEGIN 
	CREATE TABLE #tmpICLogRiskPositionFromOnHandSkipList (
		strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	)
END 

-- insert into the temp table
BEGIN 
	INSERT INTO #tmpICLogRiskPositionFromOnHandSkipList (strBatchId) VALUES (@strBatchId) 
END 

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------

--BEGIN

--END

--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	
	INSERT INTO @ReduceFromSource (
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost  
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,intTransactionDetailId  
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Lot.intItemId
			,intItemLocationId		= Lot.intItemLocationId
			,intItemUOMId			= CASE WHEN @ysnPost = 1 THEN Detail.intWeightUOMId ELSE Detail.intNewWeightUOMId END
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= CASE WHEN @ysnPost = 1 THEN Detail.dblWeight ELSE Detail.dblNewWeight END * -1 
			,dblUOMQty				= CASE WHEN @ysnPost = 1 THEN Detail.dblWeightPerQty ELSE Detail.dblNewWeightPerQty END
			,dblCost				= Lot.dblLastCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ChangeLotWeight
			,intLotId				= Lot.intLotId
			,intSubLocationId		= Lot.intSubLocationId
			,intStorageLocationId	= Lot.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = Detail.intLotId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemId = Detail.intItemId
				AND ItemUOM.intItemUOMId = Lot.intItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Own -- process only company-owned stocks 
	

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @ReduceFromSource)
	BEGIN
		EXEC	dbo.uspICPostCosting  
				@ReduceFromSource 
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId

	END
END


--------------------------------------------------------------------------------
-- REDUCE THE SOURCE STORAGE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	
	INSERT INTO @ReduceFromSourceStorage (
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost  
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,intTransactionDetailId  
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Lot.intItemId
			,intItemLocationId		= Lot.intItemLocationId
			,intItemUOMId			= CASE WHEN @ysnPost = 1 THEN Detail.intWeightUOMId ELSE Detail.intNewWeightUOMId END
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= CASE WHEN @ysnPost = 1 THEN Detail.dblWeight ELSE Detail.dblNewWeight END * -1
			,dblUOMQty				= CASE WHEN @ysnPost = 1 THEN Detail.dblWeightPerQty ELSE Detail.dblNewWeightPerQty END
			,dblCost				= Lot.dblLastCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ChangeLotWeight
			,intLotId				= Lot.intLotId
			,intSubLocationId		= Lot.intSubLocationId
			,intStorageLocationId	= Lot.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = Detail.intLotId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemId = Detail.intItemId
				AND ItemUOM.intItemUOMId = Lot.intItemUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Storage -- process only storage stocks 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @ReduceFromSourceStorage)
	BEGIN
		EXEC dbo.uspICPostStorage
			@ReduceFromSourceStorage  
			,@strBatchId  
			,@intEntityUserSecurityId

	END
END	


--------------------------------------------------------------------------------
-- Update THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentChangeLotWeight
			@intTransactionId
			,@ysnPost
			,@intEntityUserSecurityId

	IF @intCreateUpdateLotError <> 0 RETURN -1	
	
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT CHANGED WEIGHT UOM.
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @AddToTarget (
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost  
			,dblValue
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,intTransactionDetailId
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= CASE WHEN @ysnPost = 1 THEN Detail.intNewWeightUOMId ELSE Detail.intWeightUOMId END
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= CASE WHEN @ysnPost = 1 THEN Detail.dblNewWeight ELSE Detail.dblWeight END
			,dblUOMQty				= CASE WHEN @ysnPost = 1 THEN Detail.dblNewWeightPerQty ELSE Detail.dblWeightPerQty END
			,dblCost				= CASE WHEN @ysnPost = 1 THEN TargetLot.dblLastCost ELSE Detail.dblCost END
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ChangeLotWeight
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= TargetLot.intSubLocationId
			,intStorageLocationId	= TargetLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICLot TargetLot
				ON TargetLot.intLotId = Detail.intLotId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.intOwnershipType, TargetLot.intOwnershipType) = @OWNERSHIP_TYPE_Own -- process only company-owned stocks
	
	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTarget)
	BEGIN
		DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList

		EXEC	dbo.uspICPostCosting  
				@AddToTarget
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId
	END

END


--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT CHANGED WEIGHT UOM STORAGE.
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @AddToTargetStorage (
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost  
			,dblValue
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,intTransactionDetailId
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= CASE WHEN @ysnPost = 1 THEN Detail.intNewWeightUOMId ELSE Detail.intWeightUOMId END
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= CASE WHEN @ysnPost = 1 THEN Detail.dblNewWeight ELSE Detail.dblWeight END
			,dblUOMQty				= CASE WHEN @ysnPost = 1 THEN Detail.dblNewWeightPerQty ELSE Detail.dblWeightPerQty END
			,dblCost				= CASE WHEN @ysnPost = 1 THEN TargetLot.dblLastCost ELSE Detail.dblCost END
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ChangeLotWeight
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= TargetLot.intSubLocationId
			,intStorageLocationId	= TargetLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICLot TargetLot
				ON TargetLot.intLotId = Detail.intLotId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.intOwnershipType, TargetLot.intOwnershipType) = @OWNERSHIP_TYPE_Storage -- process only storage stocks
	
	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTargetStorage)
	BEGIN
		EXEC dbo.uspICPostStorage
			@AddToTargetStorage
			,@strBatchId  
			,@intEntityUserSecurityId
	END
END