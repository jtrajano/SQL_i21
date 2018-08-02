﻿CREATE PROC [dbo].[uspRKRiskPositionOpenFutureByDate] 
		@intCommodityId INT = NULL, 
		@intFutureMarketId INT = NULL, 
		@dtmToDate DATETIME = NULL
AS
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

DECLARE @strCommodityCode NVARCHAR(max)
DECLARE @strFutureMarket NVARCHAR(max)

SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
SELECT @strFutureMarket = strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = @intFutureMarketId


select DISTINCT intFutOptTransactionId, intOpenContract,@strCommodityCode strCommodityCode,strInternalTradeNo,
	strLocationName,dblContractSize,strFutureMarket
,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,
intBookId,intSubBookId,ysnMonthExpired,strStatus


 from (
SELECT ROW_NUMBER() OVER (
				PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC
				) intRowNum,*  FROM(
SELECT DISTINCT dtmTransactionDate,intFutOptTransactionId, (intNoOfContract - isnull(intOpenContract, 0)) intOpenContract,@strCommodityCode strCommodityCode,strInternalTradeNo,
	strLocationName,dblContractSize,strFutureMarket
,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
FROM (
	SELECT dtmTransactionDate,intFutOptTransactionId, sum(intNoOfContract) intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus ,(
			SELECT SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE intFutOptTransactionId = mf.intLFutOptTransactionId
					and convert(DATETIME, CONVERT(VARCHAR(10), mf.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
			) intOpenContract
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC
				) intRowNum,ot.dtmTransactionDate, ot.intFutOptTransactionId, ot.intNewNoOfContract intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket 
				,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
		FROM tblRKFutOptTransactionHistory ot
		WHERE ot.strNewBuySell = 'Buy' AND isnull(ot.strInstrumentType, '') = 'Futures' AND convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 
				AND ot.strCommodity = CASE WHEN isnull(@strCommodityCode, '') = '' THEN ot.strCommodity ELSE @strCommodityCode END
				AND ot.strFutureMarket = CASE WHEN isnull(@strFutureMarket, '') = '' THEN ot.strFutureMarket ELSE @strFutureMarket END
		) t
	WHERE t.intRowNum = 1
	GROUP BY dtmTransactionDate,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
	) t1

UNION

SELECT DISTINCT dtmTransactionDate,intFutOptTransactionId, - (intNoOfContract - isnull(intOpenContract, 0)) intOpenContract,@strCommodityCode strCommodityCode,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket
,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
FROM (
	SELECT dtmTransactionDate,intFutOptTransactionId, sum(intNoOfContract) intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus, (
			SELECT SUM(mf.dblMatchQty)
			FROM tblRKMatchDerivativesHistory mf
			WHERE intFutOptTransactionId = mf.intLFutOptTransactionId
					and convert(DATETIME, CONVERT(VARCHAR(10), mf.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
			) intOpenContract
	FROM (
		SELECT ROW_NUMBER() OVER (
				PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC
				) intRowNum,dtmTransactionDate, ot.intFutOptTransactionId, ot.intNewNoOfContract intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
		FROM tblRKFutOptTransactionHistory ot
		WHERE ot.strNewBuySell = 'Sell' AND isnull(ot.strInstrumentType, '') = 'Futures' AND convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) AND ot.strCommodity = CASE WHEN isnull(@strCommodityCode, '') = '' THEN ot.strCommodity ELSE @strCommodityCode END
		AND ot.strFutureMarket = CASE WHEN isnull(@strFutureMarket, '') = '' THEN ot.strFutureMarket ELSE @strFutureMarket END
		) t
	WHERE t.intRowNum = 1
	GROUP BY dtmTransactionDate,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
	) t1

UNION

SELECT DISTINCT dtmTransactionDate,intFutOptTransactionId, (intNoOfContract - isnull(intOpenContract, 0)) intOpenContract,@strCommodityCode strCommodityCode,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
FROM (
	SELECT dtmTransactionDate,intFutOptTransactionId, sum(intNoOfContract) intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus, (
				SELECT isnull(SUM(mf.intMatchQty),0)
			FROM tblRKMatchDerivativesHistoryForOption mf
			WHERE  mf.intLFutOptTransactionId=intFutOptTransactionId
				and convert(DATETIME, CONVERT(VARCHAR(10), mf.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		 ) intOpenContract
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC) intRowNum,dtmTransactionDate,
				 ot.intFutOptTransactionId, 
				 ot.intNewNoOfContract intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket
				 ,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
		FROM tblRKFutOptTransactionHistory ot
		WHERE ot.strNewBuySell = 'Buy' AND isnull(ot.strInstrumentType, '') = 'Options'
			and convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate)  
			AND ot.strCommodity = CASE WHEN isnull(@strCommodityCode, '') = '' THEN ot.strCommodity ELSE @strCommodityCode END
			AND ot.strFutureMarket = CASE WHEN isnull(@strFutureMarket, '') = '' THEN ot.strFutureMarket ELSE @strFutureMarket END
		) t
	WHERE t.intRowNum = 1
	GROUP BY dtmTransactionDate,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
	) t1

UNION

SELECT DISTINCT dtmTransactionDate,intFutOptTransactionId, -(intNoOfContract - isnull(intOpenContract, 0)) intOpenContract,@strCommodityCode strCommodityCode,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket
,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
FROM (
	SELECT dtmTransactionDate,intFutOptTransactionId, sum(intNoOfContract) intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus, (
				SELECT isnull(SUM(mf.intMatchQty),0)
			FROM tblRKMatchDerivativesHistoryForOption mf
			WHERE  mf.intLFutOptTransactionId=intFutOptTransactionId
				and convert(DATETIME, CONVERT(VARCHAR(10), mf.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
		 ) intOpenContract
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC) intRowNum,dtmTransactionDate,
				 ot.intFutOptTransactionId, 
				 ot.intNewNoOfContract intNoOfContract,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
		FROM tblRKFutOptTransactionHistory ot
		WHERE ot.strNewBuySell = 'Sell' AND isnull(ot.strInstrumentType, '') = 'Options'
			and convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate)  
			AND ot.strCommodity = CASE WHEN isnull(@strCommodityCode, '') = '' THEN ot.strCommodity ELSE @strCommodityCode END
			AND ot.strFutureMarket = CASE WHEN isnull(@strFutureMarket, '') = '' THEN ot.strFutureMarket ELSE @strFutureMarket END
		) t
	WHERE t.intRowNum = 1
	GROUP BY dtmTransactionDate,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strFutureMarket,strFutureMonth,strOptionMonth,dblStrike,strOptionType,strInstrumentType,strBrokerAccount,strBroker,strNewBuySell,intFutOptTransactionHeaderId,intBookId,intSubBookId,ysnMonthExpired,strStatus
	) t1)t2 )t3 WHERE t3.intRowNum = 1