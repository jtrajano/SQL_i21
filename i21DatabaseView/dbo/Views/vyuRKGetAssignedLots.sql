CREATE VIEW vyuRKGetAssignedLots    
AS  
SELECT intFutOptTransactionId,convert(int,ISNULL(dblNoOfContract,0)-isnull(dblAssignedLots1,0)) as dblAssignedLots FROM(
SELECT f.intFutOptTransactionId,
		sum(f.dblNoOfContract) dblNoOfContract,
		(SELECT SUM(isnull(convert(int,dblAssignedLots),0)) FROM tblRKAssignFuturesToContractSummary af 
		WHERE af.intFutOptTransactionId= f.intFutOptTransactionId) as dblAssignedLots1
 FROM tblRKFutOptTransaction f 
GROUP BY f.intFutOptTransactionId)t

