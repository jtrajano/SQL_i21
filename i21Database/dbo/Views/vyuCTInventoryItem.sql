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
			CO.strCommodityCode

	FROM	tblICItem			IM
	JOIN	tblICItemLocation	IL	ON	IL.intItemId		=	IM.intItemId		LEFT
	JOIN	tblICCategory		CR	ON	CR.intCategoryId	=	IM.intCategoryId	LEFT
	JOIN	tblICCommodity		CO	ON	CO.intCommodityId	=	IM.intCommodityId
	WHERE	strType IN ('Inventory','Finished Good','Raw Material','Bundle')
