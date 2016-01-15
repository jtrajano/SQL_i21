CREATE VIEW dbo.vyuCFInvoiceReportSummary
AS
SELECT        cfCardAccount.strDepartment, cfCardAccount.intAccountId, cfTrans.intCardId, cfCardAccount.strCardNumber, cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, cfSiteItem.strProductDescription,
                          cfCardAccount.strCardDescription, cfTrans.strMiscellaneous, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
                         ISNULL(SUM(cfTransNetPrice.dblCalculatedAmount), 0) AS dblTotalNetAmount, ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalLC
FROM            dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON arInv.intEntityCustomerId = cfCardAccount.intCustomerId INNER JOIN
                         dbo.vyuCFSiteItem AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                               WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                               WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax
                               WHERE        (strTransactionTaxId = 'FET')) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_3
                               WHERE        (strTransactionTaxId = 'SET')) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_2
                               WHERE        (strTransactionTaxId = 'SST')) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 0) 
                                                         AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_1
                               WHERE        (strTransactionTaxId LIKE 'LC%')
                               GROUP BY intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId
GROUP BY cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfTrans.intProductId, cfTrans.intARItemId, 
                         cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, cfCardAccount.strDepartment