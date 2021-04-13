﻿CREATE VIEW [dbo].[vyuAPReceiptClearing]
AS 

--Receipt item,
SELECT	
    receipt.intEntityVendorId
    ,receipt.dtmReceiptDate AS dtmDate
    ,receipt.strReceiptNumber AS strTransactionNumber
    ,receipt.intInventoryReceiptId
    ,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
    ,receiptItem.intInventoryReceiptItemId
    ,receiptItem.intItemId
    ,receiptItem.intUnitMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
    ,(ROUND(
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
    ) 
    +
    --CASE WHEN ISNULL(voucherTax.intCount,0) = 0 THEN 0 ELSE receiptItem.dblTax END
    ISNULL(clearingTax.dblTax,0))
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    AS dblReceiptTotal
    ,ISNULL(receiptItem.dblOpenReceive, 0)
    *
    (
        CASE
        WHEN receipt.strReceiptType = 'Inventory Return'
        THEN -1
        ELSE 1
        END
    )
    AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(CASE WHEN receiptItem.intOwnershipType = 2 THEN 0 ELSE 1 END AS BIT) AS ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblICInventoryReceipt receipt 
INNER JOIN tblICInventoryReceiptItem receiptItem
	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId)
LEFT JOIN vyuAPReceiptClearingGL APClearing
    ON APClearing.strTransactionId = receipt.strReceiptNumber
        AND APClearing.intItemId = receiptItem.intItemId
        AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
OUTER APPLY (
    --SINCE WE REVERSE IN GL THOSE TAX DETAIL THAT DOES NOT HAVE VOUCHER
    --WE NEED TO EXCLUDE THAT ON THE REPORT TO BALANCE WITH GL
    --GET ONLY THE TAX IF IT HAS RELATED VOUCHER TAX DETAIL AND IF THERE IS A VOUCHER FOR IT
    --IF NO VOUCHER JUST TAKE THE TAX
    SELECT SUM(dblTax) AS dblTax
    FROM (
        SELECT DISTINCT --TO HANDLE MULTIPLE VOUCHER PER RECEIPT ITEM
            rctTax.intInventoryReceiptItemId, rctTax.dblTax AS dblTax
        FROM tblICInventoryReceiptItemTax rctTax
        LEFT JOIN tblAPBillDetail billDetail 
            ON billDetail.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
            AND billDetail.intInventoryReceiptChargeId IS NULL
        LEFT JOIN tblAPBillDetailTax billDetailTax
                ON billDetail.intBillDetailId = billDetailTax.intBillDetailId
                AND billDetailTax.intTaxCodeId = rctTax.intTaxCodeId
                AND billDetailTax.intTaxClassId = rctTax.intTaxClassId
        WHERE 
            rctTax.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId 
        AND 1 = CASE WHEN billDetail.intBillDetailId IS NULL THEN 1
                ELSE (
                    CASE WHEN billDetailTax.intBillDetailTaxId IS NOT NULL THEN 1 ELSE 0 END
                )
                END
    ) tmpTax

) clearingTax
-- OUTER APPLY (
--     --DO NOT ADD TAX FOR RECEIPT IF THERE IS NO TAX (NO TAX DETAILS) ON VOUCHER TO REMOVE DATA ON CLEARING REPORT
--     --FOR MATCHING WITH GL, WE HAVE DATA FIXES FOR GL
--     SELECT
--         COUNT(*) AS intCount
--     FROM tblAPBillDetail billDetail
--     INNER JOIN tblAPBillDetailTax bdTax ON bdTax.intBillDetailId = billDetail.intBillDetailId
--     WHERE billDetail.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
-- ) voucherTax
-- OUTER APPLY (
-- 	SELECT 
--     TOP 1
--         ad.strAccountId
--         ,ad.intAccountId
--         ,t.strTransactionId
--         ,t.intTransactionDetailId
--         ,t.intTransactionId
--         ,t.intItemId
-- 	FROM 
-- 		tblICInventoryTransaction t 
-- 		--INNER JOIN tblICItem item
-- 		--	ON t.intItemId = item.intItemId
-- 		INNER JOIN tblGLDetail gd
-- 			ON t.strTransactionId = gd.strTransactionId
-- 			--AND t.strBatchId = gd.strBatchId
-- 			AND t.intInventoryTransactionId = gd.intJournalLineNo
-- 		--INNER JOIN tblGLAccount ga
-- 		--	ON ga.intAccountId = gd.intAccountId
-- 		INNER JOIN vyuGLAccountDetail ad
-- 			ON gd.intAccountId = ad.intAccountId
-- 		--LEFT JOIN tblICItemLocation itemLoc
-- 		--	ON itemLoc.intItemLocationId = t.intItemLocationId
-- 	WHERE
-- 		t.strTransactionId = receipt.strReceiptNumber
-- 		--AND t.intTransactionId = receipt.intInventoryReceiptId
-- 		--AND t.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		AND t.intItemId = receiptItem.intItemId
-- 		--AND ag.strAccountType = 'Liability'
-- 		--AND t.ysnIsUnposted = 0 
-- 		AND	ad.intAccountCategoryId = 45
-- 		AND t.ysnIsUnposted = 0 
-- ) APClearing
-- 	--ON		APClearing.strTransactionId = receipt.strReceiptNumber
-- 		--AND APClearing.intTransactionId = receipt.intInventoryReceiptId
-- 		--AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		--AND APClearing.intItemId = receiptItem.intItemId
WHERE 
    receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
--DO NOT INCLUDE RECEIPT WHICH USES IN-TRANSIT AS GL
--CLEARING FOR THIS IS ALREADY PART OF vyuAPLoadClearing
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND receipt.ysnPosted = 1
AND NOT EXISTS (
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing transferClr
    WHERE transferClr.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
)
AND NOT EXISTS (
	--receipts in storage that were FULLY transferred from DP to DP only
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing_FullDPtoDP transferClrDP
    WHERE transferClrDP.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
)
-- AND receipt.intSourceType != 7 --NOT STORE
-- UNION ALL
-- SELECT	
--     receipt.intEntityVendorId
--     ,receipt.dtmReceiptDate AS dtmDate
--     ,receipt.strReceiptNumber AS strTransactionNumber
--     ,receipt.intInventoryReceiptId
--     ,NULL AS intBillId
--     ,NULL AS strBillId
--     ,NULL AS intBillDetailId
--     ,receiptItem.intInventoryReceiptItemId
--     ,receiptItem.intItemId
--     ,ISNULL(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId) AS intItemUOMId
--     ,unitMeasure.strUnitMeasure AS strUOM
--     ,0 AS dblVoucherTotal
--     ,0 AS dblVoucherQty
--     ,ROUND(
--         CASE	
--             WHEN receiptItem.intWeightUOMId IS NULL THEN 
--                 ISNULL(receiptItem.dblOpenReceive, 0) 
--             ELSE 
--                 CASE 
--                     WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
--                         ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, receiptItem.dblOpenReceive), 0)
--                     ELSE 
--                         CASE WHEN intSourceType = 2 
--                             THEN CAST(ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intWeightUOMId,receiptItem.intUnitMeasureId , receiptItem.dblNet), 0) AS DECIMAL(18,2))
--                         ELSE ISNULL(receiptItem.dblNet, 0) 
--                         END
--                 END 
--         END
--         * dbo.fnCalculateCostBetweenUOM(ISNULL(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId), ISNULL(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId), receiptItem.dblUnitCost)
--         * (
--             CASE 
--                 WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
--                     1 / ISNULL(receipt.intSubCurrencyCents, 1) 
--                 ELSE 
--                     1 
--             END 
--         )
--         , 2
--     ) 
--     *
--     (
--         CASE
--         WHEN receipt.strReceiptType = 'Inventory Return'
--         THEN -1
--         ELSE 1
--         END
--     )
--     +
--     receiptItem.dblTax
--     AS dblReceiptTotal
--     ,CASE	
--         WHEN receiptItem.intWeightUOMId IS NULL THEN 
--             ISNULL(receiptItem.dblOpenReceive, 0) 
--         ELSE 
--             CASE 
--                 WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
--                     ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
--                 ELSE 
--                     ISNULL(receiptItem.dblNet, 0) 
--             END 
--     END 
--     *
--     (
--         CASE
--         WHEN receipt.strReceiptType = 'Inventory Return'
--         THEN -1
--         ELSE 1
--         END
--     )
--     AS dblReceiptQty
--     ,receipt.intLocationId
--     ,compLoc.strLocationName
--     ,CAST(CASE WHEN receiptItem.intOwnershipType = 2 THEN 0 ELSE 1 END AS BIT) AS ysnAllowVoucher
--     ,APClearing.intAccountId
-- 	,APClearing.strAccountId
-- FROM tblICInventoryReceipt receipt 
-- INNER JOIN tblICInventoryReceiptItem receiptItem
-- 	ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
-- INNER JOIN tblSMCompanyLocation compLoc
--     ON receipt.intLocationId = compLoc.intCompanyLocationId
-- LEFT JOIN tblSMFreightTerms ft
--     ON ft.intFreightTermId = receipt.intFreightTermId
-- LEFT JOIN 
-- (
--     tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
--         ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
-- )
--     ON itemUOM.intItemUOMId = COALESCE(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId)
-- LEFT JOIN (
-- 	SELECT 
--     --TOP 1
--         ga.strAccountId
--         ,ga.intAccountId
--         ,t.strTransactionId
--         ,t.intTransactionDetailId
--         ,t.intTransactionId
--         ,t.intItemId
-- 	FROM 
-- 		tblICInventoryTransaction t INNER JOIN tblGLDetail gd
-- 			ON t.strTransactionId = gd.strTransactionId
-- 			AND t.strBatchId = gd.strBatchId
-- 			AND t.intInventoryTransactionId = gd.intJournalLineNo
-- 		INNER JOIN tblGLAccount ga
-- 			ON ga.intAccountId = gd.intAccountId
-- 		INNER JOIN vyuGLAccountDetail ad
-- 			ON ga.intAccountId = ad.intAccountId
-- 	WHERE
-- 		--t.strTransactionId = receipt.strReceiptNumber
-- 		--AND t.intTransactionId = receipt.intInventoryReceiptId
-- 		--AND t.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		--AND t.intItemId = receiptItem.intItemId
-- 		--AND ag.strAccountType = 'Liability'
-- 		--AND t.ysnIsUnposted = 0 
-- 			ad.intAccountCategoryId = 45
-- 		AND t.ysnIsUnposted = 0 
-- ) APClearing
-- 	ON		APClearing.strTransactionId = receipt.strReceiptNumber
-- 		AND APClearing.intTransactionId = receipt.intInventoryReceiptId
-- 		AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		AND APClearing.intItemId = receiptItem.intItemId
-- WHERE 
--     receiptItem.dblUnitCost != 0 -- WILL NOT SHOW ALL THE 0 TOTAL IR 
-- --DO NOT INCLUDE RECEIPT WHICH USES IN-TRANSIT AS GL
-- --CLEARING FOR THIS IS ALREADY PART OF vyuAPLoadClearing
-- AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
-- AND receipt.strReceiptType != 'Transfer Order'
-- AND receiptItem.intOwnershipType != 2
-- AND receipt.ysnPosted = 1
-- AND receipt.intSourceType = 7 --STORE TYPE
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
    ,billDetail.intUnitOfMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,--billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal --comment temporarily, we need to use the cost of receipt until cost adjustment on report added
    ISNULL((CASE WHEN billDetail.ysnSubCurrency > 0 --CHECK IF SUB-CURRENCY
            THEN (CASE 
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((
                            --HANDLE NET WEIGHT ISSUE
                            --VOUCHER CREATED FROM RECEIPT DID NOT USE THE NET WEIGHT
                            CASE WHEN 
                                receiptItem.dblNet <> 0 AND 
                                receiptItem.dblNet <> receiptItem.dblOpenReceive AND
                                receiptItem.dblOpenReceive = billDetail.dblQtyReceived AND
                                --SOME VOUCHER CREATED USING INCORRECT NET WEIGHT BUT TOTAL IS THE SAME
                                receiptItem.dblLineTotal <> billDetail.dblTotal AND
                                ABS(receiptItem.dblLineTotal - billDetail.dblTotal) <> .01 AND
                                receiptItem.intWeightUOMId IS NOT NULL
                            THEN receiptItem.dblNet
                            --IF DIDN'T FALL TO HANDLING DATA, USE NORMAL LOGIC
                            WHEN billDetail.dblNetWeight <> 0
                            THEN billDetail.dblNetWeight
                            ELSE billDetail.dblQtyReceived
                            END
                        ) 
                        *  (receiptItem.dblUnitCost / ISNULL(bill.intSubCurrencyCents,1))  
                        * dbo.fnDivide(billDetail.dblUnitQty, ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((
                        CASE WHEN 
                                receiptItem.dblNet <> 0 AND 
                                receiptItem.dblNet <> receiptItem.dblOpenReceive AND
                                receiptItem.dblOpenReceive = billDetail.dblQtyReceived AND
                                receiptItem.dblLineTotal <> billDetail.dblTotal AND
                                ABS(receiptItem.dblLineTotal - billDetail.dblTotal) <> .01 AND
                                receiptItem.intWeightUOMId IS NOT NULL
                            THEN receiptItem.dblNet
                            WHEN billDetail.dblNetWeight <> 0
                            THEN billDetail.dblNetWeight
                            ELSE billDetail.dblQtyReceived
                            END
                        ) 
                    * (receiptItem.dblUnitCost / ISNULL(bill.intSubCurrencyCents,1))  AS DECIMAL(18,2))  --Orig Calculation
                END)
            ELSE (CASE 
                    WHEN (billDetail.intUnitOfMeasureId > 0 AND billDetail.intCostUOMId > 0)
                        THEN CAST((
                            CASE WHEN 
                                receiptItem.dblNet <> 0 AND 
                                receiptItem.dblNet <> receiptItem.dblOpenReceive AND
                                receiptItem.dblOpenReceive = billDetail.dblQtyReceived AND
                                receiptItem.dblLineTotal <> billDetail.dblTotal AND
                                ABS(receiptItem.dblLineTotal - billDetail.dblTotal) <> .01 AND
                                receiptItem.intWeightUOMId IS NOT NULL
                            THEN receiptItem.dblNet
                            --IF DIDN'T FALL TO HANDLING DATA, USE NORMAL LOGIC
                            WHEN billDetail.dblNetWeight <> 0
                            THEN billDetail.dblNetWeight
                            ELSE billDetail.dblQtyReceived
                            END
                            ) 
                        * (receiptItem.dblUnitCost)  
                        * dbo.fnDivide(billDetail.dblUnitQty, ISNULL(NULLIF(billDetail.dblCostUnitQty,0),1)) AS DECIMAL(18,2))  --Formula With Receipt UOM and Cost UOM
                    ELSE CAST((
                        CASE WHEN 
                                receiptItem.dblNet <> 0 AND 
                                receiptItem.dblNet <> receiptItem.dblOpenReceive AND
                                receiptItem.dblOpenReceive = billDetail.dblQtyReceived AND
                                receiptItem.dblLineTotal <> billDetail.dblTotal AND
                                ABS(receiptItem.dblLineTotal - billDetail.dblTotal) <> .01 AND
                                receiptItem.intWeightUOMId IS NOT NULL
                            THEN receiptItem.dblNet
                            --IF DIDN'T FALL TO HANDLING DATA, USE NORMAL LOGIC
                            WHEN billDetail.dblNetWeight <> 0
                            THEN billDetail.dblNetWeight
                            ELSE billDetail.dblQtyReceived
                            END
                        ) 
                    * (receiptItem.dblUnitCost)  AS DECIMAL(18,2))  --Orig Calculation
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
    +
    -- receiptItem.dblTax --DO NOT USE THIS, WE WILL HAVE ISSUE IF PARTIAL VOUCHER
    -- if there is tax in receipt, use the tblAPBillDetail.dblTax for the original cost
    CASE WHEN receiptItem.dblTax <> 0 THEN ISNULL(oldCostTax.dblTax,0) ELSE 0 END
    AS dblVoucherTotal
    ,ISNULL(billDetail.dblQtyReceived, 0) 
    *
    (
        CASE 
        WHEN bill.intTransactionType = 3
        THEN -1
        ELSE 1
        END
    )
    AS dblVoucherQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
    -- ,ROUND(
    --     CASE	
    --         WHEN receiptItem.intWeightUOMId IS NULL THEN 
    --             ISNULL(receiptItem.dblOpenReceive, 0) 
    --         ELSE 
    --             CASE 
    --                 WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
    --                     ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, receiptItem.dblOpenReceive), 0)
    --                 ELSE 
    --                     CASE WHEN intSourceType = 2 
    --                         THEN CAST(ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intWeightUOMId,receiptItem.intUnitMeasureId , receiptItem.dblNet), 0) AS DECIMAL(18,2))
    --                     ELSE ISNULL(receiptItem.dblNet, 0) 
    --                     END
    --             END 
    --     END
    --     * dbo.fnCalculateCostBetweenUOM(ISNULL(receiptItem.intCostUOMId, receiptItem.intUnitMeasureId), ISNULL(receiptItem.intWeightUOMId, receiptItem.intUnitMeasureId), receiptItem.dblUnitCost)
    --     * (
    --         CASE 
    --             WHEN receiptItem.ysnSubCurrency = 1 AND ISNULL(receipt.intSubCurrencyCents, 1) <> 0 THEN 
    --                 1 / ISNULL(receipt.intSubCurrencyCents, 1) 
    --             ELSE 
    --                 1 
    --         END 
    --     )
    --     , 2
    -- ) AS dblReceiptTotal
    -- ,CASE	
    --     WHEN receiptItem.intWeightUOMId IS NULL THEN 
    --         ISNULL(receiptItem.dblOpenReceive, 0) 
    --     ELSE 
    --         CASE 
    --             WHEN ISNULL(receiptItem.dblNet, 0) = 0 THEN 
    --                 ISNULL(dbo.fnCalculateQtyBetweenUOM(receiptItem.intUnitMeasureId, receiptItem.intWeightUOMId, ISNULL(receiptItem.dblOpenReceive, 0)), 0)
    --             ELSE 
    --                 ISNULL(receiptItem.dblNet, 0) 
    --         END 
    -- END AS dblReceiptQty
    ,receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
    ON bill.intBillId = billDetail.intBillId
INNER JOIN tblICInventoryReceiptItem receiptItem
    ON billDetail.intInventoryReceiptItemId  = receiptItem.intInventoryReceiptItemId
INNER JOIN tblICInventoryReceipt receipt
    ON receipt.intInventoryReceiptId  = receiptItem.intInventoryReceiptId
INNER JOIN tblSMCompanyLocation compLoc
    ON receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
OUTER APPLY (
    SELECT
        SUM(dblTax) AS dblTax --dblAdjustedTax is the new cost
    FROM tblAPBillDetailTax taxes
    WHERE taxes.intBillDetailId = billDetail.intBillDetailId
) oldCostTax
-- LEFT JOIN vyuAPReceiptClearingGL APClearing
--     ON APClearing.strTransactionId = receipt.strReceiptNumber
--         AND APClearing.intItemId = receiptItem.intItemId
--         AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
--OUTER APPLY (
-- LEFT JOIN (
-- 	SELECT 
-- 		--TOP 1
-- 		ga.strAccountId
-- 		,ga.intAccountId
-- 		,t.strTransactionId
-- 		,t.intTransactionDetailId
-- 		,t.intTransactionId
-- 		,t.intItemId
-- 	FROM 
-- 		tblICInventoryTransaction t INNER JOIN tblGLDetail gd
-- 			ON t.strTransactionId = gd.strTransactionId
-- 			AND t.strBatchId = gd.strBatchId
-- 			AND t.intInventoryTransactionId = gd.intJournalLineNo
-- 		INNER JOIN tblGLAccount ga
-- 			ON ga.intAccountId = gd.intAccountId
-- 		INNER JOIN vyuGLAccountDetail ad
-- 			ON ga.intAccountId = ad.intAccountId
-- 	WHERE
-- 		--t.strTransactionId = receipt.strReceiptNumber
-- 		--AND t.intTransactionId = receipt.intInventoryReceiptId
-- 		--AND t.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		--AND t.intItemId = receiptItem.intItemId
-- 		--ag.strAccountType = 'Liability'
-- 		--AND 
-- 		ad.intAccountCategoryId = 45
-- 		AND t.ysnIsUnposted = 0 
--         AND (gd.dblCredit != 0 OR gd.dblDebit != 0) --do not include entries with both 0 amount
-- ) APClearing
-- 	ON		APClearing.strTransactionId = receipt.strReceiptNumber
-- 		AND APClearing.intTransactionId = receipt.intInventoryReceiptId
-- 		AND APClearing.intTransactionDetailId = receiptItem.intInventoryReceiptItemId
-- 		AND APClearing.intItemId = receiptItem.intItemId
WHERE 
    billDetail.intInventoryReceiptItemId IS NOT NULL
AND bill.ysnPosted = 1
AND billDetail.intInventoryReceiptChargeId IS NULL
AND 1 = (CASE WHEN receipt.intSourceType = 2 AND ft.intFreightTermId > 0 AND ft.strFobPoint = 'Origin' THEN 0 ELSE 1 END) --Inbound Shipment
AND receipt.strReceiptType != 'Transfer Order'
AND receiptItem.intOwnershipType != 2
AND NOT EXISTS (
	--receipts in storage that were transferred
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing transferClr
    WHERE transferClr.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
)
AND NOT EXISTS (
	--receipts in storage that were FULLY transferred from DP to DP only
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing_FullDPtoDP transferClrDP
    WHERE transferClrDP.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
)
--AND receipt.dtmReceiptDate >= '2020-09-09'GO








--Vouchers for receipt items
union all
SELECT
    bill.intEntityVendorId
    ,bill.dtmDate AS dtmDate
    ,Receipt.strReceiptNumber
    ,Receipt.intInventoryReceiptId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,StorageReceipt.intInventoryReceiptItemId
    ,billDetail.intItemId
    ,billDetail.intUnitOfMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,StorageReceipt.dblUnits * ReceiptItem.dblUnitCost as dblVoucherTotal	
    ,Round(StorageReceipt.dblUnits, 2) AS dblVoucherQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
   
    ,Receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
FROM tblGRStorageInventoryReceipt StorageReceipt
			join ( 

				select  Charge.intInventoryReceiptId, Tickets.intTicketId from (
					select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
					) Tickets
					join tblICInventoryReceiptItem Item
						on Item.intSourceId = Tickets.intTicketId				
					join tblQMTicketDiscount TicketDiscount
						on TicketDiscount.intTicketId = Tickets.intTicketId
					join tblGRDiscountScheduleCode DiscountScheduleCode
						on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
					join tblICInventoryReceiptCharge Charge
						on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
							and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
		) TicketLinking			
			on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
		join tblICInventoryReceipt Receipt
			on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
		join tblICInventoryReceiptItem ReceiptItem
			on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
			and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
join tblAPBillDetail billDetail
			on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
				and ReceiptItem.intItemId = billDetail.intItemId
		INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
INNER JOIN tblSMCompanyLocation compLoc
    ON Receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = Receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
WHERE 
     bill.ysnPosted = 1


AND Receipt.strReceiptType != 'Transfer Order'

AND NOT EXISTS (
	--receipts in storage that were transferred
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing transferClr
    WHERE transferClr.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
)
AND NOT EXISTS (
	--receipts in storage that were FULLY transferred from DP to DP only
    SELECT intInventoryReceiptItemId
    FROM vyuGRTransferClearing_FullDPtoDP transferClrDP
    WHERE transferClrDP.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
)
--AND receipt.dtmReceiptDate >= '2020-09-09'GO


--This is for the settlement of the remaining IR in a transfer
union all
SELECT
	--'4' as flag,
	--*
	
	-- original select
    bill.intEntityVendorId
    ,bill.dtmDate AS dtmDate
    ,Receipt.strReceiptNumber
    ,Receipt.intInventoryReceiptId
    ,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
    ,StorageReceipt.intInventoryReceiptItemId
    ,billDetail.intItemId
    ,billDetail.intUnitOfMeasureId AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM
    ,(StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage)))  * ReceiptItem.dblUnitCost as dblVoucherTotal	
    ,Round((StorageReceipt.dblTransactionUnits + ((StorageReceipt.dblTransactionUnits / S.dblNetUnits) * ABS(S.dblShrinkage))) , 2) AS dblVoucherQty
    ,0 AS dblReceiptTotal
    ,0 AS dblReceiptQty
   
    ,Receipt.intLocationId
    ,compLoc.strLocationName
    ,CAST(1 AS BIT) ysnAllowVoucher
    ,APClearing.intAccountId
	,APClearing.strAccountId
	
FROM tblGRStorageInventoryReceipt StorageReceipt
INNER JOIN (
	SELECT 
		intCustomerStorageId
		,intInventoryReceiptId
        ,intInventoryReceiptItemId
		,dblNetUnits
		,dblShrinkage
        ,ROW_NUMBER() OVER(PARTITION BY intInventoryReceiptId
                                 ORDER BY intStorageInventoryReceipt) AS rk
	FROM tblGRStorageInventoryReceipt
	WHERE ysnUnposted = 0
) S ON S.intInventoryReceiptId = StorageReceipt.intInventoryReceiptId AND S.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId AND S.rk = 1
			join ( 

				select  Item.intInventoryReceiptId, Tickets.intTicketId from (
					select strTicketNumber, intTicketId, intItemId from tblSCTicket where intInventoryReceiptId is not null and intDeliverySheetId > 0
					) Tickets
					join tblICInventoryReceiptItem Item
						on Item.intSourceId = Tickets.intTicketId				
					--join tblQMTicketDiscount TicketDiscount
					--	on TicketDiscount.intTicketId = Tickets.intTicketId
					--join tblGRDiscountScheduleCode DiscountScheduleCode
					--	on DiscountScheduleCode.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId
					--join tblICInventoryReceiptCharge Charge
					--	on Item.intInventoryReceiptId = Charge.intInventoryReceiptId				
					--		and Charge.intChargeId = DiscountScheduleCode.intItemId		
						
		) TicketLinking			
			on StorageReceipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
					
		join tblICInventoryReceipt Receipt
			on Receipt.intInventoryReceiptId = TicketLinking.intInventoryReceiptId
		join tblICInventoryReceiptItem ReceiptItem
			on Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId			
			and ReceiptItem.intInventoryReceiptItemId = StorageReceipt.intInventoryReceiptItemId
join tblAPBillDetail billDetail
			on  billDetail.intCustomerStorageId = StorageReceipt.intCustomerStorageId
				and ReceiptItem.intItemId = billDetail.intItemId
				and billDetail.intSettleStorageId = StorageReceipt.intSettleStorageId
		INNER JOIN tblAPBill bill ON billDetail.intBillId = bill.intBillId
INNER JOIN tblSMCompanyLocation compLoc
    ON Receipt.intLocationId = compLoc.intCompanyLocationId
INNER JOIN vyuGLAccountDetail APClearing
    ON APClearing.intAccountId = billDetail.intAccountId AND APClearing.intAccountCategoryId = 45
LEFT JOIN tblSMFreightTerms ft
    ON ft.intFreightTermId = Receipt.intFreightTermId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = COALESCE(billDetail.intWeightUOMId, billDetail.intUnitOfMeasureId)
WHERE 
	StorageReceipt.intSettleStorageId is not null 
and bill.ysnPosted = 1
AND Receipt.strReceiptType != 'Transfer Order'


GO


