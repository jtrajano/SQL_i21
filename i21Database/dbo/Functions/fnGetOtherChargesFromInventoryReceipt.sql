-- This function returns the total allocated other charge per 
CREATE FUNCTION [dbo].[fnGetOtherChargesFromInventoryReceipt] ( 
	@intInventoryReceiptItemId AS INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @totalOtherCharges AS NUMERIC(18,6)
			,@units AS NUMERIC(18,6)
			,@intFunctionalCurrencyId AS INT 

	-- Get the functional currency. 
	BEGIN 
		SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	END 

	SELECT	@totalOtherCharges = SUM(
				CASE 
					WHEN ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(Charge.dblForexRate, 0) <> 0 THEN 
						-- Other charge is using a foreign currency. Convert the other charge to functional currency. 
						dbo.fnMultiply(ItemOtherCharges.dblAmount, ISNULL(Charge.dblForexRate, 0)) 
					ELSE 
						-- No conversion. Other charge is already in functional currency. 
						ItemOtherCharges.dblAmount 
				END 
			)
	FROM	tblICInventoryReceiptItem ReceiptItems INNER JOIN tblICInventoryReceiptItemAllocatedCharge ItemOtherCharges 
				ON ReceiptItems.intInventoryReceiptItemId = ItemOtherCharges.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceiptCharge Charge
				ON Charge.intInventoryReceiptChargeId = ItemOtherCharges.intInventoryReceiptChargeId
	WHERE	ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId
			AND ItemOtherCharges.ysnInventoryCost = 1

	SELECT	@units = 
					CASE	WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(AggregrateItemLots.dblTotalNet, 0)
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
		RETURN ISNULL(@totalOtherCharges / @units, 0);

	RETURN 0;
END