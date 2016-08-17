CREATE VIEW dbo.vyuCFAccountCreditThreshold
AS
SELECT mainQuery.intEntityCustomerId, mainQuery.strCustomerName, mainQuery.strCustomerNumber, mainQuery.dblCreditLimit, mainQuery.dblTotalDue, mainQuery.dblTotalAR, mainQuery.dblOverLimit, ARCust.strCreditCode, CFAccnt.intAccountId, 
             CASE WHEN (dblOverLimit > 0 AND dblTotalDue > 0) THEN 'Both' WHEN (dblOverLimit <= 0 AND dblTotalDue > 0) THEN 'Past Due' WHEN (dblOverLimit > 0 AND dblTotalDue <= 0) THEN 'Over Credit Limit' END AS strReason
FROM   (SELECT intEntityCustomerId, strCustomerName, strCustomerNumber, dblCreditLimit, dblTotalDue, dblTotalDue + dbl0Days AS dblTotalAR, CASE WHEN ((dblTotalDue + dbl0Days) - dblCreditLimit) <= 0 THEN 0 WHEN ((dblTotalDue + dbl0Days) - dblCreditLimit) 
                           > 0 THEN ((dblTotalDue + dbl0Days) - dblCreditLimit) END AS dblOverLimit
             FROM    dbo.vyuARCustomerInquiry) AS mainQuery INNER JOIN
             dbo.tblARCustomer AS ARCust ON mainQuery.intEntityCustomerId = ARCust.intEntityCustomerId INNER JOIN
             dbo.tblCFAccount AS CFAccnt ON mainQuery.intEntityCustomerId = CFAccnt.intCustomerId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFAccountCreditThreshold';


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
         Begin Table = "mainQuery"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 323
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ARCust"
            Begin Extent = 
               Top = 9
               Left = 380
               Bottom = 206
               Right = 762
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CFAccnt"
            Begin Extent = 
               Top = 9
               Left = 819
               Bottom = 206
               Right = 1162
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFAccountCreditThreshold';

