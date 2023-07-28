--liquibase formatted sql

-- changeset Von:fnAPGetVoucherDetailReceiptChargeTax.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPGetVoucherDetailReceiptChargeTax]
(
	@intInventoryReceiptChargeId INT
)
RETURNS TABLE AS RETURN
(
	SELECT 
		[intTaxGroupId]				= A.intTaxGroupId,
		[intTaxCodeId]				= A.intTaxCodeId,
		[intTaxClassId]				= A.intTaxClassId,
		[strTaxableByOtherTaxes]	= A.strTaxableByOtherTaxes COLLATE Latin1_General_CI_AS,
		[strCalculationMethod]		= A.strCalculationMethod COLLATE Latin1_General_CI_AS,
		[dblRate]					= A.dblRate,
		[intAccountId]				= A.intTaxAccountId,
		[dblTax]					= A.dblTax,
		[dblAdjustedTax]			= ISNULL(NULLIF(A.dblAdjustedTax,0),A.dblTax),
		[ysnTaxAdjusted]			= A.ysnTaxAdjusted,
		[ysnSeparateOnBill]			= CAST(0 AS BIT),
		[ysnCheckOffTax]			= A.ysnCheckoffTax,
		[strTaxCode]				= A.strTaxCode,
		[ysnTaxOnly]				= A.ysnTaxOnly
	FROM tblICInventoryReceiptChargeTax A
	LEFT JOIN dbo.tblICInventoryReceiptCharge B ON A.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	WHERE B.intInventoryReceiptChargeId = @intInventoryReceiptChargeId
)



