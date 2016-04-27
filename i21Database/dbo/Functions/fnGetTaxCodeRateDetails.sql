CREATE FUNCTION [dbo].[fnGetTaxCodeRateDetails]
( 
	 @TaxCodeId			INT
	,@TransactionDate	DATETIME	
)
RETURNS @returntable TABLE
(
	 [strCalculationMethod]	NVARCHAR(30)
	,[dblRate]				NUMERIC(18,6)

)
AS
BEGIN	
	
	INSERT INTO @returntable
	SELECT TOP 1 
		 [strCalculationMethod]
		,[dblRate]
	FROM 
		tblSMTaxCodeRate
	WHERE 
		[intTaxCodeId] = @TaxCodeId 
		AND CAST(@TransactionDate AS DATE) >= CAST([dtmEffectiveDate]  AS DATE)
	ORDER BY 
		 [dtmEffectiveDate] DESC
		,[dblRate] DESC					
		
	RETURN
			
END
