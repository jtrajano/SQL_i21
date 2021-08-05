CREATE VIEW [dbo].[vyuRKOpenDerivativesPosition]

AS

SELECT *
	,dblPContractBalance = CASE WHEN strBuySell = 'Buy' THEN dblBalanceLots ELSE 0 END
	,dblSContractBalance = CASE WHEN strBuySell = 'Sell' THEN dblBalanceLots ELSE 0 END
FROM (
	SELECT *
		,dblBalanceLots = dblLots - (dblAssignedLots + dblHedgedLots) 
	FROM(
		SELECT 
				ot.intFutOptTransactionId
				,ot.strInternalTradeNo
				,ot.strBrokerTradeNo 
				,ot.dtmFilledDate
				,strBuySell   
				,dblLots = ot.dblNoOfContract
				,dblAssignedLots =  ISNULL((SELECT SUM(AD.dblAssignedLots)	FROM tblRKAssignFuturesToContractSummary AD WHERE  ot.intFutOptTransactionId = AD.intFutOptTransactionId), 0)
				,dblHedgedLots = ISNULL((SELECT SUM(AD.dblHedgedLots)	FROM tblRKAssignFuturesToContractSummary AD WHERE  ot.intFutOptTransactionId = AD.intFutOptTransactionId), 0)
				,fm.strFutMarketName
				,fmh.strFutureMonth
				,ba.strAccountNumber
				,e.strName strBrokerName
				,c.strCommodityCode
				,scl.strLocationName
				,ot.dblPrice
				,b.strBook
				,sb.strSubBook
				,fmh.ysnExpired
				,ot.intFutOptTransactionHeaderId
				,ot.dtmCreateDateTime
				,strNotes = ot.strReference      		   
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
		JOIN tblRKFuturesMonth fmh on ot.intFutureMonthId=fmh.intFutureMonthId and ot.intFutureMarketId=fmh.intFutureMarketId
		JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId 
		JOIN tblEMEntity e on ot.intEntityId=e.intEntityId
		JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
		JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=ot.intLocationId
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
		WHERE ysnExpired = 0
	) a
) b where dblBalanceLots > 0
