﻿CREATE FUNCTION [dbo].[fnGetCustomerTaxCodeExemptionDetails]
( 
	 @CustomerId		INT
	,@TransactionDate	DATETIME
	,@TaxCodeId			INT
	,@TaxClassId		INT
	,@TaxState			NVARCHAR(100)
	,@ItemId			INT
	,@ItemCategoryId	INT
	,@ShipToLocationId	INT
)
RETURNS @returntable TABLE
(
	 [ysnTaxExempt]			BIT
	,[strExemptionNotes]	NVARCHAR(500)
)
AS
BEGIN
	DECLARE @TaxCodeExemption	NVARCHAR(500)
	
	SET @TaxCodeExemption = [dbo].[fnGetCustomerTaxCodeExemption](@CustomerId, @TransactionDate, @TaxCodeId, @TaxClassId, @TaxState, @ItemId, @ItemCategoryId, @ShipToLocationId)	
	
		
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
		 [ysnTaxExempt] = 1
		,[strExemptionNotes] = @TaxCodeExemption
		
		
	RETURN
			
END
