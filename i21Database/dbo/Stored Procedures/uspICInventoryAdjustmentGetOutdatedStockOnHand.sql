CREATE PROCEDURE uspICInventoryAdjustmentGetOutdatedStockOnHand
	@strTransactionId NVARCHAR(50) = NULL
	,@ysnPassed BIT = 0 OUTPUT 
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_LotIdChange AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

DECLARE @intItemId AS INT
		,@strAdjustmentId AS NVARCHAR(50)

-- Check for outdated On-Hand qty. 
BEGIN 
	SELECT TOP 1 
			@intItemId = Item.intItemId
			,@strAdjustmentId = Header.strAdjustmentNo
	FROM	dbo.tblICItem Item INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail
				ON Item.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICInventoryAdjustment Header
				ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = Item.intItemId
				AND ItemLocation.intLocationId = Header.intLocationId
			LEFT JOIN dbo.tblICItemStockUOM ItemStockUOM
				ON ItemStockUOM.intItemId = Item.intItemId
				AND ItemStockUOM.intItemLocationId = ItemLocation.intItemLocationId
				AND ItemStockUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemStockUOM.intStorageLocationId = Detail.intStorageLocationId
				AND ItemStockUOM.intSubLocationId = Detail.intSubLocationId
				AND ItemStockUOM.intItemLocationId = ItemLocation.intItemLocationId
			LEFT JOIN dbo.tblICLot Lot
				ON Detail.intLotId = Lot.intLotId
	WHERE	Header.strAdjustmentNo = @strTransactionId	
			AND Header.intAdjustmentType = @ADJUSTMENT_TYPE_QuantityChange
			AND 1 = 
				CASE	WHEN Detail.intLotId IS NOT NULL AND (ROUND(Detail.dblQuantity, 6) <> ROUND(Lot.dblQty, 6)) THEN 1
						WHEN Detail.intLotId IS NULL AND (ROUND(Detail.dblQuantity, 6) <> ROUND(ItemStockUOM.dblOnHand, 6)) THEN 1
						ELSE 0
				END 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'The stock on hand is outdated for {Adjustment id}. Please review your quantity adjustments after the system reloads the latest stock on hand.'
		RAISERROR('The stock on hand is outdated for %s. Please review your quantity adjustments after the system reloads the latest stock on hand.', 11, 1, @strAdjustmentId);
		GOTO ValidateInventoryAdjustment_ExitWithErrors
	END 
END 

-- Exit successfully
BEGIN 
	SET @ysnPassed = 1;
	GOTO ValidateInventoryAdjustment_Exit;
END 

-- Exit with Errors
ValidateInventoryAdjustment_ExitWithErrors: 
BEGIN 	
	SET @ysnPassed = 0;
END 

ValidateInventoryAdjustment_Exit: 