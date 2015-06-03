CREATE VIEW [dbo].[vyuRKGetOpenContract]

AS

SELECT distinct intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy'
Group by intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell'
Group by intFutOptTransactionId) t
