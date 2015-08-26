CREATE PROCEDURE [dbo].[uspICCalculateOtherCharges]
	@intInventoryReceiptId AS INT
AS
BEGIN

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

	UPDATE tblICInventoryReceiptCharge
	SET dblAmount = ComputedCharges.dblCalculatedAmount
	FROM (
		SELECT intInventoryReceiptChargeId, dblCalculatedAmount = SUM(dblCalculatedAmount) FROM tblICInventoryReceiptChargePerItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId
		GROUP BY intInventoryReceiptChargeId
		) ComputedCharges
		WHERE tblICInventoryReceiptCharge.intInventoryReceiptChargeId = ComputedCharges.intInventoryReceiptChargeId
	

END