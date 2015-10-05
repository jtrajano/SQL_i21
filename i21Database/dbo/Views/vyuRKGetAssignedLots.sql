CREATE VIEW vyuRKGetAssignedLots    
AS  
SELECT intFutOptTransactionId,convert(int,ISNULL(intNoOfContract,0)-isnull(intAssignedLots1,0)) as intAssignedLots FROM(
SELECT f.intFutOptTransactionId,
		sum(f.intNoOfContract) intNoOfContract,
		(SELECT SUM(isnull(convert(int,dblAssignedLots),0)) FROM tblRKAssignFuturesToContractSummary af 
		WHERE af.intFutOptTransactionId= f.intFutOptTransactionId) as intAssignedLots1
 FROM tblRKFutOptTransaction f 
GROUP BY f.intFutOptTransactionId)t

