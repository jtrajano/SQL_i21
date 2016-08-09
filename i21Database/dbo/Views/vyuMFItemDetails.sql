﻿CREATE VIEW dbo.vyuMFItemDetails
AS
	SELECT i.intConcurrencyId, 
		   i.intItemId, 
		   i.strItemNo, 
		   i.strShortName, 
		   i.strType, 
		   i.strDescription, 
		   i.intCategoryId, 
		   i.strStatus, 
		   i.strModelNo, 
		   i.strInventoryTracking, 
		   i.strLotTracking, 
		   i.ysnRequireCustomerApproval, 
		   i.intRecipeId, 
		   i.ysnSanitationRequired, 
		   i.intLifeTime, 
		   i.strLifeTimeType, 
		   i.intReceiveLife, 
		   i.strGTIN, 
		   i.strRotationType, 
		   i.intNMFCId, 
		   i.ysnStrictFIFO, 
		   i.intDimensionUOMId, 
		   i.dblHeight, 
		   i.dblWidth, 
		   i.dblDepth, 
		   i.intWeightUOMId, 
		   i.dblWeight, 
		   i.intMaterialPackTypeId, 
		   i.strMaterialSizeCode, 
		   i.intInnerUnits, 
		   i.intLayerPerPallet, 
		   i.intUnitPerLayer, 
		   i.dblStandardPalletRatio, 
		   i.strMask1, 
		   i.strMask2, 
		   i.strMask3, 
		   i.dblAmount, 
		   i.intCostUOMId, 
		   i.intPackTypeId, 
		   i.strWeightControlCode, 
		   i.dblBlendWeight, 
		   i.dblNetWeight, 
		   i.dblUnitPerCase, 
		   i.intOwnerId, 
		   i.intCustomerId, 
		   i.dblCaseWeight, 
		   i.strWarehouseStatus, 
		   i.ysnSellableItem, 
		   um.strUnitMeasure AS strWeightUOM, 
		   iu.intUnitMeasureId AS intItemUOMId,
		   um1.strUnitMeasure AS strItemUOM,
		   ISNULL(um.strUnitMeasure,um1.strUnitMeasure) AS strUOM,
		   c.strCategoryCode,
		   e.strName AS strItemOwner,
		   ac.intEntityCustomerId AS intItemOwnerId
	FROM tblICItem i
	JOIN tblICCategory c ON c.intCategoryId = i.intCategoryId --AND ysnWarehouseTracked = 1
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = i.intWeightUOMId
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId
	LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = iu.intUnitMeasureId
	LEFT JOIN tblICItemOwner io ON io.intItemId = i.intItemId 
	LEFT JOIN tblARCustomer ac ON ac.intEntityCustomerId = io.intOwnerId
	LEFT JOIN tblEMEntity e ON e.intEntityId = ac.intEntityCustomerId
	WHERE iu.ysnStockUnit = 1 