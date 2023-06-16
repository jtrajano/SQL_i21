CREATE PROCEDURE [dbo].[uspAPFixVoucherPayable]  
AS  
  
DECLARE @reinsert TABLE(intVoucherPayableId INT, intNewVoucherPayableId INT);  
  
MERGE INTO tblAPVoucherPayable AS destination  
 USING (  
  SELECT  
   D.[intEntityVendorId]      
   ,D.[strVendorId]       
   ,D.[strName]        
   ,D.[intLocationId]       
   ,D.[strLocationName]       
   ,D.[intCurrencyId]       
   ,D.[strCurrency]       
   ,D.[dtmDate]        
   ,D.[strReference]       
   ,D.[strSourceNumber]      
   ,D.[intPurchaseDetailId]     
   ,D.[strPurchaseOrderNumber]    
   ,D.[intContractHeaderId]     
   ,D.[intContractDetailId]     
   ,D.[intContractSeqId]      
   ,D.[intContractCostId]      
   ,D.[strContractNumber]      
   ,D.[intScaleTicketId]      
   ,D.[strScaleTicketNumber]     
   ,D.[intInventoryReceiptItemId]    
   ,D.[intInventoryReceiptChargeId]   
   ,D.[intInventoryShipmentItemId]   
   ,D.[intInventoryShipmentChargeId]  
   ,D.[intLoadShipmentId]      
   ,D.[intLoadShipmentDetailId]    
   ,D.[intLoadHeaderId]   
   ,D.[intItemId]        
   ,D.[strItemNo]        
   ,D.[intPurchaseTaxGroupId]     
   ,D.[strTaxGroup]       
   ,D.[intItemLocationId]     
   ,D.[strItemLocationName]   
   ,D.[intStorageLocationId]     
   ,D.[strStorageLocationName]    
   ,D.[intSubLocationId]     
   ,D.[strSubLocationName]    
   ,D.[strMiscDescription]     
   ,D.[dblOrderQty]       
   ,D.[dblOrderUnitQty]      
   ,D.[intOrderUOMId]       
   ,D.[strOrderUOM]       
   ,D.[dblQuantityToBill]      
   ,D.[dblQtyToBillUnitQty]     
   ,D.[intQtyToBillUOMId]      
   ,D.[strQtyToBillUOM]      
   ,D.[dblCost]        
   ,D.[dblCostUnitQty]      
   ,D.[intCostUOMId]       
   ,D.[strCostUOM]       
   ,D.[dblNetWeight]       
   ,D.[dblWeightUnitQty]      
   ,D.[intWeightUOMId]      
   ,D.[strWeightUOM]       
   ,D.[intCostCurrencyId]      
   ,D.[strCostCurrency]      
   ,D.[dblTax]        
   ,D.[dblDiscount]       
   ,D.[intCurrencyExchangeRateTypeId]  
   ,D.[strRateType]       
   ,D.[dblExchangeRate]      
   ,D.[ysnSubCurrency]      
   ,D.[intSubCurrencyCents]     
   ,D.[intAccountId]       
   ,D.[strAccountId]       
   ,D.[strAccountDesc]      
   ,D.[intShipViaId]       
   ,D.[strShipVia]       
   ,D.[intTermId]        
   ,D.[strTerm]        
   ,D.[strBillOfLading]      
   ,D.[int1099Form]       
   ,D.[str1099Form]       
   ,D.[int1099Category]   
   ,D.[dbl1099]     
   ,D.[str1099Type]       
   ,D.[ysnReturn]    
   ,D.[intVoucherPayableId]     
  FROM tblAPVoucherPayableCompleted D   
  LEFT JOIN (tblAPBill A INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId)   
  ON   
   D.intTransactionType = A.intTransactionType  
  AND ISNULL(D.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)  
  AND ISNULL(D.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)  
  AND ISNULL(D.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)  
  AND ISNULL(D.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)  
  AND ISNULL(D.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)  
  AND ISNULL(D.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)  
  AND ISNULL(D.intLoadShipmentDetailId,-1) = ISNULL(B.intLoadDetailId,-1)
  AND ISNULL(D.intLoadHeaderId,-1) = ISNULL(B.intLoadHeaderId,-1)  
  AND ISNULL(D.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)  
  WHERE   
   B.intBillDetailId IS NULL --REINSERT THOSE PAYABLES WHICH VOUCHER WAS DELETED BUT WE DID NOT RE-INSERT THE PAYABLES  
 ) AS SourceData  
 ON (1=0)  
 WHEN NOT MATCHED THEN  
 INSERT (  
  [intEntityVendorId]      
  ,[strVendorId]       
  ,[strName]        
  ,[intLocationId]       
  ,[strLocationName]       
  ,[intCurrencyId]       
  ,[strCurrency]       
  ,[dtmDate]        
  ,[strReference]       
  ,[strSourceNumber]      
  ,[intPurchaseDetailId]     
  ,[strPurchaseOrderNumber]    
  ,[intContractHeaderId]     
  ,[intContractDetailId]     
  ,[intContractSeqId]      
  ,[intContractCostId]      
  ,[strContractNumber]      
  ,[intScaleTicketId]      
  ,[strScaleTicketNumber]     
  ,[intInventoryReceiptItemId]    
  ,[intInventoryReceiptChargeId]   
  ,[intInventoryShipmentItemId]   
  ,[intInventoryShipmentChargeId]  
  ,[intLoadShipmentId]      
  ,[intLoadShipmentDetailId]
  ,[intLoadHeaderId]
  ,[intItemId]        
  ,[strItemNo]        
  ,[intPurchaseTaxGroupId]     
  ,[strTaxGroup]       
  ,[intItemLocationId]     
  ,[strItemLocationName]    
  ,[intStorageLocationId]     
  ,[strStorageLocationName]    
  ,[intSubLocationId]     
  ,[strSubLocationName]    
  ,[strMiscDescription]     
  ,[dblOrderQty]       
  ,[dblOrderUnitQty]      
  ,[intOrderUOMId]       
  ,[strOrderUOM]       
  ,[dblQuantityToBill]      
  ,[dblQtyToBillUnitQty]     
  ,[intQtyToBillUOMId]      
  ,[strQtyToBillUOM]      
  ,[dblCost]        
  ,[dblCostUnitQty]      
  ,[intCostUOMId]       
  ,[strCostUOM]       
  ,[dblNetWeight]       
  ,[dblWeightUnitQty]      
  ,[intWeightUOMId]      
  ,[strWeightUOM]       
  ,[intCostCurrencyId]      
  ,[strCostCurrency]      
  ,[dblTax]        
  ,[dblDiscount]       
  ,[intCurrencyExchangeRateTypeId]  
  ,[strRateType]       
  ,[dblExchangeRate]      
  ,[ysnSubCurrency]      
  ,[intSubCurrencyCents]     
  ,[intAccountId]       
  ,[strAccountId]       
  ,[strAccountDesc]      
  ,[intShipViaId]       
  ,[strShipVia]       
  ,[intTermId]        
  ,[strTerm]        
  ,[strBillOfLading]      
  ,[int1099Form]       
  ,[str1099Form]       
  ,[int1099Category]   
  ,[dbl1099]     
  ,[str1099Type]       
  ,[ysnReturn]   
 )  
 VALUES
 (  
   SourceData.[intEntityVendorId]      
  ,SourceData.[strVendorId]       
  ,SourceData.[strName]        
  ,SourceData.[intLocationId]       
  ,SourceData.[strLocationName]       
  ,SourceData.[intCurrencyId]       
  ,SourceData.[strCurrency]       
  ,SourceData.[dtmDate]        
  ,SourceData.[strReference]       
  ,SourceData.[strSourceNumber]      
  ,SourceData.[intPurchaseDetailId]     
  ,SourceData.[strPurchaseOrderNumber]    
  ,SourceData.[intContractHeaderId]     
  ,SourceData.[intContractDetailId]     
  ,SourceData.[intContractSeqId]      
  ,SourceData.[intContractCostId]      
  ,SourceData.[strContractNumber]      
  ,SourceData.[intScaleTicketId]      
  ,SourceData.[strScaleTicketNumber]     
  ,SourceData.[intInventoryReceiptItemId]    
  ,SourceData.[intInventoryReceiptChargeId]   
  ,SourceData.[intInventoryShipmentItemId]   
  ,SourceData.[intInventoryShipmentChargeId]  
  ,SourceData.[intLoadShipmentId]      
  ,SourceData.[intLoadShipmentDetailId]
  ,SourceData.[intLoadHeaderId]
  ,SourceData.[intItemId]        
  ,SourceData.[strItemNo]        
  ,SourceData.[intPurchaseTaxGroupId]     
  ,SourceData.[strTaxGroup]       
  ,SourceData.[intItemLocationId]     
  ,SourceData.[strItemLocationName]  
  ,SourceData.[intStorageLocationId]     
  ,SourceData.[strStorageLocationName]  
  ,SourceData.[intSubLocationId]     
  ,SourceData.[strSubLocationName]      
  ,SourceData.[strMiscDescription]     
  ,SourceData.[dblOrderQty]       
  ,SourceData.[dblOrderUnitQty]      
  ,SourceData.[intOrderUOMId]       
  ,SourceData.[strOrderUOM]    
  ,SourceData.[dblOrderQty]       
  ,SourceData.[dblQtyToBillUnitQty]     
  ,SourceData.[intQtyToBillUOMId]      
  ,SourceData.[strQtyToBillUOM]      
  ,SourceData.[dblCost]        
  ,SourceData.[dblCostUnitQty]      
  ,SourceData.[intCostUOMId]       
  ,SourceData.[strCostUOM]       
  ,SourceData.[dblNetWeight]       
  ,SourceData.[dblWeightUnitQty]      
  ,SourceData.[intWeightUOMId]      
  ,SourceData.[strWeightUOM]       
  ,SourceData.[intCostCurrencyId]      
  ,SourceData.[strCostCurrency]      
  ,SourceData.[dblTax]        
  ,SourceData.[dblDiscount]       
  ,SourceData.[intCurrencyExchangeRateTypeId]  
  ,SourceData.[strRateType]       
  ,SourceData.[dblExchangeRate]      
  ,SourceData.[ysnSubCurrency]      
  ,SourceData.[intSubCurrencyCents]     
  ,SourceData.[intAccountId]       
  ,SourceData.[strAccountId]       
  ,SourceData.[strAccountDesc]      
  ,SourceData.[intShipViaId]       
  ,SourceData.[strShipVia]       
  ,SourceData.[intTermId]        
  ,SourceData.[strTerm]        
  ,SourceData.[strBillOfLading]      
  ,SourceData.[int1099Form]       
  ,SourceData.[str1099Form]       
  ,SourceData.[int1099Category]    
  ,SourceData.[dbl1099]    
  ,SourceData.[str1099Type]       
  ,SourceData.[ysnReturn]   
 )  
 OUTPUT SourceData.intVoucherPayableId, inserted.intVoucherPayableId INTO @reinsert;  
  
 MERGE INTO tblAPVoucherPayableTaxStaging AS destination  
 USING (  
  SELECT  
   taxes.[intVoucherPayableId]    
   ,taxes.[intTaxGroupId]      
   ,taxes.[intTaxCodeId]      
   ,taxes.[intTaxClassId]      
   ,taxes.[strTaxableByOtherTaxes]   
   ,taxes.[strCalculationMethod]    
   ,taxes.[dblRate]       
   ,taxes.[intAccountId]      
   ,taxes.[dblTax]       
   ,taxes.[dblAdjustedTax]     
   ,taxes.[ysnTaxAdjusted]     
   ,taxes.[ysnSeparateOnBill]     
   ,taxes.[ysnCheckOffTax]     
   ,taxes.[ysnTaxOnly]  
   ,taxes.[ysnTaxExempt]  
  FROM tblAPVoucherPayableTaxCompleted taxes  
  INNER JOIN @reinsert del ON taxes.intVoucherPayableId = del.intVoucherPayableId  
 ) AS SourceData  
 ON (1=0)  
 WHEN NOT MATCHED THEN  
 INSERT (  
  [intVoucherPayableId]    
  ,[intTaxGroupId]      
  ,[intTaxCodeId]      
  ,[intTaxClassId]      
  ,[strTaxableByOtherTaxes]   
  ,[strCalculationMethod]    
  ,[dblRate]       
  ,[intAccountId]      
  ,[dblTax]       
  ,[dblAdjustedTax]     
  ,[ysnTaxAdjusted]     
  ,[ysnSeparateOnBill]     
  ,[ysnCheckOffTax]     
  ,[ysnTaxOnly]  
  ,[ysnTaxExempt]  
 )  
 VALUES (  
  [intVoucherPayableId]    
  ,[intTaxGroupId]      
  ,[intTaxCodeId]      
  ,[intTaxClassId]      
  ,[strTaxableByOtherTaxes]   
  ,[strCalculationMethod]    
  ,[dblRate]       
  ,[intAccountId]      
  ,[dblTax]       
  ,[dblAdjustedTax]     
  ,[ysnTaxAdjusted]     
  ,[ysnSeparateOnBill]     
  ,[ysnCheckOffTax]     
  ,[ysnTaxOnly]  
  ,[ysnTaxExempt]  
 );  
  
 DELETE A  
 FROM tblAPVoucherPayableCompleted A  
 INNER JOIN @reinsert B ON A.intVoucherPayableId = B.intVoucherPayableId  
  
 DELETE A  
 FROM tblAPVoucherPayableTaxCompleted A  
 INNER JOIN @reinsert B ON A.intVoucherPayableId = B.intVoucherPayableId  
      
 --UPDATE QTY AFTER REINSERTING   
 --UPDATE QTY IF THERE ARE STILL QTY LEFT TO BILL   
 --UPDATE B  
 -- SET B.dblQuantityToBill = CASE WHEN @post = 0 THEN (B.dblQuantityToBill + C.dblQuantityToBill)   
 --        ELSE (B.dblQuantityToBill - C.dblQuantityToBill) END,  
 --  B.dblQuantityBilled = CASE WHEN @post = 0 THEN (B.dblQuantityBilled - C.dblQuantityToBill)   
 --        ELSE (B.dblQuantityBilled + C.dblQuantityToBill) END  
 --FROM tblAPVoucherPayable B  
 --CROSS APPLY  
 --(  
 -- SELECT  
 --  SUM(dbo.fnCalculateQtyBetweenUOM(C.intUnitOfMeasureId, B.intQtyToBillUOMId, C.dblQtyReceived)) dblQtyBilled  
 -- FROM tblAPBill A  
 -- INNER JOIN tblAPBillDetail C  
 --  ON A.intBillId = A2.intBillId  
 -- WHERE  
 --  A.intTransactionType = B.intTransactionType  
 -- AND ISNULL(C.intPurchaseDetailId,-1) = ISNULL(B.intPurchaseDetailId,-1)  
 -- AND ISNULL(C.intContractDetailId,-1) = ISNULL(B.intContractDetailId,-1)  
 -- AND ISNULL(A.intEntityVendorId,-1) = ISNULL(B.intEntityVendorId,-1)  
 -- AND ISNULL(C.intScaleTicketId,-1) = ISNULL(B.intScaleTicketId,-1)  
 -- AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(B.intInventoryReceiptChargeId,-1)  
 -- AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(B.intInventoryReceiptItemId,-1)  
 -- AND ISNULL(C.intLoadDetailId,-1) = ISNULL(B.intLoadShipmentDetailId,-1)  
 -- AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(B.intInventoryShipmentChargeId,-1)  
 --) qtyBilled  
  
 --UPDATE A  
 -- SET A.dblTax = taxData.dblTax, A.dblAdjustedTax = taxData.dblAdjustedTax  
 --FROM tblAPVoucherPayableTaxStaging A  
 --INNER JOIN @validPayables B  
 -- ON A.intVoucherPayableId = B.intVoucherPayableId  
 --INNER JOIN tblAPVoucherPayable C  
 -- ON B.intVoucherPayableId = C.intVoucherPayableId  
 --CROSS APPLY (  
 -- SELECT  
 --  *  
 -- FROM dbo.fnAPRecomputeStagingTaxes(A.intVoucherPayableId, B.dblCost, C.dblQuantityToBill) taxes  
 -- WHERE A.intTaxCodeId = taxes.intTaxCodeId AND A.intTaxGroupId = taxes.intTaxGroupId  
 --) taxData  
  
  
RETURN 0  