CREATE TYPE [dbo].[StoreItemCostPricing] AS TABLE(
	intEffectiveItemCostId [int] NULL,
	intStoreNo [int] NULL,
	strLocationName [nvarchar](100) NULL,
	dblCost [numeric](38, 20) NULL,
	dtmEffectiveCostDate [datetime] NULL
)

