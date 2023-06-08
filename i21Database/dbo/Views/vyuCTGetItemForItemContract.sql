
Create VIEW [dbo].[vyuCTGetItemForItemContract]    
    
AS    
    SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY a.intItemId, a.intLocationId) AS INT)    , * 
	FROM (
		SELECT 
		  IM.intItemId    
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
		 , strPurchasingGroup = PG.strName    
		 , IM.strCostType    
		 , CR.dblEstimatedYieldRate    
		 , IM.ysnInventoryCost    
		 , IM.ysnBasisContract    
		 , intBundleId = BI.intItemId    
		 , intBundleItemId = NULL    
		 , UOM.intUnitMeasureId  
		 , UOM.strUnitMeasure  
		  , IU.intItemUOMId   
		FROM tblICItem      IM    
		JOIN tblICItemLocation    IL ON IL.intItemId    = IM.intItemId    
		INNER JOIN tblICItemUOM IU on IU.intItemId = IM.intItemId    
		LEFT JOIN tblICCategory    CR ON CR.intCategoryId   = IM.intCategoryId    
		LEFT JOIN tblICCommodity   CO ON CO.intCommodityId   = IM.intCommodityId    
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId AND CA.strType = 'Origin'    
		LEFT JOIN tblSMCountry    OG ON OG.intCountryID    = CA.intCountryID    
		LEFT JOIN tblSMPurchasingGroup  PG ON PG.intPurchasingGroupId  = CA.intPurchasingGroupId    
		LEFT JOIN vyuICGetBundleItem  BI ON BI.intBundleItemId   = IM.intItemId    
		 CROSS APPLY   
		   (   
		   SELECT IUOM.intItemId, IUOM.intUnitMeasureId, UOM.strUnitMeasure  
		   FROM tblICItemUOM IUOM  
		   JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId  
		   WHERE IUOM.ysnStockUnit = 1 AND IUOM.intItemId = IM.intItemId  
		   ) UOM   
		WHERE (IM.strType = 'Non-Inventory'      
		 OR (IM.strType in ('Inventory') AND (ISNULL(IM.intCommodityId, 0) = 0 OR ISNULL(CO.ysnExchangeTraded, 0) = 0)))  
		 and IU.ysnStockUnit = 1 AND IM.strType NOT in ('Other Charge', 'Service')


		 UNION ALL

		 SELECT 
		  IM.intItemId    
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
		 , strPurchasingGroup = PG.strName    
		 , IM.strCostType    
		 , CR.dblEstimatedYieldRate    
		 , IM.ysnInventoryCost    
		 , IM.ysnBasisContract    
		 , intBundleId = BI.intItemId    
		 , intBundleItemId = NULL    
		 , intUnitMeasureId = CASE WHEN  UOM.ysnStockUnit = 0 THEN NULL ELSE UOM.intUnitMeasureId   END
		 , strUnitMeasure = CASE WHEN UOM.ysnStockUnit = 0 THEN NULL ELSE UOM.strUnitMeasure   END
		  , UOM.intItemUOMId   
		FROM tblICItem      IM    
		JOIN tblICItemLocation    IL ON IL.intItemId    = IM.intItemId    
		LEFT JOIN tblICCategory    CR ON CR.intCategoryId   = IM.intCategoryId    
		LEFT JOIN tblICCommodity   CO ON CO.intCommodityId   = IM.intCommodityId    
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId AND CA.strType = 'Origin'    
		LEFT JOIN tblSMCountry    OG ON OG.intCountryID    = CA.intCountryID    
		LEFT JOIN tblSMPurchasingGroup  PG ON PG.intPurchasingGroupId  = CA.intPurchasingGroupId    
		LEFT JOIN vyuICGetBundleItem  BI ON BI.intBundleItemId   = IM.intItemId    
		 CROSS APPLY   
		   (   
			SELECT * FROM (
				 SELECT TOP 1 IUOM.intItemId, IUOM.intUnitMeasureId, UOM.strUnitMeasure  , intItemUOMId, IUOM.ysnStockUnit 
				   FROM tblICItemUOM IUOM  
				   JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId  
				   WHERE  IUOM.intItemId = IM.intItemId   
				   ORDER BY IUOM.ysnStockUnit DESC
			) a
		   ) UOM   
		WHERE   
		IM.strType in ('Other Charge', 'Service') 
		
	) a
GO


