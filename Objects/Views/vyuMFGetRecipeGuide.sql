CREATE VIEW [dbo].[vyuMFGetRecipeGuide]
	AS 
SELECT intRecipeGuideId,strName,intCustomerId,intFarmId,intFieldId FROM tblMFRecipeGuide
