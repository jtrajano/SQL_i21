CREATE TYPE [dbo].[CustomerTaxCodeExemptionParam] AS TABLE (
	  intCustomerId					INT
	, intTaxGroupId					INT
	, intTaxCodeId					INT
	, intTaxClassId					INT
	, intItemId						INT
	, intItemCategoryId				INT
	, intShipToLocationId			INT
	, intCardId						INT
	, intVehicleId					INT
	, intSiteId						INT
	, intCompanyLocationId			INT
	, intFreightTermId				INT
	, intCFSiteId					INT
	, intSiteNumber					INT NULL ---ADDED
	, strState						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL ---ADDED
	, strTaxState					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL
	, dtmTransactionDate			DATETIME
	, ysnCustomerSiteTaxable		BIT NULL DEFAULT 0
	, ysnDisregardExemptionSetup	BIT NULL DEFAULT 0
	, ysnDeliver					BIT NULL DEFAULT 0
	, ysnCFQuote					BIT NULL DEFAULT 0
	, intLineItemId					INT NULL --ADDED
)