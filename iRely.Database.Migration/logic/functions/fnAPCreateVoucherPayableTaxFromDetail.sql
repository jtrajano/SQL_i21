--liquibase formatted sql

-- changeset Von:fnAPCreateVoucherPayableTaxFromDetail.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPCreateVoucherPayableTaxFromDetail]
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
		A.intTransactionType IN (1,3) --voucher and debit memo are only on payables table
)



