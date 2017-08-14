﻿
CREATE VIEW [dbo].[vyuCFInvoiceReport]
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
		THEN cfSiteItem.intCustomerId

		ELSE cfCardAccount.intAccountId
	END),

strCustomerName = (	
	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.strName

		ELSE arInv.strCustomerName
	END),

strCustomerNumber = (	
	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.strEntityNo

		ELSE arInv.strCustomerNumber
	END),


strBillTo = (	
	CASE cfTrans.strTransactionType 
		WHEN 'Foreign Sale' 
		THEN cfSiteItem.strBillTo

		ELSE arInv.strBillTo
	END),




cfSiteItem.strNetwork,

ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, cfTrans.intTransactionId, cfTrans.dtmTransactionDate, 
						DATEADD(dd, DATEDIFF(dd, 0, cfTrans.dtmInvoiceDate), 0) AS dtmInvoiceDate,
                         cfTrans.intOdometer, ISNULL
                             ((SELECT   TOP (1) intOdometer
                                 FROM         dbo.tblCFTransaction
                                 WHERE     (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intVehicleId = cfTrans.intVehicleId) AND 
                                                           (intProductId = cfTrans.intProductId)
                                 ORDER BY dtmTransactionDate DESC), 0) AS intOdometerAging, (CASE WHEN (ISNULL
                             ((SELECT   TOP (1) intOdometer
                                 FROM         dbo.tblCFTransaction AS tblCFTransaction_1
                                 WHERE     (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intCardId = cfTrans.intCardId) AND 
                                                           (intVehicleId = cfTrans.intVehicleId) AND (intProductId = cfTrans.intProductId)
                                 ORDER BY dtmTransactionDate DESC), 0)) > 0 THEN cfTrans.intOdometer - ISNULL
                             ((SELECT   TOP (1) intOdometer
                                 FROM         dbo.tblCFTransaction AS tblCFTransaction_1
                                 WHERE     (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intCardId = cfTrans.intCardId) AND 
                                                           (intVehicleId = cfTrans.intVehicleId) AND (intProductId = cfTrans.intProductId)
                                 ORDER BY dtmTransactionDate DESC), 0) ELSE 0 END) AS dblTotalMiles, arInv.strShipTo, arInv.strCompanyName, arInv.strCompanyAddress, 
                         arInv.strType, arInv.strLocationName, arInv.intInvoiceId, arInv.strInvoiceNumber, arInv.dtmDate, arInv.dtmPostDate AS dtmPostedDate, 
                         cfTrans.intProductId, cfTrans.intCardId, cfTrans.intTransactionId AS EXPR18, cfTrans.strTransactionId, cfTrans.strTransactionType, cfTrans.strInvoiceReportNumber, 
                         cfTrans.strTempInvoiceReportNumber, cfTrans.dblQuantity, cfTrans.strMiscellaneous, cfCardAccount.strName, cfCardAccount.strCardNumber,
                          cfCardAccount.strCardDescription, cfCardAccount.intInvoiceCycle, cfCardAccount.strInvoiceCycle, cfCardAccount.strPrimarySortOptions, 
                         cfCardAccount.strSecondarySortOptions, cfCardAccount.strPrintRemittancePage, cfCardAccount.strPrintPricePerGallon, cfCardAccount.ysnPrintMiscellaneous, 
                         cfCardAccount.strPrintSiteAddress, cfCardAccount.ysnSummaryByCard, cfCardAccount.ysnSummaryByDepartment, cfCardAccount.ysnSummaryByMiscellaneous, 
                         cfCardAccount.ysnSummaryByProduct, cfCardAccount.ysnSummaryByVehicle, cfCardAccount.ysnSummaryByCardProd,cfCardAccount.ysnSummaryByDeptCardProd, cfCardAccount.ysnPrintTimeOnInvoices, cfCardAccount.ysnPrintTimeOnReports, 
                         cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, cfSiteItem.strItemNo, cfSiteItem.strShortName AS strDescription, 
                         ROUND(cfTransPrice.dblCalculatedAmount,2) AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
                         cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, 
                         cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, 
                         cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted, cfVehicle.strVehicleNumber, 
                         cfVehicle.strVehicleDescription, cfSiteItem.strTaxState, cfDep.strDepartment, cfSiteItem.strSiteType, cfSiteItem.strTaxState AS strState, cfSiteItem.strSiteAddress, 
                         cfSiteItem.ysnPostForeignSales,
						 cfSiteItem.strSiteCity,
                             (SELECT   SUM(dblTaxCalculatedAmount) AS dblTotalTax
                                FROM         dbo.tblCFTransactionTax
                                WHERE     (intTransactionId = cfTrans.intTransactionId)) / cfTrans.dblQuantity AS dblTotalTax,
                             (SELECT   ISNULL(SUM(cfTT.dblTaxCalculatedAmount), 0) AS dblTotalSST
                                FROM         dbo.tblCFTransactionTax AS cfTT INNER JOIN
                                                         dbo.tblSMTaxCode AS smTCd ON cfTT.intTaxCodeId = smTCd.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS smTCl ON smTCd.intTaxClassId = smTCl.intTaxClassId
                                WHERE     (smTCl.strTaxClass LIKE '%(SST)%') AND (smTCl.strTaxClass LIKE '%State Sales Tax%') AND (cfTT.intTransactionId = cfTrans.intTransactionId)
                                GROUP BY cfTT.intTransactionId) / cfTrans.dblQuantity AS dblTotalSST,
                             (SELECT   ISNULL(SUM(cfTT.dblTaxCalculatedAmount), 0) AS dblTaxExceptSST
                                FROM         dbo.tblCFTransactionTax AS cfTT INNER JOIN
                                                         dbo.tblSMTaxCode AS smTCd ON cfTT.intTaxCodeId = smTCd.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS smTCl ON smTCd.intTaxClassId = smTCl.intTaxClassId
                                WHERE     (smTCl.strTaxClass NOT LIKE '%(SST)%') AND (smTCl.strTaxClass NOT LIKE '%State Sales Tax%') AND (smTCl.strTaxClass <> 'SST') AND 
                                                         (cfTT.intTransactionId = cfTrans.intTransactionId)
                                GROUP BY cfTT.intTransactionId) / cfTrans.dblQuantity AS dblTaxExceptSST, cfTrans.strPrintTimeStamp, 
                         cfCardAccount.strEmailDistributionOption, cfCardAccount.strEmail
FROM         dbo.vyuCFInvoice AS arInv RIGHT OUTER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON arInv.intEntityCustomerId = cfCardAccount.intCustomerId AND cfTrans.intCardId = cfCardAccount.intCardId LEFT OUTER JOIN
                             (SELECT   arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, 
                                                         arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, arCustGroupDetail.ysnVolumeDiscount, 
                                                         arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                                FROM         dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                                                         dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON 
                         emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 INNER JOIN
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
                                                         icfItem.strProductNumber, iicItemPricing.dblAverageCost, icfNetwork.ysnPostForeignSales, icfNetwork.intCustomerId, iemEnt.strName, iemEnt.strEntityNo, icfNetwork.strNetwork
														 ,[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, arBillTo.strAddress, arBillTo.strCity, arBillTo.strState, arBillTo.strZipCode, arBillTo.strCountry, NULL, 0) AS strBillTo
														 
                                FROM         dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId LEFT JOIN 
														 tblEMEntity iemEnt ON iemEnt.intEntityId = icfNetwork.intCustomerId 
														 INNER JOIN tblARCustomer iarCus ON iarCus.intEntityCustomerId = iemEnt.intEntityId
														 LEFT JOIN tblEMEntityLocation arBillTo ON arBillTo.intEntityLocationId = iarCus.intBillToId
														 INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                                                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                                                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND 
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId AND cfSiteItem.intItemId = cfTrans.intProductId CROSS APPLY
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount') AND cfTrans.intTransactionId = intTransactionId) AS cfTransPrice CROSS APPLY
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price') AND cfTrans.intTransactionId = intTransactionId) AS cfTransGrossPrice CROSS APPLY
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price') AND cfTrans.intTransactionId = intTransactionId) AS cfTransNetPrice LEFT OUTER JOIN
                         dbo.tblCFDepartment AS cfDep ON cfDep.intDepartmentId = cfCardAccount.intDepartmentId
WHERE     (cfTrans.ysnPosted = 1)
--GO
GO


