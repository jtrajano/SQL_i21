CREATE PROCEDURE uspICPostInventoryAdjustmentItemChange  
	@intTransactionId INT = NULL  
	,@strBatchId NVARCHAR(50)
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

DECLARE @ReduceLotFromSource AS ItemCostingTableType
		,@MoveLotToNewItem AS ItemCostingTableType
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

	BEGIN 
		SELECT TOP 1 
				@intItemId = Detail.intItemId			
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				LEFT JOIN dbo.tblICItemUOM ItemUOM
					ON Detail.intItemUOMId = ItemUOM.intItemUOMId
				LEFT JOIN dbo.tblICItemUOM WeightUOM
					ON Detail.intWeightUOMId = WeightUOM.intItemUOMId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND ISNULL(WeightUOM.intItemUOMId, ItemUOM.intItemUOMId) IS NULL 
	
		IF @intItemId IS NOT NULL 
		BEGIN
			SELECT @strItemNo = strItemNo
			FROM dbo.tblICItem Item 
			WHERE intItemId = @intItemId		

			-- 'The UOM is missing on {Item}.'
			EXEC uspICRaiseError 80039, @strItemNo;
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
	-- Validate the new item. It should be a lot-tracked item. 
	------------------------------------------------------------
	BEGIN 
		SET @intItemId = NULL 

		SELECT	TOP 1 
				@strNewItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICItem Item 
					ON Item.intItemId = Detail.intNewItemId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
				AND dbo.fnGetItemLotType(Detail.intNewItemId) = 0 

		IF @intItemId IS NOT NULL 
		BEGIN
			-- 'Item %s is invalid. It must be lot tracked.'
			EXEC uspICRaiseError 80075, @strNewItemNo;
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
	INSERT INTO @ReduceLotFromSource (
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
			AND Lot.dblQty > 0 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@ReduceLotFromSource  
			,@strBatchId  
			,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intEntityUserSecurityId
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON SAME LOT BUT FOR A NEW ITEM.
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MoveLotToNewItem (
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
			,dblCost				= SourceTransaction.dblCost
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_ItemChange
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId

	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId

			INNER JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = Header.intLocationId 
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

	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND SourceTransaction.dblQty < 0 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@MoveLotToNewItem  
			,@strBatchId  
			,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intEntityUserSecurityId
END