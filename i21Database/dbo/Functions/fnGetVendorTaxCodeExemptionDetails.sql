CREATE FUNCTION [dbo].[fnGetVendorTaxCodeExemptionDetails]
( 
	 @VendorId				INT
	,@TransactionDate		DATETIME
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
	,[strExemptionNotes]	NVARCHAR(500)
)
AS
BEGIN
	DECLARE @TaxCodeExemption	NVARCHAR(500)
	
	SET @TaxCodeExemption = [dbo].[fnGetVendorTaxCodeExemption](@VendorId, @TransactionDate, @TaxCodeId, @TaxClassId, @TaxState, @ItemId, @ItemCategoryId, @ShipFromLocationId)	
	
		
	IF LEN(RTRIM(LTRIM(ISNULL(@TaxCodeExemption,'')))) > 0
		BEGIN
			INSERT INTO @returntable
			SELECT 
				 [ysnTaxExempt] = 1
				,[strExemptionNotes] = @TaxCodeExemption
				
			RETURN
		END
		
		
	INSERT INTO @returntable
	SELECT 
		 [ysnTaxExempt] = 0
		,[strExemptionNotes] = @TaxCodeExemption
		
		
	RETURN
END
