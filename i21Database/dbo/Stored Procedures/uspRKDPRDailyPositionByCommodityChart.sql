CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityChart] 
	 @intCommodityId int 
	,@intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate datetime = NULL
	,@strByType nvarchar(50) = null
AS
SET @dtmToDate = CONVERT(datetime, CONVERT(varchar(10), ISNULL(@dtmToDate,GETDATE()), 110), 110)

DECLARE @FinalTable AS TABLE (
  strCommodityCode nvarchar(200),
  strUnitMeasure nvarchar(200),
  strSeqHeader nvarchar(200),
  dblTotal numeric(24, 10),
  intCommodityId int,
  intLocationId int,
  strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS
)

DECLARE @tblFinalDetail TABLE (
  intRowNum int,
  strLocationName nvarchar(500) COLLATE Latin1_General_CI_AS,
  intLocationId int,
  intCommodityId int,
  strCommodityCode nvarchar(50) COLLATE Latin1_General_CI_AS,
  UOM nvarchar(50) COLLATE Latin1_General_CI_AS,
  [Open Purchase] decimal(24, 10),
  [Open Sale] decimal(24, 10),
  [Company Titled] decimal(24, 10),
  [Price Risk] decimal(24, 10),
  [Open Sales] decimal(24, 10),
  [Avail For Sale] decimal(24, 10),
  [In House] decimal(24, 10),
  [Basis Risk] decimal(24, 10)
)

IF(ISNULL(@intVendorId,0) = 0)
BEGIN
	INSERT INTO @FinalTable (strCommodityCode, strUnitMeasure, strSeqHeader, dblTotal, intCommodityId, strLocationName)
	EXEC uspRKDPRSubHedgePositionByCommodity @intCommodityId = @intCommodityId,
											 @intLocationId = 0,
											 @intVendorId = @intVendorId,
											 @strPurchaseSales = 'Purchase',
											 @strPositionIncludes = @strPositionIncludes,
											 @dtmToDate = @dtmToDate,
											 @strByType = 'ByLocation'
END

INSERT INTO @FinalTable (strCommodityCode, strUnitMeasure, strSeqHeader, dblTotal, intCommodityId, strLocationName)
EXEC uspRKDPRSubInvPositionByCommodity @intCommodityId = @intCommodityId,
                                       @intLocationId = 0,
                                       @intVendorId = @intVendorId,
                                       @strPurchaseSales = 'Purchase',
                                       @strPositionIncludes = @strPositionIncludes,
                                       @dtmToDate = @dtmToDate,
                                       @strByType = 'ByLocation'

INSERT INTO @tblFinalDetail (intRowNum
, strLocationName
, intLocationId
, intCommodityId
, strCommodityCode
, UOM
, [Company Titled]
, [Price Risk]
, [Avail For Sale]
, [In House]
, [Basis Risk])
SELECT intRowNum
	,strLocationName
	,intLocationId
	,intCommodityId
	,strCommodityCode
	,UOM = strUnitMeasure
	,[Company Titled] = dblCompanyTitled
	,[Price Risk] = dblCaseExposure
	,[Avail For Sale] = dblAvailForSale
	,[In House] = dblInHouse
	,[Basis Risk] = dblBasisExposure
FROM (
SELECT
  CONVERT(int, ROW_NUMBER() OVER (ORDER BY strCommodityCode ASC)) AS intRowNum,
  *
FROM (SELECT DISTINCT
  strCommodityCode,
  strUnitMeasure,
  intCommodityId,
  f.strLocationName,
  l.intCompanyLocationId intLocationId,
  dblInHouse = ISNULL((SELECT DISTINCT
		SUM(dblTotal) dblInHouse
		FROM @FinalTable t
		WHERE ROUND(dblTotal, 0) <> 0
		AND strSeqHeader = 'In-House'
		AND t.intCommodityId = f.intCommodityId
		AND t.strLocationName = f.strLocationName),0),
  dblCompanyTitled = ISNULL((SELECT DISTINCT
		SUM(dblTotal) dblCompanyTitled
		FROM @FinalTable t
		WHERE ROUND(dblTotal, 0) <> 0
		AND strSeqHeader = 'Company Titled Stock'
		AND t.intCommodityId = f.intCommodityId
		AND t.strLocationName = f.strLocationName),0),
  dblCaseExposure = ISNULL((SELECT DISTINCT
		SUM(dblTotal) dblCaseExposure
		FROM @FinalTable t
		WHERE ROUND(dblTotal, 0) <> 0
		AND strSeqHeader = 'Price Risk'
		AND t.intCommodityId = f.intCommodityId
		AND t.strLocationName = f.strLocationName),0),
  dblBasisExposure = ISNULL((SELECT DISTINCT
		SUM(dblTotal) dblBasisExposure
		FROM @FinalTable t
		WHERE ROUND(dblTotal, 0) <> 0
		AND strSeqHeader = 'Basis Risk'
		AND t.intCommodityId = f.intCommodityId
		AND t.strLocationName = f.strLocationName),0),
  dblAvailForSale = ISNULL((SELECT DISTINCT
		SUM(dblTotal) dblAvailForSale
		FROM @FinalTable t
		WHERE ROUND(dblTotal, 0) <> 0
		AND strSeqHeader = 'Avail for Spot Sale'
		AND t.intCommodityId = f.intCommodityId
		AND t.strLocationName = f.strLocationName),0)
FROM @FinalTable f
JOIN tblSMCompanyLocation l
  ON f.strLocationName = l.strLocationName) t
) FT

IF ISNULL(@intVendorId, 0) = 0
BEGIN
SELECT strTransactionType,
  UOM,
  dblTransactionQuantity = SUM(dblTransactionQuantity)
FROM @tblFinalDetail
UNPIVOT (dblTransactionQuantity FOR strTransactionType IN (
	[Company Titled]
	,[Price Risk]
	,[Basis Risk]
	,[Avail For Sale]
	,[In House]
)) AS UnPvt
GROUP BY strTransactionType,
         UOM
END
ELSE
BEGIN
SELECT strTransactionType,
  UOM,
  dblTransactionQuantity = SUM(dblTransactionQuantity)
FROM @tblFinalDetail
UNPIVOT (dblTransactionQuantity FOR strTransactionType IN (
	[In House]
)) AS UnPvt
GROUP BY strTransactionType,
         UOM
END
