CREATE VIEW vyuRKBrokerageAccount
as
select 
	s.intBrokerageAccountId,
	s.intEntityId, 
	s.strAccountNumber,
	s.strDescription,
	s.intConcurrencyId,
	s.strClearingAccountNumber,
	strName = e.strName,
	ysnDeltaHedge= isnull(s.ysnDeltaHedge,0),
	ysnOTCOthers = isnull(s.ysnOTCOthers,0),
	strInstrumentType = case when s.intInstrumentTypeId = 1 then 'Futures' 
							when  s.intInstrumentTypeId = 2 then 'Options' 
							else 'Futures & Options'  end,
	ysnHeaderLock=convert(bit,isnull(ysnHeaderLock,0))

FROM tblRKBrokerageAccount s
JOIN tblEMEntity e on e.intEntityId=s.intEntityId
OUTER APPLY (
 SELECT TOP 1 CASE WHEN ISNULL(t.intBrokerageAccountId,0) = 0  THEN 0 ELSE 1 END AS ysnHeaderLock
 FROM tblRKFutOptTransaction t 
 WHERE t.intBrokerageAccountId=s.intBrokerageAccountId
) as FOT