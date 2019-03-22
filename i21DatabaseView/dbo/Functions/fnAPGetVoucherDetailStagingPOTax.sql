CREATE FUNCTION [dbo].[fnAPGetVoucherDetailStagingPOTax]
(
	@voucherPayableId INT
)
RETURNS TABLE AS RETURN
(
	SELECT
		[intTaxGroupId]				=	A.intTaxGroupId, 
		[intTaxCodeId]				=	A.intTaxCodeId, 
		[intTaxClassId]				=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]	=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]		=	A.strCalculationMethod, 
		[dblRate]					=	A.dblRate, 
		[intAccountId]				=	A.intAccountId, 
		[dblTax]					=	A.dblTax, 
		[dblAdjustedTax]			=	ISNULL(A.dblAdjustedTax,0), 
		[ysnTaxAdjusted]			=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]			=	A.ysnSeparateOnBill, 
		[ysnCheckOffTax]			=	A.ysnCheckOffTax,
		[strTaxCode]				=	D.strTaxCode,
		[ysnTaxOnly]				=	A.ysnTaxOnly,
		[ysnTaxExempt]				=	A.ysnTaxExempt
	FROM tblAPVoucherPayableTaxStaging A
	INNER JOIN tblSMTaxCode D ON D.intTaxCodeId = A.intTaxCodeId
	WHERE A.intVoucherPayableId = @voucherPayableId
)
