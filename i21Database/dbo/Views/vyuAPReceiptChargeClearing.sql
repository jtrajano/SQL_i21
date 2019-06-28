﻿CREATE VIEW [dbo].[vyuAPReceiptChargeClearing]  
AS   
  
--BILL ysnPrice = 1/Charge Entity  
SELECT  
    Receipt.intEntityVendorId AS intEntityVendorId  
 ,Receipt.dtmReceiptDate AS dtmDate  
 ,Receipt.strReceiptNumber  
 ,Receipt.intInventoryReceiptId  
    ,NULL AS intBillId  
    ,NULL AS strBillId  
    ,NULL AS intBillDetailId  
    ,ReceiptCharge.intInventoryReceiptChargeId  
    ,ReceiptCharge.intChargeId AS intItemId  
    ,0 AS dblVoucherTotal  
    ,0 AS dblVoucherQty  
    ,CAST((ISNULL(dblAmount * -1,0) --multiple the amount to reverse if ysnPrice = 1  
        + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal  
    ,ISNULL(ReceiptCharge.dblQuantity,0) * -1 AS dblReceiptChargeQty  
    ,Receipt.intLocationId  
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
FROM tblICInventoryReceiptCharge ReceiptCharge  
INNER JOIN tblICInventoryReceipt Receipt   
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId   
INNER JOIN tblSMCompanyLocation compLoc  
    ON Receipt.intLocationId = compLoc.intCompanyLocationId  
WHERE   
    Receipt.ysnPosted = 1    
AND ReceiptCharge.ysnPrice = 1  
UNION ALL  
--BILL ysnAccrue = 1/There is a vendor selected, This includes the third party  
SELECT  
    ISNULL(ReceiptCharge.intEntityVendorId, Receipt.intEntityVendorId) AS intEntityVendorId  
 ,Receipt.dtmReceiptDate AS dtmDate  
 ,Receipt.strReceiptNumber  
 ,Receipt.intInventoryReceiptId  
    ,NULL AS intBillId  
    ,NULL AS strBillId  
    ,NULL AS intBillDetailId  
    ,ReceiptCharge.intInventoryReceiptChargeId  
    ,ReceiptCharge.intChargeId AS intItemId  
    ,0 AS dblVoucherTotal  
    ,0 AS dblVoucherQty  
    ,CAST((ISNULL(dblAmount,0) + ISNULL(dblTax,0)) AS DECIMAL (18,2)) AS dblReceiptChargeTotal  
    ,ISNULL(ReceiptCharge.dblQuantity,0) AS dblReceiptChargeQty  
    ,Receipt.intLocationId  
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
FROM tblICInventoryReceiptCharge ReceiptCharge  
INNER JOIN tblICInventoryReceipt Receipt   
    ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId   
        AND ReceiptCharge.ysnAccrue = 1   
        AND ReceiptCharge.ysnPrice = 0  
INNER JOIN tblSMCompanyLocation compLoc  
    ON Receipt.intLocationId = compLoc.intCompanyLocationId  
WHERE   
    Receipt.ysnPosted = 1    
AND ReceiptCharge.ysnAccrue = 1  
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
    ,((receiptCharge.dblAmount) * (CASE WHEN receiptCharge.ysnPrice = 1 THEN -1 ELSE 1 END))  
         + receiptCharge.dblTax AS dblReceiptChargeTotal  
    ,receiptCharge.dblQuantity   
        * (CASE WHEN receiptCharge.ysnPrice = 1 THEN -1 ELSE 1 END) AS dblReceiptChargeQty  
    ,receipt.intLocationId  
    ,compLoc.strLocationName  
    ,CAST(1 AS BIT) ysnAllowVoucher  
FROM tblAPBill bill  
INNER JOIN tblAPBillDetail billDetail  
    ON bill.intBillId = billDetail.intBillId  
INNER JOIN tblICInventoryReceiptCharge receiptCharge  
    ON billDetail.intInventoryReceiptChargeId  = receiptCharge.intInventoryReceiptChargeId  
INNER JOIN tblICInventoryReceipt receipt  
    ON receipt.intInventoryReceiptId  = receiptCharge.intInventoryReceiptId  
INNER JOIN tblSMCompanyLocation compLoc  
    ON receipt.intLocationId = compLoc.intCompanyLocationId  
WHERE   
    billDetail.intInventoryReceiptChargeId IS NOT NULL  
AND bill.ysnPosted = 1