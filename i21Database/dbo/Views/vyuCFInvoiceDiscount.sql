CREATE VIEW dbo.vyuCFInvoiceDiscount
AS
SELECT ISNULL(cfTransPrice.dblCalculatedAmount, 0) AS dblTotalAmount, smTerm.intTermID, smTerm.strTerm, smTerm.strType, smTerm.dblDiscountEP, smTerm.intBalanceDue, smTerm.intDiscountDay, smTerm.dblAPR, smTerm.strTermCode, smTerm.ysnAllowEFT, 
             smTerm.intDayofMonthDue, smTerm.intDueNextMonth, smTerm.dtmDiscountDate, smTerm.dtmDueDate, smTerm.ysnActive, smTerm.ysnEnergyTrac, smTerm.intSort, smTerm.intConcurrencyId, cfTrans.dblQuantity, cfCardAccount.intAccountId, cfTrans.intTransactionId, 
             arInv.strCustomerName, cfCardAccount.strNetwork, arInv.dtmPostDate AS dtmPostedDate, cfCardAccount.strInvoiceCycle, cfTrans.dtmTransactionDate, cfTrans.strTransactionType, cfCardAccount.intDiscountScheduleId, cfCardAccount.intCustomerId, 
             ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, arInv.intInvoiceId, arInv.strInvoiceNumber, cfTrans.strInvoiceReportNumber, cfTrans.strPrintTimeStamp
FROM   dbo.vyuCFInvoice AS arInv INNER JOIN
             dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
             dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
             dbo.vyuCFCardAccount AS cfCardAccount ON cfTrans.intCardId = cfCardAccount.intCardId INNER JOIN
             dbo.tblCFDiscountSchedule AS cfDiscount ON cfDiscount.intDiscountScheduleId = cfCardAccount.intDiscountScheduleId LEFT OUTER JOIN
                 (SELECT arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, 
                              arCustGroupDetail.ysnVolumeDiscount, arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                 FROM    dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                              dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 INNER JOIN
             dbo.tblSMTerm AS smTerm ON cfCardAccount.intTermsCode = smTerm.intTermID INNER JOIN
             dbo.vyuCFSiteItem AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND cfSiteItem.intItemId = cfTrans.intProductId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice
                 WHERE (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                 WHERE (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                 WHERE (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
                 (SELECT icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                              dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                 WHERE (ismTaxClass.strTaxClass LIKE '%(FET)%') AND (ismTaxClass.strTaxClass LIKE '%Federal Excise Tax%')
                 GROUP BY icfTramsactionTax.intTransactionId) AS FETTaxes ON cfTrans.intTransactionId = FETTaxes.intTransactionId LEFT OUTER JOIN
                 (SELECT icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                              dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                 WHERE (ismTaxClass.strTaxClass LIKE '%(SET)%') AND (ismTaxClass.strTaxClass LIKE '%State Excise Tax%')
                 GROUP BY icfTramsactionTax.intTransactionId) AS SETTaxes ON cfTrans.intTransactionId = SETTaxes.intTransactionId LEFT OUTER JOIN
                 (SELECT icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                              dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                 WHERE (ismTaxClass.strTaxClass LIKE '%(SST)%') AND (ismTaxClass.strTaxClass LIKE '%State Sales Tax%')
                 GROUP BY icfTramsactionTax.intTransactionId) AS SSTTaxes ON cfTrans.intTransactionId = SSTTaxes.intTransactionId LEFT OUTER JOIN
                 (SELECT icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                              dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                 WHERE (ismTaxClass.strTaxClass NOT LIKE '%(SET)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Excise Tax%') AND (ismTaxClass.strTaxClass <> 'SET') AND (ismTaxClass.strTaxClass NOT LIKE '%(FET)%') AND 
                              (ismTaxClass.strTaxClass NOT LIKE '%Federal Excise Tax%') AND (ismTaxClass.strTaxClass <> 'FET') AND (ismTaxClass.strTaxClass NOT LIKE '%(SST)%') AND (ismTaxClass.strTaxClass NOT LIKE '%State Sales Tax%') AND (ismTaxClass.strTaxClass <> 'SST')
                 GROUP BY icfTramsactionTax.intTransactionId) AS LCTaxes ON cfTrans.intTransactionId = LCTaxes.intTransactionId LEFT OUTER JOIN
                 (SELECT icfTramsactionTax.intTransactionId, ISNULL(SUM(icfTramsactionTax.dblTaxOriginalAmount), 0) AS dblTaxOriginalAmount, ISNULL(SUM(icfTramsactionTax.dblTaxCalculatedAmount), 0) AS dblTaxCalculatedAmount, ISNULL(SUM(icfTramsactionTax.dblTaxRate), 
                              0) AS dblTaxRate
                 FROM    dbo.tblCFTransactionTax AS icfTramsactionTax INNER JOIN
                              dbo.tblSMTaxCode AS ismTaxCode ON icfTramsactionTax.intTaxCodeId = ismTaxCode.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
                 GROUP BY icfTramsactionTax.intTransactionId) AS TotalTaxes ON cfTrans.intTransactionId = TotalTaxes.intTransactionId
WHERE (cfSiteItem.ysnIncludeInQuantityDiscount = 1) AND (cfTrans.ysnPosted = 1) OR
             (cfTrans.strTransactionType = 'Local/Network') OR
             (cfTrans.strTransactionType = 'Remote') AND (cfDiscount.ysnDiscountOnRemotes = 1) OR
             (cfTrans.strTransactionType = 'Extended Remote') AND (cfDiscount.ysnDiscountOnExtRemotes = 1)



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceDiscount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'ags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 1395
               Left = 57
               Bottom = 1592
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 1593
               Left = 57
               Bottom = 1790
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 1791
               Left = 57
               Bottom = 1988
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FETTaxes"
            Begin Extent = 
               Top = 1989
               Left = 57
               Bottom = 2186
               Right = 359
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SETTaxes"
            Begin Extent = 
               Top = 2187
               Left = 57
               Bottom = 2384
               Right = 359
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SSTTaxes"
            Begin Extent = 
               Top = 2385
               Left = 57
               Bottom = 2582
               Right = 359
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LCTaxes"
            Begin Extent = 
               Top = 2583
               Left = 57
               Bottom = 2780
               Right = 359
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TotalTaxes"
            Begin Extent = 
               Top = 2781
               Left = 57
               Bottom = 2978
               Right = 359
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfDiscount"
            Begin Extent = 
               Top = 9
               Left = 380
               Bottom = 206
               Right = 698
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
               Right = 323
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTrans"
            Begin Extent = 
               Top = 207
               Left = 57
               Bottom = 404
               Right = 356
            End
            DisplayFlags = 280
            TopColumn = 26
         End
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 405
               Left = 57
               Bottom = 602
               Right = 370
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfCardAccount"
            Begin Extent = 
               Top = 603
               Left = 57
               Bottom = 800
               Right = 443
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "emGroup"
            Begin Extent = 
               Top = 801
               Left = 57
               Bottom = 998
               Right = 369
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "smTerm"
            Begin Extent = 
               Top = 999
               Left = 57
               Bottom = 1196
               Right = 314
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 1197
               Left = 57
               Bottom = 1394
               Right = 430
            End
            DisplayFl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceDiscount';

