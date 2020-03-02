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
FROM tblRKOptionsPnSExpired E WITH (NOLOCK)
LEFT JOIN tblRKFutOptTransaction FOT WITH (NOLOCK) ON FOT.intFutOptTransactionId = E.intFutOptTransactionId
