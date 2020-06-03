CREATE PROCEDURE uspRKDPRCompareCompanyTitled
	@intDPRRun1 INT 
	,@intDPRRun2 INT
AS

BEGIN
	
DECLARE @strBucketType NVARCHAR(100) = 'Company Titled'
		,@strCommodityCode NVARCHAR(100)
		,@dtmRunDateTime1 DATETIME
		,@dtmRunDateTime2 DATETIME
		,@dtmDPRDate1 DATETIME
		,@dtmDPRDate2 DATETIME
		,@strEntityName NVARCHAR(150)
		,@strLocationName NVARCHAR(150)



SELECT *
INTO #FirstRun
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun1 and strType = @strBucketType


SELECT *
INTO #SecondRun
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun2 and strType = @strBucketType

SELECT TOP 1 
	@strCommodityCode = strCommodityCode
	,@dtmRunDateTime1 = dtmRunDateTime
	,@dtmDPRDate1 = dtmDPRDate
FROM #FirstRun

SELECT TOP 1 
	@dtmRunDateTime2 = dtmRunDateTime
	,@dtmDPRDate2 = dtmDPRDate
FROM #SecondRun


SELECT * INTO #tempFirstToSecond FROM (
	select strTransactionReferenceId, dblTotal, strEntityName, strLocationName from #FirstRun
	except
	select strTransactionReferenceId, dblTotal, strEntityName, strLocationName from #SecondRun
)t

SELECT * INTO #tempSecondToFirst FROM (
	select strTransactionReferenceId, dblTotal, strEntityName, strLocationName from #SecondRun
	except
	select strTransactionReferenceId, dblTotal, strEntityName, strLocationName from #FirstRun
) t


SELECT
	strBucketType = @strBucketType
	,strTransactionId = strTransactionReferenceId
	,dblTotalRun1
	,dblTotalRun2
	,dblDifference = ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0)
	,strComment
	,strCommodityCode = @strCommodityCode
	,strVendorCustomer = strEntityName 
	,strLocationName 
	,dtmRunDateTime1 = @dtmRunDateTime1
	,dtmRunDateTime2 = @dtmRunDateTime2
	,dtmDPRDate1 = @dtmDPRDate1
	,dtmDPRDate2 = @dtmDPRDate2
	
FROM (

	SELECT 
		a.strTransactionReferenceId
		, dblTotalRun1 =  a.dblTotal 
		, dblTotalRun2 = b.dblTotal
		, strComment = ''
		, a.strEntityName
		, a.strLocationName
	FROM #tempFirstToSecond a
	INNER JOIN #tempSecondToFirst b ON b.strTransactionReferenceId = a.strTransactionReferenceId


	UNION ALL
	SELECT 
		 a.strTransactionReferenceId
		, dblTotalRun1 = a.dblTotal
		, dblTotalRun2 = NULL
		, strComment = 'Missing in Run 2'
		, a.strEntityName
		, a.strLocationName
	FROM #tempFirstToSecond  a
	WHERE a.strTransactionReferenceId NOT IN (SELECT strTransactionReferenceId FROM #tempSecondToFirst)

	UNION ALL
	SELECT 
		 b.strTransactionReferenceId
		, dblTotalRun1 = NULL
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Missing in Run 1'
		, b.strEntityName
		, b.strLocationName
	FROM #tempSecondToFirst b
	WHERE b.strTransactionReferenceId NOT IN (SELECT strTransactionReferenceId FROM #tempFirstToSecond)
) t



DROP TABLE #FirstRun
DROP TABLE #SecondRun
DROP TABLE #tempFirstToSecond
DROP TABLE #tempSecondToFirst

END