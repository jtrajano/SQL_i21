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
			OG.strCountry AS strOrigin

	FROM	tblICItem			IM
	JOIN	tblICItemLocation	IL	ON	IL.intItemId		=	IM.intItemId		LEFT
	JOIN	tblICCategory		CR	ON	CR.intCategoryId	=	IM.intCategoryId	LEFT
	JOIN	tblICCommodity		CO	ON	CO.intCommodityId	=	IM.intCommodityId	LEFT
	JOIN	tblSMCountry		OG	ON	OG.intCountryID		=	IM.intOriginId				
	WHERE	strType IN ('Inventory','Finished Good','Raw Material','Bundle')
