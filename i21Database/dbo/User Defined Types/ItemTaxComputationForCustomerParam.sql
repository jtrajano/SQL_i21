CREATE TYPE dbo.ItemTaxComputationForCustomerParam AS TABLE (
	  intItemId						INT
	, intCustomerId					INT
	, dtmTransactionDate			DATETIME
	, dblItemPrice					NUMERIC(18,6) DEFAULT 0
	, dblQtyShipped					NUMERIC(18,6) DEFAULT 0
	, intTaxGroupId					INT	
	, intCompanyLocationId			INT
	, intCustomerLocationId			INT	
	, ysnIncludeExemptedCodes		BIT
	, ysnIncludeInvalidCodes		BIT
	, ysnCustomerSiteTaxable		BIT
	, intSiteId						INT
	, intFreightTermId				INT
	, intCardId						INT
	, intVehicleId					INT
	, ysnDisregardExemptionSetup	BIT
	, ysnExcludeCheckOff			BIT
	, intCFSiteId					INT
	, ysnDeliver					BIT
	, ysnCFQuote					BIT
	, intItemUOMId					INT
	, intCurrencyId					INT
	, intCurrencyExchangeRateTypeId	INT
	, dblCurrencyExchangeRate		NUMERIC(18,6) DEFAULT 0
	, intLineItemId					INT NULL --ADDED
	, intTransactionDetailTaxId		INT NULL --ADDED
	, intTransactionDetailId		INT NULL --ADDED
	, intTaxCodeId					INT NULL --ADDED
	, intTaxClassId					INT NULL --ADDED
	, strTaxableByOtherTaxes		NVARCHAR(100) NULL
	, strCalculationMethod			NVARCHAR(100) NULL
	, dblRate						NUMERIC(18,6) DEFAULT 0
	, dblBaseRate					NUMERIC(18,6) DEFAULT 0
	, dblExemptionPercent			NUMERIC(18,6) DEFAULT 0
	, dblTax						NUMERIC(18,6) DEFAULT 0
	, dblAdjustedTax				NUMERIC(18,6) DEFAULT 0
	, ysnSeparateOnInvoice			BIT NULL DEFAULT 0
	, intTaxAccountId				INT NULL
	, intSalesTaxExemptionAccountId	INT NULL
	, ysnTaxAdjusted				BIT NULL DEFAULT 0
	, ysnCheckoffTax				BIT NULL DEFAULT 0
	, strTaxCode					NVARCHAR(100) NULL
	, ysnTaxExempt					BIT NULL DEFAULT 0
	, ysnTaxOnly					BIT NULL DEFAULT 0
	, ysnInvalidSetup				BIT NULL DEFAULT 0
	, strTaxGroup					NVARCHAR(100) NULL
	, strNotes						NVARCHAR(100) NULL
	, intUnitMeasureId				INT NULL
	, ysnAddToCost					BIT NULL DEFAULT 0
)