CREATE FUNCTION [dbo].[fnGetTaxCodeRateDetails]
( 
	 @TaxCodeId						INT
	,@TransactionDate				DATETIME
	,@ItemUOMId						INT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
)
RETURNS @returntable TABLE
(
	 [strCalculationMethod]	NVARCHAR(30) COLLATE Latin1_General_CI_AS
	,[intUnitMeasureId]		INT NULL
	,[dblRate]				NUMERIC(18,6)
	,[dblBaseRate]			NUMERIC(18,6)
	,[strUnitMeasure]		NVARCHAR(30) COLLATE Latin1_General_CI_AS

)
AS
BEGIN
	DECLARE @ExchangeRate NUMERIC(18,6) = NULL
	DECLARE @DefaultCurrencyId INT
	DECLARE @ToBse BIT = 1

	SET @ExchangeRate = @CurrencyExchangeRate
	IF ISNULL(@ExchangeRate, 0.000000) = 0.000000
		SET @ExchangeRate = 1.000000

	SELECT TOP 1 @DefaultCurrencyId = [intDefaultCurrencyId] FROM tblSMCompanyPreference
	IF @CurrencyExchangeRateTypeId IS NOT NULL AND ISNULL(@CurrencyExchangeRate, 0.000000) = 0.000000
		BEGIN
			SET @ToBse = 1
			SELECT TOP 1
				@ExchangeRate =  SMCERD.[dblRate]
			FROM			
				tblSMCurrencyExchangeRateType SMCERT
			INNER JOIN
				tblSMCurrencyExchangeRateDetail SMCERD
					ON SMCERT.[intCurrencyExchangeRateTypeId] = SMCERD.[intRateTypeId]
			INNER JOIN
				tblSMCurrencyExchangeRate SMCER
					ON SMCERD.[intCurrencyExchangeRateId] = SMCER.[intCurrencyExchangeRateId]
			WHERE
				SMCERT.[intCurrencyExchangeRateTypeId] = @CurrencyExchangeRateTypeId
				AND dbo.fnDateLessThanEquals(SMCERD.[dtmValidFromDate], @TransactionDate) = 1
				AND SMCER.[intToCurrencyId] = @DefaultCurrencyId
				AND SMCER.[intFromCurrencyId] = @CurrencyId
			ORDER BY
				SMCERD.[dtmValidFromDate] DESC

			IF @ExchangeRate IS NULL
				BEGIN
					SET @ToBse = 0
					SELECT TOP 1
						@ExchangeRate =  SMCERD.[dblRate]
					FROM			
						tblSMCurrencyExchangeRateType SMCERT
					INNER JOIN
						tblSMCurrencyExchangeRateDetail SMCERD
							ON SMCERT.[intCurrencyExchangeRateTypeId] = SMCERD.[intRateTypeId]
					INNER JOIN
						tblSMCurrencyExchangeRate SMCER
							ON SMCERD.[intCurrencyExchangeRateId] = SMCER.[intCurrencyExchangeRateId]
					WHERE
						SMCERT.[intCurrencyExchangeRateTypeId] = @CurrencyExchangeRateTypeId
						AND dbo.fnDateLessThanEquals(SMCERD.[dtmValidFromDate], @TransactionDate) = 1
						AND SMCER.[intToCurrencyId] = @CurrencyId
						AND SMCER.[intFromCurrencyId] = @DefaultCurrencyId
					ORDER BY
						SMCERD.[dtmValidFromDate] DESC
				END
		END		


	INSERT INTO @returntable
	SELECT TOP 1 
		 [strCalculationMethod]	= SMTCR.[strCalculationMethod]
		,[intUnitMeasureId]		= SMTCR.[intUnitMeasureId]
		,[dblRate]				= CASE WHEN SMTCR.[strCalculationMethod] <> 'Unit' THEN SMTCR.[dblRate] ELSE (CASE WHEN @ToBse = 1 THEN SMTCR.[dblRate] / @ExchangeRate ELSE SMTCR.[dblRate] * @ExchangeRate END) END
		,[dblBaseRate]			= SMTCR.[dblRate]
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
			WHEN SMTCR.[strCalculationMethod] <> 'Unit' THEN 6
			ELSE 1
		 END) DESC
		,SMTCR.[dtmEffectiveDate] DESC
		,SMTCR.[dblRate] DESC					
		
	RETURN
			
END