CREATE VIEW [dbo].[vyuAPLoadClearing]
AS 

--Item for Clearing
SELECT
	B.intVendorEntityId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,B.intLoadDetailId
	,receiptItem.intInventoryReceiptItemId
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
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intPCompanyLocationId = compLoc.intCompanyLocationId
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2)
	ON receiptItem.intSourceId = B.intLoadDetailId
WHERE 
	A.ysnPosted = 1 
UNION ALL
--Voucher For Load Detail Item
SELECT
    bill.intEntityVendorId
    ,bill.dtmDate AS dtmDate
    ,l.strLoadNumber
    ,l.intLoadId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,billDetail.intLoadDetailId
	,ri.intInventoryReceiptItemId
    ,billDetail.intItemId
    ,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
    ,CASE 
        WHEN billDetail.intWeightUOMId IS NULL THEN 
            ISNULL(billDetail.dblQtyReceived, 0) 
        ELSE 
            CASE 
                WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
                    ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
                ELSE 
                    ISNULL(billDetail.dblNetWeight, 0) 
            END
    END AS dblVoucherQty
    ,ld.dblAmount AS dblLoadDetailTotal
	,ld.dblQuantity AS dblLoadDetailQty
    ,bill.intShipToId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
INNER JOIN tblLGLoadDetail ld
    ON billDetail.intLoadDetailId = ld.intLoadDetailId
INNER JOIN tblLGLoad l
	ON ld.intLoadId = l.intLoadId
LEFT JOIN tblICInventoryReceiptItem ri
	ON billDetail.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
WHERE 
    billDetail.intLoadDetailId IS NOT NULL
AND bill.ysnPosted = 1