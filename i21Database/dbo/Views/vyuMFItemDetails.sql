CREATE VIEW dbo.vyuMFItemDetails
AS
SELECT I.strItemNo
	,I.intItemId AS intProductItemId
	,I.intItemId
	,I.strDescription
	,CONVERT(BIT, 0) AS ysnSubstituteItem
	,I.intConcurrencyId
	,I.strShortName
	,I.strType
	,I.intCategoryId
	,I.strStatus
	,I.strModelNo
	,I.strInventoryTracking
	,I.strLotTracking
	,I.ysnRequireCustomerApproval
	,I.intRecipeId
	,I.ysnSanitationRequired
	,I.intLifeTime
	,I.strLifeTimeType
	,I.intReceiveLife
	,I.strGTIN
	,I.strRotationType
	,I.intNMFCId
	,I.ysnStrictFIFO
	,I.intDimensionUOMId
	,I.dblHeight
	,I.dblWidth
	,I.dblDepth
	,I.intWeightUOMId
	,I.dblWeight
	,I.intMaterialPackTypeId
	,I.strMaterialSizeCode
	,I.intInnerUnits
	,I.intLayerPerPallet
	,I.intUnitPerLayer
	,I.dblStandardPalletRatio
	,I.strMask1
	,I.strMask2
	,I.strMask3
	,I.dblAmount
	,I.intCostUOMId
	,I.intPackTypeId
	,I.strWeightControlCode
	,I.dblBlendWeight
	,I.dblNetWeight
	,I.dblUnitPerCase
	,I.intOwnerId
	,I.intCustomerId
	,I.dblCaseWeight
	,I.strWarehouseStatus
	,I.ysnSellableItem
	,UM.strUnitMeasure AS strWeightUOM
	,IU.intUnitMeasureId AS intItemUOMId
	,UM1.strUnitMeasure AS strItemUOM
	,ISNULL(UM.strUnitMeasure, UM1.strUnitMeasure) AS strUOM
	,C.strCategoryCode
	,E.strName AS strItemOwner
	,AC.[intEntityId] AS intItemOwnerId
	,CONVERT(NVARCHAR, 1) AS strAutoManual
FROM tblICItem I
JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId --AND ysnWarehouseTracked = 1
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = I.intWeightUOMId
LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemOwner IO ON IO.intItemId = I.intItemId
LEFT JOIN tblARCustomer AC ON AC.[intEntityId] = IO.intOwnerId
LEFT JOIN tblEMEntity E ON E.intEntityId = AC.[intEntityId]
WHERE IU.ysnStockUnit = 1

UNION ALL

SELECT DISTINCT I.strItemNo
	,R.intItemId AS intProductItemId
	,I.intItemId
	,I.strDescription
	,CONVERT(BIT, CASE 
			WHEN SI.intSubstituteItemId IS NOT NULL
				THEN 1
			ELSE 0
			END) AS ysnSubstituteItem
	,I.intConcurrencyId
	,I.strShortName
	,I.strType
	,I.intCategoryId
	,I.strStatus
	,I.strModelNo
	,I.strInventoryTracking
	,I.strLotTracking
	,I.ysnRequireCustomerApproval
	,I.intRecipeId
	,I.ysnSanitationRequired
	,I.intLifeTime
	,I.strLifeTimeType
	,I.intReceiveLife
	,I.strGTIN
	,I.strRotationType
	,I.intNMFCId
	,I.ysnStrictFIFO
	,I.intDimensionUOMId
	,I.dblHeight
	,I.dblWidth
	,I.dblDepth
	,I.intWeightUOMId
	,I.dblWeight
	,I.intMaterialPackTypeId
	,I.strMaterialSizeCode
	,I.intInnerUnits
	,I.intLayerPerPallet
	,I.intUnitPerLayer
	,I.dblStandardPalletRatio
	,I.strMask1
	,I.strMask2
	,I.strMask3
	,I.dblAmount
	,I.intCostUOMId
	,I.intPackTypeId
	,I.strWeightControlCode
	,I.dblBlendWeight
	,I.dblNetWeight
	,I.dblUnitPerCase
	,I.intOwnerId
	,I.intCustomerId
	,I.dblCaseWeight
	,I.strWarehouseStatus
	,I.ysnSellableItem
	,U.strUnitMeasure AS strWeightUOM
	,CASE 
		WHEN SI.intSubstituteItemId IS NOT NULL
			THEN IU1.intItemUOMId
		ELSE IU.intItemUOMId
		END AS intItemUOMId
	,UM1.strUnitMeasure AS strItemUOM
	,ISNULL(U.strUnitMeasure, UM1.strUnitMeasure) AS strUOM
	,C.strCategoryCode
	,E.strName AS strItemOwner
	,AC.[intEntityId] AS intItemOwnerId
	,CONVERT(NVARCHAR, 2) AS strAutoManual
FROM dbo.tblMFRecipe R
JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
	AND RI.intRecipeItemTypeId = 1
LEFT JOIN dbo.tblMFRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
	AND SI.intRecipeId = R.intRecipeId
JOIN dbo.tblICItem I ON (I.intItemId = RI.intItemId)
	OR (I.intItemId = SI.intSubstituteItemId)
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId --AND ysnWarehouseTracked = 1
LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemOwner IO ON IO.intItemId = I.intItemId
LEFT JOIN tblARCustomer AC ON AC.[intEntityId] = IO.intOwnerId
LEFT JOIN tblEMEntity E ON E.intEntityId = AC.[intEntityId]
LEFT JOIN tblICItemUOM IU1 ON IU1.intItemId = SI.intSubstituteItemId
	AND IU1.intUnitMeasureId = IU.intUnitMeasureId
