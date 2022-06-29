CREATE VIEW [dbo].[vyuMFGetItemSubstitutionView]
	AS
SELECT ROW_NUMBER() OVER(ORDER BY i.strItemNo) intRowNo
	,i.strItemNo strRecipeItemNo
	,i.strDescription strRecipeItemDesc
	,oi.strItemNo strOriginalItemNo
	,oi.strDescription strOriginalItemDesc
	,ri.dblQuantity dblOriginalItemQuantity
	,um1.strUnitMeasure strOriginalItemUOM
	,st.strName strSubstitutionType
	,si.strItemNo strSubstitutedItemNo
	,si.strDescription strSubstitutedItemDesc
	,sd.dblSubstituteRatio
	,sd.dblMaxSubstituteRatio
	,sd.dblPercent
	,ri1.dblQuantity dblSubstitutedItemQuantity
	,um2.strUnitMeasure strSubstitutedItemUOM
	,CASE 
		WHEN s.intItemSubstitutionTypeId = 1 
			THEN sd.dtmValidFrom
		WHEN s.intItemSubstitutionTypeId = 2
			THEN null
		END dtmValidFrom
	,CASE 
		WHEN s.intItemSubstitutionTypeId = 1 
			THEN sd.dtmValidTo
		WHEN s.intItemSubstitutionTypeId = 2 
			THEN null
		END dtmValidTo
	,s.ysnCancelled
	,e1.strName strCreatedUserName
	,s.dtmCreated
	,e2.strName strLastUpdateUserName
	,s.dtmLastModified
	,cl.intCompanyLocationId intLocationId
	,cl.strLocationName
FROM tblMFItemSubstitution s
INNER JOIN tblMFItemSubstitutionDetail sd ON s.intItemSubstitutionId = sd.intItemSubstitutionId
INNER JOIN tblMFItemSubstitutionRecipe sr ON sd.intItemSubstitutionId = sr.intItemSubstitutionId AND sr.ysnApplied = 1
INNER JOIN tblMFRecipe r ON r.intRecipeId = sr.intRecipeId
INNER JOIN tblICItem i ON i.intItemId = r.intItemId
INNER JOIN tblICItem oi ON s.intItemId = oi.intItemId
INNER JOIN tblICItem si ON sd.intItemId = si.intItemId
INNER JOIN tblMFItemSubstitutionType st ON st.intItemSubstitutionTypeId = s.intItemSubstitutionTypeId
LEFT JOIN tblMFRecipeItem ri ON ri.intRecipeItemId = sr.intRecipeItemId
INNER JOIN tblICItemUOM oiu ON ri.intItemUOMId = oiu.intItemUOMId
INNER JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = oiu.intUnitMeasureId
INNER JOIN tblMFItemSubstitutionRecipeDetail srd ON srd.intItemSubstitutionDetailId = sd.intItemSubstitutionDetailId AND srd.intItemSubstitutionRecipeId = sr.intItemSubstitutionRecipeId
LEFT JOIN tblMFRecipeItem ri1 ON ri1.intRecipeItemId = srd.intRecipeItemId
LEFT JOIN tblICItemUOM siu ON siu.intItemUOMId = ri1.intItemUOMId
LEFT JOIN tblICUnitMeasure um2 ON um2.intUnitMeasureId = siu.intUnitMeasureId
LEFT JOIN tblEMEntity e1 ON s.intCreatedUserId=e1.intEntityId
LEFT JOIN [tblEMEntityType] et1 ON e1.intEntityId=et1.intEntityId AND et1.strType='User'
LEFT JOIN tblEMEntity e2 ON s.intLastModifiedUserId=e2.intEntityId
LEFT JOIN [tblEMEntityType] et2 ON e2.intEntityId=et2.intEntityId AND et2.strType='User'
INNER JOIN tblSMCompanyLocation cl on s.intLocationId=cl.intCompanyLocationId
