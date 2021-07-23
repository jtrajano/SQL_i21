CREATE TYPE [dbo].[StoreItemGridToUpdate] AS TABLE(
	intItemId [int] NULL,
	intStoreNo [int] NULL,
	dblNewCost [numeric](38, 20) NULL,
	dblNewPrice [numeric](38, 20) NULL,
	dtmStartDate [datetime] NULL,
	dtmEndDate [datetime] NULL
)
