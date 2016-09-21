CREATE VIEW [dbo].[vyuRKGetOpenContract]

AS

SELECT distinct intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy' and intInstrumentTypeId = 1
GROUP BY intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,-(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell' and intInstrumentTypeId = 1
Group by intFutOptTransactionId) t

UNION

SELECT distinct intFutOptTransactionId,(isnull(intNoOfContract,0)-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(isnull(ot.intNoOfContract,0)) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.intMatchQty)) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy' and intInstrumentTypeId = 2
Group by intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,-(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.intMatchQty)) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell' and intInstrumentTypeId = 2
Group by intFutOptTransactionId) t
