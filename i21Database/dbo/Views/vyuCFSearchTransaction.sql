CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT        cfTrans.intTransactionId, cfTrans.strTransactionId, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfTrans.dblQuantity, cfCardAccount.strCustomerNumber, cfCardAccount.strName, 
                         cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfNetwork.strNetwork, cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, cfSiteItem.strItemNo, 
                         cfSiteItem.strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
                         cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, 
                         cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted
FROM            dbo.tblCFTransaction AS cfTrans LEFT OUTER JOIN
                             (SELECT        icfCards.intCardId, icfAccount.intAccountId, icfAccount.intSalesPersonId, icfAccount.intCustomerId, icfAccount.intTermsCode, icfAccount.strCustomerNumber, icfAccount.strName, 
                                                         icfCards.strCardNumber, icfCards.strCardDescription
                               FROM            dbo.tblCFCard AS icfCards INNER JOIN
                                                             (SELECT        cfAccnt.intAccountId, cfAccnt.intCustomerId, cfAccnt.intDiscountDays, cfAccnt.intDiscountScheduleId, cfAccnt.intInvoiceCycle, cfAccnt.intSalesPersonId, 
                                                                                         cfAccnt.dtmBonusCommissionDate, cfAccnt.dblBonusCommissionRate, cfAccnt.dblRegularCommissionRate, cfAccnt.ysnPrintTimeOnInvoices, cfAccnt.ysnPrintTimeOnReports, 
                                                                                         cfAccnt.intTermsCode, cfAccnt.strBillingSite, cfAccnt.strPrimarySortOptions, cfAccnt.strSecondarySortOptions, cfAccnt.ysnSummaryByCard, cfAccnt.ysnSummaryByVehicle, 
                                                                                         cfAccnt.ysnSummaryByMiscellaneous, cfAccnt.ysnSummaryByProduct, cfAccnt.ysnSummaryByDepartment, cfAccnt.ysnVehicleRequire, cfAccnt.intAccountStatusCodeId, 
                                                                                         cfAccnt.strPrintRemittancePage, cfAccnt.strInvoiceProgramName, cfAccnt.intPriceRuleGroup, cfAccnt.strPrintPricePerGallon, cfAccnt.ysnPPTransferCostForRemote, 
                                                                                         cfAccnt.ysnPPTransferCostForNetwork, cfAccnt.ysnPrintMiscellaneous, cfAccnt.intFeeProfileId, cfAccnt.strPrintSiteAddress, cfAccnt.dtmLastBillingCycleDate, 
                                                                                         cfAccnt.intRemotePriceProfileId, cfAccnt.intExtRemotePriceProfileId, cfAccnt.intLocalPriceProfileId, cfAccnt.intCreatedUserId, cfAccnt.dtmCreated, cfAccnt.intLastModifiedUserId, 
                                                                                         cfAccnt.dtmLastModified, cfAccnt.intConcurrencyId, arCustomer.strCustomerNumber, arCustomer.strName
                                                               FROM            dbo.tblCFAccount AS cfAccnt INNER JOIN
                                                                                         dbo.vyuCFCustomerEntity AS arCustomer ON cfAccnt.intCustomerId = arCustomer.intEntityCustomerId) AS icfAccount ON icfCards.intAccountId = icfAccount.intAccountId) 
                         AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId LEFT OUTER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTrans.intNetworkId = cfNetwork.intNetworkId LEFT OUTER JOIN
                             (SELECT        icfSite.intSiteId, icfSite.intNetworkId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, icfSite.strAuthorityId1, icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, 
                                                         icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, 
                                                         icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, 
                                                         icfSite.intIgnoreCardID, icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, 
                                                         icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, icfSite.ysnUseControllerCard, 
                                                         icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, 
                                                         icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, 
                                                         icfSite.intAdjustmentSiteGroupId, icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, 
                                                         icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, icfItem.intARItemId, icfItem.intTaxGroupMaster, 
                                                         iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription, icfItem.strProductNumber, iicItem.strItemNo, iicItemPricing.dblAmountPercent, iicItemPricing.dblAverageCost
                               FROM            dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId INNER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                                                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                                                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND 
                         cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                               WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                               WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId