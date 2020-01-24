CREATE VIEW vyuIPGetOptionsMatchPnS
AS
SELECT M.intMatchOptionsPnSId
	,M.intOptionsMatchPnSHeaderId
	,M.strTranNo
	,M.dtmMatchDate
	,M.dblMatchQty
	,M.intLFutOptTransactionId
	,M.intSFutOptTransactionId
	,M.intConcurrencyId
	,M.ysnPost
	,M.dtmPostDate
	,M.intMatchNo
	,M.intMatchOptionsPnSRefId
	,FOT.strInternalTradeNo AS strLongInternalTradeNo
	,FOT1.strInternalTradeNo AS strShortInternalTradeNo
	,FOT.intBookId
FROM tblRKOptionsMatchPnS M
LEFT JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = M.intLFutOptTransactionId
LEFT JOIN tblRKFutOptTransaction FOT1 ON FOT1.intFutOptTransactionId = M.intSFutOptTransactionId
