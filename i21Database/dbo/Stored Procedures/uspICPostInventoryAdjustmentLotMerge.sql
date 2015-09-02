CREATE PROCEDURE uspICPostInventoryAdjustmentLotMerge  
	@intTransactionId INT = NULL
	,@strBatchId NVARCHAR(50)
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY NVARCHAR(50)
	,@intUserId INT 
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

DECLARE @MergeLotSource AS ItemCostingTableType
		,@MergeToTargetLot AS ItemCostingTableType

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Validate the UOM
--------------------------------------------------------------------------------
DECLARE @intItemId AS INT 
DECLARE @strItemNo AS NVARCHAR(50)

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
		RAISERROR(51136, 11, 1, @strItemNo);
		GOTO Exit_With_Errors
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

		-- 'Merge Lot requires a negative Adjust Qty on %s as stock for the merge.'
		RAISERROR(51177, 11, 1, @strItemNo);
		GOTO Exit_With_Errors
	END
END 


--------------------------------------------------------------------------------
-- REDUCE THE SOURCE LOT NUMBER
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeLotSource (
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
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0)	
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= Detail.dblCost -- Cost saved in Adj is expected come from the cost bucket. 
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_LotMerge
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = Detail.intLotId
				AND Lot.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemUOMId = Detail.intWeightUOMId
				AND WeightUOM.intItemId = Detail.intItemId				
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND Detail.dblNewQuantity IS NOT NULL 
			AND ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) < 0 -- ensure it is reducing the stock. 

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@MergeLotSource  
			,@strBatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intUserId
END

--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentSplitLot 
			@intTransactionId
			,@intUserId

	IF @intCreateUpdateLotError <> 0
	BEGIN 
		GOTO Exit_With_Errors;
	END
END

--------------------------------------------------------------------------------
-- INCREASE THE STOCK ON MERGE
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @MergeToTargetLot (
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
			,intItemLocationId		= ISNULL(NewItemLocation.intItemLocationId, OriginalItemLocation.intItemLocationId) 
			,intItemUOMId			= ISNULL(NewItemUOM.intItemUOMId, FromStock.intItemUOMId) 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= ISNULL(Detail.dblNewSplitLotQuantity, -1 * FromStock.dblQty) 
			,dblUOMQty				= ISNULL(NewItemUOM.dblUnitQty, FromStock.dblUOMQty)
			,dblCost				= ISNULL(Detail.dblNewCost, FromStock.dblCost) 
			,dblValue				= 0
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId	= @INVENTORY_ADJUSTMENT_LotMerge
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId			
			INNER JOIN dbo.tblICInventoryTransaction FromStock
				ON Detail.intInventoryAdjustmentDetailId = FromStock.intTransactionDetailId
				AND Detail.intInventoryAdjustmentId = FromStock.intTransactionId
				AND FromStock.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation OriginalItemLocation 
				ON OriginalItemLocation.intLocationId = Header.intLocationId 
				AND OriginalItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemLocation NewItemLocation 
				ON NewItemLocation.intLocationId = Detail.intNewLocationId
				AND NewItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM OriginalItemUOM
				ON OriginalItemUOM.intItemUOMId = Detail.intItemUOMId
				AND OriginalItemUOM.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM NewItemUOM
				ON NewItemUOM.intItemUOMId = Detail.intNewItemUOMId
				AND NewItemUOM.intItemId = Detail.intItemId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
			AND ISNULL(FromStock.ysnIsUnposted, 0) = 0
			AND FromStock.strBatchId = @strBatchId

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	EXEC	dbo.uspICPostCosting  
			@MergeToTargetLot  
			,@strBatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
			,@intUserId
END

Exit_Successfully:
GOTO _Exit

Exit_With_Errors:
RETURN -1;

_Exit: 