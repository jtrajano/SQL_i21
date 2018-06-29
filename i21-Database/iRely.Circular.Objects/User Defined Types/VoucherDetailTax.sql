CREATE TYPE [dbo].[VoucherDetailTax] AS TABLE
(
    [intBillDetailId]			INT NOT NULL, 
    [intTaxGroupMasterId]		INT NULL, 
    [intTaxGroupId]				INT NOT NULL, 
    [intTaxCodeId]				INT NOT NULL, 
    [intTaxClassId]				INT NOT NULL, 
	[strTaxableByOtherTaxes]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]		NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intAccountId]				INT NOT NULL, 
    [dblTax]					DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblAdjustedTax]			DECIMAL(18, 6) NOT NULL, 
	[ysnTaxAdjusted]			BIT NOT NULL DEFAULT 0, 
	[ysnSeparateOnBill]			BIT NOT NULL DEFAULT 0, 
	[ysnCheckOffTax]			BIT NOT NULL DEFAULT 0
)
