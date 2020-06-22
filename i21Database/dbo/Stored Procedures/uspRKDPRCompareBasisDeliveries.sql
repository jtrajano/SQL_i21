CREATE PROCEDURE uspRKDPRCompareBasisDeliveries
	@intDPRRun1 INT 
	,@intDPRRun2 INT
	,@strBucketType NVARCHAR(100)
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
INNER JOIN tblRKDPRRunLog L ON L.intDPRunLogId = LD.intDPRunLogId
WHERE intRunNumber = @intDPRRun1

SELECT TOP 1 
	@dtmRunDateTime2 = dtmRunDateTime
	,@dtmDPRDate2 = dtmDPRDate
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRunLogId = LD.intDPRunLogId
WHERE intRunNumber = @intDPRRun2


SELECT LD.*
INTO #FirstRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRunLogId = LD.intDPRunLogId
WHERE intRunNumber = @intDPRRun1 and strType = @strBucketType


SELECT LD.*
INTO #SecondRun
FROM tblRKDPRRunLogDetail LD
INNER JOIN tblRKDPRRunLog L ON L.intDPRunLogId = LD.intDPRunLogId
WHERE intRunNumber = @intDPRRun2 and strType = @strBucketType




SELECT * INTO #tempFirstToSecond FROM (
	select strContractNumber, intContractHeaderId, strTransactionReferenceId, intTransactionReferenceId, strTranType, dblTotal, strEntityName, strLocationName from #FirstRun
	except
	select strContractNumber, intContractHeaderId, strTransactionReferenceId, intTransactionReferenceId, strTranType, dblTotal, strEntityName, strLocationName from #SecondRun
)t

SELECT * INTO #tempSecondToFirst FROM (
	select strContractNumber, intContractHeaderId, strTransactionReferenceId, intTransactionReferenceId, strTranType, dblTotal, strEntityName, strLocationName from #SecondRun
	except
	select strContractNumber, intContractHeaderId, strTransactionReferenceId, intTransactionReferenceId, strTranType, dblTotal, strEntityName, strLocationName from #FirstRun
) t


SELECT
	 intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strContractNumber ASC))
	,strBucketType = @strBucketType
	,strContractNumber
	,intContractHeaderId
	,dblTotalRun1
	,dblTotalRun2
	,dblDifference = ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0)
	,strComment
	,strCommodityCode = @strCommodityCode
	,strVendorCustomer = strEntityName 
	,strLocationName 
	,strTransactionId = strTransactionReferenceId
	,intTransactionReferenceId
	,strTranType
	,dtmRunDateTime1 = @dtmRunDateTime1
	,dtmRunDateTime2 = @dtmRunDateTime2
	,dtmDPRDate1 = @dtmDPRDate1
	,dtmDPRDate2 = @dtmDPRDate2
	
FROM (

	SELECT 
		a.strContractNumber
		, a.intContractHeaderId
		, dblTotalRun1 =  a.dblTotal 
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Balance Difference'
		, a.strEntityName
		, a.strLocationName
		, a.strTransactionReferenceId
		, a.intTransactionReferenceId
		, a.strTranType
	FROM #tempFirstToSecond a
	INNER JOIN #tempSecondToFirst b ON b.strContractNumber = a.strContractNumber


	UNION ALL
	SELECT 
		 a.strContractNumber
		, a.intContractHeaderId
		, dblTotalRun1 = a.dblTotal
		, dblTotalRun2 = NULL
		, strComment = 'Missing in Run 2'
		, a.strEntityName
		, a.strLocationName
		, a.strTransactionReferenceId
		, a.intTransactionReferenceId
		, a.strTranType
	FROM #tempFirstToSecond  a
	WHERE a.strContractNumber NOT IN (SELECT strContractNumber FROM #tempSecondToFirst)

	UNION ALL
	SELECT 
		 b.strContractNumber
		 , b.intContractHeaderId
		, dblTotalRun1 = NULL
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Missing in Run 1'
		, b.strEntityName
		, b.strLocationName
		, b.strTransactionReferenceId
		, b.intTransactionReferenceId
		, b.strTranType
	FROM #tempSecondToFirst b
	WHERE b.strContractNumber NOT IN (SELECT strContractNumber FROM #tempFirstToSecond)
) t



DROP TABLE #FirstRun
DROP TABLE #SecondRun
DROP TABLE #tempFirstToSecond
DROP TABLE #tempSecondToFirst

END