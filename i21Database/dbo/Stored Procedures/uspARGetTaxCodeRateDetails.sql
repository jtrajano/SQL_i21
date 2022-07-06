CREATE PROCEDURE uspARGetTaxCodeRateDetails
	@TaxCodeRateParam	TaxCodeRateParam READONLY
AS

DECLARE @TaxCodeRate TaxCodeRateParam

INSERT INTO @TaxCodeRate
SELECT * FROM @TaxCodeRateParam

IF(OBJECT_ID('tempdb..##TAXCODERATEDETAILS') IS NOT NULL) DROP TABLE ##TAXCODERATEDETAILS
CREATE TABLE ##TAXCODERATEDETAILS
(
	 [strCalculationMethod]	NVARCHAR(30) COLLATE Latin1_General_CI_AS
	,[intUnitMeasureId]		INT NULL
	,[dblRate]				NUMERIC(18,6)
	,[dblBaseRate]			NUMERIC(18,6)
	,[strUnitMeasure]		NVARCHAR(30) COLLATE Latin1_General_CI_AS
    ,[ysnInvalidSetup]      BIT
	,[intTaxGroupId]		INT NULL
	,[intTaxCodeId]			INT NULL
	,[intItemUOMId]			INT NULL
	,[intCurrencyId]		INT NULL
	,[intLineItemId]		INT NULL
)

DECLARE @intAccountsReceivableRateTypeId	INT = NULL
	  , @intDefaultCurrencyId				INT = NULL

SELECT TOP 1 @intAccountsReceivableRateTypeId = intAccountsReceivableRateTypeId 
FROM tblSMMultiCurrency 
ORDER BY intMultiCurrencyId

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId
FROM tblSMCompanyPreference
ORDER BY intCompanyPreferenceId

UPDATE P
SET dblExchangeRate = CASE WHEN dblCurrencyExchangeRate = 0 OR dblCurrencyExchangeRate IS NULL THEN 1 ELSE dblCurrencyExchangeRate END
FROM @TaxCodeRate P

UPDATE P
SET dblCurrencyExchangeRate			= ISNULL(FOREX.dblCurrencyExchangeRate, 1)
  , intCurrencyExchangeRateTypeId	= FOREX.intCurrencyExchangeRateTypeId
FROM @TaxCodeRate P
CROSS APPLY (
	SELECT TOP 1 intCurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
			   , dblCurrencyExchangeRate		= dblRate
	FROM vyuSMForex
	WHERE intFromCurrencyId = P.intCurrencyId
	  AND intCurrencyExchangeRateTypeId = @intAccountsReceivableRateTypeId 
	  AND intToCurrencyId = @intDefaultCurrencyId
	  AND CAST(P.dtmTransactionDate AS DATE) >= CAST([dtmValidFromDate] AS DATE) 
	ORDER BY [dtmValidFromDate] DESC
) FOREX
WHERE P.intCurrencyExchangeRateTypeId IS NULL 
   OR P.intCurrencyExchangeRateTypeId = 0
   	
UPDATE P
SET dblExchangeRate	= FOREX.dblRate
  , ysnBSE			= 1
FROM @TaxCodeRate P
CROSS APPLY (
	SELECT TOP 1 SMCERD.[dblRate]
	FROM tblSMCurrencyExchangeRateType SMCERT
	INNER JOIN tblSMCurrencyExchangeRateDetail SMCERD ON SMCERT.[intCurrencyExchangeRateTypeId] = SMCERD.[intRateTypeId]
	INNER JOIN tblSMCurrencyExchangeRate SMCER ON SMCERD.[intCurrencyExchangeRateId] = SMCER.[intCurrencyExchangeRateId]
	WHERE SMCERT.[intCurrencyExchangeRateTypeId] = P.intCurrencyExchangeRateTypeId
		AND dbo.fnDateLessThanEquals(SMCERD.[dtmValidFromDate], P.dtmTransactionDate) = 1
		AND SMCER.[intToCurrencyId] = @intDefaultCurrencyId
    	AND SMCER.[intFromCurrencyId] = P.intCurrencyId
	ORDER BY
		SMCERD.[dtmValidFromDate] DESC
) FOREX
WHERE P.intCurrencyExchangeRateTypeId <> 1

UPDATE P
SET dblExchangeRate	= FOREX.dblRate
  , ysnBSE			= 0
FROM @TaxCodeRate P
CROSS APPLY (
	SELECT TOP 1 SMCERD.[dblRate]
	FROM tblSMCurrencyExchangeRateType SMCERT
	INNER JOIN tblSMCurrencyExchangeRateDetail SMCERD ON SMCERT.[intCurrencyExchangeRateTypeId] = SMCERD.[intRateTypeId]
	INNER JOIN tblSMCurrencyExchangeRate SMCER ON SMCERD.[intCurrencyExchangeRateId] = SMCER.[intCurrencyExchangeRateId]
	WHERE SMCERT.[intCurrencyExchangeRateTypeId] = P.intCurrencyExchangeRateTypeId
		AND dbo.fnDateLessThanEquals(SMCERD.[dtmValidFromDate], P.dtmTransactionDate) = 1
		AND SMCER.[intToCurrencyId] = P.intCurrencyId
    	AND SMCER.[intFromCurrencyId] = @intDefaultCurrencyId
	ORDER BY
		SMCERD.[dtmValidFromDate] DESC
) FOREX
WHERE P.intCurrencyExchangeRateTypeId <> 1
  AND P.dblExchangeRate = 0
	
INSERT INTO ##TAXCODERATEDETAILS (
	  [strCalculationMethod]
	, [intUnitMeasureId]
	, [dblRate]
	, [dblBaseRate]
	, [strUnitMeasure]
	, [ysnInvalidSetup]
	, [intTaxGroupId]
	, [intTaxCodeId]
	, [intItemUOMId]
	, [intCurrencyId]
	, [intLineItemId]
)
SELECT [strCalculationMethod]	= RATE.[strCalculationMethod]
	, [intUnitMeasureId]		= RATE.[intUnitMeasureId]
	, [dblRate]					= CASE WHEN RATE.[strCalculationMethod] <> 'Unit' THEN RATE.[dblRate] ELSE (CASE WHEN P.ysnBSE = 1 THEN RATE.[dblRate] / P.dblExchangeRate ELSE RATE.[dblRate] * P.dblExchangeRate END) END
	, [dblBaseRate]				= RATE.[dblRate]
    , [strUnitMeasure]			= RATE.[strUnitMeasure]
    , [ysnInvalidSetup]			= CAST(0 AS BIT)
	, [intTaxGroupId]			= P.intTaxGroupId
	, [intTaxCodeId]			= P.intTaxCodeId
	, [intItemUOMId]			= P.intItemUOMId
	, [intCurrencyId]			= P.intCurrencyId
	, [intLineItemId]			= P.intLineItemId
FROM @TaxCodeRate P
CROSS APPLY (
	SELECT TOP 1 SMTCR.*, UOM.[strUnitMeasure]
	FROM tblSMTaxCodeRate SMTCR 
	LEFT OUTER JOIN (
		SELECT ICUOM.intItemUOMId
				, ICUM.intUnitMeasureId
				, ICUM.strUnitMeasure
		FROM tblICItemUOM ICUOM
		INNER JOIN tblICUnitMeasure ICUM ON ICUOM.intUnitMeasureId = ICUM.intUnitMeasureId
	) UOM ON SMTCR.intUnitMeasureId = UOM.intUnitMeasureId AND P.intItemUOMId = UOM.intItemUOMId
	WHERE SMTCR.intTaxCodeId = P.intTaxCodeId
	    AND ( 
				(SMTCR.[strCalculationMethod] = 'Unit' AND (UOM.[intItemUOMId] = P.intItemUOMId AND P.intItemUOMId IS NOT NULL)) 
			OR 
				(SMTCR.[strCalculationMethod] = 'Unit' AND SMTCR.[intUnitMeasureId] IS NULL) 
			OR 
				(SMTCR.[strCalculationMethod] <> 'Unit')
			)
		AND ((CAST(P.dtmTransactionDate AS TIME) = '00:00:00:000' AND CAST(P.dtmTransactionDate AS DATE) >= CAST(SMTCR.dtmEffectiveDate AS DATE)) OR 
				(CAST(P.dtmTransactionDate AS TIME) <> '00:00:00:000' AND P.dtmTransactionDate >= SMTCR.dtmEffectiveDate))
	ORDER BY 
				(CASE 
				WHEN SMTCR.[strCalculationMethod] = 'Unit' AND (UOM.[intItemUOMId] = P.intItemUOMId AND P.intItemUOMId IS NOT NULL) THEN 4
				WHEN SMTCR.[strCalculationMethod] = 'Unit' AND SMTCR.[intUnitMeasureId] IS NULL THEN 3
				WHEN SMTCR.[strCalculationMethod] <> 'Unit' THEN 2
				ELSE 1
				END) DESC
			,SMTCR.[dtmEffectiveDate] DESC
			,SMTCR.[dblRate] DESC	
) RATE
		
IF NOT EXISTS(SELECT NULL FROM ##TAXCODERATEDETAILS)
	INSERT INTO ##TAXCODERATEDETAILS
	SELECT [strCalculationMethod]	= ''
		 , [intUnitMeasureId]		= NULL
		 , [dblRate]				= 0.000000
		 , [dblBaseRate]			= 0.000000
		 , [strUnitMeasure]			= ''
		 , [ysnInvalidSetup]		= CAST(1 AS BIT)	
		 , [intTaxGroupId]			= P.intTaxGroupId
		 , [intTaxCodeId]			= P.intTaxCodeId
		 , [intItemUOMId]			= P.intItemUOMId
		 , [intCurrencyId]			= P.intCurrencyId
		 , [intLineItemId]			= P.intLineItemId
	FROM @TaxCodeRate P			