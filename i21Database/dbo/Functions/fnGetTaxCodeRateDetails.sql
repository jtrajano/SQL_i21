CREATE FUNCTION [dbo].[fnGetTaxCodeRateDetails]
( 
	 @TaxCodeId			INT
	,@TransactionDate	DATETIME
	,@ItemUOMId			INT = NULL	
)
RETURNS @returntable TABLE
(
	 [strCalculationMethod]	NVARCHAR(30) COLLATE Latin1_General_CI_AS
	,[intUnitMeasureId]		INT NULL
	,[dblRate]				NUMERIC(18,6)

)
AS
BEGIN	
	INSERT INTO @returntable
	SELECT TOP 1 
		 [strCalculationMethod]
		,[intUnitMeasureId]
		,[dblRate]
	FROM 
		tblSMTaxCodeRate
	WHERE 
		[intTaxCodeId] = @TaxCodeId
		AND CASE WHEN strCalculationMethod = 'Unit' THEN
				 CASE WHEN intUnitMeasureId = @ItemUOMId THEN 1 ELSE 0 END
		ELSE
			1
		END = 1
		--AND CASE WHEN intUnitMeasureId IS NOT NULL THEN 
		--			CASE WHEN intUnitMeasureId = @ItemUOMId THEN 1 ELSE 0 END
		--	ELSE 1 END = 1
		AND CAST(@TransactionDate AS DATE) >= CAST([dtmEffectiveDate]  AS DATE)
	ORDER BY 
		 [dtmEffectiveDate] DESC
		,[dblRate] DESC					
		
	RETURN
			
END