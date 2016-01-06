CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT        cfVehicle.strVehicleNumber, cfTrans.intOdometer, cfTrans.intPumpNumber, cfTrans.strPONumber, cfTrans.strMiscellaneous, cfTrans.strDeliveryPickupInd, cfTrans.intTransactionId, cfTrans.dtmBillingDate, 
                         cfTrans.intTransTime, cfTrans.strSequenceNumber, cfSiteItem.strLocationName AS strCompanyLocation, cfTrans.strTransactionId, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfTrans.dblQuantity, 
                         cfCardAccount.strCustomerNumber, cfCardAccount.strName, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfNetwork.strNetwork, cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, 
                         cfSiteItem.strProductNumber, cfSiteItem.strItemNo, cfSiteItem.strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, 
                         cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, 
                         cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted, 
                         FETTaxes.dblTaxCalculatedAmount AS FETTaxes, SETTaxes.dblTaxCalculatedAmount AS SETTaxes, SSTTaxes.dblTaxCalculatedAmount AS SSTTaxes, LCTaxes.dblTaxCalculatedAmount AS LCTaxes, 
                         TotalTaxes.dblTaxCalculatedAmount AS TotalTaxes
FROM            dbo.tblCFTransaction AS cfTrans LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
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
                             (SELECT        ismCompLoc.strLocationName, icfSite.intSiteId, icfSite.intNetworkId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, icfSite.strAuthorityId1, icfSite.strAuthorityId2, 
                                                         icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, 
                                                         icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, 
                                                         icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, 
                                                         icfSite.intNumberOfDecimalInTotal, icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, 
                                                         icfSite.ysnUseControllerCard, icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, icfSite.strSiteName, icfSite.strDeliveryPickup, 
                                                         icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, 
                                                         icfSite.intRebateSiteGroupId, icfSite.intAdjustmentSiteGroupId, icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, 
                                                         icfSite.intCreatedUserId, icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, icfItem.intARItemId, 
                                                         icfItem.intTaxGroupMaster, iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription, icfItem.strProductNumber, iicItem.strItemNo, iicItemPricing.dblAmountPercent, 
                                                         iicItemPricing.dblAverageCost
                               FROM            dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblSMCompanyLocation AS ismCompLoc ON ismCompLoc.intCompanyLocationId = icfSite.intARLocationId INNER JOIN
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
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax
                               WHERE        (strTransactionTaxId = 'FET')) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_4
                               WHERE        (strTransactionTaxId = 'SET')) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionTaxId, intTransactionId, strTransactionTaxId, dblTaxOriginalAmount, dblTaxCalculatedAmount, intConcurrencyId, strCalculationMethod, dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_3
                               WHERE        (strTransactionTaxId = 'SST')) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 0) 
                                                         AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_2
                               GROUP BY intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(dblTaxRate), 0) 
                                                         AS dblTaxRate
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax_1
                               WHERE        (strTransactionTaxId LIKE 'LC%')
                               GROUP BY intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchTransaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'd
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 870
               Left = 353
               Bottom = 1000
               Right = 582
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 870
               Left = 620
               Bottom = 1000
               Right = 886
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes"
            Begin Extent = 
               Top = 6
               Left = 296
               Bottom = 136
               Right = 520
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes"
            Begin Extent = 
               Top = 6
               Left = 558
               Bottom = 136
               Right = 782
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes"
            Begin Extent = 
               Top = 6
               Left = 820
               Bottom = 136
               Right = 1044
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TotalTaxes"
            Begin Extent = 
               Top = 6
               Left = 1082
               Bottom = 136
               Right = 1306
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes"
            Begin Extent = 
               Top = 138
               Left = 274
               Bottom = 268
               Right = 498
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchTransaction';


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
               Top = 138
               Left = 38
               Bottom = 268
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfNetwork"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ctContracts"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 315
            En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchTransaction';

