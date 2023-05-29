CREATE VIEW [dbo].[vyuMFStageWorkOrderCategory]
/****************************************************************
	Title: Work Order Recipe Category
	Description: Retrieve List Item based on Recipe Category
	JIRA: MFG-5056
	Created By: Jonathan Valenzuela
	Date: 05/11/2023
*****************************************************************/
AS
	SELECT RecipeCategory.intCategoryId
		 , StageWorkOrder.intOrderHeaderId 
	FROM tblMFStageWorkOrder AS StageWorkOrder  
	JOIN tblMFWorkOrder AS WorkOrder ON WorkOrder.intWorkOrderId = StageWorkOrder.intWorkOrderId  
	JOIN tblMFRecipe AS Recipe ON Recipe.intItemId = WorkOrder.intItemId AND Recipe.intLocationId = WorkOrder.intLocationId AND Recipe.ysnActive = 1  
	JOIN tblMFRecipeCategory AS RecipeCategory ON RecipeCategory.intRecipeId = Recipe.intRecipeId AND RecipeCategory.intRecipeItemTypeId = 1  
GO


