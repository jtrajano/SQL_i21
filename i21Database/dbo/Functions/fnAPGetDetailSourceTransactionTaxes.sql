CREATE FUNCTION [dbo].[fnAPGetDetailSourceTransactionTaxes]
(
	@intInventoryReceiptItemId INT,
	@intInventoryReceiptChargeId INT,
	@intInventoryShipmentChargeId INT
)
RETURNS @returntable TABLE
(
	intSourceTransactionId INT NOT NULL,
	strSourceTransaction NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	intSourceTransactionDetailId INT NOT NULL,
	intSourceTransactionTypeId INT NOT NULL,
	intSourceTaxAccountId INT NOT NULL,
	intSourceTaxGroupId INT NOT NULL,
	dblSourceTransactionTax NUMERIC(18, 6) NULL,
	strSourceTransactionType NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	strSourceModule NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL
)
AS
BEGIN
	INSERT @returntable
	--RECEIPT ITEM
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptItemId, 1, RIT.intTaxAccountId, RI.intTaxGroupId, ISNULL(RIT.dblAdjustedTax, RIT.dblTax), 'Inventory Receipt', 'Inventory'
	FROM tblICInventoryReceiptItem RI
	INNER JOIN tblICInventoryReceiptItemTax RIT ON RIT.intInventoryReceiptItemId = RI.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId AND @intInventoryReceiptChargeId IS NULL

	UNION ALL
	--RECEIPT CHARGE
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptChargeId, 2, RCT.intTaxAccountId, RC.intTaxGroupId, ISNULL(RCT.dblAdjustedTax, RCT.dblTax), 'Inventory Receipt', 'Inventory'
	FROM tblICInventoryReceiptCharge RC
	INNER JOIN tblICInventoryReceiptChargeTax RCT ON RCT.intInventoryReceiptChargeId = RC.intInventoryReceiptChargeId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RC.intInventoryReceiptId
	WHERE RC.intInventoryReceiptChargeId = @intInventoryReceiptChargeId

	UNION ALL
	--SHIPMENT CHARGE
	SELECT S.intInventoryShipmentId, S.strShipmentNumber, @intInventoryShipmentChargeId, 3, SCT.intTaxAccountId, SC.intTaxGroupId, ISNULL(SCT.dblAdjustedTax, SCT.dblTax), 'Inventory Shipment', 'Inventory'
	FROM tblICInventoryShipmentCharge SC
	INNER JOIN tblICInventoryShipmentChargeTax SCT ON SCT.intInventoryShipmentChargeId = SC.intInventoryShipmentChargeId
	INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SC.intInventoryShipmentId
	WHERE SC.intInventoryShipmentChargeId = @intInventoryShipmentChargeId

	RETURN
END
