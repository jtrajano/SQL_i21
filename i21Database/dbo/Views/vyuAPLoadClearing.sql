CREATE VIEW [dbo].[vyuAPLoadClearing]
AS 

--Item for Clearing
SELECT
	B.intVendorEntityId AS intEntityVendorId
	,A.dtmPostedDate AS dtmDate
	,A.strLoadNumber AS strTransactionNumber
	,A.intLoadId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,B.intLoadDetailId
	,receiptItem.intInventoryReceiptItemId
	,B.intItemId
    ,B.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,ISNULL(B.dblAmount,0) AS dblLoadDetailTotal
	,CASE WHEN B.dblNet != 0 THEN B.dblNet ELSE B.dblQuantity END AS dblLoadDetailQty
	,B.intPCompanyLocationId AS intLocationId
	,compLoc.strLocationName
	,CAST((CASE WHEN receiptItem.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
    ,GL.intAccountId
	,GL.strAccountId
FROM tblLGLoad A
INNER JOIN tblLGLoadDetail B
	ON A.intLoadId = B.intLoadId
INNER JOIN tblSMCompanyLocation compLoc
    ON B.intPCompanyLocationId = compLoc.intCompanyLocationId
INNER JOIN
(
    SELECT 
        GLD.intAccountId
        ,GLAcc.strAccountId 
        ,GLD.intTransactionId
        ,GLD.strTransactionId
        ,GLD.intJournalLineNo
    FROM tblGLDetail GLD
    INNER JOIN vyuGLAccountDetail GLAcc ON GLD.intAccountId = GLAcc.intAccountId
    WHERE 
        ysnIsUnposted = 0
    AND GLD.strCode IN ('LG') AND GLAcc.intAccountCategoryId = 45
) GL
    ON
        GL.intTransactionId = A.intLoadId 
    AND GL.strTransactionId = A.strLoadNumber
    AND GL.intJournalLineNo = B.intLoadDetailId
LEFT JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt
				ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId AND receipt.intSourceType = 2 AND receipt.ysnPosted = 1)
	ON receiptItem.intSourceId = B.intLoadDetailId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = B.intItemUOMId
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
    ,ld.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
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
    ,0 AS dblLoadDetailTotal
    ,0 AS dblLoadDetailQty
    -- ,ISNULL(ld.dblAmount,0) AS dblLoadDetailTotal
	-- ,CASE WHEN ld.dblNet != 0 THEN ld.dblNet ELSE ld.dblQuantity END AS dblLoadDetailQty
    ,bill.intShipToId
    ,compLoc.strLocationName
    ,CAST((CASE WHEN ri.intInventoryReceiptItemId > 0 THEN 0 ELSE 1 END) AS BIT) ysnAllowVoucher --allow voucher if there is no receipt
    ,accnt.intAccountId
	,accnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
INNER JOIN tblLGLoadDetail ld
    ON billDetail.intLoadDetailId = ld.intLoadDetailId AND billDetail.intItemId = ld.intItemId
INNER JOIN tblLGLoad l
	ON ld.intLoadId = l.intLoadId
INNER JOIN tblGLAccount accnt
    ON accnt.intAccountId = billDetail.intAccountId
LEFT JOIN tblICInventoryReceiptItem ri
	ON billDetail.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = ld.intItemUOMId
WHERE 
    billDetail.intLoadDetailId IS NOT NULL
AND bill.ysnPosted = 1