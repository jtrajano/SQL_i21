CREATE FUNCTION [dbo].[fnAPGetDetailSourceTransaction]
(
	@intInventoryReceiptItemId INT,
	@intInventoryReceiptChargeId INT,
	@intInventoryShipmentChargeId INT,
	@intLoadDetailId INT,
	@intCustomerStorageId INT,
	@intSettleStorageId INT,
	@intBillId INT,
	@intItemId INT
)
RETURNS @returntable TABLE
(
	intSourceTransactionId INT NOT NULL,
	strSourceTransaction NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	intSourceTransactionDetailId INT NOT NULL,
	intSourceTransactionTypeId INT NOT NULL
)
AS
BEGIN
	INSERT @returntable
	--RECEIPT ITEM
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptItemId, 1
	FROM tblICInventoryReceiptItem RI
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId

	UNION ALL
	--RECEIPT CHARGE
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptChargeId, 2
	FROM tblICInventoryReceiptCharge RC
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RC.intInventoryReceiptId
	WHERE RC.intInventoryReceiptChargeId = @intInventoryReceiptChargeId

	UNION ALL
	--SHIPMENT CHARGE
	SELECT S.intInventoryShipmentId, S.strShipmentNumber, @intInventoryShipmentChargeId, 3
	FROM tblICInventoryShipmentCharge SC
	INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SC.intInventoryShipmentId
	WHERE SC.intInventoryShipmentChargeId = @intInventoryShipmentChargeId

	UNION ALL
	--LOAD
	SELECT L.intLoadId, L.strLoadNumber, @intLoadDetailId, 4
	FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	WHERE LD.intLoadDetailId = @intLoadDetailId AND LD.intItemId = @intItemId

	UNION ALL
	--LOAD COST
	SELECT L.intLoadId, L.strLoadNumber, @intLoadDetailId, 5
	FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	INNER JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId
	WHERE LD.intLoadDetailId = @intLoadDetailId AND LC.intItemId = @intItemId

	UNION ALL
	--GRAIN
	SELECT SS.intSettleStorageId, SS.strStorageTicket, @intCustomerStorageId, 6
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRSettleStorageTicket ST ON ST.intCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = ST.intSettleStorageId
	WHERE CS.intCustomerStorageId = @intCustomerStorageId AND SS.intSettleStorageId = @intSettleStorageId AND CS.intItemId = @intItemId

	--UNION ALL
	--GRAIN TRANSFER


	--UNION ALL
	--GRAIN TRANSFER CHARGE

	UNION ALL
	--PAT
	SELECT R.intRefundId, R.strRefundNo, RC.intRefundCustomerId, 9
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R ON R.intRefundId = RC.intRefundId
	WHERE RC.intBillId = @intBillId

	RETURN
END
