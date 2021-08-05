

CREATE VIEW [dbo].[vyuCFInvoiceReportForNewPrint]
AS


SELECT 

 cfNetwork.strNetwork
,cfNetwork.intNetworkId
,cfTrans.intCustomerId
,emEntity.strCustomerNumber
,emEntity.strName
,cfTrans.dtmTransactionDate 
,cfTrans.dtmPostedDate
,cfTrans.dtmBillingDate
,cfTrans.dtmCreatedDate
,cfInvCycle.strInvoiceCycle
,cfInvCycle.intInvoiceCycleId
,cfTrans.intTransactionId
,cfTrans.ysnInvoiced
,cfAccount.intAccountId
,cfTrans.strInvoiceReportNumber
--,strEmailDistributionOption = arCustomerContact.strEmailDistributionOption 
,dtmInvoiceDate =Dateadd(dd, Datediff(dd, 0, cfTrans.dtmInvoiceDate), 0)

FROM   dbo.tblCFTransaction AS cfTrans 

INNER JOIN tblCFAccount AS cfAccount
	ON cfAccount.intCustomerId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN tblCFNetwork AS cfNetwork
	ON cfNetwork.intNetworkId = cfTrans.intNetworkId

LEFT JOIN tblCFInvoiceCycle AS cfInvCycle 
	ON cfAccount.intInvoiceCycle = cfInvCycle.intInvoiceCycleId 

WHERE (ysnPosted = 1 AND ysnPosted IS NOT NULL) 
AND (ysnInvalid = 0 OR ysnInvoiced IS NULL) 
AND (ysnInvoiced = 0 OR ysnInvoiced IS NULL)
AND cfTrans.intTransactionId NOT IN (
			SELECT tblCFTransaction.intTransactionId FROM tblCFTransaction
			INNER JOIN tblCFNetwork ON tblCFTransaction.intNetworkId = tblCFNetwork.intNetworkId
			 where strTransactionType = 'Foreign Sale' and (tblCFNetwork.ysnPostForeignSales = 0 OR tblCFNetwork.ysnPostForeignSales IS NULL))

GO


