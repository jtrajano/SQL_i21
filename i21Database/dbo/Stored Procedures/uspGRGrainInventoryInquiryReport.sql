CREATE PROCEDURE [dbo].[uspGRGrainInventoryInquiryReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET FMTONLY OFF

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE 
(
	[fieldname] NVARCHAR(50)
	,[condition] NVARCHAR(20)
	,[from] NVARCHAR(MAX)
	,[to] NVARCHAR(MAX)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)
DECLARE @xmlDocumentId AS INT

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
(
	[fieldname] NVARCHAR(50)
	,[condition] NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)

DECLARE @intCommodityId INT
DECLARE @intLocationId INT
DECLARE @dtmReportDate DATETIME
DECLARE @strLicensed NVARCHAR(20)
DECLARE @ysnLicensed BIT

SELECT @dtmReportDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmReportDate'

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SELECT @intLocationId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intLocationId'

SELECT @strLicensed = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strLicensed'

DECLARE @ReportData TABLE
(
	intRowNum INT
	,strLabel NVARCHAR(500) COLLATE Latin1_General_CI_AS
	,strSign NVARCHAR(2) COLLATE Latin1_General_CI_AS
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dtmReportDate DATETIME
	,strUOM NVARCHAR(20) COLLATE Latin1_General_CI_AS
)

DECLARE @guid UNIQUEIDENTIFIER = NEWID()
DECLARE @InventoryData TABLE
(
	intRowNum INT
	,strLabel NVARCHAR(500) COLLATE Latin1_General_CI_AS
	,strSign NVARCHAR(2) COLLATE Latin1_General_CI_AS
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(20) COLLATE Latin1_General_CI_AS
)

DECLARE @InventoryDataCompanyOwned TABLE
(
	dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(20) COLLATE Latin1_General_CI_AS
)

DECLARE @InventoryAdjustments TABLE
(
	dblUnits DECIMAL(18,6)
	,intCommodityId INT
	,intCompanyLocationId INT
	,strOwnership NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(20) COLLATE Latin1_General_CI_AS
)

DECLARE @intCommodityId2 INT
DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @strUOM NVARCHAR(20)
DECLARE @intCommodityUnitMeasureId AS INT

DECLARE @tblCommodities AS TABLE 
(
	intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS

)

CREATE TABLE #tblInOut
(
	dtmDate DATETIME,
	dblInvIn DECIMAL(18,6),
	dblInvOut DECIMAL(18,6),
	dblAdjustments DECIMAL(18,6),
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intCommodityId INT,
	strOwnership VARCHAR(50) COLLATE Latin1_General_CI_AS,
	intCompanyLocationId INT,
	strLocationName VARCHAR(200) COLLATE Latin1_General_CI_AS
)

CREATE TABLE #tblInOut2
(
	dtmDate DATETIME,
	dblInvIn DECIMAL(18,6),
	dblInvOut DECIMAL(18,6),
	dblAdjustments DECIMAL(18,6),
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intCommodityId INT,
	strOwnership VARCHAR(50) COLLATE Latin1_General_CI_AS,
	intCompanyLocationId INT,
	strLocationName VARCHAR(200) COLLATE Latin1_General_CI_AS
)

CREATE TABLE #tblInTransit
(
	dblInTransitQty DECIMAL(18,6)
	,intCommodityId INT
	,strCommodityCode VARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dtmDate DATETIME	
)

CREATE TABLE #tblInTransit2
(
	dtmDate DATETIME
	,intLocationId INT
	,strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS
	,dblBeginningSalesInTransit DECIMAL(18,6)
	,dblSalesInTransit DECIMAL(18,6)
)

CREATE TABLE #Locations
(
	intCompanyLocationId INT,
	strLocationName VARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
DECLARE @Locs AS Id

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END
SET @intLocationId = CASE WHEN @intLocationId = 0 THEN NULL ELSE @intLocationId END
SET @ysnLicensed =	CASE 
						WHEN @strLicensed = 'All' OR @intLocationId IS NOT NULL THEN NULL
						WHEN @strLicensed = 'Licensed' THEN 1
						WHEN @strLicensed = 'Non-Licensed' THEN 0
						ELSE NULL
					END

IF @intLocationId IS NULL
BEGIN
	INSERT INTO #Locations
	SELECT intCompanyLocationId, strLocationName 
	FROM tblSMCompanyLocation
	WHERE ysnLicensed = ISNULL(@ysnLicensed,ysnLicensed)

	INSERT INTO @Locs
	SELECT intCompanyLocationId
	FROM tblSMCompanyLocation
	WHERE ysnLicensed = ISNULL(@ysnLicensed,ysnLicensed)
END
ELSE
BEGIN
	INSERT INTO #Locations
	SELECT intCompanyLocationId, strLocationName 
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId
END
;

/* Inventory Opening Balance*/
WITH tblCOAndStorage AS (
SELECT	1 intItemId
		,I.intCommodityId
		,intLocationId
		,CL.strLocationName
		,t.intInTransitSourceLocationId
		,CL.ysnLicensed
		,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,UM.intCommodityUnitMeasureId,t.dblQty))
		,UOM.strUnitMeasure
FROM tblICInventoryTransaction t
INNER JOIN (
			tblICItemLocation ItemLocation 
			LEFT JOIN tblICItemUOM UOML
				ON UOML.intItemUOMId = ItemLocation.intReceiveUOMId
			)
		ON ItemLocation.intItemLocationId = t.intItemLocationId
LEFT JOIN tblICItemUOM UOM2
	ON UOM2.intItemId = t.intItemId
		AND UOM2.ysnStockUnit = 1
INNER JOIN tblICItem I 
	ON I.intItemId = t.intItemId
INNER JOIN tblICCommodityUnitMeasure UM
	ON UM.intCommodityId = I.intCommodityId
		AND UM.ysnStockUnit = 1
OUTER APPLY (
	SELECT TOP 1 intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = I.intCommodityId
		AND intUnitMeasureId = ISNULL(UOML.intUnitMeasureId,UOM2.intUnitMeasureId)
) UM_REF
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
INNER JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = ItemLocation.intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmReportDate 
	AND I.intCommodityId = ISNULL(@intCommodityId, I.intCommodityId)
	AND ((CL.ysnLicensed = COALESCE(@ysnLicensed,CL.ysnLicensed) AND CL.intCompanyLocationId = ISNULL(@intLocationId,CL.intCompanyLocationId))
			OR CL.intCompanyLocationId = @intLocationId
		)
	--AND (t.intCostingMethod = 5 AND t.strTransactionForm = 'Invoice' --get the ACTUAL PRICE only for the invoice transactions
	--		OR (t.intCostingMethod IS NOT NULL AND (t.intCostingMethod <> 5 AND t.strTransactionForm <> 'Invoice'))
	--	)
	AND intInTransitSourceLocationId IS NULL
GROUP BY t.intItemId
		,ItemLocation.intLocationId
		,t.intLotId
		,t.intInTransitSourceLocationId
		,CL.ysnLicensed
		,I.intCommodityId
		,CL.strLocationName
		,UOM.strUnitMeasure
UNION ALL
SELECT	1 intItemId
		,I.intCommodityId
		,intLocationId
		,CL.strLocationName
		--t.intTransactionTypeId,			
		,NULL intInTransitSourceLocationId
		,CL.ysnLicensed
		,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,UM.intCommodityUnitMeasureId,t.dblQty))
		,UOM.strUnitMeasure
FROM tblICInventoryTransactionStorage t
INNER JOIN (
			tblICItemLocation ItemLocation 
			LEFT JOIN tblICItemUOM UOML
				ON UOML.intItemUOMId = ItemLocation.intReceiveUOMId
			)
		ON ItemLocation.intItemLocationId = t.intItemLocationId
LEFT JOIN tblICItemUOM UOM2
	ON UOM2.intItemId = t.intItemId
		AND UOM2.ysnStockUnit = 1
INNER JOIN tblICItem I 
	ON I.intItemId = t.intItemId
INNER JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = ItemLocation.intLocationId
INNER JOIN tblICCommodityUnitMeasure UM
	ON UM.intCommodityId = I.intCommodityId
		AND UM.ysnStockUnit = 1
OUTER APPLY (
	SELECT TOP 1 intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = I.intCommodityId
		AND intUnitMeasureId = ISNULL(UOML.intUnitMeasureId,UOM2.intUnitMeasureId)
) UM_REF
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmReportDate
	AND I.intCommodityId = ISNULL(@intCommodityId, I.intCommodityId)
	AND ((CL.ysnLicensed = COALESCE(@ysnLicensed,CL.ysnLicensed) AND CL.intCompanyLocationId = ISNULL(@intLocationId,CL.intCompanyLocationId))
			OR CL.intCompanyLocationId = @intLocationId
		)
GROUP BY t.intItemId
		,ItemLocation.intLocationId
		,CL.ysnLicensed
		,I.intCommodityId
		,CL.strLocationName
		,UOM.strUnitMeasure
)

INSERT INTO @InventoryData
SELECT 1,
	   'PHYSICAL INVENTORY BEGINNING' AS label
	   ,'' AS [Sign]
	   ,SUM(ISNULL(OP.dblQty,0))
	   ,Commodity.strCommodityCode
	   ,Commodity.intCommodityId
	   ,OP.intLocationId
	   ,OP.strLocationName
	   ,OP.strUnitMeasure
FROM tblCOAndStorage OP
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = OP.intCommodityId
GROUP BY Commodity.strCommodityCode
		,Commodity.intCommodityId
		,OP.intLocationId
	   ,OP.strLocationName
	   ,OP.strUnitMeasure

IF NOT EXISTS(SELECT 1 FROM @InventoryData)
BEGIN
INSERT INTO @InventoryData
SELECT 1,
	   'PHYSICAL INVENTORY BEGINNING' AS label
	   ,'' AS [Sign]
	   ,0
	   ,Commodity.strCommodityCode
	   ,Commodity.intCommodityId
	   ,OP.intLocationId
	   ,OP.strLocationName
	   ,OP.strUnitMeasure
FROM (SELECT	1 intItemId
		,I.intCommodityId
		,intLocationId
		,CL.strLocationName
		,t.intInTransitSourceLocationId
		,CL.ysnLicensed
		,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,UM.intCommodityUnitMeasureId,t.dblQty))
		,UOM.strUnitMeasure
FROM tblICInventoryTransaction t
INNER JOIN (
			tblICItemLocation ItemLocation 
			LEFT JOIN tblICItemUOM UOML
				ON UOML.intItemUOMId = ItemLocation.intReceiveUOMId
			)
		ON ItemLocation.intItemLocationId = t.intItemLocationId
LEFT JOIN tblICItemUOM UOM2
	ON UOM2.intItemId = t.intItemId
		AND UOM2.ysnStockUnit = 1
INNER JOIN tblICItem I 
	ON I.intItemId = t.intItemId
INNER JOIN tblICCommodityUnitMeasure UM
	ON UM.intCommodityId = I.intCommodityId
		AND UM.ysnStockUnit = 1
OUTER APPLY (
	SELECT TOP 1 intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = I.intCommodityId
		AND intUnitMeasureId = ISNULL(UOML.intUnitMeasureId,UOM2.intUnitMeasureId)
) UM_REF
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId
INNER JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = ItemLocation.intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate >= @dtmReportDate 
	AND I.intCommodityId = ISNULL(@intCommodityId, I.intCommodityId)
	AND ((CL.ysnLicensed = COALESCE(@ysnLicensed,CL.ysnLicensed) AND CL.intCompanyLocationId = ISNULL(@intLocationId,CL.intCompanyLocationId))
			OR CL.intCompanyLocationId = @intLocationId
		)
GROUP BY t.intItemId
		,ItemLocation.intLocationId
		,t.intLotId
		,t.intInTransitSourceLocationId
		,CL.ysnLicensed
		,I.intCommodityId
		,CL.strLocationName
		,UOM.strUnitMeasure) OP
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = OP.intCommodityId
GROUP BY Commodity.strCommodityCode
		,Commodity.intCommodityId
		,OP.intLocationId
	   ,OP.strLocationName
	   ,OP.strUnitMeasure
END
/*end inventory opening balance */

/* Received, Shipped, Adjustments */
INSERT INTO @tblCommodities
SELECT DISTINCT ID.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
WHERE strLabel = 'PHYSICAL INVENTORY BEGINNING'

DECLARE @intCompanyLocationId INT
DECLARE @strLocationName NVARCHAR(200)

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL	
	SET @strUOM = NULL

	SELECT TOP 1 @intCommodityId2 = intCommodityId, @strCommodityCode = strCommodityCode FROM @tblCommodities

	SELECT @strUOM = UM.strUnitMeasure
		,@intCommodityUnitMeasureId = UOM.intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure UOM
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE intCommodityId = @intCommodityId2
		AND ysnStockUnit = 1
	
	DELETE FROM #tblInOut
	INSERT INTO #tblInOut
	EXEC uspGRGetInHousePerLocation
		@dtmDate = @dtmReportDate
		,@intCommodityId = @intCommodityId2
		,@Locations = @Locs
		,@intLocationId = @intLocationId

	--for in transit
	--DELETE FROM #tblInTransit2
	--INSERT INTO #tblInTransit2
	--EXEC uspGRGetInTransitPerLocation
	--	@dtmDate = @dtmReportDate
	--	,@intCommodityId = @intCommodityId
	--	,@intLocationId = @intLocationId
	--	,@Locations = @Locs

	--ALL LOCATIONS (#Location) SHOULD HAVE THESE ITEMS
	WHILE EXISTS(SELECT TOP 1 1 FROM #Locations)
	BEGIN
		SET @intCompanyLocationId = NULL
		SET @strLocationName = NULL

		SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId
			,@strLocationName = strLocationName
		FROM #Locations

		INSERT INTO @InventoryData
		SELECT 2
			,'RECEIVED'
			,'+'
			,ABS(SUM(ISNULL(dblInvIn,0)) - SUM(ISNULL(dblInvOut,0)))
			,@strCommodityCode
			,@intCommodityId2
			,@intCompanyLocationId
			,@strLocationName
			,@strUOM
		FROM #tblInOut
		WHERE strTransactionType = 'Inventory Receipt'
			AND dtmDate IS NOT NULL
			AND intCompanyLocationId = @intCompanyLocationId

		INSERT INTO @InventoryData
		SELECT 3
			,'SHIPPED'
			,'-'
			,ABS(SUM(ISNULL(dblInvIn,0)) - SUM(ISNULL(dblInvOut,0)))
			,@strCommodityCode
			,@intCommodityId2
			,@intCompanyLocationId
			,@strLocationName
			,@strUOM
		FROM #tblInOut
		WHERE strTransactionType IN ('Inventory Shipment','Outbound Shipment','Invoice')
			AND dtmDate IS NOT NULL
			AND intCompanyLocationId = @intCompanyLocationId

		INSERT INTO @InventoryData
		SELECT 4
			,'INTERNAL TRANSFERS RECEIVED'
			,'+'
			,ABS(SUM(ISNULL(dblInvIn,0)))
			,@strCommodityCode
			,@intCommodityId2
			,@intCompanyLocationId
			,@strLocationName
			,@strUOM
		FROM #tblInOut
		WHERE strTransactionType = 'Inventory Transfer' 
			AND dtmDate IS NOT NULL
			AND intCompanyLocationId = @intCompanyLocationId

		INSERT INTO @InventoryData
		SELECT 5
			,'INTERNAL TRANSFERS SHIPPED'
			,'-'
			,ABS(SUM(ISNULL(dblInvOut,0)))
			,@strCommodityCode
			,@intCommodityId2
			,@intCompanyLocationId
			,@strLocationName
			,@strUOM
		FROM #tblInOut 
		WHERE strTransactionType = 'Inventory Transfer' 
			AND dtmDate IS NOT NULL
			AND intCompanyLocationId = @intCompanyLocationId

		INSERT INTO @InventoryData
		SELECT 6
			,'NET ADJUSTMENTS'
			,CASE WHEN ISNULL(dblAdjustments,0) < 0 THEN '-' ELSE '+' END
			,CASE WHEN ISNULL(dblAdjustments,0) = 0 THEN 0 ELSE ABS(dblAdjustments) END
			,@strCommodityCode
			,@intCommodityId2
			,@intCompanyLocationId
			,@strLocationName
			,@strUOM
		FROM (
			SELECT dblAdjustments = SUM(ISNULL(dblAdjustments,0))
			FROM #tblInOut
			WHERE strTransactionType IN ('Storage Adjustment', 'Inventory Adjustment')
				AND dtmDate IS NOT NULL
				AND intCompanyLocationId = @intCompanyLocationId
		) ADJ

		--separate the IAs for Company Owned and Customer Owned
		INSERT INTO @InventoryAdjustments
		SELECT dblAdjustments
			,@intCommodityId2
			,@intCompanyLocationId
			,strOwnership
			,@strUOM
		FROM #tblInOut
		WHERE dtmDate IS NOT NULL
			AND strTransactionType = 'Inventory Adjustment'
			AND intCompanyLocationId = @intCompanyLocationId

		/* IN TRANSIT */	
		--INSERT INTO @InventoryData
		--SELECT 
		--	9
		--	,'INVENTORY IN TRANSIT BEGINNING'
		--	,''
		--	, SUM(ISNULL(I.TOTAL,0))
		--	,ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM
		--FROM @InventoryData ID
		--OUTER APPLY (
		--	SELECT 
		--		TOTAL = ISNULL(dblBeginningSalesInTransit,0)-- - CASE WHEN ISNULL(dblSalesInTransit,0) < 0 THEN 0 ELSE ISNULL(dblSalesInTransit,0) END
		--	FROM #tblInTransit2
		--	WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) < @dtmReportDate
		--		AND intLocationId = ID.intCompanyLocationId
		--) I
		--WHERE ID.strLabel = 'PHYSICAL INVENTORY BEGINNING'
		--	AND ID.intCompanyLocationId = @intCompanyLocationId
		--	AND ID.intCommodityId = @intCommodityId
		--GROUP BY ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM

		--INSERT INTO @InventoryData
		--SELECT 
		--	10
		--	,'INVENTORY IN TRANSIT INCREASE'
		--	,'+'
		--	, SUM(ISNULL(I.TOTAL,0))
		--	,ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM
		--FROM @InventoryData ID
		--OUTER APPLY (
		--	SELECT 
		--		TOTAL = ISNULL(dblBeginningSalesInTransit,0)
		--	FROM #tblInTransit2
		--	WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) = @dtmReportDate
		--		AND intLocationId = ID.intCompanyLocationId
		--) I
		--WHERE ID.strLabel = 'INVENTORY IN TRANSIT BEGINNING'
		--	AND ID.intCompanyLocationId = @intCompanyLocationId
		--	AND ID.intCommodityId = @intCommodityId
		--GROUP BY ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM

		--INSERT INTO @InventoryData
		--SELECT 
		--	11
		--	,'INVENTORY IN TRANSIT DECREASE'
		--	,'-'
		--	, ABS(SUM(ISNULL(I.TOTAL,0)))
		--	,ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM
		--FROM @InventoryData ID
		--OUTER APPLY (
		--	SELECT 
		--		TOTAL = ISNULL(dblSalesInTransit,0)
		--	FROM #tblInTransit2
		--	WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) = @dtmReportDate
		--		AND intLocationId = ID.intCompanyLocationId
		--) I
		--WHERE ID.strLabel = 'INVENTORY IN TRANSIT BEGINNING'
		--	AND ID.intCompanyLocationId = @intCompanyLocationId
		--	AND ID.intCommodityId = @intCommodityId
		--GROUP BY ID.strCommodityCode
		--	,ID.intCommodityId
		--	,ID.intCompanyLocationId
		--	,ID.strLocationName
		--	,ID.strUOM

		--INSERT INTO @InventoryData
		--SELECT 
		--	12
		--	,'INVENTORY IN TRANSIT ENDING'
		--	,''
		--	,SUM(ISNULL(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END,0))
		--	,strCommodityCode
		--	,intCommodityId
		--	,intCompanyLocationId
		--	,strLocationName
		--	,strUOM
		--FROM @InventoryData
		--WHERE strLabel LIKE 'INVENTORY IN TRANSIT%'
		--	AND intCompanyLocationId = @intCompanyLocationId
		--	AND intCommodityId = @intCommodityId
		--GROUP BY strCommodityCode
		--	,intCommodityId
		--	,intCompanyLocationId
		--	,strLocationName
		--	,strUOM

		----BLANK SPACE
		--INSERT INTO @ReportData
		--SELECT
		--	13
		--	,''
		--	,''
		--	,NULL
		--	,strCommodityCode
		--	,intCommodityId
		--	,intCompanyLocationId
		--	,strLocationName
		--	,@dtmReportDate
		--	,strUOM
		--FROM @InventoryData
		--WHERE intCommodityId = @intCommodityId
		--	AND intCompanyLocationId = @intCompanyLocationId
		--	AND strLabel = 'INVENTORY IN TRANSIT ENDING'
		--GROUP BY strCommodityCode
		--	,intCommodityId
		--	,intCompanyLocationId
		--	,strLocationName
		--	,strUOM
		/* END IN TRANSIT */

		DELETE FROM #Locations WHERE intCompanyLocationId = @intCompanyLocationId
	END

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
/* END-Received, Shipped, Adjustments */

/* TOTAL INVENTORY */
INSERT INTO @InventoryData
SELECT
	7
	,'PHYSICAL INVENTORY ENDING'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName	
	,strUOM
FROM @InventoryData
WHERE strLabel NOT LIKE 'INVENTORY IN TRANSIT%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

--BLANK SPACE
INSERT INTO @ReportData
SELECT
	8
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,@dtmReportDate
	,strUOM
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
/* END TOTAL INVENTORY */

DECLARE @StorageTypes TABLE
(
	intStorageScheduleTypeId INT
	,strStorageTypeDescription NVARCHAR(60) COLLATE Latin1_General_CI_AS
)

DECLARE @intCnt INT = 1
DECLARE @intOrigCnt INT = 0
DECLARE @intStorageTypeNum INT 
DECLARE @intTotalRowCnt INT

/*==START==STORAGE OBLIGATION==*/
DECLARE @StorageObligationData TABLE
(
	intRowNum INT
	,intStorageScheduleTypeId INT
	,strLabel NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSign NVARCHAR(2) COLLATE Latin1_General_CI_AS
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
)

DECLARE @StorageObligationDataDUMMY TABLE
(
	intRowNum INT
	,intStorageScheduleTypeId INT
	,strLabel NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSign NVARCHAR(2) COLLATE Latin1_General_CI_AS
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intCompanyLocationId INT
	,strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS

)
DECLARE @intStorageScheduleTypeId INT
DECLARE @strStorageTypeDescription NVARCHAR(60)
DECLARE @prevStorageType NVARCHAR(40)

INSERT INTO @tblCommodities
SELECT DISTINCT ID.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
WHERE strLabel = 'PHYSICAL INVENTORY BEGINNING'

/*==START==STORAGE OBLIGATION==*/
WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCommodityUnitMeasureId = NULL
	SET @intCnt = 1
	SET @strUOM = NULL

	SELECT TOP 1 @intCommodityId2 = intCommodityId, @strCommodityCode = strCommodityCode FROM @tblCommodities
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@strUOM = UM.strUnitMeasure
	FROM tblICCommodityUnitMeasure UOM
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE intCommodityId = @intCommodityId2
		AND ysnStockUnit = 1

	SELECT DISTINCT intCompanyLocationId
	INTO #LicensedLocation
	FROM @InventoryData

	SELECT *
	INTO #CustomerOwnershipALL
	FROM (
		SELECT
			dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
			,strDistributionType
			,strTransactionNumber
			,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
			,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
			,ST.intStorageScheduleTypeId
			,CusOwn.strStorageTypeCode
			,CusOwn.intLocationId
			,CusOwn.strLocationName
			,CusOwn.strCommodityCode
			,CusOwn.strTransactionType
		FROM dbo.fnRKGetBucketCustomerOwned(@dtmReportDate,@intCommodityId,NULL) CusOwn
		LEFT JOIN tblGRStorageType ST 
			ON ST.strStorageTypeDescription = CusOwn.strDistributionType
		WHERE CusOwn.intCommodityId = @intCommodityId2
		UNION ALL
		SELECT
			dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
			,strDistributionType
			,strTransactionNumber			
			,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
			,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
			,intStorageScheduleTypeId = -5
			,''
			,OH.intLocationId
			,OH.strLocationName
			,OH.strCommodityCode
			,OH.strTransactionType
		FROM dbo.fnRKGetBucketOnHold(@dtmReportDate,@intCommodityId,NULL) OH
		WHERE OH.intCommodityId = @intCommodityId2
	) t

	DELETE A
	FROM #CustomerOwnershipALL A
	WHERE intLocationId NOT IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	INSERT INTO @StorageTypes
	SELECT DISTINCT
		a.intStorageScheduleTypeId
		,strStorageTypeDescription 
	FROM #CustomerOwnershipALL a
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = a.intStorageScheduleTypeId

	SELECT 
		intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
		,dtmDate
		,strDistribution = strDistributionType		
		,dblIn = SUM(dblIn)
		,dblOut = SUM(dblOut)
		,dblNet = SUM(dblIn) - SUM(dblOut)
		,intStorageScheduleTypeId
		,intLocationId
		,strLocationName
		,strCommodityCode
	INTO #CustomerOwnershipBal
	FROM #CustomerOwnershipALL AA
	GROUP BY
		dtmDate
		,strDistributionType
		,intStorageScheduleTypeId
		,intLocationId
		,strLocationName
		,strCommodityCode

	SELECT *
	INTO #CustomerOwnershipIncDec
	FROM (
		SELECT 
			intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
			,dtmDate
			,strDistribution = strDistributionType		
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		INNER JOIN (
			SELECT strTransactionNumber,strStorageTypeCode
				,total = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) 
			FROM dbo.fnRKGetBucketCustomerOwned(@dtmReportDate,@intCommodityId,NULL)
			WHERE strTransactionType NOT IN ('Storage Settlement','Inventory Shipment')
			GROUP BY strTransactionNumber,strStorageTypeCode
		) A ON A.strTransactionNumber = AA.strTransactionNumber AND A.total <> 0 AND A.strStorageTypeCode = AA.strStorageTypeCode
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode
		UNION ALL
		SELECT 
			intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
			,dtmDate
			,strDistribution = strDistributionType		
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		WHERE strTransactionType IN ('Storage Settlement','Inventory Shipment')
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode
	) A

	WHILE EXISTS(SELECT 1 FROM @StorageTypes)
	BEGIN
		DELETE FROM @StorageObligationDataDUMMY

		SELECT TOP 1
			@intStorageScheduleTypeId	= intStorageScheduleTypeId
			,@strStorageTypeDescription	= strStorageTypeDescription
		FROM @StorageTypes

		SET @intTotalRowCnt = CASE WHEN (SELECT ISNULL(MAX(intRowNum),0) FROM @StorageObligationData) = 0 THEN 12 ELSE (SELECT MAX(intRowNum) + 1 FROM @StorageObligationData WHERE strLabel = @prevStorageType + ' ENDING') END

		--(OPENING) BALANCE
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 2
			,@intStorageScheduleTypeId
			,strDistribution + ' BEGINNING'
			,''
			,NET = SUM(dblIn) - SUM(dblOut)
			,strCommodityCode
			,@intCommodityId2
			,intLocationId
			,strLocationName
			,@strUOM
		FROM #CustomerOwnershipBal 
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmReportDate)
			AND intStorageScheduleTypeId = @intStorageScheduleTypeId
		GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode

		--CREATE BEGINNING IF IT'S NOT AVAILABLE
		IF NOT EXISTS(SELECT 1 FROM @StorageObligationDataDUMMY)
		BEGIN
			INSERT INTO @StorageObligationDataDUMMY
			SELECT @intTotalRowCnt + 2
				,@intStorageScheduleTypeId
				,strDistribution + ' BEGINNING'
				,''
				,NET = 0
				,strCommodityCode
				,@intCommodityId2
				,intLocationId
				,strLocationName
				,@strUOM
			FROM #CustomerOwnershipBal 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) >= CONVERT(DATETIME, @dtmReportDate)
				AND intStorageScheduleTypeId = @intStorageScheduleTypeId
			GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode
		END
		
		--INCREASE FOR THE DAY
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 3
			,DD.intStorageScheduleTypeId
			,CASE WHEN A.STRLABEL IS NULL THEN REPLACE(DD.strLabel,'BEGINNING','INCREASE') ELSE A.STRLABEL END
			,CASE WHEN A.STRSIGN IS NULL THEN '+' ELSE A.STRSIGN END
			,CASE WHEN A.TOTAL IS NULL THEN 0 ELSE A.TOTAL END
			,DD.strCommodityCode
			,DD.intCommodityId
			,DD.intCompanyLocationId
			,DD.strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY DD
		OUTER APPLY (			
			SELECT intStorageScheduleTypeId = @intStorageScheduleTypeId
				,STRLABEL = strDistribution + ' INCREASE'
				,STRSIGN = '+'
				,TOTAL = SUM(dblIn)
				,strCommodityCode
				,intCommodityId2 = @intCommodityId2
				,intLocationId
				,strLocationName
			FROM #CustomerOwnershipIncDec C
			--) A ON A.strTransactionNumber = C.strTransactionNumber AND A.total <> 0	
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
				AND intStorageScheduleTypeId = @intStorageScheduleTypeId
				AND (intStorageScheduleTypeId = DD.intStorageScheduleTypeId AND intLocationId = DD.intCompanyLocationId)
			GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode
		) A

		--DECREASE FOR THE DAY
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 4
			,DD.intStorageScheduleTypeId
			,CASE WHEN A.STRLABEL IS NULL THEN REPLACE(DD.strLabel,'BEGINNING','DECREASE') ELSE A.STRLABEL END
			,CASE WHEN A.STRSIGN IS NULL THEN '-' ELSE A.STRSIGN END
			,CASE WHEN A.TOTAL IS NULL THEN 0 ELSE A.TOTAL END
			,DD.strCommodityCode
			,DD.intCommodityId
			,DD.intCompanyLocationId
			,DD.strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY DD
		OUTER APPLY (			
			SELECT 
				intStorageScheduleTypeId = @intStorageScheduleTypeId
				,STRLABEL = strDistribution + ' DECREASE'
				,STRSIGN = '-'
				,TOTAL = SUM(dblOut)
				,strCommodityCode
				,intCommodityId2 = @intCommodityId2
				,intLocationId
				,strLocationName
			FROM #CustomerOwnershipIncDec 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
				AND intStorageScheduleTypeId = @intStorageScheduleTypeId
				AND (intStorageScheduleTypeId = DD.intStorageScheduleTypeId AND intLocationId = DD.intCompanyLocationId)
			GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode		
		) A
		WHERE DD.strLabel LIKE '%BEGINNING'

		INSERT INTO @StorageObligationData
		SELECT * FROM @StorageObligationDataDUMMY

		--TOTAL FOR THE DAY
		INSERT INTO @StorageObligationData
		SELECT @intTotalRowCnt + 5
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' ENDING'
			,''
			,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
			,strCommodityCode
			,@intCommodityId2
			,intCompanyLocationId
			,strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY
		GROUP BY strCommodityCode,intCompanyLocationId,strLocationName

		--SPACE FOR EVERY STORAGE TYPE
		INSERT INTO @StorageObligationData
		SELECT @intTotalRowCnt + 6
			,@intStorageScheduleTypeId
			,''
			,''
			,NULL
			,strCommodityCode
			,@intCommodityId2
			,intCompanyLocationId
			,strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY
		GROUP BY strCommodityCode,intCompanyLocationId,strLocationName

		--SELECT * FROM @StorageObligationData
		SELECT @prevStorageType = @strStorageTypeDescription

		DELETE FROM @StorageTypes WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
	END

	DROP TABLE #LicensedLocation
	DROP TABLE #CustomerOwnershipALL
	DROP TABLE #CustomerOwnershipBal
	DROP TABLE #CustomerOwnershipIncDec

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END

SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)

IF @intTotalRowCnt IS NULL
BEGIN
	SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @ReportData)
END

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 2
	,0
	,'TOTAL STORAGE OBLIGATION BEGINNING'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @StorageObligationData
WHERE strLabel LIKE '%BEGINNING%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 3
	,0
	,'TOTAL STORAGE OBLIGATION INCREASE'
	,'+'
	,SUM(dblUnits)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @StorageObligationData
WHERE strLabel LIKE '%INCREASE%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 4
	,0
	,'TOTAL STORAGE OBLIGATION DECREASE'
	,'-'
	,SUM(dblUnits)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @StorageObligationData
WHERE strLabel LIKE '%DECREASE%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 5
	,0
	,'TOTAL STORAGE OBLIGATION ENDING'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @StorageObligationData
WHERE strLabel LIKE '%ENDING%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

--BLANK SPACE
INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 6
	,0
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @StorageObligationData
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

/***START===STILL ADD TOTAL STORAGE OBLIGATION IF THERE'S NONE ON SPECIFIC LOCATIONS****/
INSERT INTO @ReportData
SELECT
	@intTotalRowCnt + 2
	,'TOTAL STORAGE OBLIGATION BEGINNING'
	,''
	,0
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,dtmReportDate
	,strUOM
FROM @ReportData
WHERE intCompanyLocationId NOT IN (SELECT intCompanyLocationId FROM @StorageObligationData WHERE strLabel LIKE '%BEGINNING%')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
	,dtmReportDate

INSERT INTO @ReportData
SELECT
	@intTotalRowCnt + 3
	,'TOTAL STORAGE OBLIGATION INCREASE'
	,'+'
	,0
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,dtmReportDate
	,strUOM
FROM @ReportData
WHERE intCompanyLocationId NOT IN (SELECT intCompanyLocationId FROM @StorageObligationData WHERE strLabel LIKE '%INCREASE%')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
	,dtmReportDate

INSERT INTO @ReportData
SELECT
	@intTotalRowCnt + 4
	,'TOTAL STORAGE OBLIGATION DECREASE'
	,'-'
	,0
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,dtmReportDate
	,strUOM
FROM @ReportData
WHERE intCompanyLocationId NOT IN (SELECT intCompanyLocationId FROM @StorageObligationData WHERE strLabel LIKE '%DECREASE%')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
	,dtmReportDate

INSERT INTO @ReportData
SELECT
	@intTotalRowCnt + 5
	,'TOTAL STORAGE OBLIGATION ENDING'
	,''
	,0
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,dtmReportDate
	,strUOM
FROM @ReportData
WHERE intCompanyLocationId NOT IN (SELECT intCompanyLocationId FROM @StorageObligationData WHERE strLabel LIKE '%ENDING%')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
	,dtmReportDate

INSERT INTO @ReportData
SELECT
	@intTotalRowCnt + 6
	,''
	,''
	,0
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,dtmReportDate
	,strUOM
FROM @ReportData
WHERE intCompanyLocationId NOT IN (SELECT intCompanyLocationId FROM @StorageObligationData WHERE strLabel LIKE '%TOTAL%')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
	,dtmReportDate
/***END===STILL ADD TOTAL STORAGE OBLIGATION IF THERE'S NONE ON SPECIFIC LOCATIONS****/
/*==END==STORAGE OBLIGATION==*/

SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)

/* ADD INVENTORY BALANCE IF IT DOES NOT EXIST */
INSERT INTO @InventoryData
SELECT 
	1
	,'PHYSICAL INVENTORY BEGINNING'
	,''
	,0
	,A.strCommodityCode
	,A.intCommodityId
	,A.intCompanyLocationId
	,A.strLocationName
	,A.strUOM
FROM @InventoryData A
WHERE (
	CASE 
		WHEN strLabel = 'RECEIVED' AND dblUnits <> 0 THEN 1
		WHEN strLabel = 'SHIPPED' AND dblUnits <> 0 THEN 1
		ELSE 0
	END) = 1
	AND NOT EXISTS(SELECT 1 FROM @InventoryData WHERE strLabel = 'PHYSICAL INVENTORY BEGINNING')


/* COMPANY OWNED */
INSERT INTO @InventoryData
SELECT 
	ISNULL(@intTotalRowCnt,1) + (SELECT MAX(intRowNum) FROM @ReportData)
	,'TOTAL COMPANY OWNED BEGINNING (INC DP)'
	,''
	,ISNULL(A.dblUnits,0) - ISNULL(B.dblUnits,0)
	,A.strCommodityCode
	,A.intCommodityId
	,A.intCompanyLocationId
	,A.strLocationName
	,A.strUOM
FROM (
	SELECT SUM(dblUnits) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @InventoryData
	WHERE strLabel IN ('PHYSICAL INVENTORY BEGINNING')
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) A
OUTER APPLY (
	SELECT
		SUM(ISNULL(dblUnits,0)) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @StorageObligationData 
	--WHERE strLabel LIKE '%BALANCE'--= 'TOTAL STORAGE OBLIGATION'
	WHERE strLabel = 'TOTAL STORAGE OBLIGATION BEGINNING'
		AND intCommodityId = A.intCommodityId
		AND intCompanyLocationId = A.intCompanyLocationId
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) B

INSERT INTO @InventoryData
SELECT 
	ISNULL(@intTotalRowCnt,1) + (SELECT MAX(intRowNum) FROM @ReportData)
	,'TOTAL COMPANY OWNED INCREASE (INC DP)'
	,'+'
	,ISNULL(A.dblUnits,0) + ISNULL(D.dblUnits,0) + (ISNULL(B.dblUnits,0) - ISNULL(C.dblUnits,0))
	,A.strCommodityCode
	,A.intCommodityId
	,A.intCompanyLocationId
	,A.strLocationName
	,A.strUOM
FROM (
	SELECT SUM(ISNULL(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END,0)) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @InventoryData
	WHERE strLabel = 'INTERNAL TRANSFERS RECEIVED'
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) A
OUTER APPLY (
	SELECT
		SUM(ISNULL(dblUnits,0)) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @StorageObligationData SOD
	WHERE strLabel = 'TOTAL STORAGE OBLIGATION DECREASE'
		AND intCommodityId = A.intCommodityId
		AND intCompanyLocationId = A.intCompanyLocationId
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) B
OUTER APPLY (
	SELECT SUM(ISNULL(dblDeductedUnits,0)) dblUnits
		,TS.strCommodityCode
		,TS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
	FROM vyuGRTransferStorageSearchView TS
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = TS.intFromStorageTypeId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = TS.intToStorageTypeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TS.intFromCustomerStorageId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = CS.intItemUOMId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	/*
		Transfer from Customer owned to customer owned
		from one location to another
	*/
	WHERE ST_FROM.strOwnedPhysicalStock = 'Customer'
		AND ST_TO.strOwnedPhysicalStock = 'Customer'
		AND TS.intCommodityId = A.intCommodityId
		AND TS.intFromCompanyLocationId = A.intCompanyLocationId
		--AND TS.intToCompanyLocationId <> A.intCompanyLocationId
		AND TS.dtmTransferStorageDate = @dtmReportDate
		AND ST_FROM.intStorageScheduleTypeId <> ST_TO.intStorageScheduleTypeId
	GROUP BY TS.strCommodityCode
		,TS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
) C
OUTER APPLY (
	SELECT SUM(ISNULL(SH.dblUnits,0)) dblUnits
		,IC.strCommodityCode
		,CS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			AND ST.ysnDPOwnedType = 1 --(DP only)
	INNER JOIN tblICCommodity IC
		ON IC.intCommodityId = CS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = CS.intItemUOMId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	/*
		Reversed settlement for the day 
	*/
	WHERE SH.strType = 'Reverse Settlement'
		AND CS.intCommodityId = A.intCommodityId
		AND CS.intCompanyLocationId = A.intCompanyLocationId
		AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) = @dtmReportDate
	GROUP BY IC.strCommodityCode
		,CS.intCommodityId
		,CS.intCompanyLocationId
		,CL.strLocationName
		,UM.strUnitMeasure
) D
OUTER APPLY (
	/*
		RECEIVED Company Owned stocks for the day 
	*/
	SELECT SUM(dblUnits) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @InventoryDataCompanyOwned
	WHERE intCommodityId = A.intCommodityId
		AND intCompanyLocationId = A.intCompanyLocationId
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) E
OUTER APPLY (
	SELECT ABS(SUM(dblUnits)) dblUnits
		,intCommodityId
		,intCompanyLocationId
		,strUOM
	FROM @InventoryAdjustments IA
	WHERE IA.intCommodityId = A.intCommodityId
		AND IA.intCompanyLocationId = A.intCompanyLocationId
		AND strOwnership = 'Customer Owned'
		AND IA.strUOM = A.strUOM
	GROUP BY intCommodityId
		,intCompanyLocationId
		,strUOM
) F
OUTER APPLY (
	SELECT SUM(dblUnits) dblUnits
		,intCommodityId
		,intCompanyLocationId
		,strUOM
	FROM @InventoryAdjustments IA
	WHERE IA.intCommodityId = A.intCommodityId
		AND IA.intCompanyLocationId = A.intCompanyLocationId
		AND strOwnership = 'Company Owned'
		AND IA.strUOM = A.strUOM
		AND dblUnits > 0
	GROUP BY intCommodityId
		,intCompanyLocationId
		,strUOM
) G


INSERT INTO @InventoryData
SELECT 
	ISNULL(@intTotalRowCnt,1) + (SELECT MAX(intRowNum) FROM @ReportData)
	,'TOTAL COMPANY OWNED DECREASE (INC DP)'
	,'-'
	,ABS(ISNULL(A.dblUnits,0) + ISNULL(C.dblUnits,0) + ISNULL(D.dblUnits,0) + ISNULL(E.dblUnits,0))
	,A.strCommodityCode
	,A.intCommodityId
	,A.intCompanyLocationId
	,A.strLocationName
	,A.strUOM
FROM (
	SELECT SUM(dblUnits) dblUnits
		,strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
	FROM @InventoryData
	WHERE strLabel IN ('SHIPPED','INTERNAL TRANSFERS SHIPPED')
	GROUP BY strCommodityCode
		,intCommodityId
		,intCompanyLocationId
		,strLocationName
		,strUOM
) A
OUTER APPLY (
	SELECT SUM(ISNULL(dblDeductedUnits,0)) dblUnits
		,TS.strCommodityCode
		,TS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
	FROM vyuGRTransferStorageSearchView TS
	INNER JOIN tblGRStorageType ST_FROM
		ON ST_FROM.intStorageScheduleTypeId = TS.intFromStorageTypeId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = TS.intToStorageTypeId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TS.intFromCustomerStorageId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = CS.intItemUOMId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	/*
		Transfer from Company owned to customer owned
	*/
	WHERE ST_FROM.strOwnedPhysicalStock = 'Company'
		AND ST_TO.strOwnedPhysicalStock = 'Customer'
		AND TS.intCommodityId = A.intCommodityId
		AND TS.intFromCompanyLocationId = A.intCompanyLocationId
		AND TS.dtmTransferStorageDate = @dtmReportDate
	GROUP BY TS.strCommodityCode
		,TS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
) C
OUTER APPLY (
	SELECT SUM(ISNULL(SH.dblUnits,0)) dblUnits
		,IC.strCommodityCode
		,CS.intCommodityId
		,intFromCompanyLocationId
		,strFromLocationName
		,UM.strUnitMeasure
	FROM tblGRStorageHistory SH
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SH.intCustomerStorageId
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	INNER JOIN tblICCommodity IC
		ON IC.intCommodityId = CS.intCommodityId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = CS.intCompanyLocationId
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = CS.intItemUOMId
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	/*
		Reversed settlement for the day
	*/
	WHERE SH.strType = 'Reverse Settlement'
		AND CS.intCommodityId = A.intCommodityId
		AND CS.intCompanyLocationId = A.intCompanyLocationId
		AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) = @dtmReportDate
	GROUP BY IC.strCommodityCode
		,CS.intCommodityId
		,CS.intCompanyLocationId
		,CL.strLocationName
		,UM.strUnitMeasure
) D
OUTER APPLY (
	SELECT SUM(dblUnits) dblUnits
		,intCommodityId
		,intCompanyLocationId
		,strUOM
	FROM @InventoryAdjustments IA
	WHERE IA.intCommodityId = A.intCommodityId
		AND IA.intCompanyLocationId = A.intCompanyLocationId
		AND strOwnership = 'Company Owned'
		AND IA.strUOM = A.strUOM
		AND dblUnits < 0
	GROUP BY intCommodityId
		,intCompanyLocationId
		,strUOM
) E

INSERT INTO @InventoryData
SELECT
	ISNULL(@intTotalRowCnt,1) + (SELECT MAX(intRowNum) FROM @ReportData)
	,'TOTAL COMPANY OWNED ENDING (INC DP)'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM
FROM @InventoryData
WHERE strLabel LIKE '%TOTAL COMPANY OWNED%'
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

--INSERT IN @ReportData
INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,@dtmReportDate
	,strUOM
FROM @StorageObligationData
/* END COMPANY OWNED */

--BLANK SPACE
INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + 17
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,@dtmReportDate
	,strUOM
FROM @ReportData
WHERE strLabel IN ('PHYSICAL INVENTORY ENDING')
GROUP BY strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,strUOM

/*==END==COMPANY-OWNED GRAIN==*/

/*==START==DP STORAGE==*/
INSERT INTO @tblCommodities
SELECT DISTINCT ID.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
WHERE strLabel = 'PHYSICAL INVENTORY BEGINNING'

INSERT INTO @StorageTypes
SELECT 
	intStorageScheduleTypeId
	,strStorageTypeDescription 
FROM tblGRStorageType 
WHERE intStorageScheduleTypeId > 0
	AND ysnDPOwnedType = 1

DELETE FROM @StorageObligationData

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCommodityUnitMeasureId = NULL
	SET @strUOM = NULL

	SELECT TOP 1 @intCommodityId2 = intCommodityId, @strCommodityCode = strCommodityCode FROM @tblCommodities
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@strUOM = UOM.strUnitMeasure
	FROM tblICCommodityUnitMeasure UM
	INNER JOIN tblICUnitMeasure UOM
		ON UOM.intUnitMeasureId = UM.intUnitMeasureId
	WHERE intCommodityId = @intCommodityId2
		AND ysnStockUnit = 1

	SELECT DISTINCT intCompanyLocationId
		,strLocationName
	INTO #LicensedLocation2
	FROM @InventoryData
	
	SELECT
		dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
		,strTransactionNumber
		,strDistributionType
		,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
		,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
		,ST.intStorageScheduleTypeId
		,OH.strStorageTypeCode
		,OH.intLocationId
		,OH.strLocationName
		,OH.strCommodityCode
		,OH.strTransactionType
	INTO #DelayedPricingALL
	FROM dbo.fnRKGetBucketDelayedPricing(@dtmReportDate,@intCommodityId,NULL) OH
	LEFT JOIN tblGRStorageType ST 
		ON ST.strStorageTypeDescription = OH.strDistributionType 
			AND ysnDPOwnedType = 1
	WHERE OH.intCommodityId = @intCommodityId2	

	DELETE A
	FROM #DelayedPricingALL A
	WHERE intLocationId NOT IN (SELECT intCompanyLocationId FROM #LicensedLocation2)

	SELECT
		intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
		,dtmDate
		,strDistribution = strDistributionType
		,dblIn = SUM(dblIn)
		,dblOut = SUM(dblOut)
		,dblNet = SUM(dblIn) - SUM(dblOut)
		,intStorageScheduleTypeId
		,intLocationId
		,strLocationName
		,strCommodityCode
	INTO #DelayedPricingBal
	FROM #DelayedPricingALL AA
	GROUP BY
		dtmDate
		,strDistributionType
		,intStorageScheduleTypeId
		,intLocationId
		,strLocationName
		,strCommodityCode

	SELECT *
	INTO #DelayedPricingIncDec
	FROM (
		SELECT
			intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
			,dtmDate
			,strDistribution = strDistributionType
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode		
		FROM #DelayedPricingALL AA
		INNER JOIN (
			SELECT strTransactionNumber,strStorageTypeCode
				,total = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) 
			FROM dbo.fnRKGetBucketDelayedPricing(@dtmReportDate,@intCommodityId,NULL) OH
			WHERE strTransactionType <> 'Storage Settlement'
			GROUP BY strTransactionNumber,strStorageTypeCode
		) A ON A.strTransactionNumber = AA.strTransactionNumber AND A.total <> 0 AND A.strStorageTypeCode = AA.strStorageTypeCode
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode
		UNION ALL
		SELECT
			intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
			,dtmDate
			,strDistribution = strDistributionType
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode		
		FROM #DelayedPricingALL AA
		WHERE strTransactionType = 'Storage Settlement'
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,intLocationId
			,strLocationName
			,strCommodityCode
	) A

	WHILE EXISTS(SELECT 1 FROM @StorageTypes)
	BEGIN
		DELETE FROM @StorageObligationDataDUMMY

		SELECT TOP 1
			@intStorageScheduleTypeId	= intStorageScheduleTypeId
			,@strStorageTypeDescription	= strStorageTypeDescription
		FROM @StorageTypes

		SET @intTotalRowCnt = CASE WHEN (SELECT ISNULL(MAX(intRowNum),0) FROM @StorageObligationData) = 0 THEN 100 ELSE (SELECT MAX(intRowNum) + 1 FROM @StorageObligationData WHERE strLabel = @prevStorageType + ' ENDING') END

		--(OPENING) BALANCE
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 1
			,@intStorageScheduleTypeId
			,strDistribution + ' BEGINNING'
			,''
			,NET = SUM(dblIn) - SUM(dblOut)
			,strCommodityCode
			,@intCommodityId2
			,intLocationId
			,strLocationName
			,@strUOM
		FROM #DelayedPricingBal
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmReportDate)
			AND intStorageScheduleTypeId = @intStorageScheduleTypeId
		GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode

		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 1
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' BEGINNING'
			,''
			,0
			,@strCommodityCode
			,@intCommodityId2
			,A.intCompanyLocationId
			,A.strLocationName
			,@strUOM
		FROM #LicensedLocation2 A
		LEFT JOIN @StorageObligationDataDUMMY B
			ON B.intCompanyLocationId = A.intCompanyLocationId
				AND B.strLabel LIKE '%BEGINNING'
		WHERE B.intCompanyLocationId IS NULL
		
		--INCREASE FOR THE DAY
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 2
			,DD.intStorageScheduleTypeId
			,CASE WHEN A.STRLABEL IS NULL THEN REPLACE(DD.strLabel,'BEGINNING','INCREASE') ELSE A.STRLABEL END
			,CASE WHEN A.STRSIGN IS NULL THEN '+' ELSE A.STRSIGN END
			,CASE WHEN A.TOTAL IS NULL THEN 0 ELSE A.TOTAL END
			,DD.strCommodityCode
			,DD.intCommodityId
			,DD.intCompanyLocationId
			,DD.strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY DD
		OUTER APPLY (			
			SELECT intStorageScheduleTypeId = @intStorageScheduleTypeId
				,STRLABEL = strDistribution + ' INCREASE'
				,STRSIGN = '+'
				,TOTAL = SUM(dblIn)
				,strCommodityCode
				,intCommodityId2 = @intCommodityId2
				,intLocationId
				,strLocationName
			FROM #DelayedPricingIncDec C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
				AND intStorageScheduleTypeId = @intStorageScheduleTypeId
				AND (intStorageScheduleTypeId = DD.intStorageScheduleTypeId AND intLocationId = DD.intCompanyLocationId)
			GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode
		) A

		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 2
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' INCREASE'
			,'+'
			,0
			,@strCommodityCode
			,@intCommodityId2
			,A.intCompanyLocationId
			,A.strLocationName
			,@strUOM
		FROM #LicensedLocation2 A
		LEFT JOIN @StorageObligationDataDUMMY B
			ON B.intCompanyLocationId = A.intCompanyLocationId
				AND B.strLabel LIKE '%INCREASE'
		WHERE B.intCompanyLocationId IS NULL

		--DECREASE FOR THE DAY
		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 3
			,DD.intStorageScheduleTypeId
			,CASE WHEN A.STRLABEL IS NULL THEN REPLACE(DD.strLabel,'BEGINNING','DECREASE') ELSE A.STRLABEL END
			,CASE WHEN A.STRSIGN IS NULL THEN '-' ELSE A.STRSIGN END
			,CASE WHEN A.TOTAL IS NULL THEN 0 ELSE A.TOTAL END
			,DD.strCommodityCode
			,DD.intCommodityId
			,DD.intCompanyLocationId
			,DD.strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY DD
		OUTER APPLY (			
			SELECT 
				intStorageScheduleTypeId = @intStorageScheduleTypeId
				,STRLABEL = strDistribution + ' DECREASE'
				,STRSIGN = '-'
				,TOTAL = SUM(dblOut)
				,strCommodityCode
				,intCommodityId2 = @intCommodityId2
				,intLocationId
				,strLocationName
			FROM #DelayedPricingIncDec
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
				AND intStorageScheduleTypeId = @intStorageScheduleTypeId
				AND (intStorageScheduleTypeId = DD.intStorageScheduleTypeId AND intLocationId = DD.intCompanyLocationId)
			GROUP BY strDistribution,intLocationId,strLocationName,strCommodityCode		
		) A
		WHERE DD.strLabel LIKE '%BEGINNING'

		INSERT INTO @StorageObligationDataDUMMY
		SELECT @intTotalRowCnt + 3
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' DECREASE'
			,'-'
			,0
			,@strCommodityCode
			,@intCommodityId2
			,A.intCompanyLocationId
			,A.strLocationName
			,@strUOM
		FROM #LicensedLocation2 A
		LEFT JOIN @StorageObligationDataDUMMY B
			ON B.intCompanyLocationId = A.intCompanyLocationId
				AND B.strLabel LIKE '%DECREASE'
		WHERE B.intCompanyLocationId IS NULL

		INSERT INTO @StorageObligationData
		SELECT * FROM @StorageObligationDataDUMMY

		--TOTAL FOR THE DAY
		INSERT INTO @StorageObligationData
		SELECT @intTotalRowCnt + 4
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' ENDING'
			,''
			,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
			,strCommodityCode
			,@intCommodityId2
			,intCompanyLocationId
			,strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY
		GROUP BY strCommodityCode,intCompanyLocationId,strLocationName

		--SPACE FOR EVERY STORAGE TYPE
		INSERT INTO @StorageObligationData
		SELECT @intTotalRowCnt + 5
			,@intStorageScheduleTypeId
			,''
			,''
			,NULL
			,strCommodityCode
			,@intCommodityId2
			,intCompanyLocationId
			,strLocationName
			,@strUOM
		FROM @StorageObligationDataDUMMY
		GROUP BY strCommodityCode,intCompanyLocationId,strLocationName

		SELECT @prevStorageType = @strStorageTypeDescription

		DELETE FROM @StorageTypes WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
	END

	DROP TABLE #LicensedLocation2
	DROP TABLE #DelayedPricingALL
	DROP TABLE #DelayedPricingBal
	DROP TABLE #DelayedPricingIncDec

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END

SET @intTotalRowCnt = ISNULL((SELECT MAX(intRowNum) FROM @StorageObligationData),100)

--UPDATE COMPANY-OWNED STOCKS, ADD THE DP
UPDATE ID
SET intRowNum = @intTotalRowCnt + 21
FROM @InventoryData ID
WHERE ID.strLabel = 'TOTAL COMPANY OWNED BEGINNING (INC DP)'

UPDATE ID
SET intRowNum = @intTotalRowCnt + 22
FROM @InventoryData ID
WHERE ID.strLabel = 'TOTAL COMPANY OWNED INCREASE (INC DP)'

UPDATE ID
SET intRowNum = @intTotalRowCnt + 23
FROM @InventoryData ID
WHERE ID.strLabel = 'TOTAL COMPANY OWNED DECREASE (INC DP)'

UPDATE ID
SET intRowNum = @intTotalRowCnt + 24
FROM @InventoryData ID
WHERE ID.strLabel = 'TOTAL COMPANY OWNED ENDING (INC DP)'


/*==END==DP STORAGE==*/

/*==START==REPORT DATA==*/
INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,@dtmReportDate
	,strUOM
FROM @StorageObligationData

INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,intCompanyLocationId
	,strLocationName
	,@dtmReportDate
	,strUOM
FROM @InventoryData
WHERE strLabel NOT IN ('TOTAL STORAGE OBLIGATION')
/*==END==REPORT DATA==*/

UPDATE @ReportData SET dblUnits = 0 WHERE dblUnits IS NULL AND strLabel <> ''
UPDATE @ReportData SET dblUnits = NULL WHERE dblUnits = 0 AND strLabel = ''

--'TOTAL STORAGE OBLIGATION' should be of same number
--UPDATE A
--SET intRowNum = B.intRowNum
--FROM @ReportData A
--OUTER APPLY (
--	SELECT TOP 1 intRowNum
--		,strLabel
--	FROM @ReportData
--	WHERE strLabel LIKE 'TOTAL STORAGE OBLIGATION%'
--) B
--WHERE A.strLabel LIKE 'TOTAL STORAGE OBLIGATION%'
--	AND A.strLabel = B.strLabel

IF(SELECT COUNT(*) FROM @Locs) > 1
BEGIN
	/*CREATE A SUMMARY PAGE OF ALL LOCATIONS*/
	INSERT INTO @ReportData
	SELECT
		intRowNum
		,strLabel
		,strSign
		,SUM(dblUnits)
		,strCommodityCode
		,intCommodityId
		,999
		,'ALL LOCATIONS'
		,@dtmReportDate
		,strUOM
	FROM @ReportData
	GROUP BY intRowNum
		,strLabel
		,strSign
		,strCommodityCode
		,intCommodityId
		,strUOM
END

DECLARE @LocsWithNoInventory AS Id

INSERT INTO @LocsWithNoInventory
SELECT DISTINCT intCompanyLocationId 
FROM @ReportData 
WHERE (strLabel = 'PHYSICAL INVENTORY ENDING' AND dblUnits = 0)

DELETE A
FROM @ReportData A
INNER JOIN @LocsWithNoInventory B
	ON B.intId = A.intCompanyLocationId

DELETE FROM @ReportData WHERE strUOM IS NULL

SELECT * FROM @ReportData ORDER BY intCommodityId,intCompanyLocationId,intRowNum
SET FMTONLY ON