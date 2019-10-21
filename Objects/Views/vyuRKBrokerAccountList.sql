CREATE VIEW vyuRKBrokerAccountList
AS
SELECT DISTINCT ft.intFutureMarketId,ft.intCommodityId,ft.intEntityId,ft.intBrokerageAccountId,b.strAccountNumber,
		ISNULL(ysnOTCOthers,0) ysnOTCOthers,ISNULL(ft.intInstrumentTypeId,0) intInstrumentTypeId
FROM tblRKFutOptTransaction ft
JOIN tblRKBrokerageAccount b ON ft.intBrokerageAccountId=b.intBrokerageAccountId