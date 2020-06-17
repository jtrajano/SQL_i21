CREATE PROCEDURE uspICPostInventoryAdjustmentClosingBalance  
	@intTransactionId INT = NULL
	,@strBatchId NVARCHAR(40)
	,@intEntityUserSecurityId INT = NULL
	,@ysnPost BIT = 0
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @INVENTORY_ADJUSTMENT_ClosingBalance AS INT = 57
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE @ItemsForClosingBalance AS ItemCostingTableType
DECLARE @StorageItemsForPost AS ItemCostingTableType  

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
DECLARE @intReturnValue AS INT 
DECLARE @intLocationId INT
		,@STARTING_NUMBER_BATCH AS INT = 3  
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
		EXEC uspICRaiseError 80039, @strItemNo;
		RETURN -1
	END

END

----------------------------------------------------------------------------------
---- Validate the Adjust By Qty or New Quantity
---------------------------------------------------------------------------------
--BEGIN 
--	SELECT	TOP 1 
--			@intItemId = Detail.intItemId,
--			@intLocationId = Header.intLocationId
--	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
--				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
--	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
--			AND ISNULL(Detail.dblAdjustByQuantity, 0) = 0
--			--OR ISNULL(Detail.dblNewQuantity, 0) = 0
	
--	IF @intItemId IS NOT NULL 
--	BEGIN
--		SELECT @strItemNo = strItemNo
--		FROM dbo.tblICItem Item 
--		WHERE intItemId = @intItemId		

--		-- 'Please specify the Adjust By Quantity or New Quantity on {Item}.'
--		EXEC uspICRaiseError 80040;
--		RETURN -1
--	END
--END 

DECLARE @intCreateUpdateLotError AS INT 

EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentQtyChange
		@intTransactionId
		,@intEntityUserSecurityId

--------------------------------------------------------------------------------
-- Qty Only
--------------------------------------------------------------------------------
BEGIN 
	INSERT INTO @ItemsForClosingBalance (
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
			,dblCost				= CASE	WHEN ISNULL(Detail.dblNewQuantity, 0) - ISNULL(Detail.dblQuantity, 0) > 0 THEN 
												ISNULL(
													Detail.dblNewCost
													,dbo.fnCalculateCostBetweenUOM( 
														dbo.fnGetItemStockUOM(Detail.intItemId)
														,Detail.intItemUOMId
														,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
													)
												)	
											ELSE 
												dbo.fnCalculateCostBetweenUOM( 
													dbo.fnGetItemStockUOM(Detail.intItemId)
													,Detail.intItemUOMId
													,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
												)	
									  END 	
			,dblSalesPrice			= 0
			,intCurrencyId			= NULL 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId  = @INVENTORY_ADJUSTMENT_ClosingBalance
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON Detail.intWeightUOMId = WeightUOM.intItemUOMId
			LEFT JOIN dbo.tblICLot Lot
				ON Lot.intLotId = Detail.intLotId  
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
		AND Detail.dblAdjustByQuantity <> 0

END

-- Return the result back to uspICPostInventoryAdjustment for further processing. 
SELECT	intItemId			
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
FROM	@ItemsForClosingBalance


-- Process Storage items 
BEGIN 
	INSERT INTO @StorageItemsForPost (  
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
			,intInTransitSourceLocationId
			,intForexRateTypeId
			,dblForexRate
	)  
	SELECT	intItemId = DetailItem.intItemId  
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = DetailItem.intItemUOMId
			,dtmDate = Header.dtmAdjustmentDate  
			,dblQty = CASE @ysnPost WHEN 1 THEN ISNULL(DetailItem.dblNewQuantity, 0) - ISNULL(DetailItem.dblQuantity, 0) ELSE -ISNULL(DetailItem.dblAdjustByQuantity, 0) END
			,dblUOMQty = ItemUOM.dblUnitQty		
			,dblCost =	0.00			
			,dblSalesPrice = 0  
			,intCurrencyId = @intFunctionalCurrencyId  
			,dblExchangeRate = 1  
			,intTransactionId = Header.intInventoryAdjustmentId  
			,intTransactionDetailId  = DetailItem.intInventoryAdjustmentDetailId
			,strTransactionId = Header.strAdjustmentNo  
			,intTransactionTypeId = @INVENTORY_ADJUSTMENT_ClosingBalance  
			,intLotId = DetailItem.intLotId 
			,intSubLocationId = DetailItem.intSubLocationId -- ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
			,intStorageLocationId = DetailItem.intStorageLocationId
			,intInTransitSourceLocationId = NULL
			,intForexRateTypeId = NULL
			,dblForexRate = NULL
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail DetailItem 
				ON Header.intInventoryAdjustmentId = DetailItem.intInventoryAdjustmentId 					
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = DetailItem.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM 
				ON ItemUOM.intItemUOMId = DetailItem.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON WeightUOM.intItemUOMId = DetailItem.intWeightUOMId
	WHERE	Header.intInventoryAdjustmentId = @intTransactionId   
			AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Own
			AND DetailItem.dblAdjustByQuantity != 0

	-- Update currency fields to functional currency. 
	BEGIN 
		UPDATE	storageCost
		SET		dblExchangeRate = 1
				,dblForexRate = 1
				,intCurrencyId = @intFunctionalCurrencyId
		FROM	@StorageItemsForPost storageCost
		WHERE	ISNULL(storageCost.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId 

		UPDATE	storageCost
		SET		dblCost = dbo.fnMultiply(dblCost, ISNULL(dblForexRate, 1)) 
				,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, ISNULL(dblForexRate, 1)) 
				,dblValue = dbo.fnMultiply(dblValue, ISNULL(dblForexRate, 1)) 
		FROM	@StorageItemsForPost storageCost
		WHERE	storageCost.intCurrencyId <> @intFunctionalCurrencyId 
	END

	-- Call the post routine 
	IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostStorage
				@StorageItemsForPost  
				,@strBatchId  
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO Post_Exit
	END
END

Post_Exit: