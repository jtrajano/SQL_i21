CREATE VIEW [dbo].[vyuICRecostFormulationDetail]
AS 

SELECT 
	rd.*
	,strItemNo = i.strItemNo
	,strRecipe = r.strName
	,strLocation = cl.strLocationName
FROM 
	tblICRecostFormulationDetail rd 
	LEFT JOIN tblMFRecipe r ON rd.intRecipeId = r.intRecipeId
	LEFT JOIN tblICItem i ON rd.intItemId = i.intItemId
	LEFT JOIN tblSMCompanyLocation cl ON rd.intLocationId = cl.intCompanyLocationId 