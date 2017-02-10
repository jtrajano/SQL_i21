CREATE VIEW dbo.vyuCFInvoiceReportSummary
AS
SELECT   arInv.strCustomerName, arInv.strCustomerNumber, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, CASE WHEN cfCardAccount.strDepartment = '' OR
                         cfCardAccount.strDepartment IS NULL THEN 'Unknown' ELSE cfCardAccount.strDepartment END AS strDepartment, cfCardAccount.strDepartmentDescription, 
                         CASE WHEN cfTrans.strMiscellaneous = '' OR
                         cfTrans.strMiscellaneous IS NULL THEN 'Unknown' ELSE cfTrans.strMiscellaneous END AS strMiscellaneous, CASE WHEN cfVehicle.strVehicleNumber = '' OR
                         cfVehicle.strVehicleNumber IS NULL OR
                         cfVehicle.strVehicleNumber = '0' THEN 'Unknown' ELSE cfVehicle.strVehicleNumber END AS strVehicleNumber, cfVehicle.strVehicleDescription, cfSiteItem.strShortName, 
                         cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, cfSiteItem.strItemNo AS strItemNumber, cfSiteItem.strDescription AS strItemDescription, 
                         cfSiteItem.strSiteNumber, cfSiteItem.strSiteAddress + ', ' + cfSiteItem.strSiteCity + ', ' + cfSiteItem.strTaxState AS strSiteAddress, cfTrans.dtmTransactionDate, 
                         cfTrans.intOdometer, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
                         ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) - (ISNULL(SUM(FETTaxes_1.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SETTaxes_1.dblTaxCalculatedAmount), 0) 
                         + ISNULL(SUM(SSTTaxes_1.dblTaxCalculatedAmount), 0) + ISNULL(SUM(LCTaxes_1.dblTaxCalculatedAmount), 0)) AS dblTotalNetAmount, 
                         ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, ISNULL(SUM(FETTaxes_1.dblTaxCalculatedAmount), 0) 
                         + ISNULL(SUM(SETTaxes_1.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SSTTaxes_1.dblTaxCalculatedAmount), 0) + ISNULL(SUM(LCTaxes_1.dblTaxCalculatedAmount), 0) 
                         AS dblTotalTaxAmount, cfTrans.strTransactionId, cfCardAccount.intDiscountScheduleId, cfCardAccount.intTermsCode, cfCardAccount.intTermsId, cfSiteItem.strTaxState, 
                         cfCardAccount.intAccountId, cfTrans.intCardId, cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.ysnIncludeInQuantityDiscount, 
                         ISNULL(SUM(FETTaxes_1.dblTaxCalculatedAmount), 0) AS TotalFET, ISNULL(SUM(SETTaxes_1.dblTaxCalculatedAmount), 0) AS TotalSET, 
                         ISNULL(SUM(SSTTaxes_1.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes_1.dblTaxCalculatedAmount), 0) AS TotalLC, cfTrans.intTransactionId, 
                         cfCardAccount.strNetwork, arInv.dtmPostDate AS dtmPostedDate, cfCardAccount.strInvoiceCycle, cfTrans.strTempInvoiceReportNumber AS strInvoiceReportNumber, 
                         cfTrans.strPrintTimeStamp, cfCardAccount.intCustomerId, cfCardAccount.strEmailDistributionOption, cfCardAccount.strEmail
FROM         dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                             (SELECT   icfSite.intSiteId, icfSite.intNetworkId, icfSite.intTaxGroupId, icfSite.strSiteNumber, icfSite.intARLocationId, icfSite.intCardId, icfSite.strTaxState, 
                                                         icfSite.strAuthorityId1, icfSite.strAuthorityId2, icfSite.ysnFederalExciseTax, icfSite.ysnStateExciseTax, icfSite.ysnStateSalesTax, icfSite.ysnLocalTax1, 
                                                         icfSite.ysnLocalTax2, icfSite.ysnLocalTax3, icfSite.ysnLocalTax4, icfSite.ysnLocalTax5, icfSite.ysnLocalTax6, icfSite.ysnLocalTax7, icfSite.ysnLocalTax8, 
                                                         icfSite.ysnLocalTax9, icfSite.ysnLocalTax10, icfSite.ysnLocalTax11, icfSite.ysnLocalTax12, icfSite.intNumberOfLinesPerTransaction, icfSite.intIgnoreCardID, 
                                                         icfSite.strImportFileName, icfSite.strImportPath, icfSite.intNumberOfDecimalInPrice, icfSite.intNumberOfDecimalInQuantity, icfSite.intNumberOfDecimalInTotal, 
                                                         icfSite.strImportType, icfSite.strControllerType, icfSite.ysnPumpCalculatesTaxes, icfSite.ysnSiteAcceptsMajorCreditCards, icfSite.ysnCenexSite, 
                                                         icfSite.ysnUseControllerCard, icfSite.intCashCustomerID, icfSite.ysnProcessCashSales, icfSite.ysnAssignBatchByDate, icfSite.ysnMultipleSiteImport, 
                                                         icfSite.strSiteName, icfSite.strDeliveryPickup, icfSite.strSiteAddress, icfSite.strSiteCity, icfSite.intPPHostId, icfSite.strPPSiteType, icfSite.ysnPPLocalPrice, 
                                                         icfSite.intPPLocalHostId, icfSite.strPPLocalSiteType, icfSite.intPPLocalSiteId, icfSite.intRebateSiteGroupId, icfSite.intAdjustmentSiteGroupId, 
                                                         icfSite.dtmLastTransactionDate, icfSite.ysnEEEStockItemDetail, icfSite.ysnRecalculateTaxesOnRemote, icfSite.strSiteType, icfSite.intCreatedUserId, 
                                                         icfSite.dtmCreated, icfSite.intLastModifiedUserId, icfSite.dtmLastModified, icfSite.intConcurrencyId, icfSite.intImportMapperId, icfItem.intItemId, 
                                                         icfItem.intARItemId, iicItemLoc.intItemLocationId, iicItemLoc.intIssueUOMId, iicItem.strDescription, iicItem.strShortName, iicItem.strItemNo, 
                                                         icfItem.strProductNumber, iicItemPricing.dblAverageCost, icfItem.strProductDescription, icfItem.ysnIncludeInQuantityDiscount
                                FROM         dbo.tblCFSite AS icfSite INNER JOIN
                                                         dbo.tblCFNetwork AS icfNetwork ON icfNetwork.intNetworkId = icfSite.intNetworkId INNER JOIN
                                                         dbo.tblCFItem AS icfItem ON icfSite.intSiteId = icfItem.intSiteId OR icfNetwork.intNetworkId = icfItem.intNetworkId INNER JOIN
                                                         dbo.tblICItem AS iicItem ON icfItem.intARItemId = iicItem.intItemId LEFT OUTER JOIN
                                                         dbo.tblICItemLocation AS iicItemLoc ON iicItemLoc.intLocationId = icfSite.intARLocationId AND iicItemLoc.intItemId = icfItem.intARItemId INNER JOIN
                                                         dbo.vyuICGetItemPricing AS iicItemPricing ON iicItemPricing.intItemId = icfItem.intARItemId AND iicItemPricing.intLocationId = iicItemLoc.intLocationId AND 
                                                         iicItemPricing.intItemLocationId = iicItemLoc.intItemLocationId) AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND 
                         cfTrans.intNetworkId = cfSiteItem.intNetworkId AND cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
                                                         ISNULL(SUM(dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.vyuCFTransactionTax AS FETTaxes
                                WHERE     (strTaxClass LIKE '%(FET)%') AND (strTaxClass LIKE '%Federal Excise Tax%')
                                GROUP BY intTransactionId) AS FETTaxes_1 ON cfTrans.intTransactionId = FETTaxes_1.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
                                                         ISNULL(SUM(dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.vyuCFTransactionTax AS SETTaxes
                                WHERE     (strTaxClass LIKE '%(SET)%') AND (strTaxClass LIKE '%State Excise Tax%')
                                GROUP BY intTransactionId) AS SETTaxes_1 ON cfTrans.intTransactionId = SETTaxes_1.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
                                                         ISNULL(SUM(dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.vyuCFTransactionTax AS SSTTaxes
                                WHERE     (strTaxClass LIKE '%(SST)%') AND (strTaxClass LIKE '%State Sales Tax%')
                                GROUP BY intTransactionId) AS SSTTaxes_1 ON cfTrans.intTransactionId = SSTTaxes_1.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
                                                         ISNULL(SUM(dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.vyuCFTransactionTax AS LCTaxes
                                WHERE     (strTaxClass NOT LIKE '%(SET)%') AND (strTaxClass NOT LIKE '%State Excise Tax%') AND (strTaxClass <> 'SET') AND (strTaxClass NOT LIKE '%(FET)%') AND 
                                                         (strTaxClass NOT LIKE '%Federal Excise Tax%') AND (strTaxClass <> 'FET') AND (strTaxClass NOT LIKE '%(SST)%') AND 
                                                         (strTaxClass NOT LIKE '%State Sales Tax%') AND (strTaxClass <> 'SST')
                                GROUP BY intTransactionId) AS LCTaxes_1 ON cfTrans.intTransactionId = LCTaxes_1.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionId, ISNULL(SUM(dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, 
                                                         ISNULL(SUM(dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.vyuCFTransactionTax AS TotalTaxes
                                GROUP BY intTransactionId) AS TotalTaxes_1 ON cfTrans.intTransactionId = TotalTaxes_1.intTransactionId
WHERE     (cfTrans.ysnPosted = 1)
GROUP BY cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, 
                         cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, cfCardAccount.strDepartment, 
                         cfCardAccount.strDepartmentDescription, cfSiteItem.strTaxState, cfSiteItem.ysnIncludeInQuantityDiscount, cfVehicle.strVehicleNumber, cfVehicle.strVehicleDescription, 
                         cfCardAccount.intDiscountScheduleId, cfCardAccount.intTermsCode, cfCardAccount.intTermsId, cfTrans.intTransactionId, arInv.strCustomerName, 
                         cfCardAccount.strNetwork, arInv.dtmPostDate, cfCardAccount.strInvoiceCycle, cfTrans.dtmTransactionDate, cfTrans.strTempInvoiceReportNumber, 
                         cfTrans.strPrintTimeStamp, arInv.strCustomerNumber, cfSiteItem.strItemNo, cfSiteItem.strDescription, cfSiteItem.strSiteNumber, cfSiteItem.strSiteAddress, 
                         cfSiteItem.strSiteCity, cfTrans.strTransactionId, cfTrans.intOdometer, cfCardAccount.intCustomerId, cfCardAccount.strEmailDistributionOption, cfCardAccount.strEmail, 
                         cfSiteItem.strShortName
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'      DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 1395
               Left = 57
               Bottom = 1592
               Right = 349
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes_1"
            Begin Extent = 
               Top = 9
               Left = 396
               Bottom = 206
               Right = 714
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes_1"
            Begin Extent = 
               Top = 9
               Left = 771
               Bottom = 206
               Right = 1089
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes_1"
            Begin Extent = 
               Top = 9
               Left = 1146
               Bottom = 206
               Right = 1464
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes_1"
            Begin Extent = 
               Top = 9
               Left = 1521
               Bottom = 206
               Right = 1839
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TotalTaxes_1"
            Begin Extent = 
               Top = 9
               Left = 1896
               Bottom = 206
               Right = 2214
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
      Begin ColumnWidths = 12
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';


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
         Begin Table = "arInv"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 339
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 207
               Left = 57
               Bottom = 404
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 405
               Left = 57
               Bottom = 602
               Right = 386
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCardAccount"
            Begin Extent = 
               Top = 603
               Left = 57
               Bottom = 800
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 801
               Left = 57
               Bottom = 998
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 999
               Left = 57
               Bottom = 1196
               Right = 349
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 1197
               Left = 57
               Bottom = 1394
               Right = 349
            End
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';

