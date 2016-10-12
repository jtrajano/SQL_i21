CREATE VIEW dbo.vyuCFBatchPostTransactions
AS
SELECT        cfTrans.dtmTransactionDate, cfTrans.strTransactionId, 'Card Fueling' AS strTransactionType, cfTrans.ysnPosted, 
                         'Network: ' + cfNetwork.strNetwork + ' ,Site: ' + cfSiteItem.strSiteName + ' ,Quantity: ' + CAST(cfTrans.dblQuantity AS nvarchar) AS strDescription, cfTransPrice.dblCalculatedAmount AS dblAmount, 
                         cfTrans.intTransactionId,
                             (SELECT        TOP (1) intEntityId
                               FROM            dbo.tblEMEntity) AS intEntityId
FROM         dbo.tblCFTransaction AS cfTrans INNER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTrans.intNetworkId = cfNetwork.intNetworkId INNER JOIN
                             (SELECT   icfCards.intCardId, icfAccount.intAccountId, icfAccount.intSalesPersonId, icfAccount.intCustomerId, icfAccount.intTermsCode, icfCards.strCardNumber
                                FROM         dbo.tblCFCard AS icfCards INNER JOIN
                                                         dbo.tblCFAccount AS icfAccount ON icfCards.intAccountId = icfAccount.intAccountId) AS cfCardAccount ON 
                         cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                             (SELECT   icfSite.intSiteId, icfSite.intNetworkId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, icfSite.strAuthorityId1, 
                                                         icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, icfSite.ysnLocalTax2, 
                                                         icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, icfSite.ysnLocalTax9, 
                                                         icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, icfSite.strImportFileName, 
                                                         icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, icfSite.strImportType, 
                                                         icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, icfSite.ysnUseControllerCard, 
                                                         icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, icfSite.strSiteName, 
                                                         icfSite.strDeliveryPickup, icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, icfSite.intPPLocalHostId, 
                                                         icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, icfSite.intAdjustmentSiteGroupId, icfSite.dtmLastTransactionDate, 
                                                         icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, icfSite.dtmCreated, 
                                                         icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, icfItem.intARItemId, 
                                                         icfSite.intTaxGroupId, iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription
                                FROM         dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId INNER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId) AS cfSiteItem ON 
                         (cfTrans.intSiteId = cfSiteItem.intSiteId OR
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId) AND cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId
WHERE     NOT ((1 = cfTrans.[ysnPosted]) AND (cfTrans.[ysnPosted] IS NOT NULL))
