CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT   cfVehicle.strVehicleNumber, cfTransaction.intOdometer, cfTransaction.intPumpNumber, cfTransaction.strPONumber, cfTransaction.strMiscellaneous, 
                         cfTransaction.strDeliveryPickupInd, cfTransaction.intTransactionId, cfTransaction.dtmBillingDate, cfTransaction.intTransTime, cfTransaction.strSequenceNumber, 
                         cfSite.strLocationName AS strCompanyLocation, cfTransaction.strTransactionId, cfTransaction.dtmTransactionDate, cfTransaction.strTransactionType, 
                         cfTransaction.dblQuantity, cfCard.strCustomerNumber, cfCard.strName, cfCard.strCardNumber, cfCard.strCardDescription, cfNetwork.strNetwork, cfSite.strSiteNumber, 
                         cfSite.strSiteName, cfItem.strProductNumber, cfItem.strItemNo, cfItem.strDescription, ROUND(cfTransPrice.dblCalculatedAmount,2) AS dblCalculatedTotalAmount, 
                         cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, 
                         cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, 
                         cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransaction.ysnInvalid, cfTransaction.ysnPosted, tblCFTransactionTax_1.dblTaxCalculatedAmount, 
                         tblCFTransactionTax_1.dblTaxOriginalAmount, ctContracts.strContractNumber, cfTransaction.strPriceMethod, cfTransaction.strPriceBasis, cfTransaction.dblTransferCost, 
                         ISNULL(CASE WHEN cfTransaction.strTransactionType = 'Local/Network' THEN CASE WHEN cfTransaction.ysnPosted = 1 THEN cfTransNetPrice.dblCalculatedAmount - arSalesAnalysisReport.dblUnitCost
                          ELSE cfTransNetPrice.dblCalculatedAmount - cfItem.dblAverageCost END ELSE cfTransGrossPrice.dblCalculatedAmount - cfTransaction.dblTransferCost END, 0) 
                         AS dblMargin, cfCard.intEntityCustomerId, cfTransaction.dtmInvoiceDate, cfTransaction.strInvoiceReportNumber
FROM         dbo.tblCFTransaction AS cfTransaction LEFT OUTER JOIN
                         dbo.tblARInvoice AS arInvoice ON cfTransaction.intInvoiceId = arInvoice.intInvoiceId LEFT OUTER JOIN
                         dbo.vyuARSalesAnalysisReport AS arSalesAnalysisReport ON arInvoice.intInvoiceId = arSalesAnalysisReport.intTransactionId 
						 AND arInvoice.strInvoiceNumber = arSalesAnalysisReport.strRecordNumber LEFT OUTER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTransaction.intNetworkId = cfNetwork.intNetworkId LEFT OUTER JOIN
                             (SELECT   smiCompanyLocation.strLocationName, cfiSite.intSiteId, cfiSite.strSiteNumber, cfiSite.strSiteName
                                FROM         dbo.tblCFSite AS cfiSite LEFT OUTER JOIN
                                                         dbo.tblSMCompanyLocation AS smiCompanyLocation ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId) AS cfSite ON 
                         cfTransaction.intSiteId = cfSite.intSiteId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTransaction.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
                             (SELECT   cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost, 
                                                         iciItemPricing.dblStandardCost
                                FROM         dbo.tblCFItem AS cfiItem LEFT OUTER JOIN
                                                         dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
                                                         dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND 
                                                         iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
                                                         dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND 
                                                         iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId AND iciItemLocation.intIssueUOMId = iciItemPricing.intUnitMeasureId) AS cfItem ON 
                         cfTransaction.intProductId = cfItem.intItemId LEFT OUTER JOIN
                             (SELECT   cfiAccount.intAccountId, cfiCustomer.strName, cfiCustomer.strCustomerNumber, cfiCustomer.intEntityCustomerId, cfiCard.intCardId, cfiCard.strCardNumber, 
                                                         cfiCard.strCardDescription
                                FROM         dbo.tblCFAccount AS cfiAccount INNER JOIN
                                                         dbo.tblCFCard AS cfiCard ON cfiCard.intAccountId = cfiAccount.intAccountId INNER JOIN
                                                         dbo.vyuCFCustomerEntity AS cfiCustomer ON cfiCustomer.intEntityCustomerId = cfiAccount.intCustomerId) AS cfCard ON 
                         cfTransaction.intCardId = cfCard.intCardId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
                                FROM         dbo.tblCFTransactionTax AS tblCFTransactionTax
                                GROUP BY intTransactionId) AS tblCFTransactionTax_1 ON cfTransaction.intTransactionId = tblCFTransactionTax_1.intTransactionId LEFT OUTER JOIN
                         dbo.tblCTContractHeader AS ctContracts ON cfTransaction.intContractId = ctContracts.intContractHeaderId
GO
