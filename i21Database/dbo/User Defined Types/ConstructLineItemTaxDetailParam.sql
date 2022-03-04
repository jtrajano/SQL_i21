CREATE TYPE ConstructLineItemTaxDetailParam AS TABLE (
	  dblQuantity						NUMERIC(18,6) NULL DEFAULT 0
	, dblGrossAmount					NUMERIC(18,6) NULL DEFAULT 0
	, ysnReversal						BIT DEFAULT 0
	, intItemId							INT	NULL	
	, intEntityCustomerId				INT	NULL
	, intCompanyLocationId				INT	NULL
	, intTaxGroupId						INT NULL
	, dblPrice							NUMERIC(18,6) NULL DEFAULT 0
	, dtmTransactionDate				DATE NULL	
	, intShipToLocationId				INT NULL
	, ysnIncludeExemptedCodes			BIT DEFAULT 0
	, ysnIncludeInvalidCodes			BIT	DEFAULT 0
	, intSiteId							INT NULL
	, intFreightTermId					INT	NULL
	, intCardId							INT NULL
	, intVehicleId						INT	NULL
	, ysnDisregardExemptionSetup		BIT	DEFAULT 0
	, ysnExcludeCheckOff				BIT	DEFAULT 0
	, intItemUOMId						INT	NULL
	, intCFSiteId						INT	NULL
	, ysnDeliver						BIT	DEFAULT 0
	, ysnCFQuote					    BIT DEFAULT 0
	, intCurrencyId						INT	NULL
	, intCurrencyExchangeRateTypeId		INT NULL
	, dblCurrencyExchangeRate			NUMERIC(18,6) DEFAULT 0
	, intItemCategoryId					INT NULL
	, intLineItemId						INT NULL --intDetailId
)