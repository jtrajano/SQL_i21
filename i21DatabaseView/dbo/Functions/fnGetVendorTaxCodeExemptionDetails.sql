CREATE FUNCTION [dbo].[fnGetVendorTaxCodeExemptionDetails]
( 
	 @VendorId				INT
	,@TransactionDate		DATETIME
	,@TaxGroupId			INT
	,@TaxCodeId				INT
	,@TaxClassId			INT
	,@TaxState				NVARCHAR(100)
	,@ItemId				INT
	,@ItemCategoryId		INT
	,@ShipFromLocationId	INT
)
RETURNS @returntable TABLE
(
	 [ysnTaxExempt]			BIT
	,[ysnInvalidSetup]		BIT
	,[strExemptionNotes]	NVARCHAR(500)
	,[dblExemptionPercent]	NUMERIC(18,6)
)
AS
BEGIN
	DECLARE	@TaxCodeExemption	NVARCHAR(500)
			,@ExemptionPercent	NUMERIC(18,6)
			,@TaxExempt			BIT
			,@InvalidSetup		BIT
	
	SELECT 
		@TaxCodeExemption	= TED.strExemptionNotes 
		,@ExemptionPercent	= TED.[dblExemptionPercent] 
		,@TaxExempt			= TED.[ysnTaxExempt] 
		,@InvalidSetup		= TED.[ysnInvalidSetup]  
	FROM
		[dbo].[fnGetVendorTaxCodeExemption](@VendorId, @TransactionDate, @TaxGroupId, @TaxCodeId, @TaxClassId, @TaxState, @ItemId, @ItemCategoryId, @ShipFromLocationId)	TED
	
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = @TaxExempt
				,[ysnInvalidSetup] = @InvalidSetup
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent]	= @ExemptionPercent
				
			RETURN
		END
		
		
	INSERT INTO @returntable
	SELECT 
		 [ysnTaxExempt] = @TaxExempt
		,[ysnInvalidSetup] = @InvalidSetup
		,[strExemptionNotes] = @TaxCodeExemption
		,[dblExemptionPercent]	= @ExemptionPercent
		
		
	RETURN
END
