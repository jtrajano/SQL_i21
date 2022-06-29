CREATE TABLE tblApiTaxAdjustment (
      intTaxAdjustmentId INT IDENTITY(1, 1) NOT NULL
	, guiUniqueId UNIQUEIDENTIFIER NOT NULL
    , guiItemTaxIdentifier UNIQUEIDENTIFIER NOT NULL
	, intItemId INT NOT NULL
    , intTaxCodeId INT NOT NULL
    , ysnExempt BIT NULL
    , dblAdjustedTax NUMERIC(18, 6)
)