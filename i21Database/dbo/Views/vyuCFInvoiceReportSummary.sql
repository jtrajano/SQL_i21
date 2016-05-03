﻿CREATE VIEW dbo.vyuCFInvoiceReportSummary
AS
SELECT        cfCardAccount.strDepartment, cfCardAccount.intAccountId, cfTrans.intCardId, cfCardAccount.strCardNumber, cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, cfSiteItem.strProductDescription,
                          cfCardAccount.strCardDescription, cfTrans.strMiscellaneous, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
                         ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) - ISNULL(SUM(TotalTaxes.dblTaxCalculatedAmount), 0) AS dblTotalNetAmount, ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, 
                         ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, 
                         ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) AS TotalLC, ISNULL(SUM(TotalTaxes.dblTaxCalculatedAmount), 0) AS t
FROM            dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
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
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                               WHERE        (ismTaxClass.strTaxClass LIKE '%(FET)%') OR
                                                         (ismTaxClass.strTaxClass LIKE '%Federal Excise Tax%') OR
                                                         (ismTaxClass.strTaxClass = 'FET')) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                               WHERE        (ismTaxClass.strTaxClass LIKE '%(SET)%') OR
                                                         (ismTaxClass.strTaxClass LIKE '%State Excise Tax%') OR
                                                         (ismTaxClass.strTaxClass = 'SET')) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionTaxId, icfTramsactionTax.intTransactionId, ismTaxCode.strTaxCode AS strTransactionTaxId, icfTramsactionTax.dblTaxOriginalAmount, 
                                                         icfTramsactionTax.dblTaxCalculatedAmount, icfTramsactionTax.dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                               WHERE        (ismTaxClass.strTaxClass LIKE '%(SST)%') OR
                                                         (ismTaxClass.strTaxClass LIKE '%State Sales Tax%') OR
                                                         (ismTaxClass.strTaxClass = 'SST')) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) 
                                                         AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                               WHERE        (ismTaxClass.strTaxClass NOT LIKE '%(SET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Excise Tax%') AND (ismTaxClass.strTaxClass <> 'SET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(FET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%Federal Excise Tax%') AND (ismTaxClass.strTaxClass <> 'FET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(SST)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Sales Tax%') AND (ismTaxClass.strTaxClass <> 'SST')
                               GROUP BY icfTramsactionTax.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) 
                                                         AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                               GROUP BY icfTramsactionTax.intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId
GROUP BY cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfTrans.intProductId, cfTrans.intARItemId, 
                         cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, cfCardAccount.strDepartment