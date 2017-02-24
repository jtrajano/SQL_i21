CREATE VIEW dbo.vyuCFVehicleAccountCustomer
AS
SELECT cfVehicle.intVehicleId, cfVehicle.intAccountId, cfVehicle.strVehicleNumber, cfVehicle.strCustomerUnitNumber, cfVehicle.strVehicleDescription, cfVehicle.intDaysBetweenService, cfVehicle.intMilesBetweenService, cfVehicle.intLastReminderOdometer, 
             cfVehicle.dtmLastReminderDate, cfVehicle.dtmLastServiceDate, cfVehicle.intLastServiceOdometer, cfVehicle.strNoticeMessageLine1, cfVehicle.strNoticeMessageLine2, cfVehicle.strVehicleForOwnUse, cfVehicle.intExpenseItemId, cfVehicle.strLicencePlateNumber, 
             cfVehicle.strDepartment, cfVehicle.intCreatedUserId, cfVehicle.dtmCreated, cfVehicle.intLastModifiedUserId, cfVehicle.intConcurrencyId, cfVehicle.dtmLastModified, cfVehicle.ysnCardForOwnUse, cfAccount.intAccountId AS EXPR1, cfAccount.intCustomerId, 
             cfAccount.intDiscountDays, cfAccount.intDiscountScheduleId, cfAccount.intInvoiceCycle, cfAccount.intImportMapperId, cfAccount.intSalesPersonId, cfAccount.dtmBonusCommissionDate, cfAccount.dblBonusCommissionRate, cfAccount.dblRegularCommissionRate, 
             cfAccount.ysnPrintTimeOnInvoices, cfAccount.ysnPrintTimeOnReports, cfAccount.intTermsCode, cfAccount.strBillingSite, cfAccount.strPrimarySortOptions, cfAccount.strSecondarySortOptions, cfAccount.ysnSummaryByCard, cfAccount.ysnSummaryByVehicle, 
             cfAccount.ysnSummaryByMiscellaneous, cfAccount.ysnSummaryByProduct, cfAccount.ysnSummaryByDepartment, cfAccount.ysnVehicleRequire, cfAccount.intAccountStatusCodeId, cfAccount.strPrintRemittancePage, cfAccount.strInvoiceProgramName, 
             cfAccount.intPriceRuleGroup, cfAccount.strPrintPricePerGallon, cfAccount.ysnPPTransferCostForRemote, cfAccount.ysnPPTransferCostForNetwork, cfAccount.ysnPrintMiscellaneous, cfAccount.intFeeProfileId, cfAccount.strPrintSiteAddress, 
             cfAccount.dtmLastBillingCycleDate, cfAccount.intRemotePriceProfileId, cfAccount.intExtRemotePriceProfileId, cfAccount.intLocalPriceProfileId, cfAccount.intCreatedUserId AS EXPR2, cfAccount.dtmCreated AS EXPR3, cfAccount.intLastModifiedUserId AS EXPR4, 
             cfAccount.dtmLastModified AS EXPR5, cfAccount.intConcurrencyId AS EXPR6, emEntity.intEntityId, emEntity.intEntityCustomerId, emEntity.strName, emEntity.strCustomerNumber, emEntity.strType, emEntity.strPhone, emEntity.strAddress, emEntity.strCity, 
             emEntity.strState, emEntity.strZipCode, emEntity.ysnActive, emEntity.intSalespersonId AS EXPR7, emEntity.intCurrencyId, emEntity.intTermsId, emEntity.intShipViaId, emEntity.strShipToLocationName, emEntity.strShipToAddress, emEntity.strShipToCity, 
             emEntity.strShipToState, emEntity.strShipToZipCode, emEntity.strShipToCountry, emEntity.strBillToLocationName, emEntity.strBillToAddress, emEntity.strBillToCity, emEntity.strBillToState, emEntity.strBillToZipCode, emEntity.strBillToCountry
FROM   dbo.tblCFVehicle AS cfVehicle INNER JOIN
             dbo.tblCFAccount AS cfAccount ON cfAccount.intAccountId = cfVehicle.intAccountId INNER JOIN
             dbo.vyuCFCustomerEntity AS emEntity ON emEntity.intEntityCustomerId = cfAccount.intCustomerId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFVehicleAccountCustomer';


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
         Begin Table = "cfVehicle"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 370
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfAccount"
            Begin Extent = 
               Top = 9
               Left = 427
               Bottom = 206
               Right = 770
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "emEntity"
            Begin Extent = 
               Top = 9
               Left = 827
               Bottom = 206
               Right = 1120
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFVehicleAccountCustomer';



