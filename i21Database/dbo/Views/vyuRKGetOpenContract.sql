CREATE VIEW [dbo].[vyuRKGetOpenContract]

AS

SELECT distinct intFutOptTransactionId,(dblNoOfContract-isnull(dblOpenContract,0)) dblOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) dblOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy' and intInstrumentTypeId = 1
GROUP BY intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,-(dblNoOfContract-isnull(dblOpenContract,0)) dblOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) dblOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell' and intInstrumentTypeId = 1
Group by intFutOptTransactionId) t

UNION

SELECT distinct intFutOptTransactionId,(isnull(dblNoOfContract,0)-isnull(dblOpenContract,0)) dblOpenContract from (
SELECT ot.intFutOptTransactionId,sum(isnull(ot.dblNoOfContract,0)) dblNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) dblOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy' and intInstrumentTypeId = 2
Group by intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,-(dblNoOfContract-isnull(dblOpenContract,0)) dblOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.dblNoOfContract) dblNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) dblOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell' and intInstrumentTypeId = 2
Group by intFutOptTransactionId) t