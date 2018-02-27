CREATE PROCEDURE [dbo].[uspICCalculateShipmentOtherCharges]
	@intInventoryShipmentId AS INT
AS
BEGIN

	-- Update the currency fields 
	UPDATE	ShipmentCharges
	SET		intCent = Currency.intCent
			,ysnSubCurrency = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ShipmentCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						0 
					ELSE 
						Currency.ysnSubCurrency
				END 
			,intCurrencyId = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ShipmentCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						MainCurrency.intCurrencyID
					ELSE 
						ShipmentCharges.intCurrencyId
				END 
			,dblAmount = 
				CASE 
					WHEN Currency.ysnSubCurrency = 1 AND ShipmentCharges.strCostMethod = 'Amount' AND MainCurrency.intCurrencyID IS NOT NULL THEN 
						ShipmentCharges.dblAmount / CASE WHEN ISNULL(Currency.intCent, 0) = 0  THEN 1 ELSE Currency.intCent END 
					ELSE 
						ShipmentCharges.dblAmount
				END 
	FROM	dbo.tblICInventoryShipmentCharge ShipmentCharges INNER JOIN dbo.tblSMCurrency Currency
				ON ShipmentCharges.intCurrencyId = Currency.intCurrencyID
			LEFT JOIN dbo.tblSMCurrency MainCurrency
				ON MainCurrency.intCurrencyID = Currency.intMainCurrencyId
	WHERE	ShipmentCharges.intInventoryShipmentId = @intInventoryShipmentId

	-- Calculate the other charges. 
	BEGIN 
		-- Calculate the other charges. 
		EXEC dbo.uspICCalculateInventoryShipmentOtherCharges
			@intInventoryShipmentId
	END 

	-- Calculate the surcharges
	BEGIN 
		EXEC dbo.uspICCalculateInventoryShipmentSurchargeOnOtherCharges
			@intInventoryShipmentId
	END

	UPDATE	ShipmentCharge
	SET		dblAmount = ROUND(	
							ISNULL(ComputedCharges.dblCalculatedAmount, 0)
							/ 
							CASE	WHEN ShipmentCharge.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(ShipmentCharge.intCent, 1) <> 0 THEN ISNULL(ShipmentCharge.intCent, 1) ELSE 1 END 
									ELSE 
										1
							END 
						, 2)
			,dblQuantity = ISNULL(NULLIF(ComputedCharges.dblCalculatedQty, 0), 1) 

	FROM	dbo.tblICInventoryShipmentCharge ShipmentCharge INNER JOIN  (
				SELECT	intInventoryShipmentChargeId
						, dblCalculatedAmount = SUM(dblCalculatedAmount) 
						, dblCalculatedQty = SUM(ISNULL(dblCalculatedQty, 0)) 
				FROM	tblICInventoryShipmentChargePerItem
				WHERE	intInventoryShipmentId = @intInventoryShipmentId
				GROUP BY intInventoryShipmentChargeId
			) ComputedCharges
				ON ShipmentCharge.intInventoryShipmentChargeId = ComputedCharges.intInventoryShipmentChargeId
	WHERE	ShipmentCharge.intInventoryShipmentId = @intInventoryShipmentId

END