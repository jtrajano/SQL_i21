CREATE PROCEDURE uspICPostInventoryAdjustmentItemChange  
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

DECLARE @INVENTORY_ADJUSTMENT_QuantityChange AS INT = 10
		,@INVENTORY_ADJUSTMENT_UOMChange AS INT = 14
		,@INVENTORY_ADJUSTMENT_ItemChange AS INT = 15
		,@INVENTORY_ADJUSTMENT_LotStatusChange AS INT = 16
		,@INVENTORY_ADJUSTMENT_SplitLot AS INT = 17
		,@INVENTORY_ADJUSTMENT_ExpiryDateChange AS INT = 18
		,@INVENTORY_ADJUSTMENT_LotMerge AS INT = 19
		,@INVENTORY_ADJUSTMENT_LotMove AS INT = 20

DECLARE @OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2

DECLARE @ReduceFromSource AS ItemCostingTableType
		,@ReduceFromSourceStorage AS ItemCostingTableType
		,@AddToTarget AS ItemCostingTableType
		,@AddToTargetStorage AS ItemCostingTableType
		,@intNewItemNo AS INT
		,@strNewItemNo AS NVARCHAR(50)

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
	DECLARE @intLocationId AS INT
	DECLARE @strLocationName AS NVARCHAR(50)

	DECLARE @intItemUomId AS INT
	DECLARE @strItemUom AS NVARCHAR(50)
	BEGIN 
		SELECT TOP 1 
				@intItemId 		= Detail.intItemId,
				@intItemUomId 	= Detail.intItemUOMId			
		FROM	(SELECT Detail.intItemId, intItemUOMId = Detail.intItemUOMId FROM dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				LEFT JOIN dbo.tblICItemUOM ItemUOM
					ON Detail.intItemUOMId = ItemUOM.intItemUOMId
				LEFT JOIN dbo.tblICItemUOM WeightUOM
					ON Detail.intWeightUOMId = WeightUOM.intItemUOMId
				WHERE	Header.intInventoryAdjustmentId = @intTransactionId
					AND ISNULL(WeightUOM.intItemUOMId, ItemUOM.intItemUOMId) IS NULL
					AND ItemUOM.intItemUOMId IS NOT NULL

				UNION ALL
				SELECT Detail.intNewItemId, intItemUOMId = Detail.intItemUOMId FROM dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId					
				WHERE Header.intInventoryAdjustmentId = @intTransactionId 
					AND dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Detail.intItemUOMId) IS NULL
					AND Detail.intItemUOMId IS NOT NULL
				UNION ALL
				SELECT Detail.intNewItemId, intItemUOMId = Lot.intWeightUOMId FROM dbo.tblICInventoryAdjustment Header 
					INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
						ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
					INNER JOIN tblICLot Lot
						on Detail.intLotId = Lot.intLotId					
				WHERE Header.intInventoryAdjustmentId = @intTransactionId 
					AND dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Lot.intWeightUOMId) IS NULL
					AND Lot.intWeightUOMId IS NOT NULL

				UNION ALL
				SELECT Detail.intNewItemId, intItemUOMId = Lot.intItemUOMId FROM dbo.tblICInventoryAdjustment Header 
					INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
						ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
					INNER JOIN tblICLot Lot
						on Detail.intLotId = Lot.intLotId					
				WHERE Header.intInventoryAdjustmentId = @intTransactionId 
					AND dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Lot.intItemUOMId) IS NULL
					AND Lot.intItemUOMId IS NOT NULL

				) Detail
	
		IF @intItemId IS NOT NULL 
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem Item 
			WHERE intItemId = @intItemId		

			IF @intItemUomId IS NOT NULL 
			BEGIN 
				SELECT @strItemUom = strUnitMeasure
				FROM dbo.vyuICGetItemUOM Item 
				WHERE intItemUOMId = @intItemUomId	
				-- 'The UOM is missing on {Item}.'
				EXEC uspICRaiseError 80080, @strItemUom, @strItemNo;
			END
			ELSE
			BEGIN
				EXEC uspICRaiseError 80039, @strItemNo;
			END
			
			RETURN -1
		END


	END

	--------------------------------------------------------------------------------
	-- Validate for non-negative Adjust Qty
	-------------------------------------------------------------------------------
	BEGIN 
		SELECT	TOP 1 
				@intItemId = Detail.intItemId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) > 0 
	
		IF @intItemId IS NOT NULL 
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem Item 
			WHERE intItemId = @intItemId		

			-- 'Lot Move requires a negative Adjust Qty on %s as stock for the move.'
			EXEC uspICRaiseError 80059, @strItemNo;
			RETURN -1
		END
	END 

	--------------------------------------------------------------------------------
	-- Validate the item id. It should be the different from the original item id. 	
	--------------------------------------------------------------------------------
	BEGIN 
		SET @intLotId = NULL 

		SELECT	TOP 1 
				@strLotNumber = Lot.strLotNumber
				,@intLotId = Lot.intLotId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICLot Lot
					ON Lot.intLotId = Detail.intLotId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND Lot.strLotNumber = ISNULL(Detail.strNewLotNumber, Lot.strLotNumber) 
				AND Detail.intItemId = Detail.intNewItemId

		IF @intLotId IS NOT NULL 
		BEGIN
			-- 'The lot {lot number} is assigned to the same item. Item change requires a different item.'
			EXEC uspICRaiseError 80074, @strLotNumber;
			RETURN -1
		END
	END 

	------------------------------------------------------------
	-- Validate the new item. It should be the same lot type. 
	------------------------------------------------------------
	BEGIN 
		SET @intItemId = NULL 
		
		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@strNewItemNo = NewItem.strItemNo
				,@intItemId = Item.intItemId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item 
					ON Item.intItemId = Detail.intItemId
				INNER JOIN dbo.tblICItem NewItem
					ON NewItem.intItemId = Detail.intNewItemId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND dbo.fnGetItemLotType(Detail.intItemId) != dbo.fnGetItemLotType(Detail.intNewItemId) 

		IF @intItemId IS NOT NULL 
		BEGIN
			-- Lot type of %s is different from %s. Items should have the same lot types.
			EXEC uspICRaiseError 80207,@strItemNo,@strNewItemNo;
			RETURN -1
		END
	END 

	---------------------------------------------------------
	-- Validate if the new item location is valid
	---------------------------------------------------------
	BEGIN 
		SET @intItemId = NULL 
		SET @strItemNo = NULL 

		SELECT	TOP 1 
				@intItemId = Item.intItemId
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Detail.intItemId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = Item.intItemId
					AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId) 
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND ItemLocation.intItemLocationId IS NULL 
				
		IF @intItemId IS NOT NULL 
		BEGIN
			-- --'The new Item Location is invalid or missing for %s.'
			EXEC uspICRaiseError 80083, @strItemNo;
			RETURN -1
		END
	END 

	---------------------------------------------------------
	-- Validate if the new pricing location is valid
	---------------------------------------------------------
	BEGIN 
		SET @intItemId = NULL 
		SET @strItemNo = NULL 

		SELECT	TOP 1 
				@intItemId = Item.intItemId
				,@strItemNo = Item.strItemNo
				,@intLocationId = ItemPricing.intItemLocationId
				,@strLocationName = CompLoc.strLocationName
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Detail.intItemId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = Item.intItemId
					AND ItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId) 
				LEFT JOIN dbo.tblSMCompanyLocation CompLoc
					ON CompLoc.intCompanyLocationId = ItemLocation.intLocationId
				LEFT JOIN dbo.tblICItemPricing ItemPricing
					ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND ItemPricing.intItemLocationId IS NULL 
				
		IF @intItemId IS NOT NULL 
		BEGIN
			-- 'Unable to Post. Cost is missing for %s for %s'
			EXEC uspICRaiseError 80221, @strItemNo, @strLocationName;
			RETURN -1
		END
	END 
END 

--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentItemChange
			@intTransactionId
			,@intEntityUserSecurityId

	IF @intCreateUpdateLotError <> 0 RETURN -1	
END

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
			,intItemUOMId			= Detail.intItemUOMId -- Lot.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblAdjustByQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Lot.intItemId)
										,Detail.intItemUOMId
										,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
									)
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
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
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Own
			AND Detail.dblAdjustByQuantity != 0
			--AND Lot.dblQty > 0 
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId -- Lot.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblAdjustByQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intItemId)
										,Detail.intItemUOMId
										,ItemPricing.dblLastCost
									)
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
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
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE Header.intInventoryAdjustmentId = @intTransactionId 
		AND Item.strLotTracking = 'No'
		AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Own
		AND Detail.dblAdjustByQuantity != 0

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
-- REDUCE THE SOURCE LOT NUMBER STORAGE
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
			,intItemUOMId			= Detail.intItemUOMId -- Lot.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblAdjustByQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Lot.intItemId)
										,Detail.intItemUOMId
										,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
									)
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
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
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(Detail.intOwnershipType, Lot.intOwnershipType) = @OWNERSHIP_TYPE_Storage
			AND Detail.dblAdjustByQuantity != 0
			--AND Lot.dblQty > 0 
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId -- Lot.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblAdjustByQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intItemId)
										,Detail.intItemUOMId
										,ISNULL(Detail.dblCost, ItemPricing.dblLastCost)
									)
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
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
			LEFT JOIN tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intLocationId)
	WHERE Header.intInventoryAdjustmentId = @intTransactionId 
		AND Item.strLotTracking = 'No'
		AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Storage
		AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @ReduceFromSourceStorage)
	BEGIN
		EXEC	dbo.uspICPostStorage
				@ReduceFromSourceStorage  
				,@strBatchId
				,@intEntityUserSecurityId
	END
END


--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT FOR A NEW ITEM.
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
	SELECT 	intItemId				= Detail.intNewItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= 
									--dbo.fnCalculateCostBetweenUOM( 
									--	dbo.fnGetItemStockUOM(Detail.intNewItemId)
									--	,dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Detail.intItemUOMId)
									--	,ISNULL(Detail.dblNewCost, SourceTransaction.dblCost)
									--)
									CASE 
										WHEN Detail.dblNewCost IS NULL THEN 
											SourceTransaction.dblCost
										ELSE
											Detail.dblNewCost
											--dbo.fnCalculateCostBetweenUOM ( 
											--	dbo.fnGetItemStockUOM(Detail.intNewItemId)
											--	,dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Detail.intItemUOMId)
											--	,Detail.dblNewCost
											--)
									END
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= NewLot.intSubLocationId
			,intStorageLocationId	= NewLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId) 
				AND NewItemLocation.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId

			INNER JOIN dbo.tblICInventoryTransaction SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intNewItemId
				AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, SourceTransaction.intItemUOMId)

			LEFT JOIN dbo.tblICLot NewLot
				ON NewLot.intLotId = Detail.intNewLotId


	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Own
			AND Detail.dblAdjustByQuantity != 0
			--AND SourceTransaction.dblQty < 0 
	UNION ALL
	SELECT 	intItemId				= Detail.intNewItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId) 
				AND NewItemLocation.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICInventoryTransaction SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intNewItemId
				AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, SourceTransaction.intItemUOMId)

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Item.strLotTracking = 'No'
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Own
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTarget)
	BEGIN
		EXEC	dbo.uspICPostCosting  
				@AddToTarget  
				,@strBatchId  
				,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId
	END

END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT FOR A NEW ITEM STORAGE.
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
	SELECT 	intItemId				= Detail.intNewItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty 
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= Detail.dblNewCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= SourceLot.intSubLocationId
			,intStorageLocationId	= SourceLot.intStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)  
				AND NewItemLocation.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICLot SourceLot
				ON SourceLot.intLotId = Detail.intLotId

			INNER JOIN dbo.tblICInventoryTransactionStorage SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intNewItemId
				AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, SourceTransaction.intItemUOMId)

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Storage
			AND Detail.dblAdjustByQuantity != 0
			--AND SourceTransaction.dblQty < 0 
	UNION ALL
	SELECT 	intItemId				= Detail.intNewItemId
			,intItemLocationId		= NewItemLocation.intItemLocationId
			,intItemUOMId			= NewItemUOM.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -SourceTransaction.dblQty 
			,dblUOMQty				= NewItemUOM.dblUnitQty
			,dblCost				= dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intNewItemId)
										,dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, Detail.intItemUOMId)
										,Detail.dblNewCost
									)
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = ISNULL(Detail.intNewLocationId, Header.intLocationId)  
				AND NewItemLocation.intItemId = Detail.intNewItemId

			INNER JOIN dbo.tblICInventoryTransactionStorage SourceTransaction
				ON SourceTransaction.intTransactionId = Header.intInventoryAdjustmentId				
				AND SourceTransaction.strTransactionId = Header.strAdjustmentNo
				AND SourceTransaction.strBatchId = @strBatchId
				AND SourceTransaction.intTransactionDetailId = Detail.intInventoryAdjustmentDetailId

			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemId = Detail.intNewItemId
				AND NewItemUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(Detail.intNewItemId, SourceTransaction.intItemUOMId)

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Item.strLotTracking = 'No'
			AND Detail.intOwnershipType = @OWNERSHIP_TYPE_Storage
			AND Detail.dblAdjustByQuantity != 0

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @AddToTargetStorage)
	BEGIN
		EXEC	dbo.uspICPostStorage
				@AddToTargetStorage  
				,@strBatchId  
				,@intEntityUserSecurityId
	END

END