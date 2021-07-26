CREATE VIEW [dbo].[vyuCTGetItemForItemContract]

AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY IM.intItemId, IL.intLocationId) AS INT)
	, IM.intItemId
	, IM.strItemNo
	, IM.strType
	, IM.strDescription
	, IM.strLotTracking
	, IM.strInventoryTracking
	, IM.strStatus
	, IL.intLocationId
	, IM.intCategoryId
	, CR.strCategoryCode
	, IM.intCommodityId
	, CO.strCommodityCode
	, strOrigin = OG.strCountry
	, CA.intPurchasingGroupId
	, IM.intProductTypeId
	, IM.strCostType
	, CR.dblEstimatedYieldRate
	, IM.ysnInventoryCost
	, IM.ysnBasisContract
FROM tblICItem						IM
JOIN tblICItemLocation				IL	ON	IL.intItemId				=	IM.intItemId
LEFT JOIN tblICCategory				CR	ON	CR.intCategoryId			=	IM.intCategoryId
LEFT JOIN tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId
LEFT JOIN tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId AND CA.strType = 'Origin'
LEFT JOIN tblSMCountry				OG	ON	OG.intCountryID				=	CA.intCountryID
WHERE IM.strType = 'Non-Inventory'
	OR (IM.strType = 'Inventory' AND (ISNULL(IM.intCommodityId, 0) = 0 OR ISNULL(CO.ysnExchangeTraded, 0) = 0))