CREATE VIEW vyuRKBrokerageAccount

AS

SELECT s.intBrokerageAccountId
	, s.intEntityId
	, s.strAccountNumber
	, s.strDescription
	, s.intConcurrencyId
	, s.strClearingAccountNumber
	, strName = e.strName
	, ysnDeltaHedge = ISNULL(s.ysnDeltaHedge, 0)
	, ysnOTCOthers = ISNULL(s.ysnOTCOthers, 0)
	, strInstrumentType = CASE WHEN s.intInstrumentTypeId = 1 THEN 'Futures'
							WHEN s.intInstrumentTypeId = 2 THEN 'Options'
							ELSE 'Futures & Options' END COLLATE Latin1_General_CI_AS
	, ysnHeaderLock = CONVERT(BIT, ISNULL(ysnHeaderLock, 0))
FROM tblRKBrokerageAccount s
JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
OUTER APPLY (
	SELECT TOP 1 CASE WHEN ISNULL(t.intBrokerageAccountId,0) = 0  THEN 0 ELSE 1 END AS ysnHeaderLock
	FROM tblRKFutOptTransaction t
	WHERE t.intBrokerageAccountId = s.intBrokerageAccountId
) as FOT