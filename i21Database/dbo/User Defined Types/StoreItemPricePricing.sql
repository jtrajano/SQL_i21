CREATE TYPE [dbo].[StoreItemPricePricing] AS TABLE(
	intEffectiveItemPriceId [int] NULL,
	intStoreNo [int] NULL,
	strLocationName [nvarchar](100) NULL,
	dblRetailPrice [numeric](38, 20) NULL,
	dtmEffectiveRetailPriceDate [datetime] NULL
)
