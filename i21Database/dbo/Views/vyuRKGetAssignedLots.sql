CREATE view vyuRKGetAssignedLots
AS
SELECT intFutOptTransactionId,SUM(isnull(convert(int,intAssignedLots),0)) intAssignedLots FROM tblRKAssignFuturesToContractSummary
GROUP BY intFutOptTransactionId
