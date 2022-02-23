CREATE TYPE dbo.CustomerTaxGroupParam AS TABLE (
	  intTaxGroupId					INT
	, intCustomerId					INT
	, intItemId						INT
	, intShipToLocationId			INT
	, intCardId						INT
	, intVehicleId					INT
	, intSiteId						INT
	, intItemUOMId					INT	NULL
	, intCompanyLocationId			INT
	, intFreightTermId				INT
	, intCFSiteId					INT
	, intCurrencyId					INT	NULL
	, intCurrencyExchangeRateTypeId	INT	NULL
	, intItemCategoryId				INT NULL --ADDED
	, dblCurrencyExchangeRate		NUMERIC(18,6) NULL DEFAULT 1
	, dtmTransactionDate			DATETIME
	, ysnIncludeExemptedCodes		BIT
	, ysnIncludeInvalidCodes		BIT
	, ysnCustomerSiteTaxable		BIT
	, ysnDisregardExemptionSetup	BIT
	, ysnDeliver					BIT
	, ysnCFQuote					BIT
	
	, dblTaxableAmount				NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	, dblItemPrice					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	, dblQtyShipped					NUMERIC(18,6) NULL DEFAULT 0 --ADDED
	, ysnExcludeCheckOff			BIT NULL DEFAULT 0 --ADDED
	, strItemType					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL --ADDED
	, intLineItemId					INT NULL --ADDED
)