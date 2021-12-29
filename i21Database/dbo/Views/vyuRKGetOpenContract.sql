CREATE VIEW [dbo].[vyuRKGetOpenContract]

AS

SELECT DISTINCT 
	intFutOptTransactionId
	,dblOpenContract  = (dblNoOfContract - isnull(dblMatchedContract,0))
FROM (
	SELECT 
		ot.intFutOptTransactionId
		,dblNoOfContract =  sum(ot.dblNoOfContract)
		,dblMatchedContract = (SELECT SUM(CONVERT(DECIMAL(18,6),mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId)
	FROM tblRKFutOptTransaction ot
	WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId
) t

UNION 
SELECT DISTINCT 
	intFutOptTransactionId
	,dblOpenContract = -(dblNoOfContract - isnull(dblMatchedContract,0))  
FROM (
	SELECT 
		ot.intFutOptTransactionId
		,dblNoOfContract = sum(ot.dblNoOfContract) 
		,dblMatchedContract = (SELECT SUM(CONVERT(DECIMAL(18,6),mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId)
	FROM tblRKFutOptTransaction ot 
	WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 1
	GROUP BY intFutOptTransactionId
) t

UNION
SELECT DISTINCT 
	intFutOptTransactionId
	,dblOpenContract  = (isnull(dblNoOfContract,0) - isnull(dblMatchedContract,0) - isnull(dblExpiredContract,0))
FROM (
	SELECT 
		ot.intFutOptTransactionId
		,dblNoOfContract = sum(isnull(ot.dblNoOfContract,0))
		,dblMatchedContract = (SELECT SUM(CONVERT(DECIMAL(18,6),mf.dblMatchQty)) FROM tblRKOptionsMatchPnS mf WHERE ot.intFutOptTransactionId=mf.intLFutOptTransactionId) 
		,dblExpiredContract = (SELECT SUM(CONVERT(DECIMAL(18,6),ex.dblLots)) FROM tblRKOptionsPnSExpired ex WHERE ot.intFutOptTransactionId=ex.intFutOptTransactionId) 
	FROM tblRKFutOptTransaction ot 
	WHERE ot.strBuySell = 'Buy' AND intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId
) t

UNION 
SELECT DISTINCT 
	intFutOptTransactionId
	,dblOpenContract = -(isnull(dblNoOfContract,0) - isnull(dblMatchedContract,0) - isnull(dblExpiredContract,0)) 
FROM (
	SELECT 
		ot.intFutOptTransactionId
		,dblNoOfContract = sum(ot.dblNoOfContract) 
		,dblMatchedContract = (SELECT SUM(CONVERT(DECIMAL(18,6),mf.dblMatchQty)) FROM tblRKOptionsMatchPnS mf WHERE ot.intFutOptTransactionId=mf.intSFutOptTransactionId)
		,dblExpiredContract = (SELECT SUM(CONVERT(DECIMAL(18,6),ex.dblLots)) FROM tblRKOptionsPnSExpired ex WHERE ot.intFutOptTransactionId=ex.intFutOptTransactionId)
	FROM tblRKFutOptTransaction ot 
	WHERE ot.strBuySell = 'Sell' AND intInstrumentTypeId = 2
	GROUP BY intFutOptTransactionId
) t


