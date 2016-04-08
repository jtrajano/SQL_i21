CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemptionDetails]
( 
	 @CustomerId			INT
	,@TransactionDate		DATETIME
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
	,[strExemptionNotes]	NVARCHAR(500)
	,[dblExemptionPercent]	NUMERIC(18,6)
)
AS
BEGIN
	DECLARE	@TaxCodeExemption	NVARCHAR(500)
			,@ExemptionPercent	NUMERIC(18,6)
			,@TaxExempt			BIT

	SET @TaxCodeExemption = NULL
	SET @ExemptionPercent = 0.00000
	SET @TaxExempt = 0
	
	
	SELECT 
		@TaxCodeExemption	= TED.strExemptionNotes 
		,@ExemptionPercent	= TED.[dblExemptionPercent] 
		,@TaxExempt			= TED.[ysnTaxExempt] 
	FROM
		[dbo].[fnGetCustomerTaxCodeExemption](@CustomerId, @TransactionDate, @TaxCodeId, @TaxClassId, @TaxState, @ItemId, @ItemCategoryId, @ShipToLocationId, @IsCustomerSiteTaxable) TED
	
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = @TaxExempt
				,[strExemptionNotes] = @TaxCodeExemption
				,[dblExemptionPercent]	= @ExemptionPercent

			RETURN
		END
		
		
	INSERT INTO @returntable
	SELECT 
		 [ysnTaxExempt] = @TaxExempt
		,[strExemptionNotes] = @TaxCodeExemption
		,[dblExemptionPercent]	= @ExemptionPercent
		
		
	RETURN
			
END
