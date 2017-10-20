CREATE PROCEDURE [dbo].[uspICCalculateOtherCharges]
	@intInventoryReceiptId AS INT
AS
BEGIN

	-- Update the currency fields 
	UPDATE	ReceiptCharges
	SET		intCent = Currency.intCent
			,ysnSubCurrency = Currency.ysnSubCurrency
	FROM	dbo.tblICInventoryReceiptCharge ReceiptCharges INNER JOIN dbo.tblSMCurrency Currency
				ON ReceiptCharges.intCurrencyId = Currency.intCurrencyID
	WHERE	ReceiptCharges.intInventoryReceiptId = @intInventoryReceiptId

	-- Calculate the other charges. 
	BEGIN 
		-- Calculate the other charges. 
		EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
			@intInventoryReceiptId
	END 

	-- Calculate the surcharges
	BEGIN 
		EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
			@intInventoryReceiptId
	END

	UPDATE	ReceiptCharge
	SET		dblAmount = ROUND(	
							ISNULL(ComputedCharges.dblCalculatedAmount, 0)
							/ 
							CASE	WHEN ReceiptCharge.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(ReceiptCharge.intCent, 1) <> 0 THEN ISNULL(ReceiptCharge.intCent, 1) ELSE 1 END 
									ELSE 
										1
							END 
						, 2)
			,dblQuantity = 
				CASE 
					WHEN ReceiptCharge.strCostMethod = 'Per Unit' AND ISNULL(ReceiptCharge.dblRate, 0) <> 0 THEN
						dbo.fnDivide(
							ReceiptCharge.dblAmount
							,ReceiptCharge.dblRate
						)

					ELSE 
						1
				END 

	FROM	dbo.tblICInventoryReceiptCharge ReceiptCharge INNER JOIN  (
				SELECT	intInventoryReceiptChargeId
						, dblCalculatedAmount = SUM(dblCalculatedAmount) 
				FROM	tblICInventoryReceiptChargePerItem
				WHERE	intInventoryReceiptId = @intInventoryReceiptId
				GROUP BY intInventoryReceiptChargeId
			) ComputedCharges
				ON ReceiptCharge.intInventoryReceiptChargeId = ComputedCharges.intInventoryReceiptChargeId
	WHERE	ReceiptCharge.intInventoryReceiptId = @intInventoryReceiptId

END