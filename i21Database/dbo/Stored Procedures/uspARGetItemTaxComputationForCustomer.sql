CREATE PROCEDURE [dbo].[uspARGetItemTaxComputationForCustomer]
	@ItemTaxComputationForCustomerParam		ItemTaxComputationForCustomerParam READONLY
AS 
BEGIN	
	DECLARE @TaxableByOtherTaxesTable TABLE (
		  [intTaxCodeId]			INT
		, [intTaxableTaxCodeId]		INT
	)
	DECLARE @TaxableByOtherTaxes TABLE (
		  [Id]						INT
		, [intTaxCodeId]			INT
		, [strTaxableByOtherTaxes]	NVARCHAR(MAX)
		, [strCalculationMethod]	NVARCHAR(30)
		, [dblRate]					NUMERIC(18,6)
		, [dblAdjustedTax]			NUMERIC(18,6)
		, [ysnTaxAdjusted]			BIT
		, [ysnTaxExempt]			BIT
		, [ysnTaxOnly]				BIT
	)	
	DECLARE @CustomerTaxGroupIdParam			CustomerTaxGroupIdParam
	DECLARE @CustomerTaxGroupParam				CustomerTaxGroupParam
	DECLARE @ItemTaxComputationForCustomer		ItemTaxComputationForCustomerParam	
	IF(OBJECT_ID('tempdb..##ITEMTAXES') IS NOT NULL) DROP TABLE ##ITEMTAXES
	CREATE TABLE ##ITEMTAXES (
		 [Id]								INT IDENTITY(1,1)
		,[intTransactionDetailTaxId]		INT NULL
		,[intTransactionDetailId]			INT NULL
		,[intTaxGroupId]					INT
		,[intTaxCodeId]						INT
		,[intTaxClassId]					INT
		,[strTaxableByOtherTaxes]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[strCalculationMethod]				NVARCHAR(30)
		,[dblRate]							NUMERIC(18,6)
		,[dblBaseRate]						NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6) DEFAULT 0
		,[dblAdjustedTax]					NUMERIC(18,6) DEFAULT 0
		,[intTaxAccountId]					INT
		,[intSalesTaxExemptionAccountId] 	INT
		,[ysnSeparateOnInvoice]				BIT DEFAULT 0
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(100)						
		,[ysnTaxExempt]						BIT
		,[ysnTaxOnly]						BIT
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(100)
		,[strNotes]							NVARCHAR(500)
		,[ysnTaxAdjusted]					BIT
		,[intUnitMeasureId]					INT
		,[strUnitMeasure]					NVARCHAR(30)
		,[strTaxClass]						NVARCHAR(100)
		,[ysnComputed]						BIT DEFAULT 0
		,[ysnTaxableFlagged]				BIT DEFAULT 0
		,[ysnAddToCost]						BIT DEFAULT 0
		,[dblTaxableAmount]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
		,[dblOtherTaxAmount]				NUMERIC(18,6) NULL DEFAULT 0 --ADDED
		,[dblItemTaxAmount]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
		,[dblItemPrice]						NUMERIC(18,6) NULL DEFAULT 0 --ADDED
		,[dblQtyShipped]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
		,[ysnExcludeCheckOff]				BIT
		,[strItemType]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL --ADDED
		,[intLineItemId]					INT NULL
	)

	INSERT INTO @ItemTaxComputationForCustomer
	SELECT * FROM @ItemTaxComputationForCustomerParam
	
	INSERT INTO @CustomerTaxGroupIdParam (
		  intCustomerId
		, intCompanyLocationId
		, intItemId
		, intCustomerLocationId
		, intSiteId
		, intFreightTermId
		, intLineItemId
	)
	SELECT intCustomerId
		, intCompanyLocationId
		, intItemId
		, intCustomerLocationId
		, intSiteId
		, intFreightTermId
		, intLineItemId
	FROM @ItemTaxComputationForCustomer
	WHERE intTaxGroupId IS NULL

	EXEC uspARGetTaxGroupIdForCustomer @CustomerTaxGroupIdParam
	
	UPDATE P
	SET intTaxGroupId = CT.intTaxGroupId
	FROM @ItemTaxComputationForCustomer P
	INNER JOIN ##CUSTOMERTAXGROUPID CT ON P.intCustomerId = CT.intCustomerId AND P.intCompanyLocationId = CT.intCompanyLocationId AND P.intItemId = CT.intItemId AND P.intSiteId = CT.intSiteId AND P.intFreightTermId = CT.intFreightTermId
	WHERE P.intTaxGroupId IS NULL
	  AND CT.intTaxGroupId IS NOT NULL

	UPDATE P
	SET ysnCustomerSiteTaxable = CASE WHEN P.intSiteId IS NOT NULL AND P.intTaxGroupId IS NOT NULL THEN S.ysnTaxable ELSE NULL END
	FROM @ItemTaxComputationForCustomer P
	LEFT JOIN tblTMSite S ON S.intSiteID = P.intSiteId	

	INSERT INTO @CustomerTaxGroupParam (
		  intTaxGroupId
		, intCustomerId
		, dtmTransactionDate
		, intItemId
		, intShipToLocationId
		, ysnIncludeExemptedCodes
		, ysnIncludeInvalidCodes
		, ysnCustomerSiteTaxable
		, intCardId
		, intVehicleId
		, intSiteId
		, ysnDisregardExemptionSetup
		, intItemUOMId
		, intCompanyLocationId
		, intFreightTermId
		, intCFSiteId
		, ysnDeliver
		, ysnCFQuote
		, intCurrencyId
		, intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate
		, intLineItemId
	) 
	SELECT intTaxGroupId
		, intCustomerId
		, dtmTransactionDate
		, intItemId
		, intCustomerLocationId
		, ysnIncludeExemptedCodes
		, ysnIncludeInvalidCodes
		, ysnCustomerSiteTaxable
		, intCardId
		, intVehicleId
		, intSiteId
		, ysnDisregardExemptionSetup
		, intItemUOMId
		, intCompanyLocationId
		, intFreightTermId
		, intCFSiteId
		, ysnDeliver
		, ysnCFQuote
		, intCurrencyId
		, intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate
		, intLineItemId
	FROM @ItemTaxComputationForCustomer
	
	EXEC dbo.uspARGetTaxGroupTaxCodesForCustomer @CustomerTaxGroupParam

	INSERT INTO ##ITEMTAXES (
		  [intTaxGroupId]
		, [intTaxCodeId]
		, [intTaxClassId]
		, [strTaxableByOtherTaxes]
		, [strCalculationMethod]
		, [dblRate]
		, [dblBaseRate]
		, [dblExemptionPercent]
		, [intTaxAccountId]
		, [intSalesTaxExemptionAccountId]
		, [ysnSeparateOnInvoice]
		, [ysnCheckoffTax]
		, [strTaxCode]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strTaxGroup]
		, [strNotes]
		, [ysnTaxAdjusted]
		, [intUnitMeasureId]
		, [strUnitMeasure]
		, [strTaxClass]
		, [ysnAddToCost]
		, [dblTaxableAmount]
		, [dblOtherTaxAmount]
		, [dblItemTaxAmount]
		, [dblItemPrice]
		, [dblQtyShipped]
		, [ysnExcludeCheckOff]
		, [strItemType]
		, [intLineItemId]
	)
	SELECT [intTaxGroupId]
		, [intTaxCodeId]
		, [intTaxClassId]
		, [strTaxableByOtherTaxes]
		, [strCalculationMethod]
		, [dblRate]
		, [dblBaseRate]
		, [dblExemptionPercent]
		, [intTaxAccountId]
		, [intSalesTaxExemptionAccountId]
		, [ysnSeparateOnInvoice]
		, [ysnCheckoffTax]
		, [strTaxCode]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strTaxGroup]
		, [strNotes]
		, [ysnTaxAdjusted]
		, [intUnitMeasureId]
		, [strUnitMeasure]
		, [strTaxClass]
		, [ysnAddToCost]
		, [dblTaxableAmount]
		, [dblOtherTaxAmount]
		, [dblItemTaxAmount]
		, [dblItemPrice]
		, [dblQtyShipped]
		, [ysnExcludeCheckOff]
		, [strItemType] 
		, [intLineItemId]
	FROM ##TAXGROUPTAXCODESFORCUSTOMER

	--SELECT '##ITEMTAXES', * FROM ##ITEMTAXES
	--SELECT '##TAXGROUPTAXCODESFORCUSTOMER', * FROM ##TAXGROUPTAXCODESFORCUSTOMER
	INSERT INTO @TaxableByOtherTaxesTable
	SELECT intTaxCodeId			= T.intTaxCodeId
	     , intTaxableTaxCodeId	= TOT.intID
	FROM ##ITEMTAXES T
	CROSS APPLY dbo.fnGetRowsFromDelimitedValues(T.strTaxableByOtherTaxes) TOT
	WHERE T.ysnTaxableFlagged = 0
	  AND RTRIM(LTRIM(ISNULL(T.strTaxableByOtherTaxes, ''))) <> ''
	  AND T.ysnTaxExempt = 0

	UPDATE ##ITEMTAXES
	SET ysnTaxableFlagged = 1
	WHERE RTRIM(LTRIM(ISNULL(strTaxableByOtherTaxes, ''))) <> ''
	  AND ysnTaxExempt = 0
	
	INSERT INTO @TaxableByOtherTaxes (
		  Id
		, intTaxCodeId
		, strTaxableByOtherTaxes
		, strCalculationMethod
		, dblRate
		, dblAdjustedTax
		, ysnTaxAdjusted	
		, ysnTaxExempt
		, ysnTaxOnly
	)
	SELECT IT.[Id]
		, IT.[intTaxCodeId]
		, IT.[strTaxableByOtherTaxes]
		, IT.[strCalculationMethod]
		, IT.[dblRate]
		, IT.[dblAdjustedTax]
		, IT.[ysnTaxAdjusted]
		, IT.[ysnTaxExempt]
		, IT.[ysnTaxOnly]
	FROM ##ITEMTAXES IT
	INNER JOIN @TaxableByOtherTaxesTable TBOT ON IT.[intTaxCodeId] = TBOT.[intTaxCodeId] AND IT.intTaxCodeId = TBOT.intTaxableTaxCodeId
	WHERE IT.ysnComputed = 0

	--CALCULATE TAXABLE AMOUNT
	UPDATE IT
	SET dblOtherTaxAmount = ISNULL(TOT1.dblOtherTaxAmount, 0) + ISNULL(TOT2.dblOtherTaxAmount, 0) + ISNULL(TOT3.dblOtherTaxAmount, 0)
	FROM ##ITEMTAXES IT
	OUTER APPLY (
		SELECT dblOtherTaxAmount = SUM(TBT.dblAdjustedTax)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 1
	) TOT1
	OUTER APPLY (
		SELECT dblOtherTaxAmount = (IT.dblItemPrice * IT.dblQtyShipped) * SUM(TBT.dblRate/100)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 0
		  AND TBT.strCalculationMethod = 'Percentage'
		  AND TBT.ysnTaxExempt = 0
		  AND TBT.Id = IT.Id
		  AND (IT.ysnExcludeCheckOff = 0 AND ysnCheckoffTax = 0)
		GROUP BY TBT.Id
	) TOT2
	OUTER APPLY (
		SELECT dblOtherTaxAmount = IT.dblQtyShipped * SUM(TBT.dblRate)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 0
		  AND TBT.strCalculationMethod <> 'Percentage'
		  AND TBT.ysnTaxExempt = 0
		  AND TBT.Id = IT.Id
		  AND (IT.ysnExcludeCheckOff = 0 AND ysnCheckoffTax = 0)
		GROUP BY TBT.Id
	) TOT3

	--CALCULATE ITEM TAX
	UPDATE ##ITEMTAXES
	SET dblTaxableAmount = dblTaxableAmount + dblOtherTaxAmount
	WHERE ysnComputed = 0

	UPDATE ##ITEMTAXES
	SET dblItemTaxAmount = CASE WHEN strCalculationMethod = 'Percentage' THEN dblTaxableAmount * (dblRate/100) ELSE dblQtyShipped * dblRate END
	WHERE ysnComputed = 0

	UPDATE ##ITEMTAXES
	SET dblItemTaxAmount = 0
	WHERE (ysnTaxExempt = 1 AND dblExemptionPercent = 0)
	   OR (ysnExcludeCheckOff = 1 AND ysnCheckoffTax = 1)
	   OR strItemType = 'Comment'

	UPDATE ##ITEMTAXES
	SET dblItemTaxAmount = dblItemTaxAmount - (dblItemTaxAmount * (dblExemptionPercent/100))
	WHERE ysnTaxExempt = 1 AND dblExemptionPercent <> 0

	UPDATE ##ITEMTAXES
	SET dblItemTaxAmount = dblItemTaxAmount * -1
	WHERE ysnCheckoffTax = 1 
	  AND ysnExcludeCheckOff = 0

	UPDATE ##ITEMTAXES
	SET dblTax			= dbo.fnRoundBanker(dblItemTaxAmount,[dbo].[fnARGetDefaultDecimal]())
	  , dblAdjustedTax	= dbo.fnRoundBanker(dblItemTaxAmount,[dbo].[fnARGetDefaultDecimal]())
	  , ysnComputed		= 1 
	
	SELECT [intTransactionDetailTaxId]
		,[intTransactionDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnSeparateOnInvoice]
		,[intTaxAccountId]
		,[intSalesTaxExemptionAccountId]
		,[ysnTaxAdjusted]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
		,[ysnAddToCost] 
		,[intLineItemId]
	FROM ##ITEMTAXES 	
END