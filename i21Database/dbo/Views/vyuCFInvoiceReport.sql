CREATE VIEW dbo.vyuCFInvoiceReport
AS
SELECT        Inv.strShipTo, Inv.strBillTo, Inv.strCompanyName, Inv.strCompanyAddress, Inv.strType, Inv.strCustomerName, Inv.strLocationName, Inv.intInvoiceId, Inv.strInvoiceNumber, Inv.dtmDate, Inv.dtmPostDate, 
                         cfTrans.intProductId, cfTrans.intCardId, cfTrans.intTransactionId, cfTrans.strTransactionId, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfTrans.dblQuantity, cfCardAccount.intAccountId, 
                         cfCardAccount.strCustomerNumber, cfTrans.strMiscellaneous, cfCardAccount.strName, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfNetwork.strNetwork, cfCardAccount.intInvoiceCycle, 
                         cfCardAccount.strPrimarySortOptions, cfCardAccount.strSecondarySortOptions, cfCardAccount.strPrintRemittancePage, cfCardAccount.strPrintPricePerGallon, cfCardAccount.ysnPrintMiscellaneous, 
                         cfCardAccount.strPrintSiteAddress, cfCardAccount.ysnSummaryByCard, cfCardAccount.ysnSummaryByDepartment, cfCardAccount.ysnSummaryByMiscellaneous, cfCardAccount.ysnSummaryByProduct, 
                         cfCardAccount.ysnSummaryByVehicle, cfCardAccount.ysnPrintTimeOnInvoices, cfCardAccount.ysnPrintTimeOnReports, cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, 
                         cfSiteItem.strItemNo, cfSiteItem.strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
                         cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, 
                         cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted,
                             (SELECT        SUM(dblTaxCalculatedAmount) AS EXPR1
                               FROM            dbo.tblCFTransactionTax
                               WHERE        (intTransactionId = cfTrans.intTransactionId)) AS dblTotalTax
FROM            dbo.tblCFTransaction AS cfTrans INNER JOIN
                             (SELECT        icfCards.intCardId, icfAccount.intAccountId, icfAccount.intSalesPersonId, icfAccount.intCustomerId, icfAccount.intTermsCode, icfAccount.strCustomerNumber, icfAccount.strName, 
                                                         icfCards.strCardNumber, icfAccount.intInvoiceCycle, icfAccount.strPrimarySortOptions, icfAccount.strSecondarySortOptions, icfAccount.strPrintRemittancePage, icfAccount.strPrintPricePerGallon, 
                                                         icfAccount.ysnPrintMiscellaneous, icfAccount.strPrintSiteAddress, icfAccount.ysnSummaryByCard, icfAccount.ysnSummaryByDepartment, icfAccount.ysnSummaryByMiscellaneous, 
                                                         icfAccount.ysnSummaryByProduct, icfAccount.ysnSummaryByVehicle, icfAccount.ysnPrintTimeOnInvoices, icfAccount.ysnPrintTimeOnReports, icfCards.strCardDescription
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
                         AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTrans.intNetworkId = cfNetwork.intNetworkId INNER JOIN
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
                         cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                               WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                               WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId INNER JOIN
                             (SELECT        dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strShipToLocationName, INV.strShipToAddress, INV.strShipToCity, INV.strShipToState, INV.strShipToZipCode, INV.strShipToCountry, NULL) 
                                                         AS strShipTo, dbo.fnARFormatCustomerAddress(NULL, NULL, INV.strBillToLocationName, INV.strBillToAddress, INV.strBillToCity, INV.strBillToState, INV.strBillToZipCode, INV.strBillToCountry, 
                                                         E.strName) AS strBillTo, CASE WHEN L.strUseLocationAddress = 'Letterhead' THEN '' ELSE
                                                             (SELECT        TOP 1 strCompanyName
                                                               FROM            tblSMCompanySetup) END AS strCompanyName, CASE WHEN L.strUseLocationAddress IS NULL OR
                                                         L.strUseLocationAddress = 'No' OR
                                                         L.strUseLocationAddress = '' OR
                                                         L.strUseLocationAddress = 'Always' THEN
                                                             (SELECT        TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL)
                                                               FROM            tblSMCompanySetup) WHEN L.strUseLocationAddress = 'Yes' THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, L.strAddress, L.strCity, L.strStateProvince, 
                                                         L.strZipPostalCode, L.strCountry, NULL) WHEN L.strUseLocationAddress = 'Letterhead' THEN '' END AS strCompanyAddress, ISNULL(INV.strType, 'Standard') AS strType, 
                                                         E.strName AS strCustomerName, L.strLocationName, INV.intInvoiceId, INV.strInvoiceNumber, INV.intTransactionId, INV.dtmDate, INV.dtmPostDate
                               FROM            dbo.tblARInvoice AS INV INNER JOIN
                                                         dbo.tblARCustomer AS C INNER JOIN
                                                         dbo.tblEntity AS E ON C.intEntityCustomerId = E.intEntityId ON C.intEntityCustomerId = INV.intEntityCustomerId INNER JOIN
                                                         dbo.tblSMCompanyLocation AS L ON INV.intCompanyLocationId = L.intCompanyLocationId) AS Inv ON Inv.intTransactionId = cfTrans.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ctContracts"
            Begin Extent = 
               Top = 138
               Left = 526
               Bottom = 268
               Right = 803
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Inv"
            Begin Extent = 
               Top = 138
               Left = 841
               Bottom = 268
               Right = 1037
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCardAccount"
            Begin Extent = 
               Top = 6
               Left = 296
               Bottom = 136
               Right = 542
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfNetwork"
            Begin Extent = 
               Top = 6
               Left = 580
               Bottom = 136
               Right = 859
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 6
               Left = 897
               Bottom = 136
               Right = 1163
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 6
               Left = 1201
               Bottom = 136
               Right = 1407
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 138
               Left = 282
               Bottom = 268
               Right = 488
            End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';

