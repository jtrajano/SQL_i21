CREATE PROCEDURE [dbo].[uspICCalculateShipmentOtherCharges]
	@intInventoryShipmentId AS INT
AS
BEGIN

	-- Update the currency fields 
	UPDATE	ShipmentCharges
	SET		intCent = Currency.intCent
			,ysnSubCurrency = Currency.ysnSubCurrency
	FROM	dbo.tblICInventoryShipmentCharge ShipmentCharges INNER JOIN dbo.tblSMCurrency Currency
				ON ShipmentCharges.intCurrencyId = Currency.intCurrencyID
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
	FROM	dbo.tblICInventoryShipmentCharge ShipmentCharge INNER JOIN  (
				SELECT	intInventoryShipmentChargeId
						, dblCalculatedAmount = SUM(dblCalculatedAmount) 
				FROM	tblICInventoryShipmentChargePerItem
				WHERE	intInventoryShipmentId = @intInventoryShipmentId
				GROUP BY intInventoryShipmentChargeId
			) ComputedCharges
				ON ShipmentCharge.intInventoryShipmentChargeId = ComputedCharges.intInventoryShipmentChargeId
	WHERE	ShipmentCharge.intInventoryShipmentId = @intInventoryShipmentId

END