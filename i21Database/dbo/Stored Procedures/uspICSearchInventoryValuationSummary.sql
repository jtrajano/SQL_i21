CREATE PROCEDURE dbo.[uspICSearchInventoryValuationSummary]
	@intItemId INT, -- Not needed since I transitioned to inserting to actual table
	@strItemNo NVARCHAR(50), -- Not needed since I transitioned to inserting to actual table
	@strPeriod NVARCHAR(50),
	@intRowsPerPage INT = 50, -- Not needed since I transitioned to inserting to actual table
	@intCurrentPage INT = 1 -- Not needed since I transitioned to inserting to actual table
AS

--IF(NULLIF(@intItemId, '') IS NULL)
--	SET @intItemId = (SELECT intItemId FROM tblICItem WHERE strItemNo = @strItemNo)

--DECLARE @intLowerBound INT = ((@intCurrentPage - 1) * @intRowsPerPage) + 1 
--DECLARE @intUpperBound INT = @intRowsPerPage * @intCurrentPage
--DECLARE @intMaxItemId INT = ISNULL(@intItemId, 2147483647)
--DECLARE @intMinItemId INT = ISNULL(@intItemId, 1)
SELECT TOP 1 @strPeriod = strPeriod FROM tblGLFiscalYearPeriod WHERE strPeriod = @strPeriod

--DECLARE @valuations TABLE (
--	  intInventoryValuationKeyId INT PRIMARY KEY
--	, intItemId INT
--	, strItemNo NVARCHAR(100) 
--	, strItemDescription NVARCHAR(500)
--	, intItemLocationId INT
--	, strLocationName NVARCHAR(200)
--	, dblRunningQuantity NUMERIC(38, 20)
--	, dblRunningValue NUMERIC(38, 20)
--	, dblRunningLastCost NUMERIC(38, 20)
--	, dblRunningStandardCost NUMERIC(38, 20)
--	, dblRunningAverageCost NUMERIC(38, 20)
--	, strStockUOM NVARCHAR(50)
--	, strCategoryCode NVARCHAR(50)
--	, strCommodityCode NVARCHAR(50)
--	, strInTransitLocationName NVARCHAR(50)
--	, intLocationId INT
--	, intInTransitLocationId INT
--	, ysnInTransit BIT
--	, strPeriod NVARCHAR(50))


DELETE FROM tblICInventoryValuationSummary

IF NULLIF(@strPeriod, '') IS NOT NULL
BEGIN
	--INSERT INTO @valuations
	INSERT INTO tblICInventoryValuationSummary(
		  intInventoryValuationKeyId
		, intItemId
		, strItemNo
		, strItemDescription
		, intItemLocationId 
		, strLocationName
		, dblRunningQuantity
		, dblRunningValue
		, dblRunningLastCost
		, dblRunningStandardCost
		, dblRunningAverageCost
		, strStockUOM
		, strCategoryCode
		, strCommodityCode
		, strInTransitLocationName
		, intLocationId 
		, intInTransitLocationId
		, ysnInTransit
		, strPeriod
	)
	SELECT
		  intInventoryValuationKeyId = CAST(ROW_NUMBER() OVER (ORDER BY il.intItemLocationId) AS INT)
		, i.intItemId
		, i.strItemNo
		, strItemDescription = i.strDescription 
		, il.intItemLocationId
		, strLocationName = CASE WHEN val.ysnInTransit = 1 THEN loc.strLocationName + ' (In-Transit)' ELSE loc.strLocationName END
		, dblRunningQuantity = ISNULL(val.dblQuantity, 0)
		, dblRunningValue = ISNULL(val.dblValue, 0)
		, dblRunningLastCost = ISNULL(ROUND(val.dblQuantityInStockUOM * ip.dblLastCost, 2), 0)
		, dblRunningStandardCost = ISNULL( ROUND(val.dblQuantityInStockUOM * ip.dblStandardCost, 2),0)
		, dblRunningAverageCost = ISNULL( ROUND(val.dblQuantityInStockUOM * ip.dblAverageCost, 2),0)
		, strStockUOM = umStock.strUnitMeasure
		, cat.strCategoryCode
		, com.strCommodityCode
		, strInTransitLocationName = ''
		, val.intLocationId
		, intInTransitLocationId = null  
		, val.ysnInTransit
		, strPeriod = @strPeriod
	FROM tblICItem i
		INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
		INNER JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = il.intLocationId
		LEFT JOIN tblICItemPricing ip ON ip.intItemLocationId = il.intItemLocationId
			AND ip.intItemId = i.intItemId
		LEFT JOIN tblICItemUOM ium ON ium.intItemId = i.intItemId
			AND ium.ysnStockUnit = 1  
		LEFT JOIN tblICUnitMeasure umStock ON umStock.intUnitMeasureId = ium.intUnitMeasureId 
		LEFT JOIN tblICCategory cat ON cat.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity com ON com.intCommodityId = i.intCommodityId
		CROSS APPLY dbo.fnGetItemValuation(i.intItemId, il.intItemLocationId, @strPeriod) val
	--WHERE i.intItemId BETWEEN @intMinItemId AND @intMaxItemId
	ORDER BY il.intItemLocationId
END

--SELECT *
--FROM @valuations v
--WHERE v.intInventoryValuationKeyId BETWEEN @intLowerBound AND @intUpperBound

GO