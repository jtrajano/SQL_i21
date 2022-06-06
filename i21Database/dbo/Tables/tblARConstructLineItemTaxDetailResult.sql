CREATE TABLE tblARConstructLineItemTaxDetailResult  (
	 [intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblBaseRate]					NUMERIC(18,6)
	,[dblExemptionPercent]			NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnTaxOnly]					BIT
	,[ysnInvalidSetup]				BIT
	,[strNotes]						NVARCHAR(500)
	,[dblExemptionAmount]			NUMERIC(18,6)
	,[intLineItemId]				INT NULL --intDetailId
	,[strRequestId]					NVARCHAR(100)
); 
GO
CREATE NONCLUSTERED INDEX [NC_Index_tblARConstructLineItemTaxDetailResult]
    ON [dbo].tblARConstructLineItemTaxDetailResult ([strRequestId])
GO