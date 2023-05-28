CREATE FUNCTION [dbo].[fnAPCreateVoucherPayableTaxFromDetail]
(
	@voucherDetailIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		D.[intBillDetailId]
		,D.[intTaxGroupId]				
		,D.[intTaxCodeId]				
		,D.[intTaxClassId]				
		,D.[strTaxableByOtherTaxes]	
		,D.[strCalculationMethod]		
		,D.[dblRate]					
		,D.[intAccountId]				
		,D.[dblTax]					
		,D.[dblAdjustedTax]			
		,D.[ysnTaxAdjusted]			
		,D.[ysnSeparateOnBill]			
		,D.[ysnCheckOffTax]			
		,D.[ysnTaxExempt]              
		,D.[ysnTaxOnly]	
		,B.[ysnStage]			
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherDetailIds C ON B.intBillDetailId = C.intId
	INNER JOIN tblAPBillDetailTax D ON C.intId = D.intBillDetailId
	WHERE
		A.intTransactionType IN (1,3,11,16) --voucher,claim and debit memo are only on payables table
	AND B.ysnOverrideTaxGroup = 0
	UNION ALL --GET TAX FROM RECEIPT IF OVERRIDE TAX GROUP IS ENABLED
	SELECT
		B.[intBillDetailId]
		,E.[intTaxGroupId]				
		,E.[intTaxCodeId]				
		,E.[intTaxClassId]				
		,E.[strTaxableByOtherTaxes]	
		,E.[strCalculationMethod]		
		,E.[dblRate]					
		,E.[intTaxAccountId]				
		,E.[dblTax]					
		,E.[dblAdjustedTax]			
		,E.[ysnTaxAdjusted]			
		,E.[ysnSeparateOnInvoice]			
		,E.[ysnCheckoffTax]			
		,E.[ysnTaxExempt]              
		,E.[ysnTaxOnly]	
		,B.[ysnStage]			
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @voucherDetailIds C ON B.intBillDetailId = C.intId
	INNER JOIN tblICInventoryReceiptItem D ON B.intInventoryReceiptItemId = D.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceiptItemTax E ON D.intInventoryReceiptItemId = E.intInventoryReceiptItemId
	WHERE
		A.intTransactionType IN (1,3,11,16) --voucher,claim and debit memo are only on payables table
	AND B.intInventoryReceiptChargeId IS NULL
	AND B.ysnOverrideTaxGroup = 1
)
