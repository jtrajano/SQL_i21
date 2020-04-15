CREATE FUNCTION [dbo].[fnAPGetPayableCompletedKeyInfo]  
(  
  @voucherPayables AS VoucherPayable READONLY  
)  
RETURNS TABLE  
AS  
RETURN   
(  
  SELECT  
      C.intVoucherPayableId AS intOldPayableId  
      ,A.intVoucherPayableId AS intNewPayableId  
  FROM tblAPVoucherPayableCompleted A  
  INNER JOIN @voucherPayables C  
      ON  
          A.intTransactionType = C.intTransactionType  
      AND ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)  
      AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)  
      AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)  
      AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)  
      AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)  
      AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)  
      -- AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)  
      AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)  
      AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)  
      AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)  
      AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)  
      AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
      AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
      AND C.ysnStage = 1
      AND C.ysnReturn = A.ysnReturn
)  