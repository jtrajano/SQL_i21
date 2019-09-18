CREATE PROCEDURE [dbo].[uspICCalculateShipmentOtherCharges]
	@intInventoryShipmentId AS INT
AS
BEGIN
	DECLARE @intReturnValue AS INT

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
		EXEC @intReturnValue = dbo.uspICCalculateInventoryShipmentOtherCharges
			@intInventoryShipmentId

		IF @intReturnValue < 0 GOTO _Exit_With_Error
	END 

	-- Calculate the surcharges
	BEGIN 
		EXEC @intReturnValue = dbo.uspICCalculateInventoryShipmentSurchargeOnOtherCharges
			@intInventoryShipmentId

		IF @intReturnValue < 0 GOTO _Exit_With_Error
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

GOTO _Exit 
_Exit_With_Error:
	RETURN @intReturnValue

_Exit: