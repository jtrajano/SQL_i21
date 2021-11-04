CREATE PROCEDURE [dbo].[uspRKPhysicalVsFutures]
	@dtmMatchFromDate DATETIME 
	, @dtmMatchToDate DATETIME 
	, @intCommodityId INT
	, @intFutureMarketId INT = NULL
	, @intEntityId INT = NULL
	, @intBrokerageAccountId INT = NULL
	, @intFutureMonthId INT = NULL

AS

BEGIN


SELECT
	intRowNumber = ROW_NUMBER() OVER (ORDER BY CH.strContractNumber) 
	,CH.strContractNumber
	,strContractType = CASE WHEN CH.intContractTypeId = 2 THEN 'Sale'ELSE 'Purchase' END
	,dblContractLots = CH.dblNoOfLots
	,strPONumber = (SELECT  LTRIM(STUFF((SELECT ', ' + strERPPONumber FROM tblCTContractDetail where intContractHeaderId = CH.intContractHeaderId FOR XML PATH('')), 1, 1, '')))
	,strStartDate = (SELECT LTRIM(STUFF((SELECT ', ' + dbo.fnRKFormatDate( dtmStartDate,(SELECT TOP 1 strReportDateFormat FROM tblSMCompanyPreference)) FROM tblCTContractDetail where intContractHeaderId = CH.intContractHeaderId FOR XML PATH('')), 1, 1, '')))
	,strEndDate = (SELECT LTRIM(STUFF((SELECT ', ' + dbo.fnRKFormatDate( dtmEndDate,(SELECT TOP 1 strReportDateFormat FROM tblSMCompanyPreference)) FROM tblCTContractDetail where intContractHeaderId = CH.intContractHeaderId FOR XML PATH('')), 1, 1, '')))
	,strLongInternalTradeNo = BUY.strInternalTradeNo
	,dblLongTradeLots = BUY.dblNoOfContract
	,dblLongTradePrice = BUY.dblPrice
	,dtmLongTradeFilledDate = BUY.dtmFilledDate
	,strShortInternalTradeNo = SELL.strInternalTradeNo
	,dblShortTradeLots = SELL.dblNoOfContract
	,dblShortTradePrice = SELL.dblPrice
	,dtmShortTradeFilledDate = SELL.dtmFilledDate
	,MH.intMatchNo
	,MH.dtmMatchDate
	,MD.dblMatchQty
	,C.strCommodityCode
	,strFutureMarket = FM.strFutMarketName
	,strBroker = E.strName
	,strBrokerAccount = BA.strAccountNumber
	,MO.strFutureMonth
	,C.intCommodityId
	,SELL.intFutureMarketId
	,SELL.intEntityId
	,SELL.intBrokerageAccountId
	,SELL.intFutureMonthId
	,CH.intContractHeaderId
	,intLongFutOptTransactionHeaderId = BUY.intFutOptTransactionHeaderId
	,intShortFutOptTransactionHeaderId = SELL.intFutOptTransactionHeaderId
FROM tblCTPriceFixationDetail PFD
INNER JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
INNER JOIN tblRKMatchFuturesPSDetail MD ON MD.intSFutOptTransactionId = PFD.intFutOptTransactionId
INNER JOIN tblRKMatchFuturesPSHeader MH ON MH.intMatchFuturesPSHeaderId = MD.intMatchFuturesPSHeaderId
INNER JOIN tblRKFutOptTransaction BUY ON BUY.intFutOptTransactionId = MD.intLFutOptTransactionId
INNER JOIN tblRKFutOptTransaction SELL ON SELL.intFutOptTransactionId = MD.intSFutOptTransactionId
INNER JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SELL.intFutureMarketId
INNER JOIN tblEMEntity AS E ON E.intEntityId = SELL.intEntityId
INNER JOIN tblRKBrokerageAccount BA ON BA.intBrokerageAccountId = SELL.intBrokerageAccountId
INNER JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = SELL.intFutureMonthId
WHERE PFD.intFutOptTransactionId IS NOT NULL
AND MH.dtmMatchDate BETWEEN @dtmMatchFromDate AND @dtmMatchToDate
AND C.intCommodityId = ISNULL(@intCommodityId, C.intCommodityId)
AND SELL.intFutureMarketId = ISNULL(@intFutureMarketId, SELL.intFutureMarketId)
AND SELL.intEntityId = ISNULL(@intEntityId, SELL.intEntityId)
AND SELL.intBrokerageAccountId = ISNULL(@intBrokerageAccountId, SELL.intBrokerageAccountId)
AND SELL.intFutureMonthId = ISNULL(@intFutureMonthId, SELL.intFutureMonthId)



END