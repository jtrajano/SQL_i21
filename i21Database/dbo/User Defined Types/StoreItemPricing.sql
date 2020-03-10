CREATE TYPE [dbo].[StoreItemPricing] AS TABLE
(
	intItemPricingId			INT				NULL
	, intItemId					INT				NULL 
	, dblStandardCost			NUMERIC(38,20)	NULL
	, dblLastCost				NUMERIC(38,20)	NULL
	, dblSalePrice				NUMERIC(38,20)	NULL
	, intStoreId				INT				NULL 
	, intProductCodeId			INT				NULL 
	, intIssueUOMId				INT				NULL 
	, intItemLocationId			INT				NULL 
)

--DROP TYPE [dbo].[StoreItemPricing]

