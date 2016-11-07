CREATE VIEW dbo.vyuCFCardAccount
AS
SELECT   A.intAccountId, A.intCustomerId, A.intDiscountDays, A.intDiscountScheduleId, A.intInvoiceCycle, A.intSalesPersonId, A.dtmBonusCommissionDate, 
                         A.dblBonusCommissionRate, A.dblRegularCommissionRate, A.ysnPrintTimeOnInvoices, A.ysnPrintTimeOnReports, A.intTermsCode, A.strBillingSite, A.strPrimarySortOptions, 
                         A.strSecondarySortOptions, A.ysnSummaryByCard, A.ysnSummaryByVehicle, A.ysnSummaryByMiscellaneous, A.ysnSummaryByProduct, A.ysnSummaryByDepartment, 
                         A.ysnVehicleRequire, A.intAccountStatusCodeId, A.strPrintRemittancePage, A.strInvoiceProgramName, A.intPriceRuleGroup, A.strPrintPricePerGallon, 
                         A.ysnPPTransferCostForRemote, A.ysnPPTransferCostForNetwork, A.ysnPrintMiscellaneous, A.intFeeProfileId, A.strPrintSiteAddress, A.dtmLastBillingCycleDate, 
                         A.intRemotePriceProfileId, A.intExtRemotePriceProfileId, A.intLocalPriceProfileId, A.intCreatedUserId, A.dtmCreated, A.intLastModifiedUserId, A.dtmLastModified, 
                         A.intConcurrencyId, C.intCardId, C.intNetworkId, C.strCardNumber, C.strCardDescription, C.intAccountId AS EXPR1, C.strCardForOwnUse, C.intExpenseItemId, 
                         C.intDefaultFixVehicleNumber, C.intDepartmentId, C.dtmLastUsedDated, C.intCardTypeId, C.dtmIssueDate, C.ysnActive, C.ysnCardLocked, C.strCardPinNumber, 
                         C.dtmCardExpiratioYearMonth, C.strCardValidationCode, C.intNumberOfCardsIssued, C.intCardLimitedCode, C.intCardFuelCode, C.strCardTierCode, 
                         C.strCardOdometerCode, C.strCardWCCode, C.strSplitNumber, C.intCardManCode, C.intCardShipCat, C.intCardProfileNumber, C.intCardPositionSite, 
                         C.intCardvehicleControl, C.intCardCustomPin, C.intCreatedUserId AS EXPR2, C.dtmCreated AS EXPR3, C.intLastModifiedUserId AS EXPR4, C.intConcurrencyId AS EXPR5, 
                         C.dtmLastModified AS EXPR6, C.ysnCardForOwnUse, C.ysnIgnoreCardTransaction, N.intNetworkId AS EXPR7, N.strNetwork, N.strNetworkType, N.strNetworkDescription, 
                         N.intCustomerId AS EXPR8, N.intCACustomerId, N.intDebitMemoGLAccount, N.intLocationId, N.dblFeeRateAmount, N.dblFeePerGallon, N.dblFeeTransactionPerGallon, 
                         N.dblMonthlyCommisionFeeAmount, N.dblVariableCommisionFeePerGallon, N.strImportPath, N.dtmLastImportDate, N.intErrorBatchNumber, N.intPPhostId, 
                         N.intPPDistributionSite, N.strPPFileImportType, N.ysnRejectExportCard, N.strRejectPath, N.strParticipant, N.strCFNFileVersion, N.ysnPassOnSSTFromRemotes, 
                         N.ysnExemptFETOnRemotes, N.ysnExemptSETOnRemotes, N.ysnExemptLCOnRemotes, N.strExemptLCCode, N.intImportMapperId, N.strLinkNetwork, 
                         N.intConcurrencyId AS EXPR9, D.intDepartmentId AS EXPR10, D.intAccountId AS EXPR11, D.strDepartment, D.strDepartmentDescription, D.intConcurrencyId AS EXPR12, 
                         Cus.intEntityId, Cus.intEntityCustomerId, Cus.strName, Cus.strCustomerNumber, Cus.strType, Cus.strPhone, Cus.strAddress, Cus.strCity, Cus.strState, Cus.strZipCode, 
                         Cus.ysnActive AS EXPR13, Cus.intSalespersonId AS EXPR14, Cus.intCurrencyId, Cus.intTermsId, Cus.intShipViaId, Cus.strShipToLocationName, Cus.strShipToAddress, 
                         Cus.strShipToCity, Cus.strShipToState, Cus.strShipToZipCode, Cus.strShipToCountry, Cus.strBillToLocationName, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState,
                          Cus.strBillToZipCode, Cus.strBillToCountry, I.strInvoiceCycle, arCustCon.strEmailDistributionOption, arCustCon.strEmail
FROM         dbo.tblCFAccount AS A LEFT OUTER JOIN
                         dbo.tblCFCard AS C ON A.intAccountId = C.intAccountId LEFT OUTER JOIN
                         dbo.tblCFNetwork AS N ON N.intNetworkId = C.intNetworkId LEFT OUTER JOIN
                         dbo.tblCFDepartment AS D ON D.intDepartmentId = C.intDepartmentId INNER JOIN
                         dbo.vyuCFCustomerEntity AS Cus ON A.intCustomerId = Cus.intEntityCustomerId INNER JOIN
                         dbo.tblCFInvoiceCycle AS I ON I.intInvoiceCycleId = A.intInvoiceCycle INNER JOIN
                         dbo.vyuARCustomerContacts AS arCustCon ON A.intCustomerId = arCustCon.intCustomerEntityId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFCardAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFCardAccount';


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
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "N"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Cus"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 534
               Left = 293
               Bottom = 664
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "arCustCon"
            Begin Extent = 
               Top = 6
               Left = 326
               Bottom = 251
               Right = 556
            End
            DisplayFlags = 280
            TopColumn = 0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFCardAccount';

