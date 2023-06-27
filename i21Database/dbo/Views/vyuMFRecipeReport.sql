CREATE VIEW [dbo].[vyuMFRecipeReport]
AS 
/****************************************************************
	Title: Recipe View Report
	Description: Recipe View Report intended for Strauss 
	JIRA: MFG-4596 
	HD: HDTN-275494  
	Created By: Jonathan Valenzuela
	Date: 06/22/2023
*****************************************************************/
SELECT strName				AS [Recipe Name]
	 , strCustomer			AS [Customer]
	 , strItemNo			AS [Item No]
	 , strDescription		AS [Description]
	 , dblQuantity			AS [Quantity]
	 , strUOM				AS [UOM]
	 , intVersionNo			AS [Version No]
	 , ysnActive			AS [Active]
	 , strLocationName		AS [Location]
	 , dtmValidFrom			AS [Valid From]
	 , dtmValidTo			AS [Valid To]
	 , strComment			AS [Comment]
	 , strProcessName		AS [Process Name]
FROM vyuMFGetRecipe