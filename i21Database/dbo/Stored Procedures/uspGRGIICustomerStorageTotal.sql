CREATE PROCEDURE [dbo].[uspGRGIICustomerStorageTotal]
	@intCommodityId INT
	,@dtmReportDate DATETIME
AS
BEGIN

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END

DECLARE @CustomerStorageData AS TABLE (
	intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblTotalBeginningBalance DECIMAL(18,6) DEFAULT 0
	,dblTotalIncrease DECIMAL(18,6) DEFAULT 0
	,dblTotalDecrease DECIMAL(18,6) DEFAULT 0
	,dblTotalEndingBalance DECIMAL(18,6) DEFAULT 0
)

DECLARE @tblCommodities AS TABLE 
(
	intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
)

DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @strUOM NVARCHAR(20)
DECLARE @intCommodityUnitMeasureId AS INT

INSERT INTO @tblCommodities
SELECT DISTINCT intCommodityId, strCommodityCode FROM vyuGRStorageSearchView WHERE intCommodityId = ISNULL(@intCommodityId,intCommodityId)

/*==START==STORAGE OBLIGATION==*/
WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId = NULL
	SET @strCommodityCode = NULL
	SET @intCommodityUnitMeasureId = NULL
	SET @strUOM = NULL

	SELECT TOP 1 @intCommodityId = intCommodityId, @strCommodityCode = strCommodityCode FROM @tblCommodities
	
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
		,dblIn = SUM(dblIn)
		,dblOut = SUM(dblOut)
		,dblNet = SUM(dblIn) - SUM(dblOut)
		,strCommodityCode
	INTO #CustomerOwnershipBal
	FROM #CustomerOwnershipALL AA
	GROUP BY
		dtmDate
		,strDistributionType
		,strCommodityCode

	SELECT *
	INTO #CustomerOwnershipIncDec
	FROM (
		SELECT 
			dtmDate
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		INNER JOIN (
			SELECT strTransactionNumber
				,total = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) 
			FROM dbo.fnRKGetBucketCustomerOwned(@dtmReportDate,@intCommodityId,NULL)
			WHERE strTransactionType NOT IN ('Storage Settlement','Inventory Shipment')
			GROUP BY strTransactionNumber
		) A ON A.strTransactionNumber = AA.strTransactionNumber AND A.total <> 0
		GROUP BY
			dtmDate
			,strDistributionType
			,strCommodityCode
		UNION ALL
		SELECT 
			dtmDate
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,strCommodityCode	
		FROM #CustomerOwnershipALL AA
		WHERE strTransactionType IN ('Storage Settlement','Inventory Shipment')
		GROUP BY
			dtmDate
			,strCommodityCode
	) A

	INSERT INTO @CustomerStorageData
	SELECT @intCommodityId
		,strCommodityCode
		,SUM(dblIn) - SUM(dblOut)
		,0
		,0
		,0
	FROM #CustomerOwnershipBal 
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmReportDate)
	GROUP BY strCommodityCode
		
	--INCREASE FOR THE DAY
	UPDATE CSD
	SET dblTotalIncrease = STORAGE.TOTAL
	FROM @CustomerStorageData CSD
	INNER JOIN (
		SELECT TOTAL = SUM(dblIn)
			,strCommodityCode
		FROM #CustomerOwnershipIncDec C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
		GROUP BY strCommodityCode
	) STORAGE
		ON STORAGE.strCommodityCode = CSD.strCommodityCode

	--DECREASE FOR THE DAY
	UPDATE CSD
	SET dblTotalIncrease = STORAGE.TOTAL
	FROM @CustomerStorageData CSD
	INNER JOIN (
		SELECT TOTAL = SUM(dblOut)
			,strCommodityCode
		FROM #CustomerOwnershipIncDec C
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
		GROUP BY strCommodityCode
	) STORAGE
		ON STORAGE.strCommodityCode = CSD.strCommodityCode

	DROP TABLE #CustomerOwnershipALL
	DROP TABLE #CustomerOwnershipBal
	DROP TABLE #CustomerOwnershipIncDec

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId
END

UPDATE @CustomerStorageData SET dblTotalEndingBalance = ISNULL(dblTotalBeginningBalance,0) + ISNULL(dblTotalIncrease,0) - ISNULL(dblTotalDecrease,0)

SELECT * FROM @CustomerStorageData

END