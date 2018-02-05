CREATE PROC uspRKFutOptTransactionLimit @strXml NVARCHAR(max)
AS
DECLARE @idoc INT

EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

DECLARE @tblTransaction TABLE (intFutOptTransactionId INT)

INSERT INTO @tblTransaction
SELECT intFutOptTransactionId
FROM OPENXML(@idoc, 'root/Transaction', 2) WITH ([intFutOptTransactionId] INT)

SELECT intFutOptTransactionId
	,intFutureMonthId
INTO #temp
FROM tblRKFutOptTransaction
WHERE intFutOptTransactionId IN (
		SELECT intFutOptTransactionId
		FROM @tblTransaction
		)

SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY strFutMarketName ASC
			)) intRowNumber
	,*
FROM (
	SELECT *
	FROM (
		SELECT strFutMarketName
			,strFutureMonth
			,strCommodityCode
			,strBook
			,strSubBook
			,sum(dblOpenContract1) dblOpenContract
			,dblLimit
		FROM (
			SELECT fm.strFutMarketName
				,m.strFutureMonth
				,c.strCommodityCode
				,b.strBook
				,sb.strSubBook
				,CASE WHEN strBuySell = 'Buy' THEN intNoOfContract ELSE - intNoOfContract END dblOpenContract1
				,dblLimit
			FROM tblRKFutOptTransaction fot
			JOIN tblCTLimit l ON fot.intBookId = l.intBookId AND fot.intFutureMarketId = l.intFutureMarketId AND fot.intFutureMonthId = l.intFutureMonthId AND fot.intSubBookId = l.intSubBookId AND fot.intCommodityId = l.intCommodityId
			JOIN tblCTBook b ON b.intBookId = l.intBookId AND isnull(ysnLimitForMonth, 0) = 1
			JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = l.intFutureMarketId
			JOIN tblRKFuturesMonth m ON m.intFutureMonthId = l.intFutureMonthId
			JOIN tblICCommodity c ON c.intCommodityId = l.intCommodityId
			JOIN tblCTSubBook sb ON sb.intSubBookId = l.intSubBookId
			WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL AND fot.intFutOptTransactionId IN (
					SELECT intFutOptTransactionId
					FROM @tblTransaction
					) AND fot.intFutureMonthId IN (
					SELECT intFutureMonthId
					FROM #temp
					)
			) t
		GROUP BY strFutMarketName
			,strFutureMonth
			,strCommodityCode
			,strBook
			,strSubBook
			,dblLimit
		) t1
	WHERE dblOpenContract > dblLimit
	
	UNION
	
	SELECT *
	FROM (
		SELECT strFutMarketName
			,strFutureMonth
			,strCommodityCode
			,strBook
			,strSubBook
			,sum(dblOpenContract1) dblOpenContract
			,dblLimit
		FROM (
			SELECT fm.strFutMarketName
				,NULL strFutureMonth
				,c.strCommodityCode
				,b.strBook
				,sb.strSubBook
				,CASE WHEN strBuySell = 'Buy' THEN intNoOfContract ELSE - intNoOfContract END dblOpenContract1
				,dblLimit
			FROM vyuRKGetOpenContract oc
			JOIN tblRKFutOptTransaction fot ON oc.intFutOptTransactionId = fot.intFutOptTransactionId
			JOIN tblCTLimit l ON fot.intBookId = l.intBookId AND fot.intFutureMarketId = l.intFutureMarketId AND fot.intSubBookId = l.intSubBookId AND fot.intCommodityId = l.intCommodityId
			JOIN tblCTBook b ON b.intBookId = l.intBookId AND isnull(ysnLimitForMonth, 0) = 0
			JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = l.intFutureMarketId
			JOIN tblICCommodity c ON c.intCommodityId = l.intCommodityId
			JOIN tblCTSubBook sb ON sb.intSubBookId = l.intSubBookId
			WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL AND fot.intFutOptTransactionId IN (
					SELECT intFutOptTransactionId
					FROM @tblTransaction
					)
			) t1
		GROUP BY strFutMarketName
			,strFutureMonth
			,strCommodityCode
			,strBook
			,strSubBook
			,dblLimit
		) t
	WHERE dblOpenContract > dblLimit
	) t1
