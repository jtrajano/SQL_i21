CREATE FUNCTION [dbo].[fnCTCheckIfDuplicateFutOptTransactionHistory]
(
	@intFutOptTransactionId int
)
RETURNS INT
AS
BEGIN

DECLARE @total INT

SELECT @total = COUNT(*)
FROM
(
	SELECT DISTINCT intFutOptTransactionHeaderId,strSelectedInstrumentType,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strInstrumentType,
	strFutureMarket,strCurrency,strCommodity,strBroker,strBrokerAccount,strTrader,strBrokerTradeNo,strFutureMonth,strOptionMonth,strOptionType,dblStrike,
	dblPrice,strStatus,dtmFilledDate,intNewNoOfContract,intBalanceContract,intBookId,intSubBookId,ysnMonthExpired,strUserName,ysnPreCrush
	FROM
	(
		SELECT H.intFutOptTransactionHeaderId
		, H.strSelectedInstrumentType
		, T.intFutOptTransactionId
		, strInternalTradeNo
		, strLocationName = (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = T.intLocationId)
		, dblContractSize = (SELECT TOP 1 dblContractSize FROM tblRKFutureMarket WHERE intFutureMarketId = T.intFutureMarketId)
		, strInstrumentType = (CASE WHEN intInstrumentTypeId = 1 THEN 'Futures'
							WHEN intInstrumentTypeId = 2 THEN 'Options'
							WHEN intInstrumentTypeId = 3 THEN 'Currency Contract' ELSE '' END)
		, strFutureMarket = (SELECT TOP 1 strFutMarketName FROM tblRKFutureMarket WHERE intFutureMarketId = T.intFutureMarketId)
		, strCurrency = (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = T.intCurrencyId)
		, strCommodity = (SELECT TOP 1 strCommodityCode FROM tblICCommodity WHERE intCommodityId = T.intCommodityId)
		, strBroker = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intEntityId)
		, strBrokerAccount = (SELECT TOP 1 strAccountNumber FROM tblRKBrokerageAccount WHERE intBrokerageAccountId = T.intBrokerageAccountId)
		, strTrader = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = T.intTraderId)
		, strBrokerTradeNo
		, strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId = T.intFutureMonthId)
		, strOptionMonth = (SELECT TOP 1 strOptionMonth FROM tblRKOptionsMonth WHERE intOptionMonthId = T.intOptionMonthId)
		, strOptionType
		, dblStrike
		, dblPrice
		, strStatus
		, dtmFilledDate
		, intNewNoOfContract = (CASE WHEN 'UPDATE' = 'DELETE' THEN 0 ELSE T.intNoOfContract END)
		, intBalanceContract = (CASE WHEN 'UPDATE' = 'DELETE' THEN 0 ELSE T.intNoOfContract END)
		, intBookId
		, intSubBookId
		, ysnMonthExpired = (SELECT TOP 1 ysnExpired FROM tblRKFuturesMonth a WHERE a.intFutureMonthId = T.intFutureMonthId)
		, strUserName = (SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = 1)
		, ysnPreCrush
		FROM tblRKFutOptTransaction T
		INNER JOIN tblRKFutOptTransactionHeader H on T.intFutOptTransactionHeaderId = H.intFutOptTransactionHeaderId
		WHERE T.intFutOptTransactionId = @intFutOptTransactionId	
		UNION ALL
		SELECT intFutOptTransactionHeaderId,strSelectedInstrumentType,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strInstrumentType,
				strFutureMarket,strCurrency,strCommodity,strBroker,strBrokerAccount,strTrader,strBrokerTradeNo,strFutureMonth,strOptionMonth,strOptionType,dblStrike,
				dblPrice,strStatus,dtmFilledDate,intNewNoOfContract,intBalanceContract,intBookId,intSubBookId,ysnMonthExpired,strUserName,ysnPreCrush FROM
		(
			SELECT TOP 1 intFutOptTransactionHeaderId,strSelectedInstrumentType,intFutOptTransactionId,strInternalTradeNo,strLocationName,dblContractSize,strInstrumentType,
			strFutureMarket,strCurrency,strCommodity,strBroker,strBrokerAccount,strTrader,strBrokerTradeNo,strFutureMonth,strOptionMonth,strOptionType,dblStrike,
			dblPrice,strStatus,dtmFilledDate,intNewNoOfContract,intBalanceContract,intBookId,intSubBookId,ysnMonthExpired,strUserName,ysnPreCrush
			from tblRKFutOptTransactionHistory 
			WHERE intFutOptTransactionId = @intFutOptTransactionId	
			order by dtmTransactionDate DESC
		) a
	) b
) c

RETURN @total

END
