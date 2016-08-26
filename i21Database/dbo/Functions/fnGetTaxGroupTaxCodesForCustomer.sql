CREATE FUNCTION [dbo].[fnGetTaxGroupTaxCodesForCustomer]
(
	 @TaxGroupId			INT
	,@CustomerId			INT
	,@TransactionDate		DATETIME
	,@ItemId				INT
	,@ShipToLocationId		INT
	,@IncludeExemptedCodes	BIT
	,@IsCustomerSiteTaxable	BIT
	,@CardId				INT
	,@VehicleId				INT
)
RETURNS @returntable TABLE
(
	 [intTransactionDetailTaxId]	INT
	,[intTransactionDetailId]		INT
	,[intTaxGroupId]				INT
	,[intTaxCodeId]					INT
	,[intTaxClassId]				INT
	,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
	,[strCalculationMethod]			NVARCHAR(30)
	,[dblRate]						NUMERIC(18,6)
	,[dblExemptionPercent]			NUMERIC(18,6)
	,[dblTax]						NUMERIC(18,6)
	,[dblAdjustedTax]				NUMERIC(18,6)
	,[intTaxAccountId]				INT
	,[ysnSeparateOnInvoice]			BIT
	,[ysnCheckoffTax]				BIT
	,[strTaxCode]					NVARCHAR(100)						
	,[ysnTaxExempt]					BIT
	,[ysnInvalidSetup]				BIT
	,[strTaxGroup]					NVARCHAR(100)
	,[strNotes]						NVARCHAR(500)
)
AS
BEGIN

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@ItemCategoryId INT

	SET @ZeroDecimal = 0.000000
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId 
	
	INSERT INTO @returntable
		([intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		)
	SELECT
		 [intTransactionDetailTaxId]	= 0
		,[intTransactionDetailId]		= 0
		,[intTaxGroupId]				= TG.[intTaxGroupId] 
		,[intTaxCodeId]					= TC.[intTaxCodeId]
		,[intTaxClassId]				= TC.[intTaxClassId]				
		,[strTaxableByOtherTaxes]		= TC.[strTaxableByOtherTaxes]
		,[strCalculationMethod]			= R.[strCalculationMethod]
		,[dblRate]						= R.[dblRate]
		,[dblExemptionPercent]			= E.[dblExemptionPercent]
		,[dblTax]						= @ZeroDecimal
		,[dblAdjustedTax]				= @ZeroDecimal
		,[intTaxAccountId]				= TC.[intSalesTaxAccountId]
		,[ysnSeparateOnInvoice]			= 0
		,[ysnCheckoffTax]				= TC.[ysnCheckoffTax]
		,[strTaxCode]					= TC.[strTaxCode]
		,[ysnTaxExempt]					= E.[ysnTaxExempt]
		,[ysnInvalidSetup]				= E.[ysnInvalidSetup]
		,[strTaxGroup]					= TG.[strTaxGroup]
		,[strNotes]						= E.[strExemptionNotes]
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	CROSS APPLY
		[dbo].[fnGetCustomerTaxCodeExemptionDetails](@CustomerId, @TransactionDate, TC.[intTaxCodeId], TC.[intTaxClassId], TC.[strState], @ItemId, @ItemCategoryId, @ShipToLocationId, @IsCustomerSiteTaxable, @CardId, @VehicleId) E
	CROSS APPLY
		[dbo].[fnGetTaxCodeRateDetails](TC.[intTaxCodeId], @TransactionDate) R			
	WHERE
		TG.intTaxGroupId = @TaxGroupId
		AND (ISNULL(E.ysnTaxExempt,0) = 0 OR ISNULL(@IncludeExemptedCodes,0) = 1)
	ORDER BY
		TGC.[intTaxGroupCodeId]

	RETURN				
END