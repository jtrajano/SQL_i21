CREATE VIEW dbo.vyuCFInvoiceReport
AS
SELECT ISNULL(emGroup.intCustomerGroupId, 0) AS intCustomerGroupId, emGroup.strGroupName, arInv.intTransactionId, arInv.strCustomerNumber, cfTrans.dtmTransactionDate, cfTrans.intOdometer, ISNULL
                 ((SELECT TOP (1) intOdometer
                  FROM    dbo.tblCFTransaction
                  WHERE (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intVehicleId = cfTrans.intVehicleId) AND (intProductId = cfTrans.intProductId)
                  ORDER BY dtmTransactionDate DESC), 0) AS intOdometerAging, (CASE WHEN (ISNULL
                 ((SELECT TOP (1) intOdometer
                  FROM    dbo.tblCFTransaction AS tblCFTransaction_1
                  WHERE (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intCardId = cfTrans.intCardId) AND (intVehicleId = cfTrans.intVehicleId) AND (intProductId = cfTrans.intProductId)
                  ORDER BY dtmTransactionDate DESC), 0)) > 0 THEN cfTrans.intOdometer - ISNULL
                 ((SELECT TOP (1) intOdometer
                  FROM    dbo.tblCFTransaction AS tblCFTransaction_1
                  WHERE (dtmTransactionDate < cfTrans.dtmTransactionDate) AND (intCardId = cfTrans.intCardId) AND (intCardId = cfTrans.intCardId) AND (intVehicleId = cfTrans.intVehicleId) AND (intProductId = cfTrans.intProductId)
                  ORDER BY dtmTransactionDate DESC), 0) ELSE 0 END) AS dblTotalMiles, arInv.strShipTo, arInv.strBillTo, arInv.strCompanyName, arInv.strCompanyAddress, arInv.strType, arInv.strCustomerName, arInv.strLocationName, arInv.intInvoiceId, arInv.strInvoiceNumber, 
             arInv.dtmDate, arInv.dtmPostDate AS dtmPostedDate, cfTrans.intProductId, cfTrans.intCardId, cfTrans.intTransactionId AS EXPR18, cfTrans.strTransactionId, cfTrans.strTransactionType, cfTrans.strInvoiceReportNumber, cfTrans.dblQuantity, 
             cfCardAccount.intAccountId, cfTrans.strMiscellaneous, cfCardAccount.strName, cfCardAccount.strCardNumber, cfCardAccount.strCardDescription, cfCardAccount.strNetwork, cfCardAccount.intInvoiceCycle, cfCardAccount.strInvoiceCycle, 
             cfCardAccount.strPrimarySortOptions, cfCardAccount.strSecondarySortOptions, cfCardAccount.strPrintRemittancePage, cfCardAccount.strPrintPricePerGallon, cfCardAccount.ysnPrintMiscellaneous, cfCardAccount.strPrintSiteAddress, 
             cfCardAccount.ysnSummaryByCard, cfCardAccount.ysnSummaryByDepartment, cfCardAccount.ysnSummaryByMiscellaneous, cfCardAccount.ysnSummaryByProduct, cfCardAccount.ysnSummaryByVehicle, cfCardAccount.ysnPrintTimeOnInvoices, 
             cfCardAccount.ysnPrintTimeOnReports, cfSiteItem.strSiteNumber, cfSiteItem.strSiteName, cfSiteItem.strProductNumber, cfSiteItem.strItemNo, cfSiteItem.strShortName AS strDescription, cfTransPrice.dblCalculatedAmount AS dblCalculatedTotalAmount, 
             cfTransPrice.dblOriginalAmount AS dblOriginalTotalAmount, cfTransGrossPrice.dblCalculatedAmount AS dblCalculatedGrossAmount, cfTransGrossPrice.dblOriginalAmount AS dblOriginalGrossAmount, 
             cfTransNetPrice.dblCalculatedAmount AS dblCalculatedNetAmount, cfTransNetPrice.dblOriginalAmount AS dblOriginalNetAmount, cfTransNetPrice.dblCalculatedAmount - cfSiteItem.dblAverageCost AS dblMargin, cfTrans.ysnInvalid, cfTrans.ysnPosted, 
             cfVehicle.strVehicleNumber, cfVehicle.strVehicleDescription, cfSiteItem.strTaxState, cfDep.strDepartment, cfSiteItem.strSiteType, cfSiteItem.strTaxState AS strState, cfSiteItem.strSiteAddress, cfSiteItem.strSiteCity,
                 (SELECT SUM(dblTaxCalculatedAmount) AS dblTotalTax
                 FROM    dbo.tblCFTransactionTax
                 WHERE (intTransactionId = cfTrans.intTransactionId)) / cfTrans.dblQuantity AS dblTotalTax,
                 (SELECT ISNULL(SUM(cfTT.dblTaxCalculatedAmount), 0) AS dblTotalSST
                 FROM    dbo.tblCFTransactionTax AS cfTT INNER JOIN
                              dbo.tblSMTaxCode AS smTCd ON cfTT.intTaxCodeId = smTCd.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS smTCl ON smTCd.intTaxClassId = smTCl.intTaxClassId
                 WHERE (smTCl.strTaxClass LIKE '%(SST)%') AND (smTCl.strTaxClass LIKE '%State Sales Tax%') AND (cfTT.intTransactionId = cfTrans.intTransactionId)
                 GROUP BY cfTT.intTransactionId) / cfTrans.dblQuantity AS dblTotalSST,
                 (SELECT ISNULL(SUM(cfTT.dblTaxCalculatedAmount), 0) AS dblTaxExceptSST
                 FROM    dbo.tblCFTransactionTax AS cfTT INNER JOIN
                              dbo.tblSMTaxCode AS smTCd ON cfTT.intTaxCodeId = smTCd.intTaxCodeId INNER JOIN
                              dbo.tblSMTaxClass AS smTCl ON smTCd.intTaxClassId = smTCl.intTaxClassId
                 WHERE (smTCl.strTaxClass NOT LIKE '%(SST)%') AND (smTCl.strTaxClass NOT LIKE '%State Sales Tax%') AND (smTCl.strTaxClass <> 'SST') AND (cfTT.intTransactionId = cfTrans.intTransactionId)
                 GROUP BY cfTT.intTransactionId) / cfTrans.dblQuantity AS dblTaxExceptSST, cfTrans.strPrintTimeStamp
FROM   dbo.vyuCFInvoice AS arInv RIGHT OUTER JOIN
             dbo.tblCFTransaction AS cfTrans ON arInv.intTransactionId = cfTrans.intTransactionId AND arInv.intInvoiceId = cfTrans.intInvoiceId LEFT OUTER JOIN
             dbo.tblCFVehicle AS cfVehicle ON cfTrans.intVehicleId = cfVehicle.intVehicleId INNER JOIN
             dbo.vyuCFCardAccount AS cfCardAccount ON arInv.intEntityCustomerId = cfCardAccount.intCustomerId AND cfTrans.intCardId = cfCardAccount.intCardId LEFT OUTER JOIN
                 (SELECT arCustGroupDetail.intCustomerGroupDetailId, arCustGroupDetail.intCustomerGroupId, arCustGroupDetail.intEntityId, arCustGroupDetail.ysnSpecialPricing, arCustGroupDetail.ysnContract, arCustGroupDetail.ysnBuyback, arCustGroupDetail.ysnQuote, 
                              arCustGroupDetail.ysnVolumeDiscount, arCustGroupDetail.intConcurrencyId, arCustGroup.strGroupName
                 FROM    dbo.tblARCustomerGroup AS arCustGroup INNER JOIN
                              dbo.tblARCustomerGroupDetail AS arCustGroupDetail ON arCustGroup.intCustomerGroupId = arCustGroupDetail.intCustomerGroupId) AS emGroup ON emGroup.intEntityId = cfCardAccount.intCustomerId AND emGroup.ysnVolumeDiscount = 1 INNER JOIN
             dbo.vyuCFSiteItem AS cfSiteItem ON cfTrans.intSiteId = cfSiteItem.intSiteId AND cfSiteItem.intARItemId = cfTrans.intARItemId AND cfSiteItem.intItemId = cfTrans.intProductId INNER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice
                 WHERE (strTransactionPriceId = 'Total Amount')) AS cfTransPrice ON cfTrans.intTransactionId = cfTransPrice.intTransactionId INNER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
                 WHERE (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTrans.intTransactionId = cfTransGrossPrice.intTransactionId INNER JOIN
                 (SELECT intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
                 FROM    dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
                 WHERE (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTrans.intTransactionId = cfTransNetPrice.intTransactionId LEFT OUTER JOIN
             dbo.vyuCTContractDetailView AS ctContracts ON cfTrans.intContractId = ctContracts.intContractDetailId LEFT OUTER JOIN
             dbo.tblCFDepartment AS cfDep ON cfDep.intDepartmentId = cfCardAccount.intCardId
WHERE (cfTrans.ysnPosted = 1)



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'layFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransGrossPrice"
            Begin Extent = 
               Top = 1395
               Left = 57
               Bottom = 1592
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransNetPrice"
            Begin Extent = 
               Top = 1593
               Left = 57
               Bottom = 1790
               Right = 333
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ctContracts"
            Begin Extent = 
               Top = 1791
               Left = 57
               Bottom = 1988
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfDep"
            Begin Extent = 
               Top = 1989
               Left = 57
               Bottom = 2186
               Right = 366
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';


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
            TopColumn = 0
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
         Begin Table = "cfSiteItem"
            Begin Extent = 
               Top = 999
               Left = 57
               Bottom = 1196
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfTransPrice"
            Begin Extent = 
               Top = 1197
               Left = 57
               Bottom = 1394
               Right = 333
            End
            Disp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFInvoiceReport';

