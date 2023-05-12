CREATE VIEW [dbo].[vyuMFStageWorkOrderItem]
/****************************************************************
	Title: Stage Work Order Recipe Input Item
	Description: Retrieve List Item based on Stage Work Order Recipe
	JIRA: MFG-5056
	Created By: Jonathan Valenzuela
	Date: 05/11/2023
*****************************************************************/
AS
	SELECT Item.intItemId
		 , StageWorkOrder.intOrderHeaderId
	FROM tblMFStageWorkOrder AS StageWorkOrder  
	JOIN tblMFWorkOrder AS WorkOrder ON WorkOrder.intWorkOrderId = StageWorkOrder.intWorkOrderId  
	LEFT JOIN tblMFRecipe AS Recipe ON Recipe.intItemId = WorkOrder.intItemId AND Recipe.intLocationId = WorkOrder.intLocationId AND Recipe.ysnActive = 1  
	JOIN tblMFRecipeItem AS RecipeItem ON RecipeItem.intRecipeId = Recipe.intRecipeId AND RecipeItem.intRecipeItemTypeId = 1  
	LEFT JOIN tblMFRecipeSubstituteItem AS RecipeSubstituteItem ON RecipeSubstituteItem.intRecipeItemId = RecipeItem.intRecipeItemId  
	JOIN tblICItem AS Item ON (Item.intItemId = RecipeItem.intItemId OR Item.intItemId = RecipeSubstituteItem.intSubstituteItemId)  
GO


