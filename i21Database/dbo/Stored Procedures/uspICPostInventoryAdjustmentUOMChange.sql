CREATE PROCEDURE uspICPostInventoryAdjustmentUOMChange  
	@intTransactionId INT = NULL  
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


DECLARE @INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
		,@ReduceFromSourceUOM AS ItemCostingTableType
		,@ReduceFromSourceStorageUOM AS ItemCostingTableType
		,@AddToTargetUOM AS ItemCostingTableType
		,@AddToTargetStorageUOM AS ItemCostingTableType
		,@strNewItemUOM AS NVARCHAR(50);

DECLARE @OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2

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
BEGIN 
	--------------------------------------------------------------------------------
	-- Validate the UOM
	--------------------------------------------------------------------------------
	DECLARE @intItemId AS INT 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @strLotNumber AS NVARCHAR(50)
	DECLARE @intLotId AS INT 
	DECLARE @strUnitMeasure AS NVARCHAR(50)

	BEGIN 
		SELECT TOP 1 
				@intItemId = Detail.intItemId,
				@strItemNo = Item.strItemNo			
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN tblICItem Item
					ON Item.intItemId = Detail.intItemId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND Detail.intItemUOMId = Detail.intNewItemUOMId
	
		IF @intItemId IS NOT NULL 
		BEGIN
			-- 'Source and Target UOM should not be the same for {Item}.'
			EXEC uspICRaiseError 80207, @strItemNo;
			RETURN -1
		END

	END

	
	------------------------------------------------------------------------------
	-- Check if the lot change is full.
	------------------------------------------------------------------------------
	BEGIN 

		-- Check if the lot change is full.
		BEGIN 
			SELECT	TOP 1 
					@strUnitMeasure = iUOM.strUnitMeasure 
					,@strLotNumber = Lot.strLotNumber
			FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
						ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
					INNER JOIN tblICLot Lot
						ON Lot.intLotId = Detail.intLotId
					INNER JOIN tblICInventoryLot LotTrans
						ON LotTrans.intLotId = Detail.intLotId
						AND LotTrans.intSubLocationId = Lot.intSubLocationId
						AND LotTrans.intStorageLocationId = Lot.intStorageLocationId
					INNER JOIN (
						tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
							ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
					)	ON ItemUOM.intItemUOMId = Detail.intNewItemUOMId
			WHERE Header.intInventoryAdjustmentId = @intTransactionId 
				AND LotTrans.dblStockOut > 0

			IF @strLotNumber IS NOT NULL 
			BEGIN 
				-- 'Cannot change UOM to {New UOM} . {Lot Number} is partially allocated.'
				EXEC uspICRaiseError 80215, @strUnitMeasure, @strLotNumber;
				RETURN -1; 			 
			END 
		END 
	END
--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	
	INSERT INTO @ReduceFromSourceUOM (
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
			,intItemUOMId			= Lot.intWeightUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -Lot.dblWeight --dbo.fnCalculateQtyBetweenUOM(Detail.intWeightUOMId, Lot.intWeightUOMId, Detail.dblQuantity) * -1
			,dblUOMQty				= Detail.dblWeightPerQty
			,dblCost				= Lot.dblLastCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
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
			LEFT JOIN dbo.tblICItemUOM TargetItemUOM
				ON TargetItemUOM.intItemId = Detail.intItemId
				AND TargetItemUOM.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		--AND Detail.dblNewQuantity > 0 
		AND Detail.dblAdjustByQuantity <> 0 
		AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Own -- process only company-owned stocks 
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblAdjustByQuantity			
									--dbo.fnCalculateQtyBetweenUOM(Detail.intNewItemUOMId, Detail.intItemUOMId, Detail.dblNewQuantity) * -1
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= ISNULL(
											Detail.dblCost
											,dbo.fnCalculateCostBetweenUOM( 
												dbo.fnGetItemStockUOM(Detail.intItemId)
												,Detail.intItemUOMId
												,ItemPricing.dblLastCost
											)
										)	
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemId = Detail.intItemId
				AND ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM TargetItemUOM
				ON TargetItemUOM.intItemId = Detail.intItemId
				AND TargetItemUOM.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE Header.intInventoryAdjustmentId = @intTransactionId 
		AND Item.strLotTracking = 'No'
		--AND Detail.dblNewQuantity > 0 
		AND Detail.dblAdjustByQuantity <> 0 
		AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Own -- process only company-owned stocks 
	

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @ReduceFromSourceUOM)
	BEGIN
		EXEC	dbo.uspICPostCosting  
				@ReduceFromSourceUOM 
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId

	END
END


--------------------------------------------------------------------------------
-- REDUCE THE SOURCE STORAGE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	
	INSERT INTO @ReduceFromSourceStorageUOM (
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
			,intItemUOMId			= Lot.intWeightUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -Lot.dblWeight --dbo.fnCalculateQtyBetweenUOM(Detail.intWeightUOMId, Lot.intWeightUOMId, Detail.dblQuantity) * -1
			,dblUOMQty				= Detail.dblWeightPerQty
			,dblCost				= Lot.dblLastCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
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
			LEFT JOIN dbo.tblICItemUOM TargetItemUOM
				ON TargetItemUOM.intItemId = Detail.intItemId
				AND TargetItemUOM.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		--AND Detail.dblNewQuantity > 0 
		AND Detail.dblAdjustByQuantity <> 0 
		AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Storage -- process only storage stocks 
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -dbo.fnCalculateQtyBetweenUOM(Detail.intNewItemUOMId, Detail.intItemUOMId, Detail.dblAdjustByQuantity) 
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= Detail.dblCost
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemId = Detail.intItemId
				AND ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM TargetItemUOM
				ON TargetItemUOM.intItemId = Detail.intItemId
				AND TargetItemUOM.intItemUOMId = Detail.intNewItemUOMId
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE Header.intInventoryAdjustmentId = @intTransactionId 
		AND Item.strLotTracking = 'No'
		--AND Detail.dblNewQuantity > 0 
		AND Detail.dblAdjustByQuantity <> 0 
		AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Storage -- process only storage stocks 
	

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @ReduceFromSourceStorageUOM)
	BEGIN
		EXEC dbo.uspICPostStorage
			@ReduceFromSourceStorageUOM  
			,@strBatchId  
			,@intEntityUserSecurityId

	END
END

--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentUOMChange
			@intTransactionId
			,@intEntityUserSecurityId

	IF @intCreateUpdateLotError <> 0 RETURN -1	
	
END
	

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT FOR A NEW ITEM.
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @AddToTargetUOM (
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
			,intItemUOMId			= Detail.intWeightUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty
			,dblUOMQty				= WeightUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= TargetLot.intSubLocationId
			,intStorageLocationId	= TargetLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICLot TargetLot
				ON TargetLot.intLotId = Detail.intNewLotId

			INNER JOIN dbo.tblICInventoryTransaction SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemId = Detail.intItemId
				AND WeightUOM.intItemUOMId = Detail.intWeightUOMId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblQuantity > 0 
			AND ISNULL(Detail.intOwnershipType, TargetLot.intOwnershipType) = @OWNERSHIP_TYPE_Own -- process only company-owned stocks
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -dbo.fnCalculateQtyBetweenUOM(Detail.intItemUOMId, Detail.intNewItemUOMId, SourceTransaction.dblQty) 
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = Header.intLocationId 
				AND NewItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICInventoryTransaction SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intItemId
				AND NewItemUOM.intItemUOMId = Detail.intNewItemUOMId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Item.strLotTracking = 'No'
			--AND Detail.dblNewQuantity > 0
			AND Detail.dblAdjustByQuantity <> 0 
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Own -- process only company-owned stocks
	
	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTargetUOM)
	BEGIN
		DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList

		EXEC	dbo.uspICPostCosting  
				@AddToTargetUOM  
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId
	END

END


--------------------------------------------------------------------------------
-- INCREASE THE STOCK STORAGE ON SAME LOT BUT FOR A NEW ITEM.
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @AddToTargetStorageUOM (
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
			,intItemUOMId			= Detail.intWeightUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty
			,dblUOMQty				= WeightUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= TargetLot.intSubLocationId
			,intStorageLocationId	= TargetLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICLot TargetLot
				ON TargetLot.intLotId = Detail.intNewLotId

			INNER JOIN dbo.tblICInventoryTransactionStorage SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemId = Detail.intItemId
				AND WeightUOM.intItemUOMId = Detail.intWeightUOMId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblQuantity > 0 
			AND ISNULL(Detail.intOwnershipType, TargetLot.intOwnershipType) = @OWNERSHIP_TYPE_Storage -- process only storage stocks
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -dbo.fnCalculateQtyBetweenUOM(Detail.intItemUOMId, Detail.intNewItemUOMId, SourceTransaction.dblQty)
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_UOMChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = Header.intLocationId 
				AND NewItemLocation.intItemId = Detail.intItemId

			INNER JOIN dbo.tblICInventoryTransactionStorage SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intItemId
				AND NewItemUOM.intItemUOMId = Detail.intNewItemUOMId

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Item.strLotTracking = 'No'
			--AND Detail.dblNewQuantity > 0
			AND Detail.dblAdjustByQuantity <> 0 
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Storage -- process only storage stocks
	
	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTargetStorageUOM)
	BEGIN
		EXEC dbo.uspICPostStorage
			@AddToTargetStorageUOM
			,@strBatchId  
			,@intEntityUserSecurityId
	END

END


END