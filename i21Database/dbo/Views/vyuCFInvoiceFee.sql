

CREATE VIEW [dbo].[vyuCFInvoiceFee]
AS



SELECT 
--count(*),
----------------------------------------------
 cfTrans.intCustomerId
,cfTrans.dblQuantity
,cfTrans.intTransactionId
,cfTrans.dtmTransactionDate
,cfTrans.strTransactionType
,cfTrans.strInvoiceReportNumber
,cfTrans.strPrintTimeStamp
,cfTrans.dtmInvoiceDate
,cfTrans.intSalesPersonId
,dblTotalAmount = ROUND(ISNULL(cfTrans.dblCalculatedTotalPrice, 0),2)
----------------------------------------------
,arInv.strCustomerName
,arInv.dtmPostDate AS dtmPostedDate
,arInv.intInvoiceId
,arInv.strInvoiceNumber
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
,cfAccount.intAccountId
,cfAccount.intFeeProfileId
----------------------------------------------
,cfCard.intCardId
----------------------------------------------
,cfNetwork.strNetwork
,cfNetwork.intNetworkId
----------------------------------------------
,cfInvCycle.strInvoiceCycle
----------------------------------------------
,cfDiscountSchedule.intDiscountScheduleId
----------------------------------------------
,intCustomerGroupId = ISNULL(emGroup.intCustomerGroupId, 0)
,emGroup.strGroupName
----------------------------------------------
,cfSite.intARLocationId
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
-------------------------------------------------------------
INNER JOIN tblCFAccount AS cfAccount
	ON cfAccount.intCustomerId = cfTrans.intCustomerId
-------------------------------------------------------------
LEFT JOIN dbo.tblSMTerm AS smTerm
	ON smTerm.intTermID = cfAccount.intTermsCode
-------------------------------------------------------------
LEFT JOIN tblCFCard AS cfCard 
	ON cfCard.intCardId = cfTrans.intCardId 
-------------------------------------------------------------
INNER JOIN tblCFNetwork AS cfNetwork
	ON cfNetwork.intNetworkId = cfTrans.intNetworkId
-------------------------------------------------------------
LEFT JOIN tblCFInvoiceCycle AS cfInvCycle 
	ON cfAccount.intInvoiceCycle = cfInvCycle.intInvoiceCycleId 
-------------------------------------------------------------
INNER JOIN tblCFDiscountSchedule AS cfDiscountSchedule
	ON cfAccount.intDiscountScheduleId = cfDiscountSchedule.intDiscountScheduleId
-------------------------------------------------------------
LEFT JOIN tblCFItem AS cfItem
	ON cfItem.intItemId = cfTrans.intProductId
-------------------------------------------------------------
LEFT JOIN tblCFSite AS cfSite
	ON cfSite.intSiteId = cfTrans.intSiteId
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
WHERE (cfItem.ysnIncludeInQuantityDiscount = 1) 
AND (ISNULL(cfTrans.ysnPosted,0) = 1 AND ISNULL(cfTrans.ysnInvalid,0) = 0) 
AND ((cfTrans.strTransactionType = 'Local/Network' OR cfTrans.strTransactionType = 'Foreign Sale') 
OR	(cfTrans.strTransactionType = 'Remote') AND (cfDiscountSchedule.ysnDiscountOnRemotes = 1) 
OR	(cfTrans.strTransactionType = 'Extended Remote') AND (cfDiscountSchedule.ysnDiscountOnExtRemotes = 1))



