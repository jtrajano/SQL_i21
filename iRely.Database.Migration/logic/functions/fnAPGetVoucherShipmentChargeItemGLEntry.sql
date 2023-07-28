--liquibase formatted sql

-- changeset Von:fnAPGetVoucherShipmentChargeItemGLEntry.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].fnAPGetVoucherShipmentChargeItemGLEntry
(  
 @billId INT  
)  
RETURNS TABLE AS RETURN  
(  
 SELECT  
  B.intBillDetailId  
  ,B.strMiscDescription  
  ,CAST(CASE WHEN B.dblTotal <> D.dblAmount AND B.dblQtyReceived >= D.dblQuantity THEN D.dblAmount
		ELSE B.dblTotal   
		END   
   * ISNULL(NULLIF(B.dblRate,0),1)   
   * CASE WHEN A.intTransactionType IN (2, 3, 13) THEN (-1)   
      ELSE 1 END AS DECIMAL(18,2)) AS dblTotal  
  ,CAST(CASE WHEN B.dblTotal <> D.dblAmount AND B.dblQtyReceived >= D.dblQuantity THEN D.dblAmount
		ELSE B.dblTotal   
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
 LEFT JOIN (tblICInventoryShipmentCharge D  INNER JOIN tblICInventoryShipment D2 ON D.intInventoryShipmentId = D2.intInventoryShipmentId)
  ON B.intInventoryShipmentChargeId = D.intInventoryShipmentChargeId  
 LEFT JOIN tblICItem F  
  ON B.intItemId = F.intItemId  
 LEFT JOIN dbo.tblSMCurrencyExchangeRateType G  
  ON G.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId  
 WHERE A.intBillId = @billId  
 AND B.intInventoryShipmentChargeId IS NOT NULL  
)



