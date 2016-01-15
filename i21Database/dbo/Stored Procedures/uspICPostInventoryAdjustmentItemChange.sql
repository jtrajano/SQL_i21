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

--------------------------------------------------------------------------------
-- VALIDATIONS
--------------------------------------------------------------------------------
-- None for now. 

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
			,intItemUOMId			= Lot.intItemUOMId
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= -1 * Lot.dblQty -- Transfer all the Qty's 
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= Lot.dblLastCost
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
			,dblQty					= -1 * SourceTransaction.dblQty
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
			,intSubLocationId		= SourceTransaction.intSubLocationId
			,intStorageLocationId	= SourceTransaction.intStorageLocationId

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