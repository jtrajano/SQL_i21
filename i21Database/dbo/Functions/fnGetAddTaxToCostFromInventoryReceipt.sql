-- This function returns the tax that needs to be added to the item cost. 
-- Return value is using the Receipt's currency. 
CREATE FUNCTION [dbo].[fnGetAddTaxToCostFromInventoryReceipt] ( 
	@intInventoryReceiptItemId AS INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @totalTax AS NUMERIC(18,6)
			,@units AS NUMERIC(18,6)
			,@intFunctionalCurrencyId AS INT 

	SELECT	@totalTax = SUM(ReceiptTax.dblTax)
	FROM	tblICInventoryReceiptItem ReceiptItems INNER JOIN tblICInventoryReceiptItemTax ReceiptTax
				ON ReceiptItems.intInventoryReceiptItemId = ReceiptTax.intInventoryReceiptItemId
	WHERE	ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId
			AND ReceiptTax.ysnAddToCost = 1

	SELECT	@units = 
					CASE	WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(AggregrateItemLots.dblTotalNet, ri.dblNet)
							ELSE ISNULL(ri.dblOpenReceive, 0)
					END 
	FROM	dbo.tblICInventoryReceiptItem ri 
			OUTER APPLY (
				SELECT  dblTotalNet = SUM(
							CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
										ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
									ELSE 
										ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
							END 
						)
				FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
				WHERE	ReceiptItem.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			) AggregrateItemLots
	WHERE	ri.intInventoryReceiptItemId = @intInventoryReceiptItemId

	IF ISNULL(@units, 0) <> 0 
		RETURN ISNULL(@totalTax, 0) / @units;
		
	RETURN 0;
END