CREATE VIEW [dbo].[vyuRKGetMatchingLotAvailableQty]

AS


SELECT DISTINCT intFutOptTransactionId,(dblNoOfContract-isnull(dblOpenContract,0)) AS dblOpenContract,strType = strType COLLATE Latin1_General_CI_AS FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,m.dblOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		INNER JOIN (SELECT SUM(CONVERT(int,mf.dblMatchQty)) as dblOpenContract , h.strType,intLFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			GROUP BY strType,intLFutOptTransactionId) as m on m.intLFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Buy' and intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId,dblOpenContract,strType
) t

UNION 

SELECT DISTINCT intFutOptTransactionId,(dblNoOfContract-isnull(dblOpenContract,0)) AS dblOpenContract,strType = strType COLLATE Latin1_General_CI_AS FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,m.dblOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as dblOpenContract , h.strType,intSFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intSFutOptTransactionId) as m on m.intSFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Sell' and intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId,dblOpenContract,strType
) t

UNION

SELECT DISTINCT intFutOptTransactionId,(dblNoOfContract-isnull(dblOpenContract,0)) AS dblOpenContract,strType = strType COLLATE Latin1_General_CI_AS FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,m.dblOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as dblOpenContract , h.strType,intLFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intLFutOptTransactionId) as m on m.intLFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Buy' and intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId,dblOpenContract,strType
) t

UNION 

SELECT DISTINCT intFutOptTransactionId,(dblNoOfContract-isnull(dblOpenContract,0)) AS dblOpenContract,strType = strType COLLATE Latin1_General_CI_AS FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,m.dblOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as dblOpenContract , h.strType,intSFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intSFutOptTransactionId) as m on m.intSFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Sell' and intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId,dblOpenContract,strType
) t