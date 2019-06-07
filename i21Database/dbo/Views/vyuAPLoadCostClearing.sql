CREATE VIEW [dbo].[vyuAPLoadCostClearing]
AS 

SELECT
	B.intVendorEntityId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,B.intLoadDetailId
	,B.intItemId
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,B.dblAmount AS dblLoadDetailTotal
	,B.dblQuantity AS dblLoadDetailQty
	,B.intPCompanyLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblLGLoadCost C
	ON A.intLoadId = C.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intPCompanyLocationId = compLoc.intCompanyLocationId
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
			ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
ON receiptItem.intSourceId = B.intLoadDetailId
WHERE 
	A.ysnPosted = 1 
AND A.str