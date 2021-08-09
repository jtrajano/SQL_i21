CREATE FUNCTION [dbo].[fnAPGetDetailSourceTransaction]
(
	@intInventoryReceiptItemId INT,
	@intInventoryReceiptChargeId INT,
	@intInventoryShipmentChargeId INT,
	@intLoadDetailId INT,
	@intLoadShipmentCostId INT,
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
	intSourceTransactionTypeId INT NOT NULL,
	dblSourceTransactionQuantity NUMERIC(18, 6) NULL,
	dblSourceTransactionAmount NUMERIC(18, 6) NULL,
	dblSourceTransactionTax NUMERIC(18, 6) NULL,
	strSourceTransactionType NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL,
	strSourceModule NVARCHAR(55) COLLATE Latin1_General_CI_AS NOT NULL
)
AS
BEGIN
	INSERT @returntable
	--RECEIPT ITEM
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptItemId, 1, NULL, NULL, RI.dblTax, 'Inventory Receipt', 'Inventory'
	FROM tblICInventoryReceiptItem RI
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId AND @intInventoryReceiptChargeId IS NULL

	UNION ALL
	--RECEIPT CHARGE
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, @intInventoryReceiptChargeId, 2, NULL, NULL, RC.dblTax, 'Inventory Receipt', 'Inventory'
	FROM tblICInventoryReceiptCharge RC
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RC.intInventoryReceiptId
	WHERE RC.intInventoryReceiptChargeId = @intInventoryReceiptChargeId

	UNION ALL
	--SHIPMENT CHARGE
	SELECT S.intInventoryShipmentId, S.strShipmentNumber, @intInventoryShipmentChargeId, 3, NULL, NULL, SC.dblTax, 'Inventory Shipment', 'Inventory'
	FROM tblICInventoryShipmentCharge SC
	INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SC.intInventoryShipmentId
	WHERE SC.intInventoryShipmentChargeId = @intInventoryShipmentChargeId

	UNION ALL
	--LOAD
	SELECT L.intLoadId, L.strLoadNumber, @intLoadDetailId, 4, NULL, NULL, NULL, 'Load', 'Logistics'
	FROM tblLGLoadDetail LD
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	WHERE LD.intLoadDetailId = @intLoadDetailId AND LD.intItemId = @intItemId AND @intLoadShipmentCostId IS NULL

	UNION ALL
	--LOAD COST
	SELECT L.intLoadId, L.strLoadNumber, @intLoadShipmentCostId, 5, NULL, NULL, NULL, 'Load', 'Logistics'
	FROM tblLGLoadCost LC
	INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	WHERE LC.intLoadCostId = @intLoadShipmentCostId AND LC.intItemId = @intItemId

	UNION ALL
	--GRAIN SETTLE
	SELECT SS.intSettleStorageId, SS.strStorageTicket, @intCustomerStorageId, 6, NULL, NULL, NULL, 'Storage', 'Grain'
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 0
	INNER JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SST.intSettleStorageId
	WHERE CS.intCustomerStorageId = @intCustomerStorageId AND SS.intSettleStorageId = @intSettleStorageId

	UNION ALL
	--GRAIN DELIVERY SHEET
	SELECT R.intInventoryReceiptId, R.strReceiptNumber, RI.intInventoryReceiptItemId, 1, SIR.dblTransactionUnits, NULL, RI.dblTax, 'Delivery Sheet', 'Grain'
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
	INNER JOIN tblGRStorageInventoryReceipt SIR ON SIR.intCustomerStorageId = CS.intCustomerStorageId AND SIR.ysnUnposted = 0
	INNER JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = SIR.intInventoryReceiptItemId AND RI.intItemId = @intItemId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE CS.ysnTransferStorage = 0 AND CS.intCustomerStorageId = @intCustomerStorageId AND SIR.intSettleStorageId = @intSettleStorageId
	
	UNION ALL
	--GRAIN TRANSFER ITEM
	SELECT TS.intTransferStorageId, TS.strTransferStorageTicket, TSR.intTransferStorageReferenceId, 7, NULL, NULL, NULL, 'Transfer', 'Grain'
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
	INNER JOIN tblGRTransferStorageReference TSR ON TSR.intToCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblGRTransferStorage TS ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblICItem I ON I.intItemId = @intItemId AND I.strType = 'Inventory'
	WHERE CS.ysnTransferStorage = 1 AND CS.intCustomerStorageId = @intCustomerStorageId

	UNION ALL
	--GRAIN TRANSFER CHARGE
	SELECT TS.intTransferStorageId, TS.strTransferStorageTicket, TSR.intTransferStorageReferenceId, 8, NULL, NULL, NULL, 'Transfer', 'Grain'
	FROM tblGRCustomerStorage CS
	INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
	INNER JOIN tblGRTransferStorageReference TSR ON TSR.intToCustomerStorageId = CS.intCustomerStorageId
	INNER JOIN tblGRTransferStorage TS ON TS.intTransferStorageId = TSR.intTransferStorageId
	INNER JOIN tblICItem I ON I.intItemId = @intItemId AND I.strType != 'Inventory'
	WHERE CS.ysnTransferStorage = 1 AND CS.intCustomerStorageId = @intCustomerStorageId

	UNION ALL
	--PAT
	SELECT R.intRefundId, R.strRefundNo, RC.intRefundCustomerId, 9, NULL, NULL, NULL, 'Refund', 'Patronage'
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R ON R.intRefundId = RC.intRefundId
	WHERE RC.intBillId = @intBillId

	RETURN
END
