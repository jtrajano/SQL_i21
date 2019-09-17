CREATE VIEW [dbo].[vyuAPClearingFilterTransactionNo]
AS 

SELECT 
	receipt.strReceiptNumber AS strTransactionNumber
FROM tblICInventoryReceipt receipt
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
WHERE 
	1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND receipt.ysnPosted = 1
UNION ALL
SELECT
	Shipment.strShipmentNumber
FROM dbo.tblICInventoryShipmentCharge ShipmentCharge  
INNER JOIN tblICInventoryShipment Shipment   
 ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId  
WHERE 
	Shipment.ysnPosted = 1
AND ShipmentCharge.ysnAccrue = 1 
UNION ALL
SELECT
	A.strLoadNumber
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
WHERE
	A.ysnPosted = 1 
AND A.intPurchaseSale IN (1,3) --Inbound/Drop Ship load shipment type only have AP Clearing GL Entries.
AND A.intSourceType != 1 --Source Type should not be 'None'
UNION ALL
SELECT
	A.strStorageTicket
FROM tblGRSettleStorage A
WHERE 
	A.ysnPosted = 1
And A.intParentSettleStorageId IS NOT NULL
UNION ALL
SELECT	
    refund.strRefundNo
FROM tblPATRefund refund
INNER JOIN tblPATRefundCustomer refundEntity
	ON refund.intRefundId = refundEntity.intRefundId
WHERE 
    refund.ysnPosted = 1
AND refundEntity.ysnEligibleRefund = 1