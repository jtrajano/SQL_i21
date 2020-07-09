CREATE VIEW [dbo].[vyuAPBillDetailSource]
AS

--SELECT * FROM (
	SELECT
	--ROW_NUMBER() OVER(ORDER BY A.intBillDetailId) AS intBillDetailSourceId
	--Items.*
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = purchase.strPurchaseOrderNumber
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			strPurchaseOrderNumber
		FROM tblPOPurchase po
		INNER JOIN tblPOPurchaseDetail poDetail ON po.intPurchaseId = poDetail.intPurchaseId
		WHERE poDetail.intPurchaseDetailId = voucherDetail.intPurchaseDetailId
	) purchase
	WHERE voucherDetail.intInventoryReceiptItemId IS NULL AND voucherDetail.intPurchaseDetailId > 0
	UNION ALL
	SELECT
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = receipt.strReceiptNumber
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			strReceiptNumber
		FROM tblICInventoryReceipt receipt
		INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
		WHERE receiptItem.intInventoryReceiptItemId = voucherDetail.intInventoryReceiptItemId
	) receipt
	WHERE voucherDetail.intInventoryReceiptItemId > 0 AND voucherDetail.intInventoryShipmentChargeId IS NULL
	UNION ALL
	SELECT
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = charge.strReceiptNumber
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			strReceiptNumber
		FROM tblICInventoryReceipt receipt
		INNER JOIN tblICInventoryReceiptCharge receiptChrage ON receipt.intInventoryReceiptId = receiptChrage.intInventoryReceiptId
		WHERE receiptChrage.intInventoryReceiptChargeId = voucherDetail.intInventoryReceiptChargeId
	) charge
	WHERE voucherDetail.intInventoryReceiptChargeId > 0 AND voucherDetail.intInventoryReceiptItemId IS NULL AND voucherDetail.intInventoryShipmentChargeId IS NULL
	UNION ALL
	SELECT
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = shipment.strShipmentNumber
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			strShipmentNumber
		FROM dbo.tblICInventoryShipment shipment
		INNER JOIN dbo.tblICInventoryShipmentCharge shipmentCharge ON shipment.intInventoryShipmentId = shipmentCharge.intInventoryShipmentId
		WHERE shipmentCharge.intInventoryShipmentChargeId = voucherDetail.intInventoryShipmentChargeId
	) shipment
	WHERE voucherDetail.intInventoryShipmentChargeId > 0
	UNION ALL
	SELECT
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = ticket.strTicketNumber
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			ticket.strTicketNumber
		FROM dbo.tblHDTicket ticket
		WHERE ticket.intTicketId = voucherDetail.intTicketId
	) ticket
	WHERE voucherDetail.intTicketId is not null and voucherDetail.intTicketId > 0
	UNION ALL
	SELECT
	voucherDetail.intBillDetailId
	,intInventoryReceiptItemId = NULL
	,intPurchaseDetailId = NULL
	,strSourceNumber = storage.strStorageTicket
	FROM tblAPBillDetail voucherDetail
	OUTER APPLY (
		SELECT TOP 1
			storage.strStorageTicket
			  FROM tblGRSettleStorage storage
			  WHERE storage.intSettleStorageId = voucherDetail.intSettleStorageId
		--INNER JOIN tblGRSettleStorageTicket ticket ON storage.intSettleStorageId = ticket.intSettleStorageId
		--WHERE storage.intParentSettleStorageId IS NULL AND ticket.intCustomerStorageId = voucherDetail.intCustomerStorageId
	) storage
	WHERE voucherDetail.intCustomerStorageId IS NOT NULL AND voucherDetail.intCustomerStorageId > 0
	--INNER JOIN
	--(
	--	--PO Items
	--	SELECT
	--		tblReceived.strReceiptNumber AS strSourceNumber
	--		,B.intPurchaseDetailId
	--		,tblReceived.intInventoryReceiptItemId
	--	FROM tblPOPurchase A
	--	INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	--	CROSS APPLY 
	--	(
	--		SELECT
	--			A1.strReceiptNumber
	--			,B1.intInventoryReceiptItemId
	--		FROM tblICInventoryReceipt A1
	--			INNER JOIN tblICInventoryReceiptItem B1 ON A1.intInventoryReceiptId = B1.intInventoryReceiptId
	--		WHERE A1.ysnPosted = 1
	--		AND B.intPurchaseDetailId = B1.intLineNo
	--		GROUP BY
	--			A1.strReceiptNumber
	--			,B1.intInventoryReceiptItemId
	--	) as tblReceived
	--	UNION ALL
	--	--Miscellaneous items
	--	SELECT
	--		A.strPurchaseOrderNumber
	--		,B.intPurchaseDetailId
	--		,NULL
	--	FROM tblPOPurchase A
	--		INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
	--		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	--	WHERE C.strType IN ('Service','Software','Non-Inventory','Other Charge')

	--	UNION ALL
	--	--DIRECT TYPE
	--	SELECT
	--		A.strReceiptNumber
	--		,NULL
	--		,B.intInventoryReceiptItemId
	--	FROM tblICInventoryReceipt A
	--	INNER JOIN tblICInventoryReceiptItem B
	--		ON A.intInventoryReceiptId = B.intInventoryReceiptId
	--	WHERE A.strReceiptType IN ('Direct','Purchase Contract','Inventory Return') AND A.ysnPosted = 1
	--) Items
	--ON (voucherDetail.intPurchaseDetailId = Items.intPurchaseDetailId AND voucherDetail.intInventoryReceiptItemId IS NULL)
	--OR (voucherDetail.intInventoryReceiptItemId = Items.intInventoryReceiptItemId AND voucherDetail.intPurchaseDetailId IS NULL)
	--OR (voucherDetail.intInventoryReceiptItemId = Items.intInventoryReceiptItemId AND voucherDetail.intPurchaseDetailId = Items.intPurchaseDetailId)
  
	--UNION ALL
	----IS TYPE
	--SELECT
	--A.strShipmentNumber AS strSourceNumber
	--,NULL
	--,NULL  
	--,C.intBillDetailId 
	--FROM dbo.tblICInventoryShipment A  
	--INNER JOIN dbo.tblICInventoryShipmentCharge B ON B.intInventoryShipmentId = A.intInventoryShipmentId
	--INNER JOIN dbo.tblAPBillDetail C ON B.intInventoryShipmentChargeId = C.intInventoryShipmentChargeId
--) BillDetailSource
GO