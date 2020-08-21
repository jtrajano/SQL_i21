CREATE FUNCTION [dbo].[fnAPGetVoucherChargeItemGLEntry]  
(  
 @billId INT  
)  
RETURNS TABLE AS RETURN  
(  
 SELECT  
  B.intBillDetailId  
  ,B.strMiscDescription  
  ,CAST(CASE WHEN B.dblOldCost IS NULL THEN B.dblTotal   
  --if charge entity vendor and voucher vendor is the same, meaning the charge added on voucher is for third party  
  --meaning, we don't need to reverse the sign of the amount  
     ELSE (CASE WHEN A.intEntityVendorId = ISNULL(NULLIF(D.intEntityVendorId,0), D2.intEntityVendorId) AND   
       D.ysnPrice = 1   
       THEN D.dblAmount * -1   
        ELSE D.dblAmount  
       END)  
   END   
   * ISNULL(NULLIF(B.dblRate,0),1)   
   * CASE WHEN A.intTransactionType IN (2, 3, 13) THEN (-1)   
      ELSE 1 END AS DECIMAL(18,2)) AS dblTotal  
  ,CAST(CASE WHEN B.dblOldCost IS NULL THEN B.dblTotal   
     ELSE (CASE WHEN A.intEntityVendorId = ISNULL(NULLIF(D.intEntityVendorId,0), D2.intEntityVendorId) AND   
         D.ysnPrice = 1   
       THEN D.dblAmount * -1   
        ELSE D.dblAmount  
       END)  
   END   
   * CASE WHEN A.intTransactionType IN (2, 3, 13) THEN (-1)   
      ELSE 1 END AS DECIMAL(18,2)) AS dblForeignTotal  
  ,B.dblQtyReceived as dblTotalUnits  
  ,B.intAccountId  
  ,G.intCurrencyExchangeRateTypeId  
  ,G.strCurrencyExchangeRateType  
  ,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate  
 FROM tblAPBill A  
 INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId  
 INNER JOIN tblICItem B2  
    ON B.intItemId = B2.intItemId  
 INNER JOIN tblICItemLocation loc  
  ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId  
 LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId)  
  ON A.intEntityVendorId = C.[intEntityId]  
 LEFT JOIN (tblICInventoryReceiptCharge D  INNER JOIN tblICInventoryReceipt D2 ON D.intInventoryReceiptId = D2.intInventoryReceiptId)
  ON B.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId  
 LEFT JOIN tblICItem F  
  ON B.intItemId = F.intItemId  
 LEFT JOIN dbo.tblSMCurrencyExchangeRateType G  
  ON G.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId  
 WHERE A.intBillId = @billId  
 AND B.intInventoryReceiptChargeId IS NOT NULL  
)