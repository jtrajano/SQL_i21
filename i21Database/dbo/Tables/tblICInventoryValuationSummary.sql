CREATE TABLE dbo.tblICInventoryValuationSummary (
	  intInventoryValuationSummaryId INT IDENTITY(1,1) NOT NULL
	, intInventoryValuationKeyId INT
	, intItemId INT
	, strItemNo NVARCHAR(100) 
	, strItemDescription NVARCHAR(500)
	, intItemLocationId INT
	, strLocationName NVARCHAR(200)
	, dblRunningQuantity NUMERIC(38, 20)
	, dblRunningValue NUMERIC(38, 20)
	, dblRunningLastCost NUMERIC(38, 20)
	, dblRunningStandardCost NUMERIC(38, 20)
	, dblRunningAverageCost NUMERIC(38, 20)
	, strStockUOM NVARCHAR(50)
	, strCategoryCode NVARCHAR(50)
	, strCommodityCode NVARCHAR(50)
	, strInTransitLocationName NVARCHAR(50)
	, intLocationId INT
	, intInTransitLocationId INT
	, ysnInTransit BIT
	, strPeriod NVARCHAR(50),
	CONSTRAINT [PK_tblICInventoryValuationSummary] PRIMARY KEY ([intInventoryValuationSummaryId]))