CREATE PROCEDURE uspICInventoryAdjustmentUpdateOutdatedExpiryDate
	@strTransactionId NVARCHAR(50) = NULL
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Update the expiry date. 
UPDATE	Detail
SET		dtmExpiryDate = Lot.dtmExpiryDate
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
		AND Detail.intLotId IS NOT NULL 
		AND Detail.dtmExpiryDate <> Lot.dtmExpiryDate
