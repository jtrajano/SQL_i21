CREATE VIEW [dbo].[vyuCTInventoryItem]

AS 

	SELECT	intKey = CAST(ROW_NUMBER() OVER(ORDER BY IM.intItemId, IL.intLocationId) AS INT),
			IM.intItemId,
			IM.strItemNo,
			IM.strType,
			IM.strDescription,
			IM.strLotTracking,
			IM.strInventoryTracking,
			IM.strStatus,
			IL.intLocationId,
			IM.intCategoryId,
			CR.strCategoryCode,
			IM.intCommodityId,
			CO.strCommodityCode,
			OG.strCountry AS strOrigin,
			CA.intPurchasingGroupId,
			IM.intProductTypeId,
			PG.strName	AS	strPurchasingGroup

	FROM	tblICItem				IM
	JOIN	tblICItemLocation		IL	ON	IL.intItemId				=	IM.intItemId		LEFT
	JOIN	tblICCategory			CR	ON	CR.intCategoryId			=	IM.intCategoryId	LEFT
	JOIN	tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId	LEFT
	JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
										AND	CA.strType					=	'Origin'			LEFT
	JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID		LEFT
	JOIN	tblSMPurchasingGroup	PG	ON	PG.intPurchasingGroupId		=	CA.intPurchasingGroupId
	WHERE	IM.strType IN ('Inventory','Finished Good','Raw Material','Bundle')
