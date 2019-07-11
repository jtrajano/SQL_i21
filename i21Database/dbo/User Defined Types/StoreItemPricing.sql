CREATE TYPE [dbo].[StoreItemPricing] AS TABLE
(
	intItemPricingId			INT				NOT NULL
	, intItemId					INT				NOT NULL 
	, dblStandardCost			NUMERIC(38,20)	NULL
	, dblLastCost				NUMERIC(38,20)	NULL
)

--DROP TYPE [dbo].[StoreItemPricing]