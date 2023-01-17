CREATE VIEW [dbo].[vyuAPReceiptChargeClearing]      
AS       
  
 SELECT  
    charges.*  
    ,APClearing.intAccountId  
    ,APClearing.strAccountId  
FROM (     
--BILL ysnPrice = 1/Charge Entity      
SELECT      
    Receipt.intEntityVendorId AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber     
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intBillId      
    ,NULL AS strBillId      
    ,NULL AS intBillDetailId      
    ,ReceiptCharge.intInventoryReceiptChargeId      
    ,ReceiptCharge.intChargeId AS intItemId     
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM   
    ,0 AS dblVoucherTotal      
    ,0 AS dblVoucherQty      
    ,CAST((ISNULL(dblAmount * -1,0) --multiple the amount to reverse if ysnPrice = 1      
        --WE NEED TO MULTIPLY THE TAX AS WELL TO MATCH WITH VOUCHER
        --EXAMPLE SCENARIO
        --"IR" CHARGE 100, TAX -10 (CHECKOFF) * 1QTY = 90
        --"BL" CHARGE 100, TAX -10 (CHECKOFF) * -1QTY = 90
        --IF WE DON'T HAVE *-1 IN TAX THE TOTAL WOULD BE
        --(CHARGE 100 * -1QTY) + TAX -10 = -110
        --TO ACCOMPLISH THIS CHECKOFF TAX MUST BE CONSISTENTLY NEGATIVE
        + ISNULL(dblTax * -1,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) * -1 AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,CAST(1 AS BIT) ysnAllowVoucher      
    -- ,APClearing.intAccountId    
    -- ,APClearing.strAccountId    
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId  
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId    
-- OUTER APPLY (    
--  SELECT TOP 1    
--   ga.strAccountId    
--   ,ga.intAccountId    
--  FROM     
--   tblGLDetail gd INNER JOIN tblGLAccount ga    
--    ON ga.intAccountId = gd.intAccountId    
--   INNER JOIN tblGLAccountGroup ag    
--    ON ag.intAccountGroupId = ga.intAccountGroupId    
--  WHERE    
--   gd.strTransactionId = Receipt.strReceiptNumber    
--   AND ag.strAccountType = 'Liability'    
--   AND gd.ysnIsUnposted = 0     
-- ) APClearing    
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnPrice = 1   
AND NOT EXISTS (
	--DP to OS and vice verse
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing transferClr
    WHERE transferClr.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr.strTransactionNumber = Receipt.strReceiptNumber
)
AND NOT EXISTS (
	--DP to DP only
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing_DPtoDP transferClr_dp
    WHERE transferClr_dp.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr_dp.strTransactionNumber = Receipt.strReceiptNumber
)   
UNION ALL      
--BILL ysnAccrue = 1/There is a vendor selected, receipt vendor   IR-4345 Roth
SELECT      
    ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber    
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intBillId      
    ,NULL AS strBillId      
    ,NULL AS intBillDetailId      
    ,ReceiptCharge.intInventoryReceiptChargeId      
    ,ReceiptCharge.intChargeId AS intItemId    
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM     
    ,0 AS dblVoucherTotal      
    ,0 AS dblVoucherQty      
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,CAST(1 AS BIT) ysnAllowVoucher     
--     ,APClearing.intAccountId     
--  ,APClearing.strAccountId    
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
        AND ReceiptCharge.ysnAccrue = 1       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId     
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId     
-- OUTER APPLY (    
--  SELECT TOP 1    
--   ga.strAccountId    
--   ,ga.intAccountId    
--  FROM     
--   tblGLDetail gd INNER JOIN tblGLAccount ga    
--    ON ga.intAccountId = gd.intAccountId    
--   INNER JOIN tblGLAccountGroup ag    
--    ON ag.intAccountGroupId = ga.intAccountGroupId    
--  WHERE    
--   gd.strTransactionId = Receipt.strReceiptNumber    
--   AND ag.strAccountType = 'Liability'    
--   AND gd.ysnIsUnposted = 0     
-- ) APClearing    
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnAccrue = 1      
--HANDLE RECEIPT WHICH intEntityVendorId IS NULL
AND ISNULL(Receipt.intEntityVendorId, 0) = ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) --make sure that the result would be for receipt vendor only
AND NOT EXISTS (
	--DP to OS and vice verse
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing transferClr
    WHERE transferClr.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr.strTransactionNumber = Receipt.strReceiptNumber
)
AND NOT EXISTS (
	--DP to DP only
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing_DPtoDP transferClr_dp
    WHERE transferClr_dp.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr_dp.strTransactionNumber = Receipt.strReceiptNumber
)  
UNION ALL      
--BILL ysnAccrue = 1/There is a vendor selected, third party vendor    
SELECT      
    ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId      
    ,Receipt.dtmReceiptDate AS dtmDate      
    ,Receipt.strReceiptNumber  AS strTransactionNumber    
    ,Receipt.intInventoryReceiptId      
    ,NULL AS intBillId      
    ,NULL AS strBillId      
    ,NULL AS intBillDetailId      
    ,ReceiptCharge.intInventoryReceiptChargeId          
    ,ReceiptCharge.intChargeId AS intItemId      
    ,ReceiptCharge.intCostUOMId  AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM     
    ,0 AS dblVoucherTotal      
    ,0 AS dblVoucherQty      
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal      
    ,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty      
    ,Receipt.intLocationId      
    ,compLoc.strLocationName      
    ,CAST(1 AS BIT) ysnAllowVoucher     
--     ,APClearing.intAccountId     
--  ,APClearing.strAccountId    
FROM tblICInventoryReceiptCharge ReceiptCharge      
INNER JOIN tblICInventoryReceipt Receipt       
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId       
        AND ReceiptCharge.ysnAccrue = 1       
INNER JOIN tblSMCompanyLocation compLoc      
    ON Receipt.intLocationId = compLoc.intCompanyLocationId    
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = ReceiptCharge.intCostUOMId     
-- OUTER APPLY (    
--  SELECT TOP 1    
--   ga.strAccountId    
--   ,ga.intAccountId    
--  FROM     
--   tblGLDetail gd INNER JOIN tblGLAccount ga    
--    ON ga.intAccountId = gd.intAccountId    
--   INNER JOIN tblGLAccountGroup ag    
--    ON ag.intAccountGroupId = ga.intAccountGroupId    
--  WHERE    
--   gd.strTransactionId = Receipt.strReceiptNumber    
--   AND ag.strAccountType = 'Liability'    
--   AND gd.ysnIsUnposted = 0     
-- ) APClearing    
WHERE       
    Receipt.ysnPosted = 1        
AND ReceiptCharge.ysnAccrue = 1      
AND ReceiptCharge.intEntityVendorId IS NOT NULL    
--HANDLE RECEIPT WHICH intEntityVendorId IS NULL
AND ReceiptCharge.intEntityVendorId != ISNULL(Receipt.intEntityVendorId, 0) --make sure that the result would be for third party vendor only    
AND NOT EXISTS (
	--DP to OS and vice verse
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing transferClr
    WHERE transferClr.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr.strTransactionNumber = Receipt.strReceiptNumber
)
AND NOT EXISTS (
	--DP to DP only
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing_DPtoDP transferClr_dp
    WHERE transferClr_dp.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
		AND transferClr_dp.strTransactionNumber = Receipt.strReceiptNumber
) 
UNION ALL      
--Voucher For Receipt Charges      
SELECT      
    bill.intEntityVendorId      
    ,bill.dtmDate AS dtmDate      
    ,receipt.strReceiptNumber      
    ,receipt.intInventoryReceiptId      
    ,bill.intBillId      
    ,bill.strBillId      
    ,billDetail.intBillDetailId      
    ,billDetail.intInventoryReceiptChargeId      
    ,billDetail.intItemId      
    ,billDetail.intUnitOfMeasureId AS intItemUOMId  
    ,unitMeasure.strUnitMeasure AS strUOM  
    ,(ROUND(
        (
            CASE WHEN ABS(billDetail.dblTotal) <> receiptCharge.dblAmount
                THEN (
                   --IF THERE IS OLD COST, ASSUME THIS IS NOT PRORATED
                   --PRO RATED SHOULD HAVE NO COST ADJUSTMENT
                   CASE WHEN billDetail.dblOldCost IS NOT NULL
                   THEN receiptCharge.dblAmount * (CASE WHEN billDetail.dblQtyReceived < 0 THEN -1 ELSE 1 END)
                   ELSE billDetail.dblTotal
                   END
                )
            ELSE billDetail.dblTotal END
        )
    + billDetail.dblTax, 2))
    *        
    (        
        CASE         
        WHEN bill.intTransactionType = 3        
        THEN -1        
        ELSE 1        
        END        
    )    
    AS dblVoucherTotal      
    ,ROUND(CASE       
        WHEN billDetail.intWeightUOMId IS NULL THEN       
            ISNULL(billDetail.dblQtyReceived, 0)       
        ELSE       
            CASE       
                WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN       
                    ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)      
                ELSE       
                    ISNULL(billDetail.dblNetWeight, 0)       
            END      
    END,2) AS dblVoucherQty      
    ,0 AS dblReceiptChargeTotal  
    ,0 AS dblReceiptChargeQty  
    -- ,((receiptCharge.dblAmount) * (CASE WHEN receiptCharge.ysnPrice = 1 THEN -1 ELSE 1 END))    
    --      + receiptCharge.dblTax AS dblReceiptChargeTotal    
    -- ,receiptCharge.dblQuantity     
    --     * (CASE WHEN receiptCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty     
    ,receipt.intLocationId      
    ,compLoc.strLocationName      
    ,CAST(1 AS BIT) ysnAllowVoucher     
--     ,APClearing.intAccountId    
--  ,APClearing.strAccountId     
FROM tblAPBill bill      
INNER JOIN tblAPBillDetail billDetail      
    ON bill.intBillId = billDetail.intBillId      
INNER JOIN tblICInventoryReceiptCharge receiptCharge      
    ON billDetail.intInventoryReceiptChargeId  = receiptCharge.intInventoryReceiptChargeId      
INNER JOIN tblICInventoryReceipt receipt      
    ON receipt.intInventoryReceiptId  = receiptCharge.intInventoryReceiptId      
INNER JOIN tblSMCompanyLocation compLoc      
    ON receipt.intLocationId = compLoc.intCompanyLocationId    
LEFT JOIN   
(  
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure  
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId  
)  
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId  
WHERE       
    billDetail.intInventoryReceiptChargeId IS NOT NULL      
AND bill.ysnPosted = 1  
AND NOT EXISTS (
	--DP to OS and vice verse
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing transferClr
    WHERE transferClr.intInventoryReceiptChargeId = receiptCharge.intInventoryReceiptChargeId
		AND transferClr.strTransactionNumber = receipt.strReceiptNumber
)
AND NOT EXISTS (
	--DP to DP only
    SELECT intInventoryReceiptChargeId
    FROM vyuGRTransferChargesClearing_DPtoDP transferClr_dp
    WHERE transferClr_dp.intInventoryReceiptChargeId = receiptCharge.intInventoryReceiptChargeId
		AND transferClr_dp.strTransactionNumber = receipt.strReceiptNumber
) 
) charges  
OUTER APPLY (
SELECT TOP 1 intAccountId, strAccountId FROM vyuAPReceiptClearingGL gl
	 WHERE gl.strTransactionId = charges.strTransactionNumber
) APClearing
GO


