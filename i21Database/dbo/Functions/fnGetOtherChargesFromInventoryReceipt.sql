-- This function returns the item cost based on the other charge-item allocation. 
CREATE FUNCTION [dbo].[fnGetOtherChargesFromInventoryReceipt] ( 
	@intInventoryReceiptItemId AS INT
	,@intStockUOMId AS INT = NULL 
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @totalOtherCharges AS NUMERIC(18,6)
			,@units AS NUMERIC(18,6)
			,@intFunctionalCurrencyId AS INT 
			,@intItemUOMId AS INT 
			,@intItemId AS INT 
			,@intReceiptCurrencyId AS INT 
			,@dblForexRate AS NUMERIC(38, 20) 

	-- Get the functional currency. 
	BEGIN 
		SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	END 

	-- Get the receipt currency. 
	BEGIN 
		SELECT TOP 1 
			@intReceiptCurrencyId = r.intCurrencyId
			,@dblForexRate = ISNULL(NULLIF(ri.dblForexRate, 0), 1) 
		FROM 
			tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r 
				ON ri.intInventoryReceiptId = r.intInventoryReceiptId 
		WHERE ri.intInventoryReceiptItemId = @intInventoryReceiptItemId
	END 


	SELECT	@totalOtherCharges = SUM(
				ROUND(
					CASE 
						-- Other Charge shares the same currency with the detail item. 
						WHEN ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) = @intReceiptCurrencyId THEN 
							-- No conversion required. Other charges shares the same currency with the item.
							CASE WHEN ItemOtherCharges.ysnPrice = 1 THEN -ItemOtherCharges.dblAmount ELSE ItemOtherCharges.dblAmount END 

						-- Other charge is a different currency compared to the currency at the receipt item. 
						-- 1. Convert the other charge to functional currency. 
						-- 2. Then convert the amount in functional currency to the item currency. 
						WHEN 
							--ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId 
							ISNULL(Charge.intCurrencyId, @intFunctionalCurrencyId) <> @intReceiptCurrencyId
							--AND ISNULL(Charge.dblForexRate, 0) <> 0 							
						THEN
							dbo.fnDivide (							
								dbo.fnMultiply(
									CASE WHEN ItemOtherCharges.ysnPrice = 1 THEN -ItemOtherCharges.dblAmount ELSE ItemOtherCharges.dblAmount END 
									, ISNULL(NULLIF(Charge.dblForexRate, 0), 1)
								) 
								, @dblForexRate
							) 
						ELSE 
							-- No conversion. Other charge is already in functional currency. 
							CASE WHEN ItemOtherCharges.ysnPrice = 1 THEN -ItemOtherCharges.dblAmount ELSE ItemOtherCharges.dblAmount END 
					END
					,2
				)
			)
	FROM	tblICInventoryReceiptItem ReceiptItems INNER JOIN tblICInventoryReceiptItemAllocatedCharge ItemOtherCharges 
				ON ReceiptItems.intInventoryReceiptItemId = ItemOtherCharges.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceiptCharge Charge
				ON Charge.intInventoryReceiptChargeId = ItemOtherCharges.intInventoryReceiptChargeId
	WHERE	ReceiptItems.intInventoryReceiptItemId = @intInventoryReceiptItemId
			AND ItemOtherCharges.ysnInventoryCost = 1


	SELECT	@units = 
					CASE	WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(AggregrateItemLots.dblTotalNet, ri.dblNet)
							ELSE ISNULL(ri.dblOpenReceive, 0)
					END 
			,@intItemUOMId = ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId) 
			,@intItemId = ri.intItemId
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

	SELECT @units = dbo.fnCalculateQtyBetweenUOM (
				@intItemUOMId
				,COALESCE(@intStockUOMId, @intItemUOMId)
				,@units
			)
	FROM	dbo.tblICItemUOM iu
	WHERE	iu.intItemUOMId = @intStockUOMId
			AND iu.intItemId = @intItemId

	IF ISNULL(@units, 0) <> 0 
		RETURN 
			dbo.fnDivide(
				ISNULL(@totalOtherCharges, 0)
				,@units
			);
		
	RETURN 0;
END
