CREATE PROCEDURE [dbo].[uspARGetTaxGroupTaxCodesForCustomer]
	@CustomerTaxGroupParam	CustomerTaxGroupParam READONLY
AS

DECLARE @CustomerTaxGroup			CustomerTaxGroupParam
DECLARE @TaxCodeRate				TaxCodeRateParam
DECLARE @CustomerTaxCodeExemption	CustomerTaxCodeExemptionParam        

IF(OBJECT_ID('tempdb..##TAXGROUPTAXCODESFORCUSTOMER') IS NOT NULL) DROP TABLE ##TAXGROUPTAXCODESFORCUSTOMER
CREATE TABLE ##TAXGROUPTAXCODESFORCUSTOMER (
	 [intTaxGroupId]					INT
	,[intTaxCodeId]						INT
	,[intTaxClassId]					INT
	,[strTaxableByOtherTaxes]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,[strCalculationMethod]				NVARCHAR(30)
	,[dblRate]							NUMERIC(18,6) NULL DEFAULT 0
	,[dblBaseRate]						NUMERIC(18,6) NULL DEFAULT 0
	,[dblExemptionPercent]				NUMERIC(18,6) NULL DEFAULT 0
	,[intTaxAccountId]					INT
	,[intSalesTaxExemptionAccountId] 	INT
	,[ysnSeparateOnInvoice]				BIT
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
	,[ysnAddToCost]						BIT
	,[dblTaxableAmount]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	,[dblOtherTaxAmount]				NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	,[dblItemTaxAmount]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	,[dblItemPrice]						NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	,[dblQtyShipped]					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	,[ysnExcludeCheckOff]				BIT
	,[strItemType]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL --ADDED
	,[intLineItemId]					INT NULL --ADDED
)

BEGIN
	INSERT INTO @CustomerTaxGroup
	SELECT * FROM @CustomerTaxGroupParam
	
	UPDATE P
	SET intItemCategoryId = intCategoryId
	FROM @CustomerTaxGroup P
	INNER JOIN tblICItem I ON P.intItemId = I.intItemId

	INSERT INTO @TaxCodeRate (
		  intTaxCodeId
		, intTaxGroupId
		, dtmTransactionDate
		, intItemUOMId
		, intCurrencyId
		, intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate
		, intLineItemId
	)
	SELECT inTaxCodeId						= TC.intTaxCodeId
		, intTaxGroupId						= P.intTaxGroupId
		, dtmTransactionDate				= P.dtmTransactionDate
		, intItemUOMId						= P.intItemUOMId
		, intCurrencyId						= P.intCurrencyId
		, intCurrencyExchangeRateTypeId		= P.intCurrencyExchangeRateTypeId
		, dblCurrencyExchangeRate			= P.dblCurrencyExchangeRate
		, intLineItemId						= P.intLineItemId
	FROM tblSMTaxCode TC
	INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	INNER JOIN @CustomerTaxGroup P ON TG.intTaxGroupId = P.intTaxGroupId
	
	--GET TAX CODE RATE DETAILS	
	EXEC dbo.uspARGetTaxCodeRateDetails @TaxCodeRate

	INSERT INTO @CustomerTaxCodeExemption (
		  intCustomerId
		, dtmTransactionDate
		, intTaxGroupId
		, intTaxCodeId
		, intTaxClassId
		, strState
		, intItemId
		, intItemCategoryId
		, intShipToLocationId
		, ysnCustomerSiteTaxable
		, intCardId
		, intVehicleId
		, intSiteId
		, ysnDisregardExemptionSetup
		, intCompanyLocationId
		, intFreightTermId
		, intCFSiteId
		, ysnDeliver
		, ysnCFQuote
		, intLineItemId
	)
	SELECT intCustomerId				= P.intCustomerId
		, dtmTransactionDate			= P.dtmTransactionDate
		, intTaxGroupId					= TG.intTaxGroupId
		, intTaxCodeId					= TC.intTaxCodeId
		, intTaxClassId					= TC.intTaxClassId
		, strState						= TC.strState
		, intItemId						= P.intItemId
		, intItemCategoryId				= P.intItemCategoryId
		, intShipToLocationId			= P.intShipToLocationId
		, ysnCustomerSiteTaxable		= P.ysnCustomerSiteTaxable
		, intCardId						= P.intCardId
		, intVehicleId					= P.intVehicleId
		, intSiteId						= P.intSiteId
		, ysnDisregardExemptionSetup	= P.ysnDisregardExemptionSetup
		, intCompanyLocationId			= P.intCompanyLocationId
		, intFreightTermId				= P.intFreightTermId
		, intCFSiteId					= P.intCFSiteId
		, ysnDeliver					= P.ysnDeliver
		, ysnCFQuote					= P.ysnCFQuote
		, intLineItemId					= P.intLineItemId
	FROM tblSMTaxCode TC
	INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	INNER JOIN @CustomerTaxGroup P ON TG.intTaxGroupId = P.intTaxGroupId

	--GET CUSTOMER TAX EXEMPTION
	EXEC dbo.uspARGetCustomerTaxCodeExemption @CustomerTaxCodeExemption
	
	UPDATE TG
	SET strItemType = I.strType
	FROM @CustomerTaxGroup TG 
	INNER JOIN tblICItem I ON TG.intItemId = I.intItemId
	WHERE TG.intItemId IS NOT NULL

	INSERT INTO ##TAXGROUPTAXCODESFORCUSTOMER WITH (TABLOCK) (
		 [intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblBaseRate]
		,[dblExemptionPercent]
		,[intTaxAccountId]
		,[intSalesTaxExemptionAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[ysnTaxOnly]
		,[ysnInvalidSetup]
		,[strTaxGroup]
		,[strNotes]
		,[intUnitMeasureId]
		,[strUnitMeasure]
		,[strTaxClass]
		,[ysnAddToCost]
		,[dblTaxableAmount]
		,[dblItemPrice]
		,[dblQtyShipped]
		,[ysnExcludeCheckOff]
		,[strItemType]
		,[intLineItemId]
	)	
	SELECT intTaxGroupId					= TG.[intTaxGroupId] 
		, intTaxCodeId						= TC.[intTaxCodeId]
		, intTaxClassId						= TC.[intTaxClassId]				
		, strTaxableByOtherTaxes			= TC.[strTaxableByOtherTaxes]
		, strCalculationMethod				= R.[strCalculationMethod]
		, dblRate							= ISNULL(R.[dblRate], 0)
		, dblBaseRate						= ISNULL(R.[dblBaseRate], 0)
		, dblExemptionPercent				= ISNULL(E.[dblExemptionPercent], 0)
		, intTaxAccountId					= TC.[intSalesTaxAccountId]
		, intSalesTaxExemptionAccountId		= TC.[intSalesTaxExemptionAccountId]
		, ysnSeparateOnInvoice				= 0
		, ysnCheckoffTax					= ISNULL(TC.[ysnCheckoffTax], 0)
		, strTaxCode						= TC.[strTaxCode]
		, ysnTaxExempt						= CASE WHEN ISNULL(R.[ysnInvalidSetup], 0) = 1 THEN 1 ELSE ISNULL(E.[ysnTaxExempt], 0) END
		, ysnTaxOnly						= ISNULL(TC.[ysnTaxOnly], 0)
		, ysnInvalidSetup					= CASE WHEN ISNULL(R.[ysnInvalidSetup], 0) = 1 THEN 1 ELSE ISNULL(E.[ysnInvalidSetup], 0) END
		, strTaxGroup						= TG.[strTaxGroup]
		, strNotes							= CASE WHEN ISNULL(R.[ysnInvalidSetup], 0) = 1 THEN 'No Valid Tax Code Detail!' ELSE E.[strExemptionNotes] END
		, intUnitMeasureId					= R.[intUnitMeasureId]
		, strUnitMeasure					= R.[strUnitMeasure]
		, strTaxClass						= TCLASS.[strTaxClass]
		, ysnAddToCost						= ISNULL(TC.[ysnAddToCost], 0)
		, dblTaxableAmount					= P.dblItemPrice * P.dblQtyShipped
		, dblItemPrice						= P.dblItemPrice
		, dblQtyShipped						= P.dblQtyShipped
		, ysnExcludeCheckOff				= P.ysnExcludeCheckOff
		, strItemType						= P.strItemType
		, intLineItemId						= P.intLineItemId
	FROM tblSMTaxCode TC
	INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	INNER JOIN tblSMTaxClass TCLASS ON TC.[intTaxClassId] = TCLASS.[intTaxClassId]
	INNER JOIN @CustomerTaxGroup P ON TG.intTaxGroupId = P.intTaxGroupId
	OUTER APPLY (
		SELECT * 
		FROM ##TAXCODEEXEMPTIONS EX 
		WHERE EX.intCustomerId = P.intCustomerId 
		  AND EX.intTaxGroupId = P.intTaxGroupId 
		  AND EX.intTaxCodeId = TC.intTaxCodeId
		  AND EX.intTaxClassId= TC.intTaxClassId
	) E
	OUTER APPLY (
		SELECT * 
		FROM ##TAXCODERATEDETAILS CRD 
		WHERE CRD.intTaxGroupId = P.intTaxGroupId 
		  AND CRD.intTaxCodeId = TC.intTaxCodeId
		  AND CRD.intItemUOMId = P.intItemUOMId
		  AND CRD.intCurrencyId = P.intCurrencyId
	) R
	WHERE (ISNULL(E.ysnTaxExempt, 0) = 0 OR ISNULL(P.ysnIncludeExemptedCodes, 0) = 1)
	 AND ((ISNULL(E.[ysnInvalidSetup], 0) = 0 AND ISNULL(R.[ysnInvalidSetup], 0) = 0) OR ISNULL(P.ysnIncludeInvalidCodes, 0) = 1)
	ORDER BY TGC.[intTaxGroupCodeId]
END