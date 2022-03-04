CREATE TYPE dbo.TaxCodeRateParam AS TABLE (
	  intTaxCodeId					INT
	, intTaxGroupId					INT
	, intItemUOMId					INT
	, intCurrencyId					INT
	, intCurrencyExchangeRateTypeId	INT
	, dtmTransactionDate			DATETIME
	, dblCurrencyExchangeRate		NUMERIC(18, 6) NULL DEFAULT 0
	, dblExchangeRate				NUMERIC(18, 6) NULL DEFAULT 0
	, ysnBSE						BIT NULL DEFAULT 0
	, intLineItemId					INT NULL --ADDED
)