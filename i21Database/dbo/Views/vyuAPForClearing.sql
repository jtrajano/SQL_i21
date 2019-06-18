CREATE VIEW [dbo].[vyuAPForClearing]
AS 

--Receipt item,
SELECT	
    receipt.intEntityVendorId
    ,receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber
    ,receipt.intInventoryReceiptId
    ,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
    ,receiptItem.intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
    ,ROUND(
        CASE	
            WHEN receiptItem.intWeightUOMId IS NULL THEN 
                ISNULL(receiptItem.dblOpenReceive, 0) 
            ELSE 
                CASE 
                    WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
                        ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, receiptItem.dblOpenReceive), 0)
                    ELSE 
                        CASE WHEN intSourceType = 2 
                            THEN CAST(ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intWeightUOMId,receiptItem.intUnitMeasureId , receiptItem.dblNet), 0) AS DECIMAL(18,2))
                        ELSE ISNULL(receiptItem.dblNet, 0) 
                        END
                END 
        END
        * dbo.fnCalculateCostBetweenUOM(ISNULL(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId), ISNULL(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId), receiptItem.dblUnitCost)
        * (
            CASE 
                WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
                    1 / ISNULL(receipt.intSubCurrencyCents, 1) 
                ELSE 
                    1 
            END 
        )
        , 2
    ) AS dblReceiptTotal
    ,CASE	
        WHEN receiptItem.intWeightUOMId IS NULL THEN 
            ISNULL(receiptItem.dblOpenReceive, 0) 
        ELSE 
            CASE 
                WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
                    ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
                ELSE 
                    ISNULL(receiptItem.dblNet, 0) 
            END 
    END AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(CASE WHEN receiptItem.intOwnershipType = 2 THEN 0 ELSE 1 END AS BIT) AS ysnAllowVoucher
    ,APClearing.intAccountId
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
OUTER APPLY (
	SELECT TOP 1
		ga.strAccountId
		,ga.intAccountId
	FROM 
		tblICInventoryTransaction t INNER JOIN tblGLDetail gd
			ON t.strTransactionId = gd.strTransactionId
			AND t.strBatchId = gd.strBatchId
			AND t.intInventoryTransactionId = gd.intJournalLineNo
		INNER JOIN tblGLAccount ga
			ON ga.intAccountId = gd.intAccountId
		INNER JOIN tblGLAccountGroup ag
			ON ag.intAccountGroupId = ga.intAccountGroupId
	WHERE
		t.strTransactionId = receipt.strReceiptNumber
		AND t.intTransactionId = receipt.intInventoryReceiptId
		AND t.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
		AND t.intItemId = receiptItem.intItemId
		AND ag.strAccountType = 'Liability'
		AND t.ysnIsUnposted = 0 
) APClearing
WHERE 
    receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
--DO NOT INCLUDE RECEIPT WHICH USES IN-TRANSIT AS GL
--CLEARING FOR THIS IS ALREADY PART OF vyuAPLoadClearing
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND receipt.ysnPosted = 1
UNION ALL
--Vouchers for receipt items
SELECT
    bill.intEntityVendorId
    ,bill.dtmDate AS dtmDate
    ,receipt.strReceiptNumber
    ,receipt.intInventoryReceiptId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,billDetail.intInventoryReceiptItemId
    ,billDetail.intItemId
    ,--billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal --comment temporarily, we need to use the cost of receipt until cost adjustment on report added
    ISNULL((CASE WHEN billDetail.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
            THEN (CASE 
                    WHEN billDetail.intWeightUOMId > 0 
                        THEN CAST(receiptItem.dblUnitCost / ISNULL(bill.intSubCurrencyCents,1)  * billDetail.dblNetWeight * billDetail.dblWeightUnitQty / ISNULL(billDetail.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((billDetail.dblQtyReceived) *  (receiptItem.dblUnitCost / ISNULL(bill.intSubCurrencyCents,1))  * (billDetail.dblUnitQty/ ISNULL(billDetail.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((billDetail.dblQtyReceived) * (receiptItem.dblUnitCost / ISNULL(bill.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
                END)
            ELSE (CASE 
                    WHEN billDetail.intWeightUOMId > 0 --CHECK IF SUB-CURRENCY
                        THEN CAST(receiptItem.dblUnitCost  * billDetail.dblNetWeight * billDetail.dblWeightUnitQty / ISNULL(billDetail.dblCostUnitQty,1) AS DECIMAL(18,2)) --Formula With Weight UOM
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((billDetail.dblQtyReceived) *  (receiptItem.dblUnitCost)  * (billDetail.dblUnitQty/ ISNULL(billDetail.dblCostUnitQty,1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((billDetail.dblQtyReceived) * (receiptItem.dblUnitCost)  AS DECIMAL(18,2))  --Orig Calculation
                END)
            END),0)	AS dblVoucherTotal
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
    ,ROUND(
        CASE	
            WHEN receiptItem.intWeightUOMId IS NULL THEN 
                ISNULL(receiptItem.dblOpenReceive, 0) 
            ELSE 
                CASE 
                    WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
                        ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, receiptItem.dblOpenReceive), 0)
                    ELSE 
                        CASE WHEN intSourceType = 2 
                            THEN CAST(ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intWeightUOMId,receiptItem.intUnitMeasureId , receiptItem.dblNet), 0) AS DECIMAL(18,2))
                        ELSE ISNULL(receiptItem.dblNet, 0) 
                        END
                END 
        END
        * dbo.fnCalculateCostBetweenUOM(ISNULL(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId), ISNULL(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId), receiptItem.dblUnitCost)
        * (
            CASE 
                WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
                    1 / ISNULL(receipt.intSubCurrencyCents, 1) 
                ELSE 
                    1 
            END 
        )
        , 2
    ) AS dblReceiptTotal
    ,CASE	
        WHEN receiptItem.intWeightUOMId IS NULL THEN 
            ISNULL(receiptItem.dblOpenReceive, 0) 
        ELSE 
            CASE 
                WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
                    ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
                ELSE 
                    ISNULL(receiptItem.dblNet, 0) 
            END 
    END AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
    ,billDetail.intAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON billDetail.intInventoryReceiptItemId  = receiptItem.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
WHERE 
    billDetail.intInventoryReceiptItemId IS NOT NULL
AND billDetail.intInventoryReceiptChargeId IS NULL
AND bill.ysnPosted = 1 --voucher should be posted in 18.3
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
GO

