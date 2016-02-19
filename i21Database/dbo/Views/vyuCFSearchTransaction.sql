CREATE VIEW dbo.vyuCFSearchTransaction
AS
SELECT        cfVehicle.strVehicleNumber, cfTransaction.intOdometer, cfTransaction.intPumpNumber, cfTransaction.strPONumber, cfTransaction.strMiscellaneous, cfTransaction.strDeliveryPickupInd, 
                         cfTransaction.intTransactionId, cfTransaction.dtmBillingDate, cfTransaction.intTransTime, cfTransaction.strSequenceNumber, cfSite.strLocationName AS strCompanyLocation, cfTransaction.strTransactionId, 
                         cfTransaction.dtmTransactionDate, cfTransaction.strTransactionType, cfTransaction.dblQuantity, cfCard.strCustomerNumber, cfCard.strName, cfCard.strCardNumber, cfCard.strCardDescription, 
                         cfNetwork.strNetwork, cfSite.strSiteNumber, cfSite.strSiteName, cfItem.strProductNumber, cfItem.strItemNo, cfItem.strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, 
                         cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, 
                         cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfItem.dblAverageCost AS dblMargin, 
                         cfTransaction.ysnInvalid, cfTransaction.ysnPosted, tblCFTransactionTax_1.dblTaxCalculatedAmount, tblCFTransactionTax_1.dblTaxOriginalAmount
FROM            dbo.tblCFTransaction AS cfTransaction LEFT OUTER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTransaction.intNetworkId = cfNetwork.intNetworkId LEFT OUTER JOIN
                             (SELECT        smiCompanyLocation.strLocationName, cfiSite.intSiteId, cfiSite.intNetworkId, cfiSite.intTaxGroupId, cfiSite.strSiteNumber, cfiSite.intARLocationId, cfiSite.intCardId, cfiSite.strTaxState, 
                                                         cfiSite.strAuthorityId1, cfiSite.strAuthorityId2, cfiSite.ysnFederalExciseTax, cfiSite.ysnStateExciseTax, cfiSite.ysnStateSalesTax, cfiSite.ysnLocalTax1, cfiSite.ysnLocalTax2, cfiSite.ysnLocalTax3, 
                                                         cfiSite.ysnLocalTax4, cfiSite.ysnLocalTax5, cfiSite.ysnLocalTax6, cfiSite.ysnLocalTax7, cfiSite.ysnLocalTax8, cfiSite.ysnLocalTax9, cfiSite.ysnLocalTax10, cfiSite.ysnLocalTax11, 
                                                         cfiSite.ysnLocalTax12, cfiSite.intNumberOfLinesPerTransaction, cfiSite.intIgnoreCardID, cfiSite.strImportFileName, cfiSite.strImportPath, cfiSite.intNumberOfDecimalInPrice, 
                                                         cfiSite.intNumberOfDecimalInQuantity, cfiSite.intNumberOfDecimalInTotal, cfiSite.strImportType, cfiSite.strControllerType, cfiSite.ysnPumpCalculatesTaxes, cfiSite.ysnSiteAcceptsMajorCreditCards, 
                                                         cfiSite.ysnCenexSite, cfiSite.ysnUseControllerCard, cfiSite.intCashCustomerID, cfiSite.ysnProcessCashSales, cfiSite.ysnAssignBatchByDate, cfiSite.ysnMultipleSiteImport, cfiSite.strSiteName, 
                                                         cfiSite.strDeliveryPickup, cfiSite.strSiteAddress, cfiSite.strSiteCity, cfiSite.intPPHostId, cfiSite.strPPSiteType, cfiSite.ysnPPLocalPrice, cfiSite.intPPLocalHostId, cfiSite.strPPLocalSiteType, 
                                                         cfiSite.intPPLocalSiteId, cfiSite.intRebateSiteGroupId, cfiSite.intAdjustmentSiteGroupId, cfiSite.dtmLastTransactionDate, cfiSite.ysnEEEStockItemDetail, cfiSite.ysnRecalculateTaxesOnRemote, 
                                                         cfiSite.strSiteType, cfiSite.intCreatedUserId, cfiSite.dtmCreated, cfiSite.intLastModifiedUserId, cfiSite.dtmLastModified, cfiSite.intConcurrencyId, cfiSite.intImportMapperId
                               FROM            dbo.tblCFSite AS cfiSite LEFT OUTER JOIN
                                                         dbo.tblSMCompanyLocation AS smiCompanyLocation ON cfiSite.intARLocationId = smiCompanyLocation.intCompanyLocationId) AS cfSite ON 
                         cfTransaction.intSiteId = cfSite.intSiteId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTransaction.intVehicleId = cfVehicle.intVehicleId LEFT OUTER JOIN
                             (SELECT        cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost
                               FROM            dbo.tblCFItem AS cfiItem LEFT OUTER JOIN
                                                         dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
                                                         dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
                                                         dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND 
                                                         iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId) AS cfItem ON cfTransaction.intProductId = cfItem.intItemId LEFT OUTER JOIN
                             (SELECT        cfiAccount.intAccountId, cfiCustomer.strName, cfiCustomer.strCustomerNumber, cfiCustomer.intEntityCustomerId, cfiCard.intCardId, cfiCard.strCardNumber, cfiCard.strCardDescription
                               FROM            dbo.tblCFAccount AS cfiAccount INNER JOIN
                                                         dbo.tblCFCard AS cfiCard ON cfiCard.intAccountId = cfiAccount.intAccountId INNER JOIN
                                                         dbo.vyuCFCustomerEntity AS cfiCustomer ON cfiCustomer.intEntityCustomerId = cfiAccount.intCustomerId) AS cfCard ON cfTransaction.intCardId = cfCard.intCardId LEFT OUTER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTransaction.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                               WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                               WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT        intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount
                               FROM            dbo.tblCFTransactionTax AS tblCFTransactionTax
                               GROUP BY intTransactionId) AS tblCFTransactionTax_1 ON cfTransaction.intTransactionId = tblCFTransactionTax_1.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTransaction.intContractId = ctContracts.intContractDetailId

						
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchTransaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSite"
            Begin Extent = 
               Top = 6
               Left = 296
               Bottom = 136
               Right = 562
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfItem"
            Begin Extent = 
               Top = 6
               Left = 600
               Bottom = 136
               Right = 788
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCard"
            Begin Extent = 
               Top = 6
               Left = 826
               Bottom = 136
               Right = 1024
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCFTransactionTax_1"
            Begin Extent = 
               Top = 138
               Left = 355
               Bottom = 251
               Right = 579
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
         Begin Table = "cfTransaction"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfNetwork"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ctContracts"
            Begin Extent = 
               Top = 1722
               Left = 38
               Bottom = 1852
               Right = 315
          ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchTransaction';

