CREATE TABLE [dbo].[tblICStagingItemPricing] (
	  intStagingItemPricingId INT IDENTITY(1,1)
	, intItemId INT -- Normally used when this field is included in export
	, intItemPricingId INT -- Normally used when this field is included in export
	, intItemLocationId INT -- Normally used when this field is included in export
	, intLocationId INT -- Normally used when this field is included in export
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblStandardCost NUMERIC(18, 6) NULL
	, strPricingMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblRetailPrice NUMERIC(18, 6) NULL
	, dblAmountPercentage NUMERIC(18, 6) NULL
	, dtmDateLastUpdated DATETIME NULL
	, CONSTRAINT PK_tblICStagingItemPricing_intStagingItemPricingId PRIMARY KEY (intStagingItemPricingId)
)