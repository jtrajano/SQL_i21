CREATE VIEW [dbo].[vyuMFRecipeItemReport]
AS 
/****************************************************************
	Title: Recipe View Item Report
	Description: Recipe View Item Report intended for Strauss 
	JIRA: MFG-4596 
	HD: HDTN-275494  
	Created By: Jonathan Valenzuela
	Date: 06/22/2023
*****************************************************************/
SELECT strName						AS [Recipe Name]
	 , strRecipeItemNo				AS [Recipe Item No.]
	 , strRecipeItemDesc			AS [Recipe Item Description]
	 , strCustomer					AS [Customer]
	 , intVersionNo					AS [Version No]
	 , dblRecipeQuantity			AS [Recipe Quantity]
	 , strRecipeUOM					AS [Recipe UOM]
	 , strProcessName				AS [Process Name]
	 , strRecipeType				AS [Recipe Type]
	 , ysnActive					AS [Active]
	 , dtmRecipeValidFrom			AS [Recipe Valid From]
	 , dtmRecipeValidTo				AS [Recipe Valid To]
	 , strComment					AS [Comment]
	 , strItemNo					AS [Item No.]
	 , strDescription				AS [Description]
	 , strRecipeItemType			AS [Recipe Item Type]
	 , dblQuantity					AS [Quantity]
	 , strUOM						AS [UOM]
	 , dblLowerTolerance			AS [Lower Tolerance]
	 , dblUpperTolerance			AS [Upper Tolerance]
	 , strConsumptionMethod			AS [Consumption Method]
	 , dtmValidFrom					AS [Valid From]
	 , dtmValidTo					AS [Valid To]
	 , strStorageLocation			AS [Consumption Storage Unit]
	 , strCommentType				AS [Comment Type]
	 , ysnCostAppliedAtInvoice		AS [Cost Applied At Invoice]
	 , strLocationName				AS [Location]
	 , strItemGroupName				AS [Group Name]
	 , dblShrinkage					AS [Shrinkage]
	 , ysnSubstitute				AS [Substitute]
	 , strStorageLocation			AS [Storage Unit]
	 , ysnYearValidationRequired	AS [Year Validation Required]
	 , ysnMinorIngredient			AS [Minor Ingredient]
	 , dblCost						AS [Cost]
	 , strCostDriver				AS [Cost Driver]
	 , dblCostRate					AS [Cost Rate]
	 , strDocumentNo				AS [Document No]
	 , strItemStatus				AS [Status]
	 , ysnPartialFillConsumption	AS [Partial Fill Consumption]
FROM vyuMFGetRecipeItem