CREATE PROCEDURE [dbo].[uspGRGIICustomerStorage]
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

SELECT @dtmReportDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmReportDate'

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END

DECLARE @CustomerStorageData AS TABLE (
	dtmReportDate DATETIME
	,intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strStorageTypeDescription NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblBeginningBalance DECIMAL(18,6) DEFAULT 0
	,dblIncrease DECIMAL(18,6) DEFAULT 0
	,dblDecrease DECIMAL(18,6) DEFAULT 0
	,dblEndingBalance DECIMAL(18,6) DEFAULT 0
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
)

DECLARE @strUOM NVARCHAR(20)
DECLARE @intCommodityUnitMeasureId AS INT
DECLARE @strCommodity NVARCHAR(100)

SELECT strStorageTypeDescription
	,intStorageScheduleTypeId
INTO #StorageTypes
FROM tblGRStorageType
WHERE ysnDPOwnedType = 0
	AND strOwnedPhysicalStock = 'Customer'
	AND intStorageScheduleTypeId > 0

SELECT @strCommodity = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId

/*==START==STORAGE OBLIGATION==*/
BEGIN	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@strUOM = UM.strUnitMeasure
	FROM tblICCommodityUnitMeasure UOM
	INNER JOIN tblICUnitMeasure UM
		ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE intCommodityId = @intCommodityId
		AND ysnStockUnit = 1

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
			,CusOwn.strStorageTypeDescription
			,CusOwn.strCommodityCode
			,CusOwn.strTransactionType
		FROM dbo.fnRKGetBucketCustomerOwned(@dtmReportDate,@intCommodityId,NULL) CusOwn
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = CusOwn.intLocationId
				AND CL.ysnLicensed = 1
		LEFT JOIN tblGRStorageType ST 
			ON ST.strStorageTypeDescription = CusOwn.strDistributionType
		WHERE CusOwn.intCommodityId = @intCommodityId
		UNION ALL
		SELECT
			dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
			,strDistributionType
			,strTransactionNumber			
			,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
			,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
			,intStorageScheduleTypeId = -5
			,'Hold'
			,OH.strCommodityCode
			,OH.strTransactionType
		FROM dbo.fnRKGetBucketOnHold(@dtmReportDate,@intCommodityId,NULL) OH
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = OH.intLocationId
				AND CL.ysnLicensed = 1
		WHERE OH.intCommodityId = @intCommodityId
	) t

	SELECT 
		intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
		,dtmDate
		,strDistribution = strDistributionType		
		,dblIn = SUM(dblIn)
		,dblOut = SUM(dblOut)
		,dblNet = SUM(dblIn) - SUM(dblOut)
		,intStorageScheduleTypeId
		,strStorageTypeDescription
		,strCommodityCode
	INTO #CustomerOwnershipBal
	FROM #CustomerOwnershipALL AA
	GROUP BY
		dtmDate
		,strDistributionType
		,intStorageScheduleTypeId
		,strStorageTypeDescription
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
			,AA.strStorageTypeDescription
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		INNER JOIN (
			SELECT strTransactionNumber,strStorageTypeDescription
				,total = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) 
			FROM dbo.fnRKGetBucketCustomerOwned(@dtmReportDate,@intCommodityId,NULL)
			WHERE strTransactionType NOT IN ('Storage Settlement','Inventory Shipment')
			GROUP BY strTransactionNumber,strStorageTypeDescription
		) A ON A.strTransactionNumber = AA.strTransactionNumber AND A.total <> 0 AND A.strStorageTypeDescription = AA.strStorageTypeDescription
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,AA.strStorageTypeDescription
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
			,strStorageTypeDescription
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		WHERE strTransactionType IN ('Storage Settlement','Inventory Shipment')
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,strStorageTypeDescription
			,strCommodityCode
	) A

	--BEGINNING
	INSERT INTO @CustomerStorageData
	SELECT @dtmReportDate
		,@intCommodityId
		,@strCommodity
		,strStorageTypeDescription
		,SUM(dblIn) - SUM(dblOut)
		,0
		,0
		,0
		,@strUOM
	FROM #CustomerOwnershipBal A
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmReportDate)		
	GROUP BY strCommodityCode,strStorageTypeDescription

	INSERT INTO @CustomerStorageData
	SELECT @dtmReportDate
		,@intCommodityId
		,@strCommodity
		,strStorageTypeDescription
		,0
		,0
		,0
		,0
		,@strUOM
	FROM #StorageTypes S
	OUTER APPLY (
		SELECT storage = 1 
		FROM @CustomerStorageData D
		WHERE D.strStorageTypeDescription = S.strStorageTypeDescription
	) C
	WHERE C.storage IS NULL
		
	--INCREASE FOR THE DAY
	UPDATE CSD
	SET dblIncrease = STORAGE.TOTAL
	FROM @CustomerStorageData CSD
	INNER JOIN (
		SELECT TOTAL = SUM(dblIn)
			,strCommodityCode
			,strStorageTypeDescription
		FROM #CustomerOwnershipIncDec C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
		GROUP BY strCommodityCode,strStorageTypeDescription
	) STORAGE
		ON STORAGE.strCommodityCode = CSD.strCommodityCode
			AND STORAGE.strStorageTypeDescription = CSD.strStorageTypeDescription

	--DECREASE FOR THE DAY
	UPDATE CSD
	SET dblIncrease = STORAGE.TOTAL
	FROM @CustomerStorageData CSD
	INNER JOIN (
		SELECT TOTAL = SUM(dblOut)
			,strCommodityCode
			,strStorageTypeDescription
		FROM #CustomerOwnershipIncDec C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
		GROUP BY strCommodityCode,strStorageTypeDescription
	) STORAGE
		ON STORAGE.strCommodityCode = CSD.strCommodityCode
			AND STORAGE.strStorageTypeDescription = CSD.strStorageTypeDescription

	DROP TABLE #CustomerOwnershipALL
	DROP TABLE #CustomerOwnershipBal
	DROP TABLE #CustomerOwnershipIncDec

END

DELETE FROM #StorageTypes

UPDATE @CustomerStorageData SET dblEndingBalance = ISNULL(dblBeginningBalance,0) + ISNULL(dblIncrease,0) - ISNULL(dblDecrease,0)

INSERT INTO tblGRGIICustomerStorage
SELECT * FROM @CustomerStorageData

SELECT * FROM @CustomerStorageData ORDER BY intCommodityId

END