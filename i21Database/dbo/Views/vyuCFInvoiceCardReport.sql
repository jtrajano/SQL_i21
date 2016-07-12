CREATE VIEW dbo.vyuCFInvoiceCardReport
AS
SELECT        cfCard.intAccountId, cfTrans.intCardId, cfCard.strCardNumber, cfTrans.intProductId, cfTrans.intARItemId, cfItem.strProductNumber, cfItem.strProductDescription, cfCard.strCardDescription, 
                         cfTrans.strMiscellaneous, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
                         ISNULL(SUM(cfTransNetPrice.dblCalculatedAmount), 0) AS dblTotalNetAmount, ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalLC
FROM            dbo.tblCFTransaction AS cfTrans INNER JOIN
                         dbo.vyuCFInvoiceReport AS main ON main.intTransactionId = cfTrans.intTransactionId INNER JOIN
                         dbo.tblCFCard AS cfCard ON cfTrans.intCardId = cfCard.intCardId INNER JOIN
                             (SELECT        icfItem.intItemId, icfItem.strProductNumber, icfItem.strProductDescription, icfItem.intARItemId, iicItem.strItemNo, iicItem.strDescription
                               FROM            dbo.tblCFItem AS icfItem INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId) AS cfItem ON cfItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                               WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                               WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId
                               WHERE        (ismTaxCode.strTaxCode = 'FET')) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId
                               WHERE        (ismTaxCode.strTaxCode = 'SET')) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId
                               WHERE        (ismTaxCode.strTaxCode = 'SST')) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) 
                                                         AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId
                               WHERE        (ismTaxCode.strTaxCode LIKE 'LC%')
                               GROUP BY icfTramsactionTax.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId
GROUP BY cfCard.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCard.strCardNumber, cfCard.strCardDescription, cfTrans.intProductId, cfTrans.intARItemId, cfItem.strProductNumber, 
                         cfItem.strProductDescription
