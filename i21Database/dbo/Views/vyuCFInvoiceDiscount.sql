

CREATE VIEW [dbo].[vyuCFInvoiceDiscount]
AS
SELECT   

intCustomerId = (

	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.intCustomerId

		ELSE cfCardAccount.intCustomerId
	END),

intAccountId = (

	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.intAccountId

		ELSE cfCardAccount.intAccountId
	END),

strCustomerName = (	
	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.strName

		ELSE cfCardAccount.strName
	END),

strCustomerNumber = (	
	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.strEntityNo

		ELSE cfCardAccount.strCustomerNumber
	END),

ROUND(ISNULL(cfTransPrice.dblCalculatedAmount, 0), 2) AS dblTotalAmount, smTerm.intTermID, smTerm.strTerm, smTerm.strType, smTerm.dblDiscountEP, 
                         smTerm.intBalanceDue, smTerm.intDiscountDay, smTerm.dblAPR, smTerm.strTermCode, smTerm.ysnAllowEFT, smTerm.intDayofMonthDue, smTerm.intDueNextMonth, 
                         smTerm.dtmDiscountDate, smTerm.dtmDueDate, smTerm.ysnActive, smTerm.ysnEnergyTrac, smTerm.intSort, smTerm.intConcurrencyId, 
                          cfTrans.intTransactionId, cfCardAccount.strNetwork, cfTrans.dtmPostedDate AS dtmPostedDate, 
                         cfCardAccount.strInvoiceCycle, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfCardAccount.intDiscountScheduleId, 
                         ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, arInv.intInvoiceId, arInv.strInvoiceNumber, cfTrans.strInvoiceReportNumber, 
						 cfTrans.dtmCreatedDate,
                         cfTrans.strPrintTimeStamp, cfCardAccount.strEmailDistributionOption, cfCardAccount.strEmail, DATEADD(dd, DATEDIFF(dd, 0, cfTrans.dtmInvoiceDate), 0) AS dtmInvoiceDate, cfTrans.intSalesPersonId,cfDiscount.strDiscountSchedule,ISNULL(cfDiscount.ysnShowOnCFInvoice,0) as ysnShowOnCFInvoice

 ,dblQuantity = (
	CASE 
		WHEN (cfSiteItem.ysnIncludeInQuantityDiscount = 1) 
			AND ((cfTrans.strTransactionType = 'Local/Network' OR cfTrans.strTransactionType = 'Foreign Sale') 
			OR	(cfTrans.strTransactionType = 'Remote') AND (cfDiscount.ysnDiscountOnRemotes = 1) 
			OR	(cfTrans.strTransactionType = 'Extended Remote') AND (cfDiscount.ysnDiscountOnExtRemotes = 1))
		THEN ISNULL(cfTrans.dblQuantity,0)
		ELSE 0
	END)
FROM         
 dbo.vyuCFInvoice AS arInv RIGHT JOIN
                         dbo.tblCFTransaction AS cfTrans 
						 ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId 
						 LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId LEFT JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId LEFT JOIN
                         dbo.tblCFDiscountSchedule AS cfDiscount ON cfDiscount.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId LEFT OUTER JOIN
                             (SELECT   arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, 
                                                         arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, arCustGroupDetail.ysnVolumeDiscount, 
                                                         arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                                FROM         dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                                                         dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON 
                         emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 LEFT JOIN
                         dbo.tblSMTerm AS smTerm ON cfCardAccount.intTermsCode = smTerm.intTermID INNER JOIN
                             (SELECT   icfSite.intSiteId, icfSite.intNetworkId, icfSite.intTaxGroupId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, 
                                                         icfSite.strAuthorityId1, icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, 
                                                         icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, 
                                                         icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, 
                                                         icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, 
                                                         icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, 
                                                         icfSite.ysnUseControllerCard, icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, 
                                                         icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, 
                                                         icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, icfSite.intAdjustmentSiteGroupId, 
                                                         icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, 
                                                         icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, 
                                                         icfItem.intARItemId, iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription, iicItem.strShortName, iicItem.strItemNo, 
                                                         icfItem.strProductNumber, iicItemPricing.dblAverageCost, icfItem.strProductDescription, icfItem.ysnIncludeInQuantityDiscount, icfNetwork.ysnPostForeignSales, icfNetwork.intCustomerId, iemEnt.strName, iemEnt.strEntityNo
														 ,cfAcct.intAccountId
                                FROM         dbo.tblCFSite AS icfSite 
								INNER JOIN dbo.tblCFNetwork AS icfNetwork 
                                  ON icfNetwork.intNetworkId = 
                                     icfSite.intNetworkId 
                          LEFT JOIN tblEMEntity iemEnt 
                                 ON iemEnt.intEntityId = 
                                    icfNetwork.intCustomerId 
                          LEFT JOIN tblARCustomer iarCus 
                                 ON iarCus.intEntityId = 
                                    iemEnt.intEntityId 
                          LEFT JOIN tblCFAccount cfAcct 
                                 ON iarCus.intEntityId = 
                                    cfAcct.intCustomerId 
                          LEFT JOIN tblCFInvoiceCycle cfInvCycle 
                                 ON cfAcct.intInvoiceCycle = 
                                    cfInvCycle.intInvoiceCycleId 
                          LEFT JOIN tblEMEntityLocation arBillTo 
                                 ON arBillTo.intEntityLocationId = 
                                    iarCus.intBillToId 
                          INNER JOIN dbo.tblCFItem AS icfItem 
                                  ON icfSite.intSiteId = icfItem.intSiteId 
                                      OR icfNetwork.intNetworkId = 
                                         icfItem.intNetworkId 
                          INNER JOIN dbo.tblICItem AS iicItem 
                                  ON icfItem.intARItemId = iicItem.intItemId 
                          LEFT OUTER JOIN dbo.tblICItemLocation AS iicItemLoc 
                                       ON iicItemLoc.intLocationId = 
                                          icfSite.intARLocationId 
                                          AND iicItemLoc.intItemId = 
                                              icfItem.intARItemId 
                          LEFT JOIN tblICItemPricing iicItemPricing 
                                 ON iicItemPricing.intItemId = icfItem.intARItemId 
                                    and iicItemPricing.intItemLocationId = 
                                        icfSite.intARLocationId 
                          LEFT JOIN tblICItemUOM ItemUOM 
                                 ON ItemUOM.intItemId = icfItem.intARItemId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND 
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId AND cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId 
WHERE     (cfTrans.ysnPosted = 1)
GO


