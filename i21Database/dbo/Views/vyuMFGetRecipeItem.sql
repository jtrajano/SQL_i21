﻿CREATE VIEW [dbo].[vyuMFGetRecipeItem]
AS
SELECT r.intRecipeId
	,ri.intRecipeItemId
	,r.strName
	,rhi.strItemNo AS strRecipeItemNo
	,rhi.strDescription AS strRecipeItemDesc
	,cl.strLocationName
	,mp.strProcessName
	,cs.strName AS strCustomer
	,r.intVersionNo
	,rt.strName AS strRecipeItemType
	,i.strItemNo
	,i.strDescription
	,ri.dblQuantity
	--,um.strUnitMeasure strUOM
	,CASE WHEN ISNULL(r.intRecipeTypeId, 0) = 2 AND ISNULL(ri.intRecipeItemTypeId, 0) = 1 THEN '' ELSE um.strUnitMeasure END AS strUOM
	,r.dblQuantity AS dblRecipeQuantity
	,CASE WHEN ISNULL(r.intItemId,0) > 0 THEN um1.strUnitMeasure ELSE um2.strUnitMeasure END AS strRecipeUOM
	,RT1.strName AS strRecipeType
	,r.dtmValidFrom AS dtmRecipeValidFrom
	,r.dtmValidTo AS dtmRecipeValidTo
	,r.strComment
	,ri.dblLowerTolerance
	,ri.dblUpperTolerance
	,cm.strName AS strConsumptionMethod
	,sl.strName AS strStorageLocation
	,ct.strName AS strCommentType
	,ri.dtmValidFrom
	,ri.dtmValidTo
	,mg.strName AS strMarginBy
	,ri.dblMargin
	,ri.ysnCostAppliedAtInvoice
	,r.intLocationId
	,r.intItemId AS intRecipeHeaderItemId
	,ri.intItemId AS intRecipeIngredientItemId
	,ri.intRecipeItemTypeId
	,r.intCustomerId
	,r.ysnActive
	,RecipeSubItem.intSubstituteItemId AS intSubstituteItemId
	,SubstituteItem.strItemNo AS strSubstituteItemNo
	,SubstituteItem.strDescription AS strSubstituteItemDesc
	,ISNULL(RecipeSubItem.dblQuantity, 0) AS dblSubstituteItemQty
	,ri.strItemGroupName
	,ri.dblShrinkage
	,ri.ysnYearValidationRequired
	,ri.ysnMinorIngredient
	,CD.strName AS strCostDriver
	,ri.dblCostRate
	,ri.strDocumentNo
	,ri.ysnPartialFillConsumption
	,CONVERT(BIT, (
			CASE 
				WHEN ISNULL(RecipeSubItem.intRecipeItemId, 0) = 0
					THEN 0
				ELSE 1
				END
			)) AS ysnSubstitute
	,(
		CASE 
			WHEN ri.intRecipeItemTypeId = 2
				THEN ''
			WHEN ri.intRecipeItemTypeId = 1
				AND (
					(
						ri.ysnYearValidationRequired = 1
						AND GETDATE() BETWEEN ri.dtmValidFrom
							AND ri.dtmValidTo
						)
					OR (
						ri.ysnYearValidationRequired = 0
						AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ri.dtmValidFrom)
							AND DATEPART(dy, ri.dtmValidTo)
						)
					)
				THEN 'Active'
			ELSE 'In-Active'
			END
		) COLLATE Latin1_General_CI_AS AS strItemStatus
	,(
		CASE 
			WHEN ri.intRecipeItemTypeId = 2
				THEN NULL
			WHEN r.intCostTypeId = 2
				AND ISNULL(ip.dblAverageCost, 0) > 0
				THEN ISNULL(ip.dblAverageCost, 0)
			WHEN r.intCostTypeId = 3
				AND ISNULL(ip.dblLastCost, 0) > 0
				THEN ISNULL(ip.dblLastCost, 0)
			ELSE ISNULL(ip.dblStandardCost, 0)
			END
		) AS dblCost
	,B.strBook
	,SB.strSubBook
	,r.ysnVirtualRecipe
FROM tblMFRecipe r
LEFT JOIN tblICItem rhi ON r.intItemId = rhi.intItemId
LEFT JOIN tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId
JOIN tblICItem i ON ri.intItemId = i.intItemId
LEFT JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
Left Join tblICItemUOM iu1 on r.intItemUOMId=iu1.intItemUOMId
Left Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
Left Join tblICUnitMeasure um2 on r.intMarginUOMId=um2.intUnitMeasureId
LEFT JOIN tblMFRecipeType RT1 ON RT1.intRecipeTypeId = r.intRecipeTypeId
LEFT JOIN tblSMCompanyLocation cl ON r.intLocationId = cl.intCompanyLocationId
LEFT JOIN tblMFManufacturingProcess mp ON r.intManufacturingProcessId = mp.intManufacturingProcessId
LEFT JOIN vyuARCustomer cs ON r.intCustomerId = cs.[intEntityId]
LEFT JOIN tblMFConsumptionMethod cm ON ri.intConsumptionMethodId = cm.intConsumptionMethodId
LEFT JOIN tblICStorageLocation sl ON ri.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblMFCommentType ct ON ri.intCommentTypeId = ct.intCommentTypeId
LEFT JOIN tblMFMarginBy mg ON ri.intMarginById = mg.intMarginById
LEFT JOIN tblMFRecipeItemType rt ON ri.intRecipeItemTypeId = rt.intRecipeItemTypeId
LEFT JOIN tblMFRecipeSubstituteItem RecipeSubItem ON ri.intRecipeItemId = RecipeSubItem.intRecipeItemId
LEFT JOIN tblICItem SubstituteItem ON RecipeSubItem.intSubstituteItemId = SubstituteItem.intItemId
LEFT JOIN tblMFCostDriver CD ON CD.intCostDriverId = ri.intCostDriverId
LEFT JOIN tblICItemLocation il ON ri.intItemId = il.intItemId
	AND il.intLocationId = r.intLocationId
LEFT JOIN tblICItemPricing ip ON ip.intItemId = ri.intItemId
	AND ip.intItemLocationId = il.intItemLocationId
LEFT JOIN tblCTBook B ON B.intBookId = r.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = r.intSubBookId
