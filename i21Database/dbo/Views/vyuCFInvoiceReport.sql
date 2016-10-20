CREATE VIEW dbo.vyuCFInvoiceReport
AS
SELECT   ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, arInv.intTransactionId, arInv.strCustomerNumber, cfTrans.dtmTransactionDate, 
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
                                 ORDER BY dtmTransactionDate DESC), 0) ELSE 0 END) AS dblTotalMiles, arInv.strShipTo, arInv.strBillTo, arInv.strCompanyName, arInv.strCompanyAddress, 
                         arInv.strType, arInv.strCustomerName, arInv.strLocationName, arInv.intInvoiceId, arInv.strInvoiceNumber, arInv.dtmDate, arInv.dtmPostDate AS dtmPostedDate, 
                         cfTrans.intProductId, cfTrans.intCardId, cfTrans.intTransactionId AS EXPR18, cfTrans.strTransactionId, cfTrans.strTransactionType, cfTrans.strInvoiceReportNumber, 
                         cfTrans.dblQuantity, cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfCardAccount.strName, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, 
                         cfCardAccount.strNetwork, cfCardAccount.intInvoiceCycle, cfCardAccount.strInvoiceCycle, cfCardAccount.strPrimarySortOptions, 
                         cfCardAccount.strSecondarySortOptions, cfCardAccount.strPrintRemittancePage, cfCardAccount.strPrintPricePerGallon, cfCardAccount.ysnPrintMiscellaneous, 
                         cfCardAccount.strPrintSiteAddress, cfCardAccount.ysnSummaryByCard, cfCardAccount.ysnSummaryByDepartment, cfCardAccount.ysnSummaryByMiscellaneous, 
                         cfCardAccount.ysnSummaryByProduct, cfCardAccount.ysnSummaryByVehicle, cfCardAccount.ysnPrintTimeOnInvoices, cfCardAccount.ysnPrintTimeOnReports, 
                         cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, cfSiteItem.strItemNo, cfSiteItem.strShortName AS strDescription, 
                         cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
                         cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, 
                         cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, 
                         cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted, cfVehicle.strVehicleNumber, 
                         cfVehicle.strVehicleDescription, cfSiteItem.strTaxState, cfDep.strDepartment, cfSiteItem.strSiteType, cfSiteItem.strTaxState AS strState, cfSiteItem.strSiteAddress, 
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
                                GROUP BY cfTT.intTransactionId) / cfTrans.dblQuantity AS dblTaxExceptSST, cfTrans.strPrintTimeStamp
FROM         dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON arInv.intEntityCustomerId = cfCardAccount.intCustomerId AND cfTrans.intCardId = cfCardAccount.intCardId LEFT OUTER JOIN
                             (SELECT   arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, 
                                                         arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, arCustGroupDetail.ysnVolumeDiscount, 
                                                         arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                                FROM         dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                                                         dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON 
                         emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 INNER JOIN
                         dbo.vyuCFSiteItem AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND 
                         cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId LEFT OUTER JOIN
                         dbo.tblCFDepartment AS cfDep ON cfDep.intDepartmentId = cfCardAccount.intCardId
WHERE     (cfTrans.ysnPosted = 1)


