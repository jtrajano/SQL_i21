CREATE PROCEDURE [dbo].[uspGRGIIPhysicalInventory]
	@xmlParam NVARCHAR(MAX)
AS
BEGIN
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
DECLARE @dtmReportDate DATETIME

DECLARE @PhysicalInventoryData AS TABLE (
	dtmReportDate DATETIME
	,strLicensed NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strCommodityDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblBegInventory DECIMAL(18,6) DEFAULT 0
	,dblReceived DECIMAL(18,6) DEFAULT 0
	,dblShipped DECIMAL(18,6) DEFAULT 0
	,dblInternalTransfersReceived DECIMAL(18,6) DEFAULT 0
	,dblInternalTransfersShipped DECIMAL(18,6) DEFAULT 0
	,dblNetAdjustments DECIMAL(18,6) DEFAULT 0
	,dblEndInventory DECIMAL(18,6) DEFAULT 0
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
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

DECLARE @tblCommodities AS TABLE 
(
	intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strCommodityDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @strCommodityDescription NVARCHAR(100)
DECLARE @strUOM NVARCHAR(20)
DECLARE @intCommodityUnitMeasureId AS INT
DECLARE @Locs Id

SELECT @dtmReportDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmReportDate'

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END

INSERT INTO @Locs
SELECT intCompanyLocationId
FROM tblSMCompanyLocation
WHERE ysnLicensed = 1
;

/*BEGINNING BALANCE*/
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
	AND CL.ysnLicensed = 1
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
	AND CL.ysnLicensed = 1
GROUP BY t.intItemId
		,ItemLocation.intLocationId
		,CL.ysnLicensed
		,I.intCommodityId
		,CL.strLocationName
		,UOM.strUnitMeasure
)

INSERT INTO @PhysicalInventoryData
(
	dtmReportDate
	,intCommodityId
	,strCommodityCode
	,strCommodityDescription
	,strLocationName
	,dblBegInventory
	,strUOM
)
SELECT @dtmReportDate
	,CO.intCommodityId
	,IC.strCommodityCode
	,IC.strDescription
	,CO.strLocationName
	,SUM(CO.dblQty)
	,strUnitMeasure
FROM tblCOAndStorage CO
INNER JOIN tblICCommodity IC
	ON IC.intCommodityId = CO.intCommodityId
GROUP BY CO.intCommodityId
	,IC.strCommodityCode
	,IC.strDescription
	,CO.strLocationName
	,strUnitMeasure

INSERT INTO @tblCommodities
SELECT DISTINCT
	intCommodityId
	,strCommodityCode
	,strCommodityDescription
FROM @PhysicalInventoryData

DECLARE @intCompanyLocationId INT
DECLARE @strLocationName NVARCHAR(200)
DECLARE @intCommodityId2 INT
DECLARE @intLocationId INT

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL

	SELECT TOP 1 @intCommodityId2 = intCommodityId FROM @tblCommodities
	
	DELETE FROM #tblInOut
	INSERT INTO #tblInOut
	EXEC uspGRGetInHousePerLocation
		@dtmDate = @dtmReportDate
		,@intCommodityId = @intCommodityId2
		,@Locations = @Locs
		,@intLocationId = @intLocationId

	UPDATE PID
	SET dblReceived = RECEIVED.TOTAL
		,dblShipped = SHIPPED.TOTAL
		,dblInternalTransfersReceived = IT_RECEIVED.TOTAL
		,dblInternalTransfersShipped = IT_SHIPPED.TOTAL
		,dblNetAdjustments = NET_ADJUSTMENTS.dblAdjustments
	FROM @PhysicalInventoryData PID
	LEFT JOIN (
		SELECT TOTAL = ABS(SUM(ISNULL(dblInvIn,0)) - SUM(ISNULL(dblInvOut,0)))
			,intCommodityId
			,strLocationName
		FROM #tblInOut
		WHERE strTransactionType = 'Inventory Receipt'
			AND dtmDate IS NOT NULL
		GROUP BY intCommodityId
			,strLocationName
	) RECEIVED
		ON RECEIVED.intCommodityId = PID.intCommodityId
			AND RECEIVED.strLocationName = PID.strLocationName
	LEFT JOIN (
		SELECT TOTAL = ABS(SUM(ISNULL(dblInvIn,0)) - SUM(ISNULL(dblInvOut,0)))
			,intCommodityId
			,strLocationName
		FROM #tblInOut
		WHERE strTransactionType IN ('Inventory Shipment','Outbound Shipment','Invoice')
			AND dtmDate IS NOT NULL
		GROUP BY intCommodityId
			,strLocationName
	) SHIPPED
		ON SHIPPED.intCommodityId = PID.intCommodityId
			AND SHIPPED.strLocationName = PID.strLocationName
	LEFT JOIN (
		SELECT TOTAL = ABS(SUM(ISNULL(dblInvIn,0)))
			,intCommodityId
			,strLocationName
		FROM #tblInOut
		WHERE strTransactionType = 'Inventory Transfer' 
			AND dtmDate IS NOT NULL
		GROUP BY intCommodityId
			,strLocationName
	) IT_RECEIVED
		ON IT_RECEIVED.intCommodityId = PID.intCommodityId
			AND IT_RECEIVED.strLocationName = PID.strLocationName
	LEFT JOIN (
		SELECT TOTAL = ABS(SUM(ISNULL(dblInvOut,0)))
			,intCommodityId
			,strLocationName
		FROM #tblInOut
		WHERE strTransactionType = 'Inventory Transfer' 
			AND dtmDate IS NOT NULL
		GROUP BY intCommodityId
			,strLocationName
	) IT_SHIPPED
		ON IT_SHIPPED.intCommodityId = PID.intCommodityId
			AND IT_SHIPPED.strLocationName = PID.strLocationName
	LEFT JOIN (
		SELECT dblAdjustments = SUM(ISNULL(dblAdjustments,0))
				,intCommodityId
				,strLocationName
			FROM #tblInOut
			WHERE strTransactionType IN ('Storage Adjustment', 'Inventory Adjustment')
				AND dtmDate IS NOT NULL
			GROUP BY intCommodityId
				,strLocationName
	) NET_ADJUSTMENTS
		ON NET_ADJUSTMENTS.intCommodityId = PID.intCommodityId
			AND NET_ADJUSTMENTS.strLocationName = PID.strLocationName
	

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END

--add missing locs in commodities
SELECT DISTINCT intCommodityId
	,strCommodityCode
	,strCommodityDescription
	,strUOM
INTO #Coms
FROM @PhysicalInventoryData

INSERT INTO @PhysicalInventoryData
SELECT @dtmReportDate
	,1
	,C.intCommodityId
	,C.strCommodityCode
	,C.strCommodityDescription
	,CL.strLocationName
	,0
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,0
	,C.strUOM	
FROM tblSMCompanyLocation CL
OUTER APPLY (
	SELECT * FROM #Coms
) C
OUTER APPLY (
	SELECT P.strLocationName
		,P.intCommodityId
	FROM @PhysicalInventoryData P
	WHERE P.strLocationName = CL.strLocationName
		AND P.intCommodityId = C.intCommodityId
) I
WHERE CL.ysnLicensed = 1
	AND I.strLocationName IS NULL

DROP TABLE #Coms

UPDATE @PhysicalInventoryData
SET dblBegInventory = ISNULL(dblBegInventory,0), dblEndInventory = ISNULL(dblBegInventory,0) + ISNULL(dblReceived,0) - ISNULL(dblShipped,0) + ISNULL(dblInternalTransfersReceived,0) - ISNULL(dblInternalTransfersShipped,0) + ISNULL(dblNetAdjustments,0)

INSERT INTO tblGRGIIPhysicalInventory
SELECT * FROM @PhysicalInventoryData

INSERT INTO @PhysicalInventoryData
SELECT @dtmReportDate
	,1
	,intCommodityId
	,strCommodityCode
	,strCommodityDescription
	,'TOTALS - PHYSICAL INVENTORY'
	,SUM(ISNULL(dblBegInventory,0))
	,SUM(ISNULL(dblReceived,0))
	,SUM(ISNULL(dblShipped,0))
	,SUM(ISNULL(dblInternalTransfersReceived,0))
	,SUM(ISNULL(dblInternalTransfersShipped,0))
	,SUM(ISNULL(dblNetAdjustments,0))
	,SUM(ISNULL(dblEndInventory,0))
	,strUOM
FROM @PhysicalInventoryData
GROUP BY intCommodityId
	,strCommodityCode
	,strCommodityDescription
	,strUOM

SELECT * FROM @PhysicalInventoryData

END