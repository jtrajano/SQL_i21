CREATE TABLE dbo.tblICInventoryValuationSummary (
	  intInventoryValuationSummaryId INT IDENTITY(1,1) NOT NULL
	, intInventoryValuationKeyId INT
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS
	, intItemLocationId INT
	, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblRunningQuantity NUMERIC(38, 6)
	, dblRunningValue NUMERIC(38, 6)
	, dblRunningLastCost NUMERIC(38, 6)
	, dblRunningStandardCost NUMERIC(38, 6)
	, dblRunningAverageCost NUMERIC(38, 6)
	, strStockUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strInTransitLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, intInTransitLocationId INT
	, ysnInTransit BIT
	, strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dtmDateLastSynced DATETIME2 NULL
	, strKey NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblICInventoryValuationSummary] PRIMARY KEY ([intInventoryValuationSummaryId]))