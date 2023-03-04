﻿CREATE PROCEDURE [dbo].[uspICPostInventoryAdjustmentOpeningInventory]
	@intTransactionId INT = NULL,
	@strBatchId NVARCHAR(40),
	@intEntityUserSecurityId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  



DECLARE @OpeningBalanceIncrease AS ItemCostingTableType
		,@OpeningBalanceStorageIncrease AS ItemCostingTableType
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2

		,@INVENTORY_ADJUSTMENT_OpeningInventory AS INT = 47

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
DECLARE @intReturnValue AS INT 
DECLARE @intLocationId INT
		,@STARTING_NUMBER_BATCH AS INT = 3  


--------------------------------------------------------------------------------
-- CREATE THE LOT NUMBER RECORD
--------------------------------------------------------------------------------
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryAdjustmentOpeningInventory
			@intTransactionId
			,@intEntityUserSecurityId

	IF @intCreateUpdateLotError <> 0 RETURN -1	
END


-------------------------------------------------------------------------------
-- INCREASE OPENING BALANCE
-------------------------------------------------------------------------------
BEGIN
	INSERT INTO @OpeningBalanceIncrease(
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost 
			,dblForexCost
			,dblSalesPrice  
			,intCurrencyId  
			,intForexRateTypeId
			,dblExchangeRate  
			,dblForexRate
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
			,intItemUOMId			= ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId)
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= COALESCE(Detail.dblNewWeight, Detail.dblNewQuantity, 0)
			,dblUOMQty				= COALESCE(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty, 0)
			,dblCost				= 
					CASE 
						WHEN Detail.intCostUOMId IS NOT NULL AND Detail.dblNewCost IS NOT NULL THEN 
							dbo.fnCalculateCostBetweenUOM(Detail.intCostUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), Detail.dblNewCost) 
						ELSE 
							COALESCE(
								Detail.dblNewCost
								, dbo.fnCalculateCostBetweenUOM(stockUnit.intItemUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), ItemPricing.dblLastCost) 
								, 0
							)
					END 
					
			,dblForexCost			= 
					CASE 
						WHEN Detail.intCurrencyId <> @intFunctionalCurrencyId THEN 
							CASE 
								WHEN Detail.intCostUOMId IS NOT NULL AND Detail.dblUnitCostInForeignCurrency IS NOT NULL  THEN 
									dbo.fnCalculateCostBetweenUOM(Detail.intCostUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), Detail.dblUnitCostInForeignCurrency) 
								ELSE 
									Detail.dblUnitCostInForeignCurrency
							END 
						ELSE 
							NULL 
					END 

			,dblSalesPrice			= 0
			,intCurrencyId			= Detail.intCurrencyId 
			,intForexRateTypeId		= Detail.intForexRateTypeId
			,dblExchangeRate		= ISNULL(Detail.dblForexRate, 1) 
			,dblForexRate			= ISNULL(Detail.dblForexRate, 1) 
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId   = @INVENTORY_ADJUSTMENT_OpeningInventory
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId
				AND ItemLocation.intItemId = Detail.intItemId
			OUTER APPLY (
				SELECT TOP 1 *
				FROM 
					tblICItemUOM stockUnit
				WHERE
					stockUnit.intItemId = Detail.intItemId
					AND stockUnit.ysnStockUnit = 1
			) stockUnit

			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intNewItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON Detail.intNewWeightUOMId = WeightUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	
		Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
		AND Item.strLotTracking <> 'No'
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intNewItemUOMId 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblNewQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= 
					CASE 
						WHEN Detail.intCostUOMId IS NOT NULL AND Detail.dblNewCost IS NOT NULL THEN 
							dbo.fnCalculateCostBetweenUOM(Detail.intCostUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), Detail.dblNewCost) 
						ELSE 
							COALESCE(
								Detail.dblNewCost
								, dbo.fnCalculateCostBetweenUOM(stockUnit.intItemUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), ItemPricing.dblLastCost) 
								, 0
							)
					END 
					
			,dblForexCost			= 
					CASE 
						WHEN Detail.intCurrencyId <> @intFunctionalCurrencyId THEN 
							CASE 
								WHEN Detail.intCostUOMId IS NOT NULL AND Detail.dblUnitCostInForeignCurrency IS NOT NULL  THEN 
									dbo.fnCalculateCostBetweenUOM(Detail.intCostUOMId, ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId), Detail.dblUnitCostInForeignCurrency) 
								ELSE 
									Detail.dblUnitCostInForeignCurrency
							END 
						ELSE 
							NULL 
					END 
			,dblSalesPrice			= 0
			,intCurrencyId			= Detail.intCurrencyId 
			,intForexRateTypeId		= Detail.intForexRateTypeId
			,dblExchangeRate		= ISNULL(Detail.dblForexRate, 1) 
			,dblForexRate			= ISNULL(Detail.dblForexRate, 1) 
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId   = @INVENTORY_ADJUSTMENT_OpeningInventory
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId
				AND ItemLocation.intItemId = Detail.intItemId
			OUTER APPLY (
				SELECT TOP 1 *
				FROM 
					tblICItemUOM stockUnit
				WHERE
					stockUnit.intItemId = Detail.intItemId
					AND stockUnit.ysnStockUnit = 1
			) stockUnit
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intNewItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	
		Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
		AND Item.strLotTracking = 'No'

	-- Call the post routine
	IF EXISTS (SELECT TOP 1 1 FROM @OpeningBalanceIncrease)
	BEGIN
		EXEC @intReturnValue = dbo.uspICPostCosting
				@OpeningBalanceIncrease  
				,@strBatchId  
				,NULL
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO Post_Exit
	END

END

-------------------------------------------------------------------------------
-- INCREASE OPENING BALANCE STORAGE
-------------------------------------------------------------------------------
BEGIN
	INSERT INTO @OpeningBalanceStorageIncrease(
			intItemId			
			,intItemLocationId	
			,intItemUOMId		
			,dtmDate			
			,dblQty				
			,dblUOMQty			
			,dblCost  
			,dblSalesPrice  
			,intCurrencyId
			,intForexRateTypeId
			,dblExchangeRate
			,dblForexRate
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
			,intItemUOMId			= ISNULL(Detail.intNewWeightUOMId, Detail.intNewItemUOMId)
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= COALESCE(Detail.dblNewWeight, Detail.dblNewQuantity, 0)
			,dblUOMQty				= COALESCE(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty, 0)
			,dblCost				= ISNULL(ISNULL(Detail.dblNewCost, ItemPricing.dblLastCost), 0)
			,dblSalesPrice			= 0
			,intCurrencyId			= Detail.intCurrencyId 
			,intForexRateTypeId		= Detail.intForexRateTypeId
			,dblExchangeRate		= ISNULL(Detail.dblForexRate, 1) 
			,dblForexRate			= ISNULL(Detail.dblForexRate, 1) 
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId   = @INVENTORY_ADJUSTMENT_OpeningInventory
			,intLotId				= Detail.intNewLotId
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intNewItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemUOM WeightUOM
				ON Detail.intNewWeightUOMId = WeightUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	
		Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Storage
		AND Item.strLotTracking <> 'No'
	UNION ALL
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intNewItemUOMId 
			,dtmDate				= Header.dtmAdjustmentDate
			,dblQty					= Detail.dblNewQuantity
			,dblUOMQty				= ItemUOM.dblUnitQty
			,dblCost				= ISNULL(dbo.fnCalculateCostBetweenUOM( 
										dbo.fnGetItemStockUOM(Detail.intItemId)
										,Detail.intNewItemUOMId
										,ISNULL(Detail.dblNewCost, ItemPricing.dblLastCost)
									), 0)
			,dblSalesPrice			= 0
			,intCurrencyId			= Detail.intCurrencyId 
			,intForexRateTypeId		= Detail.intForexRateTypeId
			,dblExchangeRate		= ISNULL(Detail.dblForexRate, 1) 
			,dblForexRate			= ISNULL(Detail.dblForexRate, 1) 
			,intTransactionId		= Header.intInventoryAdjustmentId
			,intTransactionDetailId = Detail.intInventoryAdjustmentDetailId
			,strTransactionId		= Header.strAdjustmentNo
			,intTransactionTypeId   = @INVENTORY_ADJUSTMENT_OpeningInventory
			,intLotId				= NULL
			,intSubLocationId		= Detail.intNewSubLocationId
			,intStorageLocationId	= Detail.intNewStorageLocationId
	FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId
				AND ItemLocation.intItemId = Detail.intItemId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intNewItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId		
	WHERE	
		Header.intInventoryAdjustmentId = @intTransactionId
		AND ISNULL(Detail.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Storage
		AND Item.strLotTracking = 'No'

	-------------------------------------------
	-- Call the costing SP	
	-------------------------------------------
	IF EXISTS(SELECT TOP 1 1 FROM @OpeningBalanceStorageIncrease)
	BEGIN
		EXEC dbo.uspICPostStorage
			@OpeningBalanceStorageIncrease  
			,@strBatchId  
			,@intEntityUserSecurityId

	END

END


Post_Exit: