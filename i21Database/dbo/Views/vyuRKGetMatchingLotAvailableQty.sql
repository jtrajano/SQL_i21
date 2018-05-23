CREATE VIEW [dbo].[vyuRKGetMatchingLotAvailableQty]

AS


SELECT DISTINCT intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) AS intOpenContract,strType FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,m.intOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		INNER JOIN (SELECT SUM(CONVERT(int,mf.dblMatchQty)) as intOpenContract , h.strType,intLFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			GROUP BY strType,intLFutOptTransactionId) as m on m.intLFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Buy' and intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId,intOpenContract,strType
) t

UNION 

SELECT DISTINCT intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) AS intOpenContract,strType FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,m.intOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as intOpenContract , h.strType,intSFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intSFutOptTransactionId) as m on m.intSFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Sell' and intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId,intOpenContract,strType
) t

UNION

SELECT DISTINCT intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) AS intOpenContract,strType FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,m.intOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as intOpenContract , h.strType,intLFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intLFutOptTransactionId) as m on m.intLFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Buy' and intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId,intOpenContract,strType
) t

UNION 

SELECT DISTINCT intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) AS intOpenContract,strType FROM (
	SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,m.intOpenContract,strType
	FROM tblRKFutOptTransaction ot 
		inner join (select SUM(CONVERT(int,mf.dblMatchQty)) as intOpenContract , h.strType,intSFutOptTransactionId from tblRKMatchFuturesPSDetail mf 
			INNER JOIN tblRKMatchFuturesPSHeader h on mf.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
			group by strType,intSFutOptTransactionId) as m on m.intSFutOptTransactionId = ot.intFutOptTransactionId
	WHERE ot.strBuySell='Sell' and intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId,intOpenContract,strType
) t