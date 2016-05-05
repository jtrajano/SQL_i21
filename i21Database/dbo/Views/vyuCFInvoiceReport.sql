﻿CREATE VIEW dbo.vyuCFInvoiceReport
AS
SELECT        arInv.intTransactionId, arInv.strCustomerNumber, arInv.strShipTo, arInv.strBillTo, arInv.strCompanyName, arInv.strCompanyAddress, arInv.strType, arInv.strCustomerName, arInv.strLocationName, 
                         arInv.intInvoiceId, arInv.strInvoiceNumber, arInv.dtmDate, arInv.dtmPostDate, cfTrans.intProductId, cfTrans.intCardId, cfTrans.intTransactionId AS EXPR18, cfTrans.strTransactionId, cfTrans.dtmTransactionDate, 
                         cfTrans.strTransactionType, cfTrans.strInvoiceReportNumber, cfTrans.dblQuantity, cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfCardAccount.strName, cfCardAccount.strCardNumber, 
                         cfCardAccount.strCardDescription, cfCardAccount.strNetwork, cfCardAccount.intInvoiceCycle, cfCardAccount.strInvoiceCycle, cfCardAccount.strPrimarySortOptions, cfCardAccount.strSecondarySortOptions, 
                         cfCardAccount.strPrintRemittancePage, cfCardAccount.strPrintPricePerGallon, cfCardAccount.ysnPrintMiscellaneous, cfCardAccount.strPrintSiteAddress, cfCardAccount.ysnSummaryByCard, 
                         cfCardAccount.ysnSummaryByDepartment, cfCardAccount.ysnSummaryByMiscellaneous, cfCardAccount.ysnSummaryByProduct, cfCardAccount.ysnSummaryByVehicle, cfCardAccount.ysnPrintTimeOnInvoices, 
                         cfCardAccount.ysnPrintTimeOnReports, cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, cfSiteItem.strItemNo, cfSiteItem.strShortName AS strDescription, 
                         cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, 
                         cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, 
                         cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted, cfVehicle.strVehicleNumber, cfVehicle.strVehicleDescription,
                             (SELECT        SUM(dblTaxCalculatedAmount) AS EXPR1
                               FROM            dbo.tblCFTransactionTax
                               WHERE        (intTransactionId = cfTrans.intTransactionId)) AS dblTotalTax, cfTrans.intOdometer
FROM            dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId LEFT JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON arInv.intEntityCustomerId = cfCardAccount.intCustomerId AND cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
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
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId