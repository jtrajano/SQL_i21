CREATE PROCEDURE [dbo].[uspARConstructLineItemTaxDetail]
	  @ConstructLineItemTaxDetail		ConstructLineItemTaxDetailParam	READONLY
	, @LineItemTaxEntries				LineItemTaxDetailStagingTable	READONLY
AS
BEGIN
	DECLARE @intDefaultDecimal					INT = [dbo].[fnARGetDefaultDecimal]()
	DECLARE @TaxCodeRateParam					TaxCodeRateParam
	DECLARE @CustomerTaxCodeExemptionParam		CustomerTaxCodeExemptionParam
	DECLARE @ConstructLineItemTaxDetailParam	ConstructLineItemTaxDetailParam
	
	DECLARE @returntable TABLE (
		 [intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblBaseRate]					NUMERIC(18,6)
		,[dblExemptionPercent]			NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnTaxOnly]					BIT
		,[ysnInvalidSetup]				BIT
		,[strNotes]						NVARCHAR(500)
		,[dblExemptionAmount]			NUMERIC(18,6)
		,[intLineItemId]				INT NULL --intDetailId
	) 
	DECLARE @ItemTaxes AS TABLE(
		 [Id]							INT IDENTITY(1,1)
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblBaseRate]					NUMERIC(18,6)
		,[dblExemptionPercent]			NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnTaxOnly]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strNotes]						NVARCHAR(500)
		,[ysnTaxAdjusted]				BIT
		,[intUnitMeasureId]				INT
		,[ysnComputed]					BIT
		,[ysnTaxableFlagged]			BIT
		,[dblExemptionAmount]			NUMERIC(18,6)
		,[dblStateExciseTax]			NUMERIC(18,6) NULL DEFAULT 0
		,[dblStateSalesTax]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblFederalExciseTax]			NUMERIC(18,6) NULL DEFAULT 0
		,[dblDistrictTax]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblNetPrice]					NUMERIC(18,6) NULL DEFAULT 0
		,[dblItemPrice]					NUMERIC(18,6) NULL DEFAULT 0
		,[dblUnitTax]					NUMERIC(18,6) NULL DEFAULT 0
		,[dblTotalUnitTax]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblCheckOffUnitTax]			NUMERIC(18,6) NULL DEFAULT 0
		,[dblTaxableByOtherUnitTax]		NUMERIC(18,6) NULL DEFAULT 0
		,[dblTotalTaxRate]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblRegularRate]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblCheckOffRate]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblTaxableByOtherRate]		NUMERIC(18,6) NULL DEFAULT 0
		,[dblTOTUnitTax]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblTOTRegularRate]			NUMERIC(18,6) NULL DEFAULT 0
		,[dblTOTCheffOffRate]			NUMERIC(18,6) NULL DEFAULT 0
		,[dblTaxableAmount]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblItemTaxAmount]				NUMERIC(18,6) NULL DEFAULT 0
		,[dblItemExemptedTaxAmount]		NUMERIC(18,6) NULL DEFAULT 0
		,[dblOtherTaxAmount]			NUMERIC(18,6) NULL DEFAULT 0
		,[strTaxClass]					NVARCHAR(100) NULL
		,[intLineItemId]				INT NULL --intDetailId
	)
	DECLARE @TaxCodeRateDetails TABLE (
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
	DECLARE @TaxCodeExemption TABLE (
		  [ysnTaxExempt]			BIT
		, [ysnInvalidSetup]			BIT
		, [strExemptionNotes]		NVARCHAR(500)
		, [dblExemptionPercent]		NUMERIC(18,6)
		, [intCustomerId]			INT NULL
		, [intTaxGroupId]			INT NULL
		, [intTaxCodeId]			INT NULL
		, [intTaxClassId]			INT NULL
		, [intItemId]				INT NULL
		, [intLineItemId]			INT NULL
	)

	INSERT INTO @ConstructLineItemTaxDetailParam
	SELECT * FROM @ConstructLineItemTaxDetail

	IF NOT EXISTS(SELECT TOP 1 NULL FROM @LineItemTaxEntries)
		BEGIN
			DECLARE @ItemTaxComputationForCustomerParam		ItemTaxComputationForCustomerParam
			DECLARE @ItemTaxComputationForCustomer			ItemTaxComputationForCustomerParam

			INSERT INTO @ItemTaxComputationForCustomerParam (
				  intItemId
				, intCustomerId
				, dtmTransactionDate
				, dblItemPrice
				, dblQtyShipped
				, intTaxGroupId
				, intCompanyLocationId
				, intCustomerLocationId
				, ysnIncludeExemptedCodes
				, ysnIncludeInvalidCodes
				, ysnCustomerSiteTaxable
				, intSiteId
				, intFreightTermId
				, intCardId
				, intVehicleId
				, ysnDisregardExemptionSetup
				, ysnExcludeCheckOff
				, intCFSiteId
				, ysnDeliver
				, ysnCFQuote
				, intItemUOMId
				, intCurrencyId
				, intCurrencyExchangeRateTypeId
				, dblCurrencyExchangeRate
				, intLineItemId
			)
			SELECT intItemId
				 , intEntityCustomerId
				 , dtmTransactionDate
				 , dblPrice
				 , dblQuantity
				 , intTaxGroupId
				 , intCompanyLocationId
				 , intShipToLocationId
				 , ysnIncludeExemptedCodes
				 , ysnIncludeInvalidCodes
				 , NULL
				 , intSiteId
				 , intFreightTermId
				 , intCardId
				 , intVehicleId
				 , ysnDisregardExemptionSetup
				 , ysnExcludeCheckOff
				 , intCFSiteId
				 , ysnDeliver
				 , ysnCFQuote
				 , intItemUOMId
				 , intCurrencyId
				 , intCurrencyExchangeRateTypeId
				 , dblCurrencyExchangeRate
				 , intLineItemId
			FROM @ConstructLineItemTaxDetailParam

			INSERT INTO @ItemTaxComputationForCustomer (
				  [intTransactionDetailTaxId]
				, [intTransactionDetailId]
				, [intTaxGroupId]
				, [intTaxCodeId]
				, [intTaxClassId]
				, [strTaxableByOtherTaxes]
				, [strCalculationMethod]
				, [dblRate]
				, [dblBaseRate]
				, [dblExemptionPercent]
				, [dblTax]
				, [dblAdjustedTax]
				, [ysnSeparateOnInvoice]
				, [intTaxAccountId]
				, [intSalesTaxExemptionAccountId]
				, [ysnTaxAdjusted]
				, [ysnCheckoffTax]
				, [strTaxCode]
				, [ysnTaxExempt]
				, [ysnTaxOnly]
				, [ysnInvalidSetup]
				, [strTaxGroup]
				, [strNotes]
				, [intUnitMeasureId]
				, [ysnAddToCost] 
				, [intLineItemId]
			)
			EXEC dbo.uspARGetItemTaxComputationForCustomer @ItemTaxComputationForCustomerParam

			INSERT INTO @ItemTaxes (
				 [intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblBaseRate]
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strNotes]
				,[intUnitMeasureId]
				,[ysnComputed]
				,[ysnTaxableFlagged]
				,[intLineItemId]
			)
			SELECT
				 [intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblBaseRate]
				,[dblExemptionPercent]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnTaxOnly]
				,[ysnInvalidSetup]
				,[strNotes]
				,[intUnitMeasureId]
				,[ysnComputed]			= CAST(0 AS BIT)
				,[ysnTaxableFlagged]	= CAST(0 AS BIT)
				,[intLineItemId]
			FROM @ItemTaxComputationForCustomer
		END
					
	UPDATE @ConstructLineItemTaxDetailParam
	SET dblGrossAmount = 0
	WHERE dblGrossAmount IS NULL

	UPDATE @ConstructLineItemTaxDetailParam
	SET dblQuantity = 0
	WHERE dblQuantity IS NULL

	UPDATE @ConstructLineItemTaxDetailParam
	SET dblPrice = 0
	WHERE dblPrice IS NULL

	UPDATE P
	SET intItemCategoryId = ITEM.intCategoryId
	FROM @ConstructLineItemTaxDetailParam P
	INNER JOIN tblICItem ITEM ON P.intItemId = ITEM.intItemId

	--GET TAX CODE RATE DETAILS
	INSERT INTO @TaxCodeRateParam (
		  intTaxCodeId
		, dtmTransactionDate
		, intItemUOMId
		, intCurrencyId
		, intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate
		, intLineItemId
	)
	SELECT intTaxCodeId						= E.intTaxCodeId
		, dtmTransactionDate				= P.dtmTransactionDate
		, intItemUOMId						= P.intItemUOMId
		, intCurrencyId						= P.intCurrencyId
		, intCurrencyExchangeRateTypeId		= P.intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate			= P.dblCurrencyExchangeRate
		, intLineItemId						= P.intLineItemId
	FROM @ConstructLineItemTaxDetailParam P
	INNER JOIN @LineItemTaxEntries E ON P.intLineItemId = E.intDetailId

	INSERT INTO @TaxCodeRateDetails
	EXEC dbo.uspARGetTaxCodeRateDetails @TaxCodeRateParam

	--GET TAX EXEMPTIONS
	INSERT INTO @CustomerTaxCodeExemptionParam (
		  intCustomerId
		, dtmTransactionDate
		, intTaxCodeId
		, intTaxClassId
		, strState
		, intItemId
		, intItemCategoryId
		, intShipToLocationId
		, intCardId
		, intVehicleId
		, ysnDisregardExemptionSetup
		, intCompanyLocationId
		, intFreightTermId
		, intCFSiteId
		, ysnDeliver
		, ysnCFQuote
		, intLineItemId
	)
	SELECT intCustomerId				= P.intEntityCustomerId
		, dtmTransactionDate			= P.dtmTransactionDate
		, intTaxCodeId					= TC.intTaxCodeId
		, intTaxClassId					= TC.intTaxClassId
		, strState						= TC.strState
		, intItemId						= P.intItemId
		, intItemCategoryId				= P.intItemCategoryId
		, intShipToLocationId			= P.intShipToLocationId
		, intCardId						= P.intCardId
		, intVehicleId					= P.intVehicleId
		, ysnDisregardExemptionSetup	= P.ysnDisregardExemptionSetup
		, intCompanyLocationId			= P.intCompanyLocationId
		, intFreightTermId				= P.intFreightTermId
		, intCFSiteId					= P.intCFSiteId
		, ysnDeliver					= 0
		, ysnCFQuote					= 0
		, intLineItemId					= P.intLineItemId
	FROM @ConstructLineItemTaxDetailParam P
	INNER JOIN @LineItemTaxEntries E ON P.intLineItemId = E.intDetailId
	INNER JOIN tblSMTaxCode TC ON E.intTaxCodeId = TC.intTaxCodeId

	INSERT INTO @TaxCodeExemption
	EXEC dbo.uspARGetCustomerTaxCodeExemption @CustomerTaxCodeExemptionParam

	INSERT INTO @ItemTaxes (
		 [intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[dblExemptionPercent]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]
		,[ysnCheckoffTax]		
		,[strTaxCode]
		,[ysnTaxExempt]	
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[ysnTaxAdjusted]
		,[intUnitMeasureId]
		,[ysnComputed]
		,[ysnTaxableFlagged]
		,[intLineItemId]
	)
	SELECT [intTaxGroupId]			= E.[intTaxGroupId]
		,[intTaxCodeId]				= E.[intTaxCodeId]
		,[intTaxClassId]			= ISNULL(E.[intTaxClassId], TC.[intTaxClassId])
		,[strTaxableByOtherTaxes]	= ISNULL(E.[strTaxableByOtherTaxes], TC.[strTaxableByOtherTaxes])
		,[strCalculationMethod]		= ISNULL(E.[strCalculationMethod], R.strCalculationMethod)
		,[dblRate]					= ISNULL(ISNULL(E.[dblRate], R.dblRate), 0)
		,[dblBaseRate]				= ISNULL(ISNULL(E.[dblBaseRate], R.dblBaseRate), 0)
		,[dblExemptionPercent]		= ISNULL(TAXEXEMPT.dblExemptionPercent, 0)
		,[dblTax]					= E.[dblTax]
		,[dblAdjustedTax]			= E.[dblAdjustedTax]
		,[intTaxAccountId]			= ISNULL(E.[intTaxAccountId], TC.[intSalesTaxAccountId])
		,[ysnCheckoffTax]			= ISNULL(E.[ysnCheckoffTax], TC.[ysnCheckoffTax])
		,[strTaxCode]				= TC.[strTaxCode]
		,[ysnTaxExempt]				= ISNULL(E.[ysnTaxExempt], CAST(0 AS BIT))
		,[ysnTaxOnly]				= ISNULL(E.[ysnTaxOnly], CAST(0 AS BIT))
		,[ysnInvalidSetup]          = CAST(0 AS BIT)
		,[ysnTaxAdjusted]			= ISNULL(E.[ysnTaxAdjusted], CAST(0 AS BIT))
		,[intUnitMeasureId]         = NULL
		,[ysnComputed]              = CAST(0 AS BIT)
		,[ysnTaxableFlagged]        = CAST(0 AS BIT)
		,[intLineItemId]			= P.intLineItemId
	FROM @ConstructLineItemTaxDetailParam P
	INNER JOIN @LineItemTaxEntries E ON P.intLineItemId = E.intDetailId
	INNER JOIN tblSMTaxCode TC ON E.intTaxCodeId = TC.intTaxCodeId
	OUTER APPLY (
		SELECT * 
		FROM @TaxCodeExemption EX 
		WHERE EX.intCustomerId = P.intEntityCustomerId 
		  AND EX.intTaxGroupId = P.intTaxGroupId 
		  AND EX.intTaxCodeId = TC.intTaxCodeId
		  AND EX.intTaxClassId = TC.intTaxClassId
		  AND EX.intLineItemId = P.intLineItemId
	) TAXEXEMPT
	OUTER APPLY (
		SELECT * 
		FROM @TaxCodeRateDetails CRD 
		WHERE CRD.intTaxGroupId = P.intTaxGroupId 
		  AND CRD.intTaxCodeId = TC.intTaxCodeId
		  AND CRD.intItemUOMId = P.intItemUOMId
		  AND CRD.intCurrencyId = P.intCurrencyId
		  AND CRD.intLineItemId = P.intLineItemId
	) R	
	
	UPDATE IT
	SET strTaxClass = TC.strTaxClass
	FROM @ItemTaxes IT
	INNER JOIN tblSMTaxClass TC ON IT.intTaxClassId = TC.intTaxClassId
	
	UPDATE IT
	SET dblStateExciseTax = TAX.dblStateExciseTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT intLineItemId
			 , dblStateExciseTax = CASE WHEN strCalculationMethod = 'Percentage' THEN SUM(ISNULL(dblRate, 0)) / 100 ELSE SUM(ISNULL(dblRate, 0)) END
		FROM @ItemTaxes
		WHERE strTaxClass Like '%State Excise Tax%'
		GROUP BY intLineItemId, strCalculationMethod
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	WHERE strTaxClass Like '%State Excise Tax%'
		
	UPDATE IT
	SET dblStateSalesTax = TAX.dblStateSalesTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT intLineItemId
			 , dblStateSalesTax = CASE WHEN strCalculationMethod = 'Percentage' THEN SUM(ISNULL(dblRate, 0)) / 100 ELSE SUM(ISNULL(dblRate, 0)) END
		FROM @ItemTaxes
		WHERE strTaxClass Like '%State Sales Tax%'
		GROUP BY intLineItemId, strCalculationMethod
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	WHERE strTaxClass Like '%State Sales Tax%'
	
	UPDATE IT
	SET dblFederalExciseTax = TAX.dblFederalExciseTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT intLineItemId
			 , dblFederalExciseTax = CASE WHEN strCalculationMethod = 'Percentage' THEN SUM(ISNULL(dblRate, 0)) / 100 ELSE SUM(ISNULL(dblRate, 0)) END
		FROM @ItemTaxes
		WHERE strTaxClass Like '%Federal Excise Tax%'
		GROUP BY intLineItemId, strCalculationMethod
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	WHERE strTaxClass Like '%Federal Excise Tax%'

	UPDATE IT
	SET dblDistrictTax = TAX.dblDistrictTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT intLineItemId
			 , dblDistrictTax = CASE WHEN strCalculationMethod = 'Percentage' THEN SUM(ISNULL(dblRate, 0)) / 100 ELSE SUM(ISNULL(dblRate, 0)) END
		FROM @ItemTaxes
		WHERE strTaxClass Like '%District Tax%'
		GROUP BY intLineItemId, strCalculationMethod
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	WHERE strTaxClass Like '%District Tax%'
	  
	UPDATE @ItemTaxes
	SET dblNetPrice = (((P.dblGrossAmount/P.dblQuantity) - IT.dblStateExciseTax) / (1 + IT.dblDistrictTax + IT.dblStateSalesTax)) - IT.dblFederalExciseTax
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	
	UPDATE IT
	SET dblItemPrice = P.dblPrice
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON IT.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal IS NULL OR P.ysnReversal = 0

	DECLARE @TaxableByOtherTaxUnit AS TABLE(
		 [Id]							INT IDENTITY(1,1)
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblBaseRate]					NUMERIC(18,6)
		,[dblExemptionPercent]			NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnTaxOnly]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strNotes]						NVARCHAR(500)
		,[ysnTaxAdjusted]				BIT
		,[ysnComputed]					BIT
		,[intLineItemId]				INT NULL
	)
	DECLARE @TBOTTaxCodesTable TABLE (
		  intTaxCodeId			INT NULL
		, intTBOTId				INT NULL
		, intLineItemId			INT NULL
		, dblRate				NUMERIC(18,6) NULL DEFAULT 0
		, dblTBOTRate			NUMERIC(18,6) NULL DEFAULT 0
		, dblQuantity			NUMERIC(18,6) NULL DEFAULT 0
		, ysnExcludeCheckOff	BIT NULL DEFAULT 0
	)

	INSERT INTO @TaxableByOtherTaxUnit(
		  [intTaxGroupId]
		, [intTaxCodeId]
		, [intTaxClassId]
		, [strTaxableByOtherTaxes]
		, [strCalculationMethod]
		, [dblRate]
		, [dblBaseRate]
		, [dblExemptionPercent]
		, [dblTax]
		, [dblAdjustedTax]
		, [intTaxAccountId]
		, [ysnCheckoffTax]
		, [strTaxCode]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strTaxGroup]
		, [strNotes]
		, [ysnTaxAdjusted]
		, [ysnComputed]
		, [intLineItemId]
	)
	SELECT intTaxGroupId			= IT.intTaxGroupId
		, intTaxCodeId				= IT.intTaxCodeId
		, intTaxClassId				= IT.intTaxClassId
		, strTaxableByOtherTaxes	= IT.strTaxableByOtherTaxes
		, strCalculationMethod		= IT.strCalculationMethod
		, dblRate					= IT.dblRate
		, dblBaseRate				= IT.dblBaseRate
		, dblExemptionPercent		= IT.dblExemptionPercent
		, dblTax					= IT.dblTax
		, dblAdjustedTax			= IT.dblAdjustedTax
		, intTaxAccountId			= IT.intTaxAccountId
		, ysnCheckoffTax			= IT.ysnCheckoffTax
		, strTaxCode				= IT.strTaxCode
		, ysnTaxExempt				= IT.ysnTaxExempt
		, ysnTaxOnly				= IT.ysnTaxOnly
		, ysnInvalidSetup			= IT.ysnInvalidSetup
		, strTaxGroup				= IT.strTaxGroup
		, strNotes					= IT.strNotes
		, ysnTaxAdjusted			= IT.ysnTaxAdjusted
		, ysnComputed				= 0
		, intLineItemId				= P.intLineItemId
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON IT.intLineItemId = P.intLineItemId
	WHERE LEN(RTRIM(LTRIM(ISNULL(IT.strTaxableByOtherTaxes, '')))) > 0
	  AND LOWER(RTRIM(LTRIM(IT.strCalculationMethod))) = 'unit'
	  AND (IT.ysnTaxExempt = 0 OR P.ysnDisregardExemptionSetup = 1)
	  AND IT.ysnInvalidSetup = 0
	  AND P.ysnReversal = 1

	INSERT INTO @TBOTTaxCodesTable (
		  intTaxCodeId
		, intTBOTId
		, intLineItemId
		, dblTBOTRate
		, dblQuantity
	)
	SELECT intTaxCodeId		= TBOT.intTaxCodeId
		 , intTBOTId		= TBOT.Id
		 , intLineItemId	= TBOT.intLineItemId
		 , dblTBOTRate		= TBOT.dblRate
		 , dblQuantity		= P.dblQuantity
	FROM @TaxableByOtherTaxUnit TBOT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = TBOT.intLineItemId
	CROSS APPLY dbo.fnGetRowsFromDelimitedValues(TBOT.strTaxableByOtherTaxes) TOT
	WHERE TBOT.ysnComputed = 0
	  AND TBOT.ysnInvalidSetup = 0
	  AND P.ysnReversal = 1

	UPDATE TCT 
	SET dblRate = IT.dblRate
	FROM @TBOTTaxCodesTable TCT
	INNER JOIN @ItemTaxes IT ON TCT.intTaxCodeId = IT.intTaxCodeId AND TCT.intLineItemId = IT.intLineItemId
	WHERE LOWER(RTRIM(LTRIM(IT.[strCalculationMethod]))) = 'percentage'
	  AND IT.[ysnInvalidSetup] = 0

	DELETE FROM @TBOTTaxCodesTable WHERE dblRate IS NULL

	UPDATE IT
	SET dblTaxableByOtherUnitTax = TAX.dblTaxableByOtherUnitTax * (ISNULL(IT.dblRate, 0)/100)
	FROM @ItemTaxes IT 
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	INNER JOIN (
		SELECT intTaxCodeId
			 , intLineItemId
			 , dblTaxableByOtherUnitTax = SUM(TCT.dblTBOTRate) * AVG(TCT.dblQuantity)
		FROM @TBOTTaxCodesTable TCT 
		GROUP BY TCT.intTaxCodeId, TCT.intLineItemId					 
	) TAX ON IT.intTaxCodeId = TAX.intTaxCodeId AND IT.intLineItemId = TAX.intLineItemId
	WHERE P.ysnReversal = 1
	  AND LOWER(RTRIM(LTRIM(IT.strCalculationMethod))) = 'percentage'
	  AND IT.ysnInvalidSetup = 0

	UPDATE IT
	SET dblUnitTax = P.dblQuantity * TAX.dblUnitTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT ITP.intLineItemId
			 , dblUnitTax =  SUM(ITP.dblRate)
		FROM @ItemTaxes ITP		
		WHERE LOWER(RTRIM(LTRIM(ITP.strCalculationMethod))) = 'unit'
		  AND ITP.ysnCheckoffTax = 0
		  AND ITP.ysnTaxExempt = 0
		GROUP BY ITP.intLineItemId
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	INNER JOIN @ConstructLineItemTaxDetailParam P ON TAX.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal = 1
	
	UPDATE IT
	SET dblCheckOffUnitTax = TAX.dblCheckOffUnitTax
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT ITP.intLineItemId
			 , dblCheckOffUnitTax = P.dblQuantity * SUM(ITP.dblRate)
		FROM @ItemTaxes ITP
		INNER JOIN @ConstructLineItemTaxDetailParam P ON ITP.intLineItemId = P.intLineItemId
		WHERE LOWER(RTRIM(LTRIM(ITP.strCalculationMethod))) = 'unit'
		  AND ITP.ysnCheckoffTax = 1
		  AND ITP.ysnTaxExempt = 0
		  AND P.ysnExcludeCheckOff = 0
		  AND P.ysnReversal = 1
		GROUP BY ITP.intLineItemId, P.dblQuantity
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	INNER JOIN @ConstructLineItemTaxDetailParam P ON TAX.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal = 1

	UPDATE IT
	SET dblTotalUnitTax = (ISNULL(dblUnitTax, 0) - ISNULL(dblCheckOffUnitTax, 0)) + ISNULL(dblTaxableByOtherUnitTax, 0)
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON IT.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal = 1

	UPDATE IT
	SET dblRegularRate = TAX.dblRegularRate
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT ITP.intLineItemId
			 , dblRegularRate = SUM(ITP.dblRate)
		FROM @ItemTaxes ITP
		WHERE LOWER(RTRIM(LTRIM(ITP.strCalculationMethod))) = 'percentage'
		  AND ITP.ysnCheckoffTax = 0
		  AND ITP.ysnTaxExempt = 0
		GROUP BY ITP.intLineItemId
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	INNER JOIN @ConstructLineItemTaxDetailParam P ON TAX.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal = 1

	UPDATE IT
	SET dblCheckOffRate = TAX.dblCheckOffRate
	FROM @ItemTaxes IT
	INNER JOIN (
		SELECT ITP.intLineItemId
			 , dblCheckOffRate = SUM(ITP.dblRate)
		FROM @ItemTaxes ITP
		INNER JOIN @ConstructLineItemTaxDetailParam P ON ITP.intLineItemId = P.intLineItemId
		WHERE LOWER(RTRIM(LTRIM(ITP.strCalculationMethod))) = 'percentage'
		  AND ITP.ysnCheckoffTax = 1
		  AND ITP.ysnTaxExempt = 0
		  AND P.ysnExcludeCheckOff = 0
		GROUP BY ITP.intLineItemId
	) TAX ON IT.intLineItemId = TAX.intLineItemId
	INNER JOIN @ConstructLineItemTaxDetailParam P ON TAX.intLineItemId = P.intLineItemId
	WHERE P.ysnReversal = 1
	
	DELETE FROM @TaxableByOtherTaxUnit
	INSERT INTO @TaxableByOtherTaxUnit (
		  [intTaxGroupId]
		, [intTaxCodeId]
		, [intTaxClassId]
		, [strTaxableByOtherTaxes]
		, [strCalculationMethod]
		, [dblRate]
		, [dblBaseRate]
		, [dblExemptionPercent]
		, [dblTax]
		, [dblAdjustedTax]
		, [intTaxAccountId]
		, [ysnCheckoffTax]
		, [strTaxCode]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strTaxGroup]
		, [strNotes]
		, [ysnTaxAdjusted]
		, [ysnComputed]
		, [intLineItemId]
	)
	SELECT [intTaxGroupId]				= IT.intTaxGroupId
		, [intTaxCodeId]				= IT.intTaxCodeId
		, [intTaxClassId]				= IT.intTaxClassId
		, [strTaxableByOtherTaxes]		= IT.strTaxableByOtherTaxes
		, [strCalculationMethod]		= IT.strCalculationMethod
		, [dblRate]						= IT.dblRate
		, [dblBaseRate]					= IT.dblBaseRate
		, [dblExemptionPercent]			= IT.dblExemptionPercent
		, [dblTax]						= IT.dblTax
		, [dblAdjustedTax]				= IT.dblAdjustedTax
		, [intTaxAccountId]				= IT.intTaxAccountId
		, [ysnCheckoffTax]				= IT.ysnCheckoffTax
		, [strTaxCode]					= IT.strTaxCode
		, [ysnTaxExempt]				= IT.ysnTaxExempt
		, [ysnTaxOnly]					= IT.ysnTaxOnly
		, [ysnInvalidSetup]				= IT.ysnInvalidSetup
		, [strTaxGroup]					= IT.strTaxGroup
		, [strNotes]					= IT.strNotes
		, [ysnTaxAdjusted]				= IT.ysnTaxAdjusted
		, [ysnComputed]					= 0
		, [intLineItemId]				= IT.intLineItemId
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON IT.intLineItemId = P.intLineItemId
	WHERE LEN(RTRIM(LTRIM(ISNULL(IT.strTaxableByOtherTaxes, '')))) > 0
	  AND LOWER(RTRIM(LTRIM(IT.strCalculationMethod))) = 'percentage'
	  AND (IT.ysnTaxExempt = 0 OR P.ysnDisregardExemptionSetup = 1)
	  AND IT.ysnInvalidSetup = 0
	  AND P.ysnReversal = 1
	  
	DELETE FROM @TBOTTaxCodesTable
	INSERT INTO @TBOTTaxCodesTable (
		  intTaxCodeId
		, intTBOTId
		, intLineItemId
		, dblTBOTRate
		, dblQuantity
		, ysnExcludeCheckOff
	)
	SELECT intTaxCodeId			= TBOT.intTaxCodeId
		 , intTBOTId			= TBOT.Id
		 , intLineItemId		= TBOT.intLineItemId
		 , dblTBOTRate			= TBOT.dblRate
		 , dblQuantity			= P.dblQuantity
		 , ysnExcludeCheckOff	= P.ysnExcludeCheckOff
	FROM @TaxableByOtherTaxUnit TBOT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = TBOT.intLineItemId
	CROSS APPLY dbo.fnGetRowsFromDelimitedValues(TBOT.strTaxableByOtherTaxes) TOT
	WHERE TBOT.ysnComputed = 0
	  AND TBOT.ysnInvalidSetup = 0
	  AND P.ysnReversal = 1

	UPDATE TCT 
	SET dblRate = IT.dblRate
	FROM @TBOTTaxCodesTable TCT
	INNER JOIN @ItemTaxes IT ON TCT.intTaxCodeId = IT.intTaxCodeId AND TCT.intLineItemId = IT.intLineItemId
	WHERE LOWER(RTRIM(LTRIM(IT.[strCalculationMethod]))) = 'percentage'
	  AND NOT (IT.ysnCheckoffTax = 1 AND TCT.ysnExcludeCheckOff = 1)

	DELETE FROM @TBOTTaxCodesTable WHERE dblRate IS NULL

	UPDATE IT
	SET dblTaxableByOtherRate = TAX.dblTaxableByOtherRate * (ISNULL(IT.dblRate, 0)/100)
	FROM @ItemTaxes IT 
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	INNER JOIN (
		SELECT intTaxCodeId
			 , intLineItemId
			 , dblTaxableByOtherRate = SUM(TCT.dblTBOTRate) --* AVG(TCT.dblQuantity)
		FROM @TBOTTaxCodesTable TCT 
		GROUP BY TCT.intTaxCodeId, TCT.intLineItemId					 
	) TAX ON IT.intTaxCodeId = TAX.intTaxCodeId AND IT.intLineItemId = TAX.intLineItemId
	WHERE P.ysnReversal = 1
	  AND LOWER(RTRIM(LTRIM(IT.strCalculationMethod))) = 'percentage'
	  AND NOT (IT.ysnCheckoffTax = 1 AND P.ysnExcludeCheckOff = 1)

	UPDATE IT
	SET dblTotalTaxRate = (ISNULL(dblRegularRate, 0) - ISNULL(dblCheckOffRate, 0)) + ISNULL(dblTaxableByOtherRate, 0)
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE P.ysnReversal = 1

	UPDATE IT
	SET dblItemPrice = (P.dblGrossAmount - IT.dblTotalUnitTax) / (P.dblQuantity + (P.dblQuantity * (IT.dblTotalTaxRate/100)))
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE P.ysnReversal = 1
			

	DECLARE @TaxableByOtherTaxesTable TABLE (
		  intTaxCodeId			INT
		, intTaxableTaxCodeId	INT
		, intLineItemId			INT NULL
		, intItemTaxesId		INT NULL
	)
	DECLARE @TaxableByOtherTaxes TABLE(
		  Id						INT
		, intTaxCodeId				INT
		, strTaxableByOtherTaxes	NVARCHAR(MAX)
		, strCalculationMethod		NVARCHAR(30)
		, dblRate					NUMERIC(18,6)
		, dblAdjustedTax			NUMERIC(18,6)
		, ysnTaxAdjusted			BIT
		, ysnTaxExempt				BIT
		, ysnTaxOnly				BIT
		, intLineItemId				INT NULL
	)

	INSERT INTO @TaxableByOtherTaxesTable (
		  intTaxCodeId
		, intTaxableTaxCodeId
		, intLineItemId
		, intItemTaxesId
	)
	SELECT intTaxCodeId			= IT.intTaxCodeId
		, intTaxableTaxCodeId	= TAX.intID
		, intLineItemId			= IT.intLineItemId
		, intItemTaxesId		= IT.Id
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	CROSS APPLY dbo.fnGetRowsFromDelimitedValues(IT.strTaxableByOtherTaxes) TAX
	WHERE IT.ysnTaxableFlagged = 0
	  AND RTRIM(LTRIM(ISNULL(IT.strTaxableByOtherTaxes, ''))) <> ''
	  AND IT.ysnTaxExempt = 0

	UPDATE IT
	SET ysnTaxableFlagged = 1
	FROM @ItemTaxes IT
	INNER JOIN @TaxableByOtherTaxesTable TBT ON IT.Id = TBT.intItemTaxesId
				
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
		, intLineItemId
	)
	SELECT Id						= IT.[Id]
		, intTaxCodeId				= IT.[intTaxCodeId]
		, strTaxableByOtherTaxes	= IT.[strTaxableByOtherTaxes]
		, strCalculationMethod		= IT.[strCalculationMethod]
		, dblRate					= IT.[dblRate]
		, dblAdjustedTax			= IT.[dblAdjustedTax]
		, ysnTaxAdjusted			= IT.[ysnTaxAdjusted]
		, ysnTaxExempt				= IT.[ysnTaxExempt]
		, ysnTaxOnly				= IT.ysnTaxOnly
		, intLineItemId				= IT.intLineItemId
	FROM @ItemTaxes IT
	INNER JOIN @TaxableByOtherTaxesTable TBOT ON IT.[intTaxCodeId] = TBOT.[intTaxCodeId] AND IT.intTaxCodeId = TBOT.intTaxableTaxCodeId
	WHERE IT.ysnInvalidSetup = 0
	  AND IT.ysnComputed = 0

	UPDATE IT 
	SET dblTaxableAmount = ISNULL(IT.dblItemPrice, 0) * ISNULL(P.dblQuantity, 0) 
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE IT.ysnInvalidSetup = 0 
	  AND IT.ysnComputed = 0

	UPDATE @ItemTaxes SET dblExemptionPercent = CASE WHEN ISNULL([dblExemptionPercent], 0) = 0 THEN 100 ELSE [dblExemptionPercent] END WHERE ysnInvalidSetup = 0 AND ysnComputed = 0	
	UPDATE @ItemTaxes SET ysnTaxAdjusted = ISNULL(ysnTaxAdjusted, 0) WHERE ysnInvalidSetup = 0 AND ysnComputed = 0
	UPDATE @ItemTaxes SET ysnCheckoffTax = ISNULL(ysnCheckoffTax, 0) WHERE ysnInvalidSetup = 0 AND ysnComputed = 0
	UPDATE @ItemTaxes SET ysnTaxExempt = ISNULL(ysnTaxExempt, 0) WHERE ysnInvalidSetup = 0 AND ysnComputed = 0
	
	--CALCULATE TAXABLE AMOUNT
	UPDATE IT
	SET dblOtherTaxAmount = ISNULL(TOT1.dblOtherTaxAmount, 0) + ISNULL(TOT2.dblOtherTaxAmount, 0) + ISNULL(TOT3.dblOtherTaxAmount, 0)
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON IT.intLineItemId = P.intLineItemId
	OUTER APPLY (
		SELECT dblOtherTaxAmount = SUM(TBT.dblAdjustedTax)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 1
	) TOT1
	OUTER APPLY (
		SELECT dblOtherTaxAmount = (IT.dblItemPrice * P.dblQuantity) * SUM(TBT.dblRate/100)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 0
		  AND TBT.strCalculationMethod = 'Percentage'
		  AND TBT.ysnTaxExempt = 0
		  AND TBT.Id = IT.Id
		  AND (P.ysnExcludeCheckOff = 0 AND ysnCheckoffTax = 0)
		GROUP BY TBT.Id
	) TOT2
	OUTER APPLY (
		SELECT dblOtherTaxAmount = P.dblQuantity * SUM(TBT.dblRate)
		FROM @TaxableByOtherTaxes TBT
		WHERE TBT.strTaxableByOtherTaxes IS NOT NULL
		  AND TBT.strTaxableByOtherTaxes <> ''
		  AND TBT.ysnTaxAdjusted = 0
		  AND TBT.strCalculationMethod <> 'Percentage'
		  AND TBT.ysnTaxExempt = 0
		  AND TBT.Id = IT.Id
		  AND (P.ysnExcludeCheckOff = 0 AND ysnCheckoffTax = 0)
		GROUP BY TBT.Id
	) TOT3
	
	UPDATE @ItemTaxes
	SET dblTaxableAmount = dblTaxableAmount + ISNULL(dblOtherTaxAmount, 0)

	UPDATE IT
	SET dblItemTaxAmount = CASE WHEN IT.strCalculationMethod = 'Percentage' THEN IT.dblTaxableAmount * (IT.dblRate/100) ELSE P.dblQuantity * IT.dblRate END
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE IT.ysnInvalidSetup = 0 
	  AND IT.ysnComputed = 0

	UPDATE IT
	SET dblItemTaxAmount			= CASE WHEN IT.strCalculationMethod = 'Percentage' 
										   THEN CASE WHEN P.ysnReversal = 0
													 THEN IT.dblItemTaxAmount - (IT.dblItemTaxAmount * (IT.dblExemptionPercent/100))
													 ELSE (((CASE WHEN P.dblGrossAmount = 0 
															      THEN P.dblPrice 
															      ELSE P.dblGrossAmount 
														     END + IT.dblFederalExciseTax) * (IT.dblRate/100)) * (1 - (IT.dblExemptionPercent/100))) * P.dblQuantity
												END
										   ELSE IT.dblItemTaxAmount * (IT.dblExemptionPercent/100)
									  END
	  , dblItemExemptedTaxAmount	= CASE WHEN IT.strCalculationMethod = 'Percentage' 
										   THEN CASE WHEN P.ysnReversal = 0
													 THEN IT.dblItemTaxAmount * (IT.dblExemptionPercent/100)
													 ELSE (((CASE WHEN P.dblGrossAmount = 0 
															      THEN P.dblPrice 
															      ELSE P.dblGrossAmount 
														     END + IT.dblFederalExciseTax) * (IT.dblRate/100)) * (IT.dblExemptionPercent/100)) * P.dblQuantity
												END
										   ELSE IT.dblItemTaxAmount * (IT.dblExemptionPercent/100)
									  END
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE IT.ysnInvalidSetup = 0 
	  AND IT.ysnComputed = 0
	  AND IT.ysnTaxExempt = 1
	  AND P.ysnDisregardExemptionSetup = 0

	UPDATE IT
	SET dblItemTaxAmount = CASE WHEN P.ysnExcludeCheckOff = 1 THEN 0 ELSE dblItemTaxAmount * -1 END
	FROM @ItemTaxes IT
	INNER JOIN @ConstructLineItemTaxDetailParam P ON P.intLineItemId = IT.intLineItemId
	WHERE IT.ysnInvalidSetup = 0 
	  AND IT.ysnComputed = 0
	  AND IT.ysnCheckoffTax = 1
	
	UPDATE IT
	SET dblTax				= ROUND(ROUND(IT.dblItemTaxAmount, 3), @intDefaultDecimal)
	  , dblAdjustedTax		= ROUND(ROUND(IT.dblItemTaxAmount, 3), @intDefaultDecimal)
	  , dblExemptionAmount	= ROUND(ROUND(IT.dblItemExemptedTaxAmount, 3), @intDefaultDecimal)
	  , ysnComputed			= 1 
	FROM @ItemTaxes IT
	WHERE IT.ysnInvalidSetup = 0 
	  AND IT.ysnComputed = 0
				
	INSERT INTO @returntable(
		  [intTaxGroupId]
		, [intTaxCodeId]
		, [intTaxClassId]
		, [strTaxableByOtherTaxes]
		, [strCalculationMethod]
		, [dblRate]
		, [dblBaseRate]
		, [dblExemptionPercent]
		, [dblTax]
		, [dblAdjustedTax]
		, [intTaxAccountId]
		, [ysnCheckoffTax]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strNotes]
		, [dblExemptionAmount]
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
		, [dblTax]
		, [dblAdjustedTax]
		, [intTaxAccountId]
		, [ysnCheckoffTax]
		, [ysnTaxExempt]
		, [ysnTaxOnly]
		, [ysnInvalidSetup]
		, [strNotes]
		, [dblExemptionAmount]
		, [intLineItemId]
	FROM @ItemTaxes

	SELECT * FROM @returntable		

END