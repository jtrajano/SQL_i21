CREATE FUNCTION [dbo].[fnAPGetDebitMemoItemCostAdjGLEntry]  
(  
  @billId INT  
)  
RETURNS TABLE AS RETURN  
(  
 SELECT DISTINCT  
  B.intBillDetailId  
  ,B.strMiscDescription
  ,dblTotal = -CAST(
                    (ISNULL(IR.dblTotal, LS.dblTotal) 
                    - 
                    (B.dblOldCost 
                    * (CASE WHEN B.intComputeTotalOption = 0 AND B.intWeightUOMId > 0 
                       THEN B.dblOldNetWeight 
                       ELSE B.dblFinalQtyReceived END)
                      )
                    ) * ISNULL(NULLIF(B.dblRate,0),1) AS  DECIMAL(18, 2)
                  )
  ,dblForeignTotal = -CAST(ISNULL(IR.dblTotal, LS.dblTotal) 
                      - 
                      (B.dblOldCost 
                        * (CASE WHEN B.intComputeTotalOption = 0 AND B.intWeightUOMId > 0 
                            THEN B.dblOldNetWeight 
                            ELSE B.dblFinalQtyReceived END)
                        ) AS  DECIMAL(18, 2)
                      ) 
  ,(CASE WHEN F.intItemId IS NULL THEN B.dblQtyReceived - B.dblOldNetWeight  
    ELSE  
     CASE WHEN F.strType = 'Inventory' THEN --units is only of inventory item  
      dbo.fnCalculateQtyBetweenUOM((CASE WHEN B.intWeightUOMId > 0   
              THEN B.intWeightUOMId ELSE B.intUnitOfMeasureId END),   
             itemUOM.intItemUOMId,  
             CASE WHEN B.intWeightUOMId > 0 THEN B.dblNetWeight ELSE B.dblQtyReceived END)  
     ELSE 0 END  
  END) as dblTotalUnits  
  ,CASE   
   WHEN B.intInventoryReceiptItemId IS NULL
    THEN [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Inventory In-Transit')
   WHEN B.intLoadShipmentCostId > 0 OR B.intInventoryReceiptChargeId > 0 OR F.strType = 'Non-Inventory'  
    THEN [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'Other Charge Expense')  
   ELSE [dbo].[fnGetItemGLAccount](B.intItemId, loc.intItemLocationId, 'AP Clearing')  
  END AS intAccountId  
  ,G.intCurrencyExchangeRateTypeId  
  ,G.strCurrencyExchangeRateType  
  ,ISNULL(NULLIF(B.dblRate,0),1) AS dblRate  
 FROM tblAPBill A  
 INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId  
 LEFT JOIN (tblICInventoryReceiptItem E INNER JOIN tblICInventoryReceipt E2 ON E.intInventoryReceiptId = E2.intInventoryReceiptId)  
  ON B.intInventoryReceiptItemId = E.intInventoryReceiptItemId  
 LEFT JOIN (tblICInventoryReceiptCharge charges INNER JOIN tblICInventoryReceipt r ON charges.intInventoryReceiptId = r.intInventoryReceiptId)  
  ON B.intInventoryReceiptChargeId = charges.intInventoryReceiptChargeId  
 LEFT JOIN dbo.tblSMCurrencyExchangeRateType G  
  ON B.intCurrencyExchangeRateTypeId = G.intCurrencyExchangeRateTypeId  
 LEFT JOIN tblICItem B2  
  ON B.intItemId = B2.intItemId  
 LEFT JOIN tblICItemLocation loc  
  ON loc.intItemId = B.intItemId AND loc.intLocationId = A.intShipToId  
 LEFT JOIN tblICItem F  
  ON B.intItemId = F.intItemId  
 LEFT JOIN (tblLGLoadDetail LD INNER JOIN tblLGLoad L1 ON L1.intLoadId = L1.intLoadId)  
  ON B.intLoadDetailId = LD.intLoadDetailId  
 LEFT JOIN (tblLGLoadCost LC INNER JOIN tblLGLoad L2 ON L2.intLoadId = LC.intLoadId)  
  ON B.intLoadShipmentCostId = LC.intLoadCostId  
 OUTER APPLY (  
  SELECT TOP 1 stockUnit.*  
  FROM tblICItemUOM stockUnit   
  WHERE   
   B.intItemId = stockUnit.intItemId   
  AND stockUnit.ysnStockUnit = 1  
 ) itemUOM  
 OUTER APPLY (  
  SELECT dblTotal = CAST (  
        CASE WHEN B.intInventoryReceiptChargeId > 0  
        THEN charges.dblAmount  
          WHEN B.intInventoryReceiptItemId > 0 THEN  
            (CASE   
              -- If there is a Gross/Net UOM, compute by the net weight.   
              WHEN E.intWeightUOMId IS NOT NULL THEN   
                -- Convert the Cost UOM to Gross/Net UOM.   
                dbo.fnCalculateCostBetweenUOM(  
                  ISNULL(E.intCostUOMId, E.intUnitMeasureId)  
                    ,E.intWeightUOMId  
                    ,E.dblUnitCost  
                )   
                / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END   
                * B.dblNetWeight  
  
              -- If Gross/Net UOM is missing: compute by the receive qty.   
              ELSE   
                -- Convert the Cost UOM to Gross/Net UOM.   
                dbo.fnCalculateCostBetweenUOM(  
                  ISNULL(E.intCostUOMId, E.intUnitMeasureId)  
                  , E.intUnitMeasureId  
                  , E.dblUnitCost  
                )   
                / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END    
                * B.dblQtyReceived  
            END)     
   END AS DECIMAL(18, 2)  
  )  
 ) IR
 OUTER APPLY (  
  SELECT dblTotal = CAST (  
    CASE WHEN B.intLoadShipmentCostId > 0  
      THEN LC.dblAmount  
    WHEN B.intLoadDetailId > 0 THEN  
    (CASE   
      -- If there is a Gross/Net UOM, compute by the net weight.   
      WHEN LD.intWeightItemUOMId IS NOT NULL THEN   
        --Convert the Cost UOM to Gross/Net UOM.   
      dbo.fnCalculateCostBetweenUOM(  
             ISNULL(LD.intItemUOMId, LD.intPriceUOMId)  
            ,LD.intWeightItemUOMId  
            ,LD.dblUnitPrice)   
            / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END   
            * LD.dblNet  
      ELSE   
          -- Convert the Cost UOM to Gross/Net UOM.   
        dbo.fnCalculateCostBetweenUOM(  
              ISNULL(LD.intItemUOMId, LD.intPriceUOMId)  
              ,LD.intWeightItemUOMId  
              ,LD.dblUnitPrice)   
              / CASE WHEN B.ysnSubCurrency > 0 THEN ISNULL(NULLIF(A.intSubCurrencyCents, 0),1) ELSE 1 END    
              * LD.dblQuantity     
       END)  
    END AS DECIMAL(18, 2)  
  )  
 ) LS
 WHERE A.intBillId = @billId  
 AND B.dblOldCost IS NOT NULL AND B.dblCost != B.dblOldCost   
 AND B.intCustomerStorageId IS NULL  
 AND ISNULL(A.ysnConvertedToDebitMemo, 0) = 1  
 AND A.intTransactionType = 3
 AND B.intInventoryReceiptItemId IS NULL 
 AND B.intInventoryReceiptChargeId IS NULL
  
)  