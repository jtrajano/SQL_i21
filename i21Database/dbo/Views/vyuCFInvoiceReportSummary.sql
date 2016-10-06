CREATE VIEW dbo.vyuCFInvoiceReportSummary
AS
SELECT   CASE WHEN cfVehicle.strVehicleNumber = '' OR
                         cfVehicle.strVehicleNumber IS NULL OR
                         cfVehicle.strVehicleNumber = 0 THEN 'Unknown' ELSE cfVehicle.strVehicleNumber END AS strVehicleNumber, CASE WHEN cfTrans.strMiscellaneous = '' OR
                         cfTrans.strMiscellaneous IS NULL THEN 'Unknown' ELSE cfTrans.strMiscellaneous END AS strMiscellaneous, CASE WHEN cfCardAccount.strDepartment = '' OR
                         cfCardAccount.strDepartment IS NULL THEN 'Unknown' ELSE cfCardAccount.strDepartment END AS strDepartment, cfCardAccount.intDiscountScheduleId, 
                         cfCardAccount.intTermsCode, cfCardAccount.intTermsId, cfVehicle.strVehicleDescription, cfSiteItem.strTaxState, cfCardAccount.intAccountId, cfTrans.intCardId, 
                         cfCardAccount.strCardNumber, cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, 
                         cfCardAccount.strCardDescription, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, cfSiteItem.ysnIncludeInQuantityDiscount, 
                         ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, 
                         ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, 
                         ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) AS TotalLC, 
                         ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) - (ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) 
                         + ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) + ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0)) AS dblTotalNetAmount
FROM         dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                         dbo.vyuCFSiteItem AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND 
                         cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice
                                WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                                WHERE     (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                                FROM         dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                                WHERE     (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(FET)%') AND (ismTaxClass.strTaxClass LIKE '%Federal Excise Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(SET)%') AND (ismTaxClass.strTaxClass LIKE '%State Excise Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass LIKE '%(SST)%') AND (ismTaxClass.strTaxClass LIKE '%State Sales Tax%')
                                GROUP BY icfTramsactionTax.intTransactionId) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                WHERE     (ismTaxClass.strTaxClass NOT LIKE '%(SET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Excise Tax%') AND (ismTaxClass.strTaxClass <> 'SET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(FET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%Federal Excise Tax%') AND (ismTaxClass.strTaxClass <> 'FET') AND 
                                                         (ismTaxClass.strTaxClass NOT LIKE '%(SST)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Sales Tax%') AND (ismTaxClass.strTaxClass <> 'SST')
                                GROUP BY icfTramsactionTax.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId LEFT OUTER JOIN
                             (SELECT   icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, 
                                                         ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 0) AS dblTaxRate
                                FROM         dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                                                         dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                                                         dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                                GROUP BY icfTramsactionTax.intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId
GROUP BY cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, 
                         cfTrans.intProductId, cfTrans.intARItemId, cfSiteItem.strProductNumber, cfSiteItem.strProductDescription, cfCardAccount.strDepartment, cfSiteItem.strTaxState, 
                         cfSiteItem.ysnIncludeInQuantityDiscount, cfVehicle.strVehicleNumber, cfVehicle.strVehicleDescription, cfCardAccount.intDiscountScheduleId, cfCardAccount.intTermsCode, 
                         cfCardAccount.intTermsId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes"
            Begin Extent = 
               Top = 1062
               Left = 38
               Bottom = 1192
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes"
            Begin Extent = 
               Top = 1194
               Left = 38
               Bottom = 1324
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes"
            Begin Extent = 
               Top = 1326
               Left = 38
               Bottom = 1456
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes"
            Begin Extent = 
               Top = 1458
               Left = 38
               Bottom = 1588
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TotalTaxes"
            Begin Extent = 
               Top = 1590
               Left = 38
               Bottom = 1720
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 327
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';


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
               Top = 6
               Left = 38
               Bottom = 136
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCardAccount"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 260
            End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';

