CREATE VIEW dbo.[vyuCFSearchIndexPricingDetail]
AS
SELECT cfIPH.intIndexPricingBySiteGroupHeaderId, cfIPH.dtmDate, cfSG.intSiteGroupId, cfSG.strSiteGroup, cfSG.strDescription AS strSiteGroupDescription, cfSG.strType AS strSiteGroupType, cfPI.intPriceIndexId, cfPI.strPriceIndex, cfPI.strDescription AS strIndexDescription, 
             cfIPD.intIndexPricingBySiteGroupId, cfIPD.intTime, cfIPD.dblIndexPrice, icItem.intItemId, icItem.strItemNo, icItem.strShortName, icItem.strType AS strItemType, icItem.strDescription AS strItemDescription
FROM   dbo.tblCFIndexPricingBySiteGroupHeader AS cfIPH LEFT OUTER JOIN
             dbo.tblCFSiteGroup AS cfSG ON cfIPH.intSiteGroupId = cfSG.intSiteGroupId LEFT OUTER JOIN
             dbo.tblCFPriceIndex AS cfPI ON cfIPH.intPriceIndexId = cfPI.intPriceIndexId LEFT OUTER JOIN
             dbo.tblCFIndexPricingBySiteGroup AS cfIPD ON cfIPH.intIndexPricingBySiteGroupHeaderId = cfIPD.intIndexPricingBySiteGroupHeaderId LEFT OUTER JOIN
             dbo.tblICItem AS icItem ON cfIPD.intARItemID = icItem.intItemId
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchIndexPricingDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'd
   End
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchIndexPricingDetail';


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
         Begin Table = "cfIPH"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfIPD"
            Begin Extent = 
               Top = 9
               Left = 505
               Bottom = 206
               Right = 896
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "icItem"
            Begin Extent = 
               Top = 9
               Left = 953
               Bottom = 206
               Right = 1326
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfSG"
            Begin Extent = 
               Top = 9
               Left = 1383
               Bottom = 206
               Right = 1621
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cfPI"
            Begin Extent = 
               Top = 9
               Left = 1678
               Bottom = 206
               Right = 1916
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
      En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vyuCFSearchIndexPricingDetail';

