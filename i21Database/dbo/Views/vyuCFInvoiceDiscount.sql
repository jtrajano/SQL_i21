CREATE VIEW dbo.vyuCFInvoiceDiscount
AS
SELECT   ISNULL(cfTransPrice.dblCalculatedAmount, 0) AS dblTotalAmount, smTerm.intTermID, smTerm.strTerm, smTerm.strType, smTerm.dblDiscountEP, smTerm.intBalanceDue, 
                         smTerm.intDiscountDay, smTerm.dblAPR, smTerm.strTermCode, smTerm.ysnAllowEFT, smTerm.intDayofMonthDue, smTerm.intDueNextMonth, smTerm.dtmDiscountDate, 
                         smTerm.dtmDueDate, smTerm.ysnActive, smTerm.ysnEnergyTrac, smTerm.intSort, smTerm.intConcurrencyId, cfTrans.dblQuantity, cfCardAccount.intAccountId, 
                         CASE WHEN cfSiteItem.ysnIncludeInQuantityDiscount = 1 THEN CASE WHEN cfTrans.strTransactionType = 'Local/Network' THEN ISNULL
                             ((SELECT   TOP 1 ISNULL(dblRate, 0)
                                 FROM         tblCFDiscountSchedule AS cfDs INNER JOIN
                                                           tblCFDiscountScheduleDetail AS cfDsd ON cfDs.intDiscountScheduleId = cfDsd.intDiscountScheduleId
                                 WHERE     (cfTrans.dblQuantity >= cfDsd.intFromQty AND cfTrans.dblQuantity < cfDsd.intThruQty) AND 
                                                           cfDs.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId), 0) ELSE CASE WHEN cfTrans.strTransactionType = 'Remote' THEN ISNULL
                             ((SELECT   TOP 1 ISNULL(dblRate, 0)
                                 FROM         tblCFDiscountSchedule AS cfDs INNER JOIN
                                                           tblCFDiscountScheduleDetail AS cfDsd ON cfDs.intDiscountScheduleId = cfDsd.intDiscountScheduleId
                                 WHERE     (cfTrans.dblQuantity >= cfDsd.intFromQty AND cfTrans.dblQuantity < cfDsd.intThruQty) AND 
                                                           cfDs.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId AND cfDs.ysnDiscountOnRemotes = 1), 0) ELSE ISNULL
                             ((SELECT   TOP 1 ISNULL(dblRate, 0)
                                 FROM         tblCFDiscountSchedule AS cfDs INNER JOIN
                                                           tblCFDiscountScheduleDetail AS cfDsd ON cfDs.intDiscountScheduleId = cfDsd.intDiscountScheduleId
                                 WHERE     (cfTrans.dblQuantity >= cfDsd.intFromQty AND cfTrans.dblQuantity < cfDsd.intThruQty) AND 
                                                           cfDs.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId AND cfDs.ysnDiscountOnExtRemotes = 1), 0) 
                         END END ELSE 0 END AS dblDiscountRate
FROM         dbo.vyuCFInvoice AS arInv INNER JOIN
                         dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId LEFT OUTER JOIN
                         dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
                         dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
                         dbo.tblSMTerm AS smTerm ON cfCardAccount.intTermsCode = smTerm.intTermID INNER JOIN
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
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'lags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 138
               Left = 593
               Bottom = 268
               Right = 799
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 138
               Left = 837
               Bottom = 268
               Right = 1043
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes"
            Begin Extent = 
               Top = 138
               Left = 1081
               Bottom = 268
               Right = 1305
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 262
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes"
            Begin Extent = 
               Top = 270
               Left = 300
               Bottom = 400
               Right = 524
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes"
            Begin Extent = 
               Top = 270
               Left = 562
               Bottom = 400
               Right = 786
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TotalTaxes"
            Begin Extent = 
               Top = 270
               Left = 824
               Bottom = 400
               Right = 1048
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[50] 4[11] 2[20] 3) )"
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
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 6
               Left = 274
               Bottom = 136
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 6
               Left = 532
               Bottom = 136
               Right = 761
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCardAccount"
            Begin Extent = 
               Top = 6
               Left = 799
               Bottom = 136
               Right = 1078
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "smTerm"
            Begin Extent = 
               Top = 6
               Left = 1116
               Bottom = 136
               Right = 1307
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 311
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 138
               Left = 349
               Bottom = 268
               Right = 555
            End
            DisplayF', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceDiscount';

