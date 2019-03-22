CREATE VIEW [dbo].[vyuSMMasterContactMenu]
AS 
SELECT [MasterMenu].[intMenuID]
      ,[MasterMenu].[strMenuName]
      ,[MasterMenu].[strModuleName]
      ,[MasterMenu].[intParentMenuID]
      ,[MasterMenu].[strDescription]
      ,[MasterMenu].[strCategory]
      ,[MasterMenu].[strType]
      ,[MasterMenu].[strCommand]
      ,[MasterMenu].[strIcon]
      ,[MasterMenu].[ysnVisible]
      ,[MasterMenu].[ysnExpanded]
      ,[MasterMenu].[ysnIsLegacy]
      ,[MasterMenu].[ysnLeaf]
      ,[MasterMenu].[intSort]
	  ,ISNULL([ContactMenu].[ysnContactOnly], 0) AS [ysnContactOnly]
      ,[MasterMenu].[intConcurrencyId] FROM tblSMMasterMenu MasterMenu
LEFT JOIN tblSMContactMenu ContactMenu ON MasterMenu.intMenuID = ContactMenu.intMasterMenuId
