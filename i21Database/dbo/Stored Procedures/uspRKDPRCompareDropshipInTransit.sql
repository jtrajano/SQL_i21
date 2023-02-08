CREATE PROCEDURE uspRKDPRCompareDropshipInTransit
	@intDPRRun1 INT 
	,@intDPRRun2 INT
AS

BEGIN
	
DECLARE @strCommodityCode NVARCHAR(100)
		,@dtmRunDateTime1 DATETIME
		,@dtmRunDateTime2 DATETIME
		,@dtmDPRDate1 DATETIME
		,@dtmDPRDate2 DATETIME
		,@strEntityName NVARCHAR(150)
		,@strLocationName NVARCHAR(150)

SELECT TOP 1 
	@strCommodityCode = strCommodityCode
	,@dtmRunDateTime1 = dtmRunDateTime
	,@dtmDPRDate1 = dtmDPRDate
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun1

SELECT TOP 1 
	@dtmRunDateTime2 = dtmRunDateTime
	,@dtmDPRDate2 = dtmDPRDate
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun2

SELECT LD.*
INTO #FirstRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun1 and strType = 'Dropship In-Transit'


SELECT LD.*
INTO #SecondRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
WHERE intRunNumber = @intDPRRun2 and strType = 'Dropship In-Transit'



SELECT * INTO #tempFirstToSecond FROM (
	select strTransactionReferenceId, intTransactionReferenceDetailId, dblTotal, strEntityName, strItemNo, strLocationName, strTranType from #FirstRun
	except
	select strTransactionReferenceId, intTransactionReferenceDetailId, dblTotal, strEntityName, strItemNo, strLocationName, strTranType from #SecondRun
)t

SELECT * INTO #tempSecondToFirst FROM (
	select strTransactionReferenceId, intTransactionReferenceDetailId, dblTotal, strEntityName, strItemNo, strLocationName, strTranType from #SecondRun
	except
	select strTransactionReferenceId, intTransactionReferenceDetailId, dblTotal, strEntityName, strItemNo, strLocationName, strTranType from #FirstRun
) t


SELECT
	 intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY intTransactionReferenceDetailId ASC))
	,strBucketType = 'Dropship In-Transit'
	,strTicketNumber = strTransactionReferenceId
	,intTicketId = intTransactionReferenceDetailId
	,dblTotalRun1
	,dblTotalRun2
	,dblDifference = ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0)
	,strComment
	,strCommodityCode = @strCommodityCode
	,strEntityName
	,strItemNo
	,strLocationName
	,strType  = strTranType
	,dtmRunDateTime1 = @dtmRunDateTime1
	,dtmRunDateTime2 = @dtmRunDateTime2
	,dtmDPRDate1 = @dtmDPRDate1
	,dtmDPRDate2 = @dtmDPRDate2
	
FROM (

	SELECT 
		a.strTransactionReferenceId
		, a.intTransactionReferenceDetailId
		, dblTotalRun1 =  a.dblTotal 
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Balance Difference'
		, a.strEntityName
		, a.strItemNo
		, a.strLocationName
		, a.strTranType
	FROM #tempFirstToSecond a
	INNER JOIN #tempSecondToFirst b ON b.intTransactionReferenceDetailId = a.intTransactionReferenceDetailId


	UNION ALL
	SELECT 
		 a.strTransactionReferenceId
		, a.intTransactionReferenceDetailId
		, dblTotalRun1 = a.dblTotal
		, dblTotalRun2 = NULL
		, strComment = 'Missing in Run 2'
		, a.strEntityName
		, a.strItemNo
		, a.strLocationName
		, a.strTranType
	FROM #tempFirstToSecond  a
	WHERE a.intTransactionReferenceDetailId NOT IN (SELECT intTransactionReferenceDetailId FROM #tempSecondToFirst)

	UNION ALL
	SELECT 
		 b.strTransactionReferenceId
		, b.intTransactionReferenceDetailId
		, dblTotalRun1 = NULL
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Missing in Run 1'
		, b.strEntityName
		, b.strItemNo
		, b.strLocationName
		, b.strTranType
	FROM #tempSecondToFirst b
	WHERE b.intTransactionReferenceDetailId NOT IN (SELECT intTransactionReferenceDetailId FROM #tempFirstToSecond)
) t
WHERE  ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0) <> 0



DROP TABLE #FirstRun
DROP TABLE #SecondRun
DROP TABLE #tempFirstToSecond
DROP TABLE #tempSecondToFirst

END