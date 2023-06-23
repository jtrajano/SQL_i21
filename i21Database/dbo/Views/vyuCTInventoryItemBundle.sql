CREATE VIEW [dbo].[vyuCTInventoryItemBundle]

AS 
	--column mapping change here should also update vyuCTInventoryItem
	SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intItemId, intLocationId) AS INT), 
	* FROM (
	SELECT	
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
			PG.strName	AS	strPurchasingGroup,
			IM.strCostType,
			CR.dblEstimatedYieldRate,
			IM.ysnInventoryCost,
			IM.ysnBasisContract,
			NULL AS	intBundleId, 
			NULL as intBundleItemId,
			ICC.strProductType,
			ICC.strGrade,
			ICC.strRegion,
			ICC.strSeason,
			ICC.strClass,
			ICC.strProductLine,
		   strXrefVendorProduct = x.strVendorProduct,
		   strXrefCustomerProduct = xc.strCustomerProduct
	FROM	tblICItem				IM
	JOIN	tblICItemLocation		IL	ON	IL.intItemId				=	IM.intItemId		LEFT
	JOIN	tblICCategory			CR	ON	CR.intCategoryId			=	IM.intCategoryId	LEFT
	JOIN	tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId	LEFT
	JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
										AND	CA.strType					=	'Origin'			LEFT
	JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID		LEFT
	JOIN	tblSMPurchasingGroup	PG	ON	PG.intPurchasingGroupId		=	CA.intPurchasingGroupId LEFT 
	JOIN	 vyuICGetCompactItem ICC ON ICC.intItemId = IM.intItemId
	left join tblICItemVendorXref x on x.intItemId = IM.intItemId
	left join tblICItemCustomerXref xc on xc.intItemId = IM.intItemId
			
	WHERE	IM.strType IN ('Inventory','Finished Good','Raw Material')


	UNION ALL

	SELECT	
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
			PG.strName	AS	strPurchasingGroup,
			IM.strCostType,
			CR.dblEstimatedYieldRate,
			IM.ysnInventoryCost,
			IM.ysnBasisContract,
			null AS	intBundleId, 
			null as intBundleItemId,
			ICC.strProductType,
			ICC.strGrade,
			ICC.strRegion,
			ICC.strSeason,
			ICC.strClass,
			ICC.strProductLine,
		   strXrefVendorProduct = x.strVendorProduct,
		   strXrefCustomerProduct = xc.strCustomerProduct
	FROM	tblICItem				IM
	JOIN	tblICItemLocation		IL	ON	IL.intItemId				=	IM.intItemId		
	LEFT JOIN	tblICCategory			CR	ON	CR.intCategoryId			=	IM.intCategoryId	
	LEFT JOIN	tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId	
	LEFT JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
										AND	CA.strType					=	'Origin'			
	LEFT JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID		
	LEFT JOIN	tblSMPurchasingGroup	PG	ON	PG.intPurchasingGroupId		=	CA.intPurchasingGroupId		
	LEFT JOIN	 vyuICGetCompactItem ICC ON ICC.intItemId = IM.intItemId	
	left join tblICItemVendorXref x on x.intItemId = IM.intItemId
	left join tblICItemCustomerXref xc on xc.intItemId = IM.intItemId
	WHERE	IM.strType IN ('Bundle')

	UNION ALL

	SELECT	
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
			PG.strName	AS	strPurchasingGroup,
			IM.strCostType,
			CR.dblEstimatedYieldRate,
			IM.ysnInventoryCost,
			IM.ysnBasisContract,
			BI.intItemId AS	intBundleId, 
			NULL as intBundleItemId,
			ICC.strProductType,
			ICC.strGrade,
			ICC.strRegion,
			ICC.strSeason,
			ICC.strClass,
			ICC.strProductLine,
		   strXrefVendorProduct = x.strVendorProduct,
		   strXrefCustomerProduct = xc.strCustomerProduct
	FROM	tblICItem				IM
	JOIN	tblICItemLocation		IL	ON	IL.intItemId				=	IM.intItemId		
	LEFT JOIN	tblICCategory			CR	ON	CR.intCategoryId			=	IM.intCategoryId	
	LEFT JOIN	tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId	
	LEFT JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
										AND	CA.strType					=	'Origin'			
	LEFT JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID		
	LEFT JOIN	tblSMPurchasingGroup	PG	ON	PG.intPurchasingGroupId		=	CA.intPurchasingGroupId		
	JOIN	vyuICGetBundleItem		BI	ON	BI.intBundleItemId			=	IM.intItemId 
	LEFT  JOIN	 vyuICGetCompactItem ICC ON ICC.intItemId = IM.intItemId
	left join tblICItemVendorXref x on x.intItemId = IM.intItemId
	left join tblICItemCustomerXref xc on xc.intItemId = IM.intItemId
	--LEFT JOIN	vyuICGetBundleItem		B2	ON	B2.intItemId				=	IM.intItemId
	WHERE	IM.strType IN ('Inventory','Finished Good','Raw Material','Bundle')
	
	UNION ALL

	SELECT	
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
			PG.strName	AS	strPurchasingGroup,
			IM.strCostType,
			CR.dblEstimatedYieldRate,
			IM.ysnInventoryCost,
			IM.ysnBasisContract,
			NULL AS	intBundleId, 
			B2.intBundleItemId as intBundleItemId,
			ICC.strProductType,
			ICC.strGrade,
			ICC.strRegion,
			ICC.strSeason,
			ICC.strClass,
			ICC.strProductLine,
		   strXrefVendorProduct = x.strVendorProduct,
		   strXrefCustomerProduct = xc.strCustomerProduct
	FROM	tblICItem				IM
	JOIN	tblICItemLocation		IL	ON	IL.intItemId				=	IM.intItemId		
	LEFT JOIN	tblICCategory			CR	ON	CR.intCategoryId			=	IM.intCategoryId	
	LEFT JOIN	tblICCommodity			CO	ON	CO.intCommodityId			=	IM.intCommodityId	
	LEFT JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId
										AND	CA.strType					=	'Origin'			
	LEFT JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	CA.intCountryID		
	LEFT JOIN	tblSMPurchasingGroup	PG	ON	PG.intPurchasingGroupId		=	CA.intPurchasingGroupId		
	JOIN	vyuICGetBundleItem		B2	ON	B2.intItemId				=	IM.intItemId
	LEFT  JOIN	 vyuICGetCompactItem ICC ON ICC.intItemId = IM.intItemId
	left join tblICItemVendorXref x on x.intItemId = IM.intItemId
	left join tblICItemCustomerXref xc on xc.intItemId = IM.intItemId
	WHERE	IM.strType IN ('Inventory','Finished Good','Raw Material','Bundle')


	) fq
