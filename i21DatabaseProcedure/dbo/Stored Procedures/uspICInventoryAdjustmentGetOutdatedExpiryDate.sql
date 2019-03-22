CREATE PROCEDURE uspICInventoryAdjustmentGetOutdatedExpiryDate
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

-- Check for outdated expiry dates
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
			LEFT JOIN dbo.tblICItemStock ItemStock
				ON ItemStock.intItemId = Item.intItemId
				AND ItemStock.intItemLocationId = ItemLocation.intItemLocationId
			LEFT JOIN dbo.tblICLot Lot
				ON Detail.intLotId = Lot.intLotId
	WHERE	Header.strAdjustmentNo = @strTransactionId	
			AND Header.intAdjustmentType = @ADJUSTMENT_TYPE_ExpiryDateChange
			AND Detail.intLotId IS NOT NULL AND (Detail.dtmExpiryDate <> Lot.dtmExpiryDate)

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'The lot expiry dates are outdated for {Adjustment id}. Please review your quantity adjustments after the system reloads the latest expiry dates.'
		EXEC uspICRaiseError 80028, @strAdjustmentId;
		GOTO _ExitWithErrors
	END 
END 

-- Exit successfully
BEGIN 
	SET @ysnPassed = 1;
	GOTO _Exit;
END 

-- Exit with Errors
_ExitWithErrors: 
BEGIN 	
	SET @ysnPassed = 0;
END 

_Exit: 