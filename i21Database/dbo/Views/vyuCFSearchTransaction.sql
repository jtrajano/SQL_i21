CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT cfVehicle.strVehicleNumber, cfTransaction.intOdometer, cfTransaction.intPumpNumber, cfTransaction.strPONumber, cfTransaction.strMiscellaneous, cfTransaction.strDeliveryPickupInd, cfTransaction.intTransactionId, cfTransaction.dtmBillingDate, 
             cfTransaction.intTransTime, cfTransaction.strSequenceNumber, cfSite.strLocationName AS strCompanyLocation, cfTransaction.strTransactionId, cfTransaction.dtmTransactionDate, cfTransaction.strTransactionType, cfTransaction.dblQuantity, 
             cfCard.strCustomerNumber, cfCard.strName, cfCard.strCardNumber, cfCard.strCardDescription, cfNetwork.strNetwork, cfSite.strSiteNumber, cfSite.strSiteName, cfItem.strProductNumber, cfItem.strItemNo, cfItem.strDescription, 
             cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, 
             cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransactionMargin.dblMargin, cfTransaction.ysnInvalid, cfTransaction.ysnPosted, tblCFTransactionTax_1.dblTaxCalculatedAmount, 
             tblCFTransactionTax_1.dblTaxOriginalAmount, ctContracts.strContractNumber, cfTransaction.strPriceMethod, cfTransaction.strPriceBasis, cfTransaction.dblTransferCost
FROM   dbo.tblCFTransaction AS cfTransaction INNER JOIN
             dbo.vyuCFTransactionMargin AS cfTransactionMargin ON cfTransaction.intTransactionId = cfTransactionMargin.intTransactionId LEFT OUTER JOIN
             dbo.tblCFNetwork AS cfNetwork ON cfTransaction.intNetworkId = cfNetwork.intNetworkId LEFT OUTER JOIN
                 (SELECT smiCompanyLocation.strLocationName, cfiSite.intSiteId, cfiSite.intNetworkId, cfiSite.intTaxGroupId, cfiSite.strSiteNumber, cfiSite.intARLocationId, cfiSite.intCardId, cfiSite.strTaxState, cfiSite.strAuthorityId1, cfiSite.strAuthorityId2, cfiSite.ysnFederalExciseTax, 
                              cfiSite.ysnStateExciseTax, cfiSite.ysnStateSalesTax, cfiSite.ysnLocalTax1, cfiSite.ysnLocalTax2, cfiSite.ysnLocalTax3, cfiSite.ysnLocalTax4, cfiSite.ysnLocalTax5, cfiSite.ysnLocalTax6, cfiSite.ysnLocalTax7, cfiSite.ysnLocalTax8, cfiSite.ysnLocalTax9, 
                              cfiSite.ysnLocalTax10, cfiSite.ysnLocalTax11, cfiSite.ysnLocalTax12, cfiSite.intNumberOfLinesPerTransaction, cfiSite.intIgnoreCardID, cfiSite.strImportFileName, cfiSite.strImportPath, cfiSite.intNumberOfDecimalInPrice, cfiSite.intNumberOfDecimalInQuantity, 
                              cfiSite.intNumberOfDecimalInTotal, cfiSite.strImportType, cfiSite.strControllerType, cfiSite.ysnPumpCalculatesTaxes, cfiSite.ysnSiteAcceptsMajorCreditCards, cfiSite.ysnCenexSite, cfiSite.ysnUseControllerCard, cfiSite.intCashCustomerID, 
                              cfiSite.ysnProcessCashSales, cfiSite.ysnAssignBatchByDate, cfiSite.ysnMultipleSiteImport, cfiSite.strSiteName, cfiSite.strDeliveryPickup, cfiSite.strSiteAddress, cfiSite.strSiteCity, cfiSite.intPPHostId, cfiSite.strPPSiteType, cfiSite.ysnPPLocalPrice, 
                              cfiSite.intPPLocalHostId, cfiSite.strPPLocalSiteType, cfiSite.intPPLocalSiteId, cfiSite.intRebateSiteGroupId, cfiSite.intAdjustmentSiteGroupId, cfiSite.dtmLastTransactionDate, cfiSite.ysnEEEStockItemDetail, cfiSite.ysnRecalculateTaxesOnRemote, 
                              cfiSite.strSiteType, cfiSite.intCreatedUserId, cfiSite.dtmCreated, cfiSite.intLastModifiedUserId, cfiSite.dtmLastModified, cfiSite.intConcurrencyId, cfiSite.intImportMapperId
                 FROM    dbo.tblCFSite AS cfiSite LEFT OUTER JOIN
                              dbo.tblSMCompanyLocation AS smiCompanyLocation ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId) AS cfSite ON cfTransaction.intSiteId = cfSite.intSiteId LEFT OUTER JOIN
             dbo.tblCFVehicle AS cfVehicle ON cfTransaction.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
                 (SELECT cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost, iciItemPricing.dblStandardCost
                 FROM    dbo.tblCFItem AS cfiItem LEFT OUTER JOIN
                              dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
                              dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
                              dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
                              dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId) AS cfItem ON 
             cfTransaction.intProductId = cfItem.intItemId LEFT OUTER JOIN
                 (SELECT cfiAccount.intAccountId, cfiCustomer.strName, cfiCustomer.strCustomerNumber, cfiCustomer.intEntityCustomerId, cfiCard.intCardId, cfiCard.strCardNumber, cfiCard.strCardDescription
                 FROM    dbo.tblCFAccount AS cfiAccount INNER JOIN
                              dbo.tblCFCard AS cfiCard ON cfiCard.intAccountId = cfiAccount.intAccountId INNER JOIN
                              dbo.vyuCFCustomerEntity AS cfiCustomer ON cfiCustomer.intEntityCustomerId = cfiAccount.intCustomerId) AS cfCard ON cfTransaction.intCardId = cfCard.intCardId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice
                 WHERE (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                 WHERE (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                 WHERE (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
                 FROM    dbo.tblCFTransactionTax AS tblCFTransactionTax
                 GROUP BY intTransactionId) AS tblCFTransactionTax_1 ON cfTransaction.intTransactionId = tblCFTransactionTax_1.intTransactionId LEFT OUTER JOIN
             dbo.vyuCTContractDetailView AS ctContracts ON cfTransaction.intContractId = ctContracts.intContractDetailId