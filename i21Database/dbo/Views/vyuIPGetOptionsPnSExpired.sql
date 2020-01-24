CREATE VIEW vyuIPGetOptionsPnSExpired
AS
SELECT E.intOptionsPnSExpiredId
	,E.intOptionsMatchPnSHeaderId
	,E.strTranNo
	,E.dtmExpiredDate
	,E.dblLots
	,E.intFutOptTransactionId
	,E.intOptionsPnSExpiredRefId
	,E.intConcurrencyId
	,FOT.strInternalTradeNo
	,FOT.intBookId
FROM tblRKOptionsPnSExpired E
LEFT JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = E.intFutOptTransactionId
