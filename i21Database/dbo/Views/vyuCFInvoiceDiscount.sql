



CREATE VIEW [dbo].[vyuCFInvoiceDiscount]
AS

SELECT 
--count(*),
  cfTrans.intCustomerId
 ,cfTrans.intTransactionId
 ,cfTrans.dtmPostedDate
 ,cfTrans.dtmTransactionDate
 ,cfTrans.strTransactionType
 ,cfTrans.strInvoiceReportNumber
 ,cfTrans.dtmCreatedDate
 ,cfTrans.strPrintTimeStamp
 ,cfTrans.intSalesPersonId
 ,dblTotalAmount = ROUND(ISNULL(cfTrans.dblCalculatedTotalPrice, 0), 2) 
 ,dtmInvoiceDate = DATEADD(dd, DATEDIFF(dd, 0, cfTrans.dtmInvoiceDate), 0)
 ,dblQuantity = (
	CASE 
		WHEN (cfItem.ysnIncludeInQuantityDiscount = 1) 
			AND ((cfTrans.strTransactionType = 'Local/Network' OR cfTrans.strTransactionType = 'Foreign Sale') 
			OR	(cfTrans.strTransactionType = 'Remote') AND (cfDiscountSchedule.ysnDiscountOnRemotes = 1) 
			OR	(cfTrans.strTransactionType = 'Extended Remote') AND (cfDiscountSchedule.ysnDiscountOnExtRemotes = 1))
		THEN ISNULL(cfTrans.dblQuantity,0)
		ELSE 0
	END)
----------------------------------------------
,arInv.intInvoiceId
,arInv.strInvoiceNumber
----------------------------------------------
,cfAccount.intAccountId
----------------------------------------------
,strCustomerName = emEntity.strName
,emEntity.strCustomerNumber
----------------------------------------------
,smTerm.intTermID
,smTerm.strTerm
,smTerm.strType
,smTerm.dblDiscountEP
,smTerm.intBalanceDue
,smTerm.intDiscountDay
,smTerm.dblAPR
,smTerm.strTermCode
,smTerm.ysnAllowEFT
,smTerm.intDayofMonthDue
,smTerm.intDueNextMonth
,smTerm.dtmDiscountDate
,smTerm.dtmDueDate
,smTerm.ysnActive
,smTerm.ysnEnergyTrac
,smTerm.intSort
,smTerm.intConcurrencyId
----------------------------------------------
,cfNetwork.strNetwork
----------------------------------------------
,cfInvCycle.strInvoiceCycle
----------------------------------------------
,cfDiscountSchedule.intDiscountScheduleId
,cfDiscountSchedule.strDiscountSchedule
,ysnShowOnCFInvoice =ISNULL(cfDiscountSchedule.ysnShowOnCFInvoice,0)
----------------------------------------------
,intCustomerGroupId =ISNULL(emGroup.intCustomerGroupId, 0) 
,emGroup.strGroupName
----------------------------------------------

--SPECIAL CASE--------------------------------
,arCustomerContact.strEmailDistributionOption
,arCustomerContact.strEmail
--SPECIAL CASE--------------------------------

FROM   dbo.tblCFTransaction AS cfTrans 
-----------------------------------------------------------
LEFT JOIN dbo.vyuCFInvoice AS arInv  
    ON arInv.intTransactionId = cfTrans.intTransactionId 
    AND arInv.intInvoiceId = cfTrans.intInvoiceId 
-----------------------------------------------------------	
INNER JOIN tblCFAccount AS cfAccount
	ON cfAccount.intCustomerId = cfTrans.intCustomerId
-------------------------------------------------------------
INNER JOIN vyuCFCustomerEntity AS emEntity 
	ON emEntity.intEntityId = cfTrans.intCustomerId
-------------------------------------------------------------
LEFT JOIN dbo.tblSMTerm AS smTerm
	ON smTerm.intTermID = cfAccount.intTermsCode
-------------------------------------------------------------
LEFT JOIN tblCFInvoiceCycle AS cfInvCycle 
	ON cfAccount.intInvoiceCycle = cfInvCycle.intInvoiceCycleId 
-------------------------------------------------------------
INNER JOIN tblCFNetwork AS cfNetwork
	ON cfNetwork.intNetworkId = cfTrans.intNetworkId
-------------------------------------------------------------
INNER JOIN tblCFDiscountSchedule AS cfDiscountSchedule
	ON cfAccount.intDiscountScheduleId = cfDiscountSchedule.intDiscountScheduleId
-------------------------------------------------------------
LEFT JOIN tblCFItem AS cfItem
	ON cfItem.intItemId = cfTrans.intProductId
-------------------------------------------------------------
LEFT JOIN (
	SELECT arCustGroupDetail.intCustomerGroupDetailId, 
			arCustGroupDetail.intCustomerGroupId, 
			arCustGroupDetail.intEntityId, 
			arCustGroupDetail.ysnSpecialPricing, 
			arCustGroupDetail.ysnContract, 
			arCustGroupDetail.ysnBuyback, 
			arCustGroupDetail.ysnQuote, 
			arCustGroupDetail.ysnVolumeDiscount, 
			arCustGroupDetail.intConcurrencyId, 
			arCustGroup.strGroupName 
	FROM   dbo.tblARCustomerGroup AS arCustGroup 
	INNER JOIN dbo.tblARCustomerGroupDetail AS arCustGroupDetail 
	ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId
) AS emGroup 
	ON emGroup.intEntityId = cfTrans.intCustomerId AND emGroup.ysnVolumeDiscount = 1 
-------------------------------------------------------------
OUTER APPLY (
	SELECT TOP 1 
		 strEmailDistributionOption
		,strEmail 
	FROM vyuARCustomerContacts
	WHERE intEntityId = cfTrans.intCustomerId  AND strEmailDistributionOption LIKE '%CF Invoice%' AND ISNULL(strEmail,'') != ''
) AS arCustomerContact
-------------------------------------------------------------
WHERE (ISNULL(cfTrans.ysnPosted,0) = 1 AND ISNULL(cfTrans.ysnInvalid,0) = 0)

GO


