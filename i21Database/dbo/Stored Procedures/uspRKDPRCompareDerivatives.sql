CREATE PROCEDURE uspRKDPRCompareDerivatives
	@intDPRRun1 INT 
	,@intDPRRun2 INT
	,@strBucketType NVARCHAR(100) --It can be Net Futures, Crush or Delta Adjusted Options
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
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun1

SELECT TOP 1 
	@dtmRunDateTime2 = dtmRunDateTime
	,@dtmDPRDate2 = dtmDPRDate
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun2

SELECT *
INTO #FirstRun
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun1 and strType = @strBucketType


SELECT *
INTO #SecondRun
FROM tblRKTempDPRDetailLog a
WHERE intRunNumber = @intDPRRun2 and strType = @strBucketType



SELECT * INTO #tempFirstToSecond FROM (
	select strInternalTradeNo, intFutOptTransactionHeaderId, dblTotal, strAccountNumber, strFutureMonth, strBrokerTradeNo, strNotes, strLocationName from #FirstRun
	except
	select strInternalTradeNo, intFutOptTransactionHeaderId, dblTotal, strAccountNumber, strFutureMonth, strBrokerTradeNo, strNotes, strLocationName from #SecondRun
)t

SELECT * INTO #tempSecondToFirst FROM (
	select strInternalTradeNo, intFutOptTransactionHeaderId, dblTotal, strAccountNumber, strFutureMonth, strBrokerTradeNo, strNotes, strLocationName from #SecondRun
	except
	select strInternalTradeNo, intFutOptTransactionHeaderId, dblTotal, strAccountNumber, strFutureMonth, strBrokerTradeNo, strNotes, strLocationName from #FirstRun
) t


SELECT
	 intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strInternalTradeNo ASC))
	,strBucketType = @strBucketType
	,strInternalTradeNo
	,intFutOptTransactionHeaderId
	,dblTotalRun1
	,dblTotalRun2
	,dblDifference = ISNULL(dblTotalRun2,0) - ISNULL(dblTotalRun1,0)
	,strComment
	,strCommodityCode = @strCommodityCode
	,strBrokerAccount = strAccountNumber
	,strFutureMonth
	,strBrokerTradeNo
	,strNotes
	,strLocationName 
	,dtmRunDateTime1 = @dtmRunDateTime1
	,dtmRunDateTime2 = @dtmRunDateTime2
	,dtmDPRDate1 = @dtmDPRDate1
	,dtmDPRDate2 = @dtmDPRDate2
	
FROM (

	SELECT 
		a.strInternalTradeNo
		, a.intFutOptTransactionHeaderId
		, dblTotalRun1 =  a.dblTotal 
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Balance Difference'
		, a.strAccountNumber
		, a.strFutureMonth
		, a.strBrokerTradeNo
		, a.strNotes
		, a.strLocationName
	FROM #tempFirstToSecond a
	INNER JOIN #tempSecondToFirst b ON b.strInternalTradeNo = a.strInternalTradeNo


	UNION ALL
	SELECT 
		 a.strInternalTradeNo
		, a.intFutOptTransactionHeaderId
		, dblTotalRun1 = a.dblTotal
		, dblTotalRun2 = NULL
		, strComment = 'Missing in Run 2'
		, a.strAccountNumber
		, a.strFutureMonth
		, a.strBrokerTradeNo
		, a.strNotes
		, a.strLocationName
	FROM #tempFirstToSecond  a
	WHERE a.strInternalTradeNo NOT IN (SELECT strInternalTradeNo FROM #tempSecondToFirst)

	UNION ALL
	SELECT 
		 b.strInternalTradeNo
		, b.intFutOptTransactionHeaderId
		, dblTotalRun1 = NULL
		, dblTotalRun2 = b.dblTotal
		, strComment = 'Missing in Run 1'
		, b.strAccountNumber
		, b.strFutureMonth
		, b.strBrokerTradeNo
		, b.strNotes
		, b.strLocationName
	FROM #tempSecondToFirst b
	WHERE b.strInternalTradeNo NOT IN (SELECT strInternalTradeNo FROM #tempFirstToSecond)
) t



DROP TABLE #FirstRun
DROP TABLE #SecondRun
DROP TABLE #tempFirstToSecond
DROP TABLE #tempSecondToFirst

END