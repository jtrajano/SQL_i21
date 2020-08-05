CREATE VIEW [dbo].[vyuAPPatClearing]
AS 

--Receipt item,
SELECT	
    refundEntity.intCustomerId AS intEntityVendorId
    ,refund.dtmRefundDate AS dtmDate
    ,refund.strRefundNo AS strTransactionNumber
    ,refund.intRefundId
    ,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
    ,refundEntity.intRefundCustomerId
    ,NULL AS intItemId
    ,NULL AS intItemUOMId
    ,NULL AS strUOM
    ,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
    ,refundEntity.dblCashRefund AS dblRefundTotal
    ,1 AS dblRefundQty
    ,NULL AS intLocationId
    ,NULL AS strLocationName
    ,CAST(0 AS BIT) AS ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblPATRefund refund
INNER JOIN tblPATRefundCustomer refundEntity
	ON refund.intRefundId = refundEntity.intRefundId
CROSS APPLY (
	SELECT TOP 1
		ga.strAccountId
		,ga.intAccountId
	FROM 
		tblGLDetail gd
		INNER JOIN tblGLAccount ga
			ON ga.intAccountId = gd.intAccountId
		INNER JOIN vyuGLAccountDetail ag
			ON ag.intAccountId = ga.intAccountId AND ag.intAccountCategoryId = 45
	WHERE
            refund.strRefundNo = gd.strTransactionId
        AND refund.intRefundId = gd.intTransactionId
		AND gd.ysnIsUnposted = 0 
) APClearing
WHERE 
    refund.ysnPosted = 1
AND refundEntity.ysnEligibleRefund = 1
UNION ALL
--Vouchers for receipt items
SELECT
    bill.intEntityVendorId
    ,bill.dtmDate AS dtmDate
    ,refund.strRefundNo
    ,refund.intRefundId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,refundEntity.intRefundCustomerId
    ,NULL AS intItemId
    ,NULL AS intItemUOMId
    ,NULL AS strUOM
    ,ISNULL((CASE WHEN billDetail.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
            THEN (CASE 
                    WHEN billDetail.intWeightUOMId > 0 
                        THEN CAST(billDetail.dblCost / ISNULL(bill.intSubCurrencyCents,1)  * billDetail.dblNetWeight * billDetail.dblWeightUnitQty / ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1) AS DECIMAL(18,2)) --Formula With Weight UOM
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((billDetail.dblQtyReceived) *  (billDetail.dblCost / ISNULL(bill.intSubCurrencyCents,1))  * (billDetail.dblUnitQty/ ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((billDetail.dblQtyReceived) * (billDetail.dblCost / ISNULL(bill.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
                END)
            ELSE (CASE 
                    WHEN billDetail.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
                        THEN CAST(billDetail.dblCost  * billDetail.dblNetWeight * billDetail.dblWeightUnitQty / ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1) AS DECIMAL(18,2)) --Formula With Weight UOM
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((billDetail.dblQtyReceived) *  (billDetail.dblCost)  * (billDetail.dblUnitQty/ ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((billDetail.dblQtyReceived) * (billDetail.dblCost)  AS DECIMAL(18,2))  --Orig Calculation
                END)
            END),0)	
    *
    (
        CASE 
        WHEN bill.intTransactionType = 3
        THEN -1
        ELSE 1
        END
    )
    AS dblVoucherTotal
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
    END 
    *
    (
        CASE 
        WHEN bill.intTransactionType = 3
        THEN -1
        ELSE 1
        END
    )
    AS dblVoucherQty
    ,0 AS dblRefundTotal
    ,0 AS dblRefundQty
    ,NULL AS intLocationId
    ,NULL AS strLocationName
    ,CAST(0 AS BIT) ysnAllowVoucher
    ,accnt.intAccountId
	,accnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN (
     tblPATRefund refund
        INNER JOIN tblPATRefundCustomer refundEntity
	        ON refund.intRefundId = refundEntity.intRefundId
) ON refundEntity.intBillId = bill.intBillId
INNER JOIN vyuGLAccountDetail accnt
    ON billDetail.intAccountId = accnt.intAccountId AND accnt.intAccountCategoryId = 45
WHERE bill.ysnPosted = 1
GO


