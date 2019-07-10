CREATE TYPE [dbo].[StoreItemPricing] AS TABLE
(
	intItemPricingId			INT				NOT NULL
	, intItemId					INT				NOT NULL 
	, dblStandardCost			NUMERIC(18, 6)	NULL
	, dblLastCost				NUMERIC(18, 6)	NULL
)

--DROP TYPE [dbo].[StoreItemPricing]