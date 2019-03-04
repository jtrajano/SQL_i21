CREATE TABLE [dbo].[tblICStagingItemPricing] (
	  intStagingItemPricingId INT IDENTITY(1,1)
	, intItemId INT
	, intItemPricingId INT
	, intItemLocationId INT
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblStandardCost NUMERIC(18, 6) NULL
	, strPricingMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblRetailPrice NUMERIC(18, 6) NULL
	, dblAmountPercentage NUMERIC(18, 6) NULL
	, CONSTRAINT PK_tblICStagingItemPricing_intStagingItemPricingId PRIMARY KEY (intStagingItemPricingId)
)