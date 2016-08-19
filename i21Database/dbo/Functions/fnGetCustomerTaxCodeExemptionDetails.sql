CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemptionDetails]
( 
	 @CustomerId			INT
	,@TransactionDate		DATETIME
	,@TaxGroupId			INT
	,@TaxCodeId				INT
	,@TaxClassId			INT
	,@TaxState				NVARCHAR(100)
	,@ItemId				INT
	,@ItemCategoryId		INT
	,@ShipToLocationId		INT
	,@IsCustomerSiteTaxable	BIT
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

	SET @TaxCodeExemption = NULL
	SET @ExemptionPercent = 0.00000
	SET @TaxExempt = 0
	SET @InvalidSetup = 0
	
	
	SELECT 
		@TaxCodeExemption	= TED.strExemptionNotes 
		,@ExemptionPercent	= TED.[dblExemptionPercent] 
		,@TaxExempt			= TED.[ysnTaxExempt] 
		,@InvalidSetup		= TED.[ysnInvalidSetup]  
	FROM
		[dbo].[fnGetCustomerTaxCodeExemption](@CustomerId, @TransactionDate, @TaxGroupId, @TaxCodeId, @TaxClassId, @TaxState, @ItemId, @ItemCategoryId, @ShipToLocationId, @IsCustomerSiteTaxable) TED
	
		
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
