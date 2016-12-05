﻿

CREATE VIEW [dbo].[vyuCFInvoiceReportSummary]
AS
SELECT 
arInv.strCustomerName,
arInv.strCustomerNumber,
cfCardAccount.strCardNumber,
cfCardAccount.strCardDescription,
CASE WHEN cfCardAccount.strDepartment = '' OR cfCardAccount.strDepartment IS NULL THEN 'Unknown' ELSE cfCardAccount.strDepartment END AS strDepartment,
cfCardAccount.strDepartmentDescription,
CASE WHEN cfTrans.strMiscellaneous = '' OR cfTrans.strMiscellaneous IS NULL THEN 'Unknown' ELSE cfTrans.strMiscellaneous END AS strMiscellaneous,
CASE WHEN cfVehicle.strVehicleNumber = '' OR cfVehicle.strVehicleNumber IS NULL OR cfVehicle.strVehicleNumber = '0' THEN 'Unknown' ELSE cfVehicle.strVehicleNumber END AS strVehicleNumber,   
cfVehicle.strVehicleDescription,
cfSiteItem.strProductNumber, 
cfSiteItem.strProductDescription, 
cfSiteItem.strItemNo AS strItemNumber,
cfSiteItem.strDescription AS strItemDescription,
cfSiteItem.strSiteNumber,
cfSiteItem.strSiteAddress + ', ' + cfSiteItem.strSiteCity + ', ' + cfSiteItem.strTaxState AS strSiteAddress,
cfTrans.dtmTransactionDate, 
cfTrans.intOdometer,
ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity,
ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) - (ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount),  0)) AS dblTotalNetAmount,
ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, 
(ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount),  0)) AS dblTotalTaxAmount, 
cfTrans.strTransactionId,

cfCardAccount.intDiscountScheduleId, cfCardAccount.intTermsCode, cfCardAccount.intTermsId,  
             cfSiteItem.strTaxState, cfCardAccount.intAccountId, cfTrans.intCardId,  cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.ysnIncludeInQuantityDiscount, 
             ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) AS TotalLC, 
             cfTrans.intTransactionId,  cfCardAccount.strNetwork, arInv.dtmPostDate AS dtmPostedDate, cfCardAccount.strInvoiceCycle,cfTrans.strInvoiceReportNumber, 
             cfTrans.strPrintTimeStamp
FROM   dbo.vyuCFInvoice AS arInv INNER JOIN
             dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
             dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
             dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId 
			 INNER JOIN
             
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
                                                         icfItem.strProductNumber, iicItemPricing.dblAverageCost, icfItem.strProductDescription, icfItem.ysnIncludeInQuantityDiscount
                                FROM         dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                                                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                                                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND 
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId AND cfSiteItem.intItemId = cfTrans.intProductId 

			 LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice
                 WHERE (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                 WHERE (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                 WHERE (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId 

				 LEFT OUTER JOIN
                 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) 
				 AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 
                              0) AS dblTaxRate
                 FROM  vyuCFTransactionTax AS FETTaxes
                 WHERE (strTaxClass LIKE '%(FET)%') AND (strTaxClass LIKE '%Federal Excise Tax%')
                 GROUP BY FETTaxes.intTransactionId) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId 
				 
				 LEFT OUTER JOIN
                 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 
                              0) AS dblTaxRate
                 FROM  vyuCFTransactionTax AS SETTaxes
                 WHERE (strTaxClass LIKE '%(SET)%') AND (strTaxClass LIKE '%State Excise Tax%')
                 GROUP BY SETTaxes.intTransactionId) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId 
				 
				 LEFT OUTER JOIN
                 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    vyuCFTransactionTax AS SSTTaxes
                 WHERE (strTaxClass LIKE '%(SST)%') AND (strTaxClass LIKE '%State Sales Tax%')
                 GROUP BY SSTTaxes.intTransactionId) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId 
				 
				 LEFT OUTER JOIN
                 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    vyuCFTransactionTax AS LCTaxes
                 WHERE (strTaxClass NOT LIKE '%(SET)%') AND (strTaxClass NOT LIKE '%State Excise Tax%') AND (strTaxClass <> 'SET') AND (strTaxClass NOT LIKE '%(FET)%') AND 
                              (strTaxClass NOT LIKE '%Federal Excise Tax%') AND (strTaxClass <> 'FET') AND (strTaxClass NOT LIKE '%(SST)%') AND (strTaxClass NOT LIKE '%State Sales Tax%') AND (strTaxClass <> 'SST')
                 GROUP BY LCTaxes.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId

				 LEFT OUTER JOIN
				 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    vyuCFTransactionTax AS TotalTaxes
                 GROUP BY TotalTaxes.intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId
WHERE (cfTrans.ysnPosted = 1)
GROUP BY cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, 
             cfSiteItem.strProductDescription, cfCardAccount.strDepartment,cfCardAccount.strDepartmentDescription, cfSiteItem.strTaxState, cfSiteItem.ysnIncludeInQuantityDiscount, cfVehicle.strVehicleNumber, cfVehicle.strVehicleDescription, cfCardAccount.intDiscountScheduleId, cfCardAccount.intTermsCode, 
             cfCardAccount.intTermsId, cfTrans.intTransactionId, arInv.strCustomerName, cfCardAccount.strNetwork, arInv.dtmPostDate, cfCardAccount.strInvoiceCycle, cfTrans.dtmTransactionDate, cfTrans.strInvoiceReportNumber, cfTrans.strPrintTimeStamp,arInv.strCustomerNumber,cfSiteItem.strItemNo,cfSiteItem.strDescription,
			 cfSiteItem.strSiteNumber,cfSiteItem.strSiteAddress,cfSiteItem.strSiteCity,cfTrans.strTransactionId,cfTrans.intOdometer

