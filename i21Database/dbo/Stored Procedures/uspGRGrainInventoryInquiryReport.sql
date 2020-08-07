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
	,strLabel NVARCHAR(500)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
	,dtmReportDate DATETIME
)

DECLARE @guid UNIQUEIDENTIFIER = NEWID()
DECLARE @InventoryData TABLE
(
	intRowNum INT
	,strLabel NVARCHAR(500)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
)

DECLARE @intCommodityId2 INT
DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @tblCommodities TABLE
(
	intCommodityId INT
	,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

DECLARE @tblStorageQuantitiesMain TABLE
(
	intCommodityId INT
	,intDPIHeaderId INT
	,strStorageTypeDescriptionA NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionB NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionC NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionD NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionE NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionF NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionG NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionH NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionI NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionJ NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescriptionK NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME
	,dblReceived DECIMAL(18,6)
	,dblShipped DECIMAL(18,6)
	,dblIssuedA DECIMAL(18,6)
	,dblIssuedB DECIMAL(18,6)
	,dblIssuedC DECIMAL(18,6)
	,dblIssuedD DECIMAL(18,6)
	,dblIssuedE DECIMAL(18,6)
	,dblIssuedF DECIMAL(18,6)
	,dblIssuedG DECIMAL(18,6)
	,dblIssuedH DECIMAL(18,6)
	,dblIssuedI DECIMAL(18,6)
	,dblIssuedJ DECIMAL(18,6)
	,dblIssuedK DECIMAL(18,6)
	,dblCancelledA DECIMAL(18,6)
	,dblCancelledB DECIMAL(18,6)
	,dblCancelledC DECIMAL(18,6)
	,dblCancelledD DECIMAL(18,6)
	,dblCancelledE DECIMAL(18,6)
	,dblCancelledF DECIMAL(18,6)
	,dblCancelledG DECIMAL(18,6)
	,dblCancelledH DECIMAL(18,6)
	,dblCancelledI DECIMAL(18,6)
	,dblCancelledJ DECIMAL(18,6)
	,dblCancelledK DECIMAL(18,6)
	,dblQuantityA DECIMAL(18,6)
	,dblQuantityB DECIMAL(18,6)
	,dblQuantityC DECIMAL(18,6)
	,dblQuantityD DECIMAL(18,6)
	,dblQuantityE DECIMAL(18,6)
	,dblQuantityF DECIMAL(18,6)
	,dblQuantityG DECIMAL(18,6)
	,dblQuantityH DECIMAL(18,6)
	,dblQuantityI DECIMAL(18,6)
	,dblQuantityJ DECIMAL(18,6)
	,dblQuantityK DECIMAL(18,6)
	,dblAdjustments DECIMAL(18,6)
)

DECLARE @tblStorageQuantities TABLE
(
	dtmTransactionDate DATETIME
	,dblIssued DECIMAL(18,6)
	,dblCancelled DECIMAL(18,6)
	,dblQuantity DECIMAL(18,6)
)

CREATE TABLE #tblInOut
(
	dtmDate DATETIME,
	dblInvIn DECIMAL(18,6),
	dblInvOut DECIMAL(18,6),
	dblAdjustments DECIMAL(18,6),
	dblInventoryCount DECIMAL(18,6),
	strTransactionId VARCHAR(MAX),
	intTransactionId INT,
	strDistribution VARCHAR(MAX),
	dblBalance DECIMAL(18,6),
	dblSalesInTransit DECIMAL(18,6),
	strTransactionType NVARCHAR(50),
	intCommodityId INT

)

CREATE TABLE #tblInOutAllLocation
(
	dtmDate DATETIME,
	dblInvIn DECIMAL(18,6),
	dblInvOut DECIMAL(18,6),
	dblAdjustments DECIMAL(18,6),
	dblInventoryCount DECIMAL(18,6),
	strTransactionId VARCHAR(MAX),
	intTransactionId INT,
	strDistribution VARCHAR(MAX),
	dblBalance DECIMAL(18,6),
	dblSalesInTransit DECIMAL(18,6),
	strTransactionType NVARCHAR(50),
	intCommodityId INT
)

CREATE TABLE #tblInTransit
(
	strIstrItemNo 				VARCHAR(MAX),
	intItemId					INT,
	intItemLocationId			INT,
	intItemUOMId				INT,
	strUnitMeasure				VARCHAR(MAX),
	strTransactionId			VARCHAR(MAX),
	intTransactionId			INT,
	intTransactionDetailId		INT,
	intInventoryTransactionId	INT,
	dblInTransitQty				DECIMAL(18,6),
	dtmDate						DATETIME,
	intCommodityId				INT,
	strCommodityCode			VARCHAR(MAX)
)

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END
SET @intLocationId = CASE WHEN @intLocationId = 0 THEN NULL ELSE @intLocationId END
SET @ysnLicensed =	CASE 
						WHEN @strLicensed = 'All' THEN NULL
						WHEN @strLicensed = 'Licensed' THEN 1
						WHEN @strLicensed = 'Non-Licensed' THEN 0
					END
DECLARE @_strLicensedForRKDPI VARCHAR(MAX) = CASE WHEN @strLicensed = 'Non-Licensed' THEN 'Non-licensed Storage'  WHEN @strLicensed = 'Licensed' THEN 'Licensed Storage' ELSE NULL END

DECLARE @dateToday DATETIME
SET @dateToday = dbo.fnRemoveTimeOnDate(GETDATE());

/* Inventory Opening Balance*/
WITH tblCOAndStorage AS (
SELECT	1 intTransactionType,
		t.intItemId,
		intLocationId,
		t.intTransactionTypeId,
		t.intInTransitSourceLocationId,
		CL.ysnLicensed,
		dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM tblICInventoryTransaction t
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId
	INNER JOIN tblICItem I ON I.intItemId =t.intItemId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmReportDate and ISNULL(ysnLicensed, 0) = CASE WHEN @_strLicensedForRKDPI = 'Licensed Storage' THEN 1 WHEN @_strLicensedForRKDPI = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END
GROUP BY t.intItemId,
		ItemLocation.intLocationId,
		t.intTransactionTypeId,
		t.intLotId,
		t.intInTransitSourceLocationId,
		CL.ysnLicensed
UNION ALL
SELECT	1 intTransactionType,
		t.intItemId,
		intLocationId,
		t.intTransactionTypeId,			
		NULL intInTransitSourceLocationId,
		CL.ysnLicensed,
		dblQty = SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId, t.intItemUOMId, t.dblQty))
FROM tblICInventoryTransactionStorage t
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = t.intItemLocationId
	INNER JOIN tblICItem I ON I.intItemId =t.intItemId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = intLocationId
WHERE t.ysnIsUnposted <> 1
	AND t.dtmDate < @dtmReportDate AND ISNULL(ysnLicensed, 0) = CASE WHEN @_strLicensedForRKDPI = 'Licensed Storage' THEN 1 WHEN @_strLicensedForRKDPI = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END
GROUP BY t.intItemId,
		ItemLocation.intLocationId,
		t.intTransactionTypeId,
		CL.ysnLicensed)

INSERT INTO @InventoryData
SELECT 1,
	   'INVENTORY BALANCE' AS label,
	   '' AS [Sign],
	   SUM(ISNULL(OP.dblQty,0)),
	   Commodity.strCommodityCode,
	   Commodity.intCommodityId
FROM tblICItem Item
INNER JOIN (
	tblICItemUOM StockUOM
	INNER JOIN tblICUnitMeasure sUOM ON StockUOM.intUnitMeasureId = sUOM.intUnitMeasureId
) ON StockUOM.intItemId = Item.intItemId AND StockUOM.ysnStockUnit = 1
LEFT JOIN tblCOAndStorage OP
	ON Item.intItemId = OP.intItemId
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCategory Category
	ON Category.intCategoryId = Item.intCategoryId 
WHERE Commodity.intCommodityId =ISNULL(@intCommodityId,Commodity.intCommodityId)
	AND OP.intLocationId = ISNULL(@intLocationId, OP.intLocationId)
GROUP BY Commodity.strCommodityCode
		,Commodity.intCommodityId

/*end inventory opening balance */

/*==START==GENERATE DPI==*/
INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	
	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode
	FROM @tblCommodities
		
	EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmReportDate,@dtmToTransactionDate = @dtmReportDate, @intCommodityId = @intCommodityId2,@strPositionIncludes = @_strLicensedForRKDPI, @intLocationId = @intLocationId
	
	INSERT INTO @tblStorageQuantitiesMain
	SELECT 
		@intCommodityId2
		,null
		,A.strDistributionA,A.strDistributionB,A.strDistributionC,A.strDistributionD,A.strDistributionE,A.strDistributionF,A.strDistributionG,A.strDistributionH,A.strDistributionI,A.strDistributionJ,A.strDistributionK		
		,A.dtmDate
		,0
		,0
		,A.dblAIn,A.dblBIn,A.dblCIn,A.dblDIn,A.dblEIn,A.dblFIn,A.dblGIn,A.dblHIn,A.dblIIn,A.dblJIn,A.dblKIn
		,A.dblAOut,A.dblBOut,A.dblCOut,A.dblDOut,A.dblEOut,A.dblFOut,A.dblGOut,A.dblHOut,A.dblIOut,A.dblJOut,A.dblKOut
		,A.dblANet,A.dblBNet,A.dblCNet,A.dblDNet,A.dblENet,A.dblFNet,A.dblGNet,A.dblHNet,A.dblINet,A.dblJNet,A.dblKNet, 0
	FROM tblRKDailyPositionForCustomer A

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END

/*==END==GENERATE DPI*/

/* Received and Shipped */
INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	
	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode
	FROM @tblCommodities

	DELETE FROM #tblInOut
	INSERT INTO #tblInOut
	EXEC uspRKGetInHouse @dtmFromTransactionDate = @dtmReportDate,@dtmToTransactionDate = @dtmReportDate, @intCommodityId = @intCommodityId2,@strPositionIncludes = @_strLicensedForRKDPI, @intLocationId = @intLocationId

	INSERT INTO @InventoryData
	SELECT 2
		,'RECEIVED'
		,'+'
		,CASE WHEN dblReceiveIn = 0 THEN 0.00000 ELSE dblReceiveIn END
		,@strCommodityCode
		,@intCommodityId2
	FROM (
		SELECT 
			dblReceiveIn = SUM(dblInvIn)
		FROM #tblInOut
	) B


	INSERT INTO @InventoryData
	SELECT 
		3
		,'SHIPPED'
		,'-'
		,CASE WHEN dblShipOut = 0 THEN 0.000000 ELSE dblShipOut END
		,@strCommodityCode
		,@intCommodityId2
	FROM (
		SELECT 
			dblShipOut = SUM(dblInvOut)
		FROM #tblInOut
	)B

	IF(ISNULL(@intLocationId,0) > 0)
	BEGIN
		INSERT INTO #tblInOutAllLocation
		EXEC uspRKGetInHouse @dtmFromTransactionDate = @dtmReportDate,@dtmToTransactionDate = @dtmReportDate, @intCommodityId = @intCommodityId2,@strPositionIncludes = @_strLicensedForRKDPI, @intLocationId = NULL

		DECLARE @dblInvOut DECIMAL(18,6)
		DECLARE @dblInvIn DECIMAL(18,6)

		SELECT 
			@dblInvIn = SUM(dblInvOut)
		FROM #tblInOut
		SELECT 
			@dblInvOut = SUM(dblInvIn)
		FROM #tblInOut

		INSERT INTO @InventoryData
		SELECT 4
			,'INTERNAL TRANSFERS RECEIVED'
			,'+'
			,CASE WHEN dblReceiveIn = 0 THEN 0.00000 ELSE dblReceiveIn - @dblInvIn END
			,@strCommodityCode
			,@intCommodityId2
		FROM (
			SELECT 
				dblReceiveIn = SUM(dblInvIn)
			FROM #tblInOutAllLocation
		) B


		INSERT INTO @InventoryData
		SELECT 
			5
			,'INTERNAL TRANSFERS SHIPPED'
			,'-'
			,CASE WHEN dblShipOut = 0 THEN 0.000000 ELSE dblShipOut - @dblInvOut END
			,@strCommodityCode
			,@intCommodityId2
		FROM (
			SELECT 
				dblShipOut = SUM(dblInvOut)
			FROM #tblInOutAllLocation
		)B
	END

	INSERT INTO #tblInTransit
	SELECT InTran.*,@intCommodityId2, C.strCommodityCode FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId2, @dtmReportDate) InTran
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = InTran.intItemLocationId
	LEFT JOIN tblICCommodity C
		ON C.intCommodityId = @intCommodityId2
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @_strLicensedForRKDPI = 'Licensed Storage' THEN 1 WHEN @_strLicensedForRKDPI = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
/* END-Received and Shipped */

INSERT INTO @InventoryData
SELECT 
	4 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,'NET ADJUSTMENTS'
	,CASE WHEN ISNULL(dblAdjustments,0) < 0 THEN '-' ELSE '+' END
	,CASE WHEN ISNULL(dblAdjustments,0) = 0 THEN 0.000000 ELSE ABS(dblAdjustments) END
	,@strCommodityCode
	,@intCommodityId2
FROM (
	SELECT 
		dblAdjustments = SUM(dblAdjustments)
	FROM #tblInOut
)B

/* ADJUSTMENTS */

/*END ADJUSTMENTS */


/* TOTAL INVENTORY */
INSERT INTO @InventoryData
SELECT
	5 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,'NET ELEVATOR INVENTORY'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT
	6 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @InventoryData
SELECT 
	7 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,'TOTAL INVENTORY'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @InventoryData
WHERE strLabel <> 'NET ELEVATOR INVENTORY'
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT
	8 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

/* END TOTAL INVENTORY */

/* IN TRANSIT */

INSERT INTO @InventoryData
SELECT 
	9 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,'INVENTORY IN TRANSIT'
	,''
	, SUM(ISNULL(dblInTransitQty,0))
	,strCommodityCode
	,intCommodityId
FROM #tblInTransit
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT
	10 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId


/* END IN TRANSIT */

DECLARE @StorageTypes TABLE
(
	intStorageScheduleTypeId INT
	,strStorageTypeDescription NVARCHAR(60)
)

DECLARE @intCnt INT = 1
DECLARE @intOrigCnt INT = 0
DECLARE @intStorageTypeNum INT 
DECLARE @intTotalRowCnt INT

/*==START==STORAGE OBLIGATION==*/
INSERT INTO @StorageTypes
SELECT 
	intStorageScheduleTypeId
	,strStorageTypeDescription 
FROM tblGRStorageType 
WHERE intStorageScheduleTypeId > 0 
	--AND ysnCustomerStorage = 0 
	AND ysnDPOwnedType = 0

DECLARE @StorageObligationData TABLE
(
	intRowNum INT
	,intStorageScheduleTypeId INT
	,strLabel NVARCHAR(100)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
)
DECLARE @intStorageScheduleTypeId INT
DECLARE @strStorageTypeDescription NVARCHAR(60)

INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCnt = 1

	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode		
	FROM @tblCommodities

	WHILE @intCnt <= (SELECT COUNT(*) FROM @StorageTypes)
	BEGIN
		SET @intStorageScheduleTypeId = NULL
		SET @strStorageTypeDescription = NULL		

		SELECT
			@intStorageScheduleTypeId	= intStorageScheduleTypeId
			,@strStorageTypeDescription	= strStorageTypeDescription
			,@intStorageTypeNum			= intRowCnt
		FROM (
			SELECT
				*
				,intRowCnt = ROW_NUMBER() OVER (ORDER BY intStorageScheduleTypeId)
			FROM @StorageTypes
		) ST		
		WHERE intRowCnt = @intCnt

		DELETE FROM @tblStorageQuantities

		INSERT INTO @tblStorageQuantities
		SELECT dtmTransactionDate,dblIssuedA,dblCancelledA,dblQuantityA
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionA = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedB,dblCancelledB,dblQuantityB
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionB = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedC,dblCancelledC,dblQuantityC
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionC = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedD,dblCancelledD,dblQuantityD
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionD = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedE,dblCancelledE,dblQuantityE
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionE = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedF,dblCancelledF,dblQuantityF
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionF = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedG,dblCancelledG,dblQuantityG
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionG = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedH,dblCancelledH,dblQuantityH
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionH = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedI,dblCancelledI,dblQuantityI
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionI = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedJ,dblCancelledJ,dblQuantityJ
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionJ = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2
		UNION ALL
		SELECT dtmTransactionDate,dblIssuedK,dblCancelledK,dblQuantityK
		FROM @tblStorageQuantitiesMain
		WHERE strStorageTypeDescriptionK = @strStorageTypeDescription
			AND intCommodityId = @intCommodityId2		
			 
		SET @intTotalRowCnt = CASE WHEN (SELECT ISNULL(MAX(intRowNum),0) FROM @StorageObligationData) = 0 THEN 10 ELSE (SELECT MAX(intRowNum) FROM @StorageObligationData) END

		INSERT INTO @StorageObligationData
		SELECT 
			@intTotalRowCnt + 1 
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' BALANCE'
			,'' AS [Sign]
			,NULL
			,@strCommodityCode
			,@intCommodityId2

		UPDATE @StorageObligationData
		SET dblUnits = dblQuantity
		FROM (
			SELECT SUM(ISNULL(dblQuantity,0)) dblQuantity
			FROM @tblStorageQuantities
			WHERE dtmTransactionDate IS NULL
		) A
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' BALANCE'

		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 2
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' ISSUED'
			,'+' AS [Sign]
			,NULL
			,@strCommodityCode
			,@intCommodityId2

		UPDATE @StorageObligationData
		SET dblUnits = dblIssued
		FROM (
			SELECT SUM(ISNULL(dblIssued,0)) dblIssued
			FROM @tblStorageQuantities
		) B
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' ISSUED'
	
		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 3
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' CANCELLED'
			,'-' AS [Sign]
			,NULL
			,@strCommodityCode
			,@intCommodityId2
		
		UPDATE @StorageObligationData
		SET dblUnits = dblCancelled
		FROM (
			SELECT SUM(ISNULL(dblCancelled,0)) dblCancelled
			FROM @tblStorageQuantities
		) C
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' CANCELLED'

		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 4
			,0
			,'TOTAL ' + @strStorageTypeDescription
			,''
			,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
			,@strCommodityCode
			,intCommodityId
		FROM @StorageObligationData
		WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
			AND strCommodityCode = @strCommodityCode
		GROUP BY strCommodityCode
			,intCommodityId

		UPDATE RD
		SET RD.intRowNum = r.intRowNum2
		FROM @StorageObligationData RD
		INNER JOIN (
			SELECT 
				*
				,(ROW_NUMBER() OVER (ORDER BY intRowNum) + 10 + CASE WHEN ISNULL(@intLocationId,0) > 0 THEN 2 ELSE 0 END ) intRowNum2
			FROM @StorageObligationData
		) r
			ON r.intRowNum = RD.intRowNum
				AND r.strLabel = RD.strLabel
				AND r.strCommodityCode = RD.strCommodityCode

		INSERT INTO @StorageObligationData 
		SELECT
			(SELECT (MAX(intRowNum) + 1) FROM @StorageObligationData)
			,@intStorageScheduleTypeId
			,''
			,''
			,NULL
			,@strCommodityCode
			,@intCommodityId2

		SET @intCnt = @intCnt + 1
		SET @intOrigCnt = @intOrigCnt + 2
	END

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 1
	,0
	,'TOTAL STORAGE OBLIGATION'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @StorageObligationData 
WHERE strLabel LIKE '%TOTAL%'
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 2
	,0
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
FROM @StorageObligationData
GROUP BY strCommodityCode
	,intCommodityId
/*==END==STORAGE OBLIGATION==*/
SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)
/* COMPANY OWNED */

INSERT INTO @InventoryData
SELECT 
@intTotalRowCnt + (SELECT MAX(intRowNum) FROM @ReportData),
'COMPANY-OWNED GRAIN',
'',
A.dblUnits - B.dblUnits,
A.strCommodityCode,
A.intCommodityId
FROM (SELECT SUM(dblUnits) dblUnits
	,strCommodityCode
	,intCommodityId
FROM @InventoryData
WHERE strLabel IN ('TOTAL INVENTORY')
GROUP BY strCommodityCode
	,intCommodityId) A
CROSS APPLY (
		SELECT
			SUM(dblUnits) dblUnits
			,strCommodityCode
			,intCommodityId
		FROM @StorageObligationData 
		WHERE strLabel = 'TOTAL STORAGE OBLIGATION'
		GROUP BY strCommodityCode
			,intCommodityId
) B
WHERE B.intCommodityId = A.intCommodityId
/* END COMPANY OWNED */

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt +(SELECT MAX(intRowNum) FROM @ReportData)+1
	,0
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
FROM @StorageObligationData
GROUP BY strCommodityCode
	,intCommodityId
/*==END==STORAGE OBLIGATION==*/




INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + 15
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @ReportData
WHERE strLabel IN ('TOTAL INVENTORY','TOTAL STORAGE OBLIGATION')
GROUP BY strCommodityCode
	,intCommodityId
/*==END==COMPANY-OWNED GRAIN==*/

/*==START==DP STORAGE==*/
INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCnt = 1

	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode		
	FROM @tblCommodities

	SELECT
		@intStorageScheduleTypeId	= intStorageScheduleTypeId
		,@strStorageTypeDescription	= strStorageTypeDescription
	FROM tblGRStorageType
	WHERE ysnDPOwnedType = 1

	DELETE FROM @tblStorageQuantities

	INSERT INTO @tblStorageQuantities
	SELECT dtmTransactionDate,dblIssuedA,dblCancelledA,dblQuantityA
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionA = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedB,dblCancelledB,dblQuantityB
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionB = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedC,dblCancelledC,dblQuantityC
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionC = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedD,dblCancelledD,dblQuantityD
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionD = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedE,dblCancelledE,dblQuantityE
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionE = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedF,dblCancelledF,dblQuantityF
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionF = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedG,dblCancelledG,dblQuantityG
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionG = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedH,dblCancelledH,dblQuantityH
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionH = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedI,dblCancelledI,dblQuantityI
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionI = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedJ,dblCancelledJ,dblQuantityJ
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionJ = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2
	UNION ALL
	SELECT dtmTransactionDate,dblIssuedK,dblCancelledK,dblQuantityK
	FROM @tblStorageQuantitiesMain
	WHERE strStorageTypeDescriptionK = @strStorageTypeDescription
		AND intCommodityId = @intCommodityId2

	INSERT INTO @StorageObligationData
	SELECT 
		@intTotalRowCnt + 16
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' BALANCE'
		,'' AS [Sign]
		,NULL
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = dblQuantity
	FROM (
		SELECT SUM(dblQuantity) dblQuantity
		FROM @tblStorageQuantities where dtmTransactionDate is null
	) A
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' BALANCE'

	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 17
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' ISSUED'
		,'+' AS [Sign]
		,0
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = dblIssued
	FROM (
		SELECT SUM(dblIssued) dblIssued
		FROM @tblStorageQuantities
	) B
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' ISSUED'
	
	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 18
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' CANCELLED'
		,'-' AS [Sign]
		,0
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = dblCancelled
	FROM (
		SELECT SUM(dblCancelled) dblCancelled
		FROM @tblStorageQuantities
	) C
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' CANCELLED'

	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 19
		,0
		,'TOTAL ' + @strStorageTypeDescription
		,''
		,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
		,@strCommodityCode
		,@intCommodityId2
	FROM @StorageObligationData
	WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
		AND strCommodityCode = @strCommodityCode
	GROUP BY strCommodityCode
		,intCommodityId

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
/*==END==DP STORAGE==*/

/*==START==STORAGE CAPACITY AND STORAGE AVAILABLE==*/
INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + 20
	,''
	,''
	,NULL
	,LD.strCommodityCode
	,CO.intCommodityId
	,@dtmReportDate
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId

INSERT INTO @InventoryData
SELECT 
	@intTotalRowCnt + 21
	,'TOTAL STORAGE CAPACITY'
	,''
	,CASE WHEN SUM(dblCapacity) = 0 THEN NULL ELSE SUM(dblAvailable) END
	,LD.strCommodityCode
	,CO.intCommodityId
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId

INSERT INTO @InventoryData
SELECT 
	@intTotalRowCnt + 22
	,'TOTAL CAPACITY AVAILABLE'
	,''
	,CASE WHEN SUM(dblAvailable) = 0 THEN NULL ELSE SUM(dblAvailable) END
	,LD.strCommodityCode
	,CO.intCommodityId
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId
/*==END==STORAGE CAPACITY AND STORAGE AVAILABLE==*/

/*==START==REPORT DATA==*/
INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @StorageObligationData

INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
WHERE strLabel NOT IN ('TOTAL STORAGE OBLIGATION')
/*==END==REPORT DATA==*/

SELECT * FROM @ReportData ORDER BY strCommodityCode,intRowNum

SET FMTONLY ON