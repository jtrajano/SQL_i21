CREATE PROCEDURE [dbo].[uspICCalculateOtherCharges]
	@intInventoryReceiptId AS INT
AS
BEGIN

	-- Update the currency fields 
	UPDATE	ReceiptCharges
	SET		intCent = Currency.intCent
			,ysnSubCurrency = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ReceiptCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						0 
					ELSE 
						Currency.ysnSubCurrency
				END 
			,intCurrencyId = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ReceiptCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						MainCurrency.intCurrencyID
					ELSE 
						ReceiptCharges.intCurrencyId
				END 
			,dblAmount = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ReceiptCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						ReceiptCharges.dblAmount / CASE WHEN ISNULL(Currency.intCent, 0) = 0  THEN 1 ELSE Currency.intCent END 
					ELSE 
						ReceiptCharges.dblAmount
				END 
	FROM	dbo.tblICInventoryReceiptCharge ReceiptCharges INNER JOIN dbo.tblSMCurrency Currency
				ON ReceiptCharges.intCurrencyId = Currency.intCurrencyID
			LEFT JOIN dbo.tblSMCurrency MainCurrency
				ON MainCurrency.intCurrencyID = Currency.intMainCurrencyId
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
			,dblQuantity = ISNULL(NULLIF(ComputedCharges.dblCalculatedQty, 0), 1) 

	FROM	dbo.tblICInventoryReceiptCharge ReceiptCharge INNER JOIN  (
				SELECT	intInventoryReceiptChargeId
						, dblCalculatedAmount = SUM(dblCalculatedAmount) 
						, dblCalculatedQty = SUM(ISNULL(dblCalculatedQty, 0)) 
				FROM	tblICInventoryReceiptChargePerItem
				WHERE	intInventoryReceiptId = @intInventoryReceiptId
				GROUP BY intInventoryReceiptChargeId
			) ComputedCharges
				ON ReceiptCharge.intInventoryReceiptChargeId = ComputedCharges.intInventoryReceiptChargeId
	WHERE	ReceiptCharge.intInventoryReceiptId = @intInventoryReceiptId

END