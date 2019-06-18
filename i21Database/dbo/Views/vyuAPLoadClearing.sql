CREATE VIEW [dbo].[vyuAPLoadClearing]
AS 

--Item for Clearing
SELECT
	B.intVendorEntityId AS intEntityVendorId
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
	,CASE WHEN B.dblNet != 0 THEN B.dblNet ELSE B.dblQuantity END AS dblLoadDetailQty
	,B.intPCompanyLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
	,intAccountId = GL.intAccountId
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intPCompanyLocationId = compLoc.intCompanyLocationId
CROSS APPLY (SELECT TOP 1 GLD.intAccountId FROM tblGLDetail GLD
				INNER JOIN tblGLAccount GLA ON GLA.intAccountId = GLD.intAccountId
				INNER JOIN tblGLAccountGroup GLAG ON GLAG.intAccountGroupId = GLA.intAccountGroupId
				INNER JOIN tblGLAccountCategory GLAC ON GLAC.intAccountCategoryId = GLAG.intAccountCategoryId
			WHERE intTransactionId = A.intLoadId AND strTransactionId = A.strLoadNumber AND ysnIsUnposted = 0
				AND strCode IN ('LG', 'IC') AND GLAC.strAccountCategory = 'AP Clearing') GL
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2 AND receipt.ysnPosted = 1)
	ON receiptItem.intSourceId = B.intLoadDetailId
WHERE 
	A.ysnPosted = 1 
AND A.intPurchaseSale IN (1,3) --Inbound/Drop Ship load shipment type only have AP Clearing GL Entries.
AND A.intSourceType != 1 --Source Type should not be 'None'
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
	,CASE WHEN ld.dblNet != 0 THEN ld.dblNet ELSE ld.dblQuantity END AS dblLoadDetailQty
    ,bill.intShipToId
    ,compLoc.strLocationName
    ,CAST((CASE WHEN ri.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
	,billDetail.intAccountId
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