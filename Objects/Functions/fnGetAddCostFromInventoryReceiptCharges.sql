-- This function returns the total allocated other charge per receipt line item. 
CREATE FUNCTION [dbo].[fnGetAddCostFromInventoryReceiptCharges] ( 
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

	RETURN ISNULL(@totalOtherCharges, 0) 
	;
END