CREATE FUNCTION [dbo].[fnAPGetTaxesFromIRItem]
(
	@intInventoryReceiptItemId INT
)
RETURNS @returntable TABLE
(
	[intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
	[strTaxCode] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate] NUMERIC(18, 6) NULL, 
    [intAccountId] INT NULL, 
    [dblTax] NUMERIC(18, 6) NULL, 
    [dblAdjustedTax] NUMERIC(18, 6) NULL, 
	[ysnTaxAdjusted] BIT NULL DEFAULT ((0)), 
	[ysnSeparateOnBill] BIT NULL DEFAULT ((0)), 
	[ysnCheckoffTax] BIT NULL DEFAULT ((0))
)
AS
BEGIN
	INSERT @returntable
	SELECT
		[intTaxGroupMasterId]	=	A.intTaxGroupMasterId, 
		[intTaxGroupId]			=	A.intTaxGroupId, 
		[intTaxCodeId]			=	A.intTaxCodeId, 
		[intTaxClassId]			=	A.intTaxClassId, 
		[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	A.strCalculationMethod, 
		[strTaxCode]			=	A.strTaxCode,
		[dblRate]				=	A.dblRate, 
		[intAccountId]			=	A.intTaxAccountId, 
		[dblTax]				=	A.dblTax, 
		[dblAdjustedTax]		=	A.dblAdjustedTax, 
		[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	A.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	A.ysnCheckoffTax
	FROM tblICInventoryReceiptItemTax A
	WHERE A.intInventoryReceiptItemId = @intInventoryReceiptItemId

	RETURN
END
