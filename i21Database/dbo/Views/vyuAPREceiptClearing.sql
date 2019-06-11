CREATE VIEW [dbo].[vyuAPReceiptClearing]
AS 


--Vouchers for receipt items
SELECT
    bill.dtmDate AS dtmDate
    ,receipt.strReceiptNumber
    ,receipt.intInventoryReceiptId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,billDetail.intInventoryReceiptItemId
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
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON billDetail.intInventoryReceiptItemId  = receiptItem.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
WHERE billDetail.intInventoryReceiptItemId IS NOT NULL
UNION ALL
SELECT	
    receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber
    ,receipt.intInventoryReceiptId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,receiptItem.intInventoryReceiptItemId
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
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblAPBillDetail billDetail
    ON billDetail.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
INNER JOIN tblAPBill bill
    ON bill.intBillId = billDetail.intBillId
WHERE 
    receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
GO

