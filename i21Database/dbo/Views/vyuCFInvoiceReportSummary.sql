﻿CREATE VIEW dbo.vyuCFInvoiceReportSummary
AS
SELECT        cfCard.strDepartment, cfCard.intAccountId, cfTrans.intCardId, cfCard.strCardNumber, cfTrans.intProductId, cfTrans.intARItemId, cfItem.strProductNumber, cfItem.strProductDescription, cfCard.strCardDescription, 
                         cfTrans.strMiscellaneous, ISNULL(SUM(cfTrans.dblQuantity), 0) AS dblTotalQuantity, ISNULL(SUM(cfTransGrossPrice.dblCalculatedAmount), 0) AS dblTotalGrossAmount, 
                         ISNULL(SUM(cfTransNetPrice.dblCalculatedAmount), 0) AS dblTotalNetAmount, ISNULL(SUM(cfTransPrice.dblCalculatedAmount), 0) AS dblTotalAmount, ISNULL(SUM(FETTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalFET, ISNULL(SUM(SETTaxes.dblTaxCalculatedAmount), 0) AS TotalSET, ISNULL(SUM(SSTTaxes.dblTaxCalculatedAmount), 0) AS TotalSST, ISNULL(SUM(LCTaxes.dblTaxCalculatedAmount), 0) 
                         AS TotalLC
FROM            dbo.tblCFTransaction AS cfTrans INNER JOIN
                         dbo.vyuCFInvoiceReport AS main ON main.intTransactionId = cfTrans.intTransactionId INNER JOIN
                             (SELECT        cfiCard.intCardId, cfiCard.intNetworkId, cfiCard.strCardNumber, cfiCard.strCardDescription, cfiCard.intAccountId, cfiCard.strCardForOwnUse, cfiCard.intExpenseItemId, 
                                                         cfiCard.intDefaultFixVehicleNumber, cfiCard.intDepartmentId, cfiCard.dtmLastUsedDated, cfiCard.intCardTypeId, cfiCard.dtmIssueDate, cfiCard.ysnActive, cfiCard.ysnCardLocked, 
                                                         cfiCard.strCardPinNumber, cfiCard.dtmCardExpiratioYearMonth, cfiCard.strCardValidationCode, cfiCard.intNumberOfCardsIssued, cfiCard.intCardLimitedCode, cfiCard.intCardFuelCode, 
                                                         cfiCard.strCardTierCode, cfiCard.strCardOdometerCode, cfiCard.strCardWCCode, cfiCard.strSplitNumber, cfiCard.intCardManCode, cfiCard.intCardShipCat, cfiCard.intCardProfileNumber, 
                                                         cfiCard.intCardPositionSite, cfiCard.intCardvehicleControl, cfiCard.intCardCustomPin, cfiCard.intCreatedUserId, cfiCard.dtmCreated, cfiCard.intLastModifiedUserId, cfiCard.intConcurrencyId, 
                                                         cfiCard.dtmLastModified, cfiCard.ysnCardForOwnUse, cfiCard.ysnIgnoreCardTransaction, cfiDepartment.strDepartment
                               FROM            dbo.tblCFCard AS cfiCard LEFT OUTER JOIN
                                                         dbo.tblCFDepartment AS cfiDepartment ON cfiCard.intDepartmentId = cfiDepartment.intDepartmentId) AS cfCard ON cfTrans.intCardId = cfCard.intCardId INNER JOIN
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
GROUP BY cfCard.intAccountId, cfTrans.strMiscellaneous, cfTrans.intCardId, cfTrans.intProductId, cfCard.strCardNumber, cfCard.strCardDescription, cfTrans.intProductId, cfTrans.intARItemId, cfItem.strProductNumber, 
                         cfItem.strProductDescription, cfCard.strDepartment
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'playFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes"
            Begin Extent = 
               Top = 138
               Left = 558
               Bottom = 268
               Right = 798
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes"
            Begin Extent = 
               Top = 138
               Left = 836
               Bottom = 268
               Right = 1076
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes"
            Begin Extent = 
               Top = 138
               Left = 1114
               Bottom = 268
               Right = 1354
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 278
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
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "main"
            Begin Extent = 
               Top = 6
               Left = 312
               Bottom = 136
               Right = 574
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCard"
            Begin Extent = 
               Top = 6
               Left = 612
               Bottom = 136
               Right = 868
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfItem"
            Begin Extent = 
               Top = 6
               Left = 906
               Bottom = 136
               Right = 1126
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 6
               Left = 1164
               Bottom = 136
               Right = 1386
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 138
               Left = 298
               Bottom = 268
               Right = 520
            End
            Dis', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReportSummary';

