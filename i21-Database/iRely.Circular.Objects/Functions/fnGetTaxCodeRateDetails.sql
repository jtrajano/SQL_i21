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
	,[strUnitMeasure]		NVARCHAR(30) COLLATE Latin1_General_CI_AS

)
AS
BEGIN	
	INSERT INTO @returntable
	SELECT TOP 1 
		 [strCalculationMethod]	= SMTCR.[strCalculationMethod]
		,[intUnitMeasureId]		= SMTCR.[intUnitMeasureId]
		,[dblRate]				= SMTCR.[dblRate]
		,[strUnitMeasure]		= UOM.[strUnitMeasure]
	FROM 
		tblSMTaxCodeRate SMTCR
	LEFT OUTER JOIN
		(
		SELECT
			 ICUOM.[intItemUOMId]
			,ICUM.[intUnitMeasureId]
			,ICUM.[strUnitMeasure]
		FROM
			tblICItemUOM ICUOM
		INNER JOIN
			tblICUnitMeasure ICUM
				ON ICUOM.[intUnitMeasureId] = ICUM.[intUnitMeasureId]
		) UOM
			ON SMTCR.[intUnitMeasureId] = UOM.[intUnitMeasureId]
	WHERE 
		SMTCR.[intTaxCodeId] = @TaxCodeId
		AND ( 
				(SMTCR.[strCalculationMethod] = 'Unit' AND (UOM.[intItemUOMId] = @ItemUOMId AND @ItemUOMId IS NOT NULL)) 
			OR 
				(SMTCR.[strCalculationMethod] = 'Unit' AND SMTCR.[intUnitMeasureId] IS NULL) 
			OR 
				(SMTCR.[strCalculationMethod] <> 'Unit')
			)
		AND CAST(@TransactionDate AS DATE) >= CAST([dtmEffectiveDate]  AS DATE)
	ORDER BY 
		 (CASE 
			WHEN SMTCR.[strCalculationMethod] = 'Unit' AND (UOM.[intItemUOMId] = @ItemUOMId AND @ItemUOMId IS NOT NULL) THEN 4
			WHEN SMTCR.[strCalculationMethod] = 'Unit' AND SMTCR.[intUnitMeasureId] IS NULL THEN 3
			WHEN SMTCR.[strCalculationMethod] <> 'Unit' THEN 2
			ELSE 1
		 END) DESC
		,SMTCR.[dtmEffectiveDate] DESC
		,SMTCR.[dblRate] DESC					
		
	RETURN
			
END