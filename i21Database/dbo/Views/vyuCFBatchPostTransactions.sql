CREATE VIEW dbo.vyuCFBatchPostTransactions
AS
SELECT        cfTrans.dtmTransactionDate, cfTrans.strTransactionId, 'Card Fueling' AS strTransactionType, cfTrans.ysnPosted, 
                         'Network: ' + cfNetwork.strNetwork + ' ,Site: ' + cfSiteItem.strSiteName + ' ,Quantity: ' + CAST(cfTrans.dblQuantity AS nvarchar) AS strDescription, cfTransPrice.dblCalculatedAmount AS dblAmount, 
                         cfTrans.intTransactionId,
                             (SELECT        TOP (1) intEntityId
                               FROM            dbo.tblEMEntity) AS intEntityId
FROM            dbo.tblCFTransaction AS cfTrans INNER JOIN
                         dbo.tblCFNetwork AS cfNetwork ON cfTrans.intNetworkId = cfNetwork.intNetworkId INNER JOIN
                             (SELECT        icfCards.intCardId, icfAccount.intAccountId, icfAccount.intSalesPersonId, icfAccount.intCustomerId, icfAccount.intTermsCode, icfCards.strCardNumber
                               FROM            dbo.tblCFCard AS icfCards INNER JOIN
                                                         dbo.tblCFAccount AS icfAccount ON icfCards.intAccountId = icfAccount.intAccountId) AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                             (SELECT        icfSite.intSiteId, icfSite.intNetworkId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, icfSite.strAuthorityId1, icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, 
                                                         icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, 
                                                         icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, 
                                                         icfSite.intIgnoreCardID, icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, 
                                                         icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, icfSite.ysnUseControllerCard, 
                                                         icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, 
                                                         icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, 
                                                         icfSite.intAdjustmentSiteGroupId, icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, 
                                                         icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, icfItem.intARItemId, icfSite.intTaxGroupId, 
                                                         iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription
                               FROM            dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId INNER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId) AS cfSiteItem ON (cfTrans.intSiteId = cfSiteItem.intSiteId OR
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId) AND cfSiteItem.intARItemId = cfTrans.intARItemId AND cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                             (SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                               FROM            dbo.tblCFTransactionPrice
                               WHERE        (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                         dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId
WHERE        (cfTrans.ysnPosted = 0)
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFBatchPostTransactions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'1440
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFBatchPostTransactions';


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
               Top = 161
               Left = 548
               Bottom = 291
               Right = 723
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 195
               Left = 223
               Bottom = 325
               Right = 429
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfNetwork"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ctContracts"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 315
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 6
               Left = 860
               Bottom = 136
               Right = 1126
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
         Column = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFBatchPostTransactions';

