--liquibase formatted sql

-- changeset Von:vyuICGetInventoryValuation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryValuation]
AS

SELECT	intInventoryValuationKeyId  = ISNULL(t.intInventoryTransactionId, 0) 
		,intInventoryTransactionId	= ISNULL(t.intInventoryTransactionId, 0) 
		,i.intItemId
		,strItemNo					= i.strItemNo
		,strItemDescription			= i.strDescription
		,i.intCategoryId
		,strCategory				= c.strCategoryCode
		,i.intCommodityId
		,strCommodity				= commodity.strCommodityCode
		,intLocationId				= t.intCompanyLocationId
		,t.intItemLocationId
		,strLocationName			= [location].strLocationName --ISNULL(InTransitLocation.strLocationName, [Location].strLocationName) --ISNULL([Location].strLocationName, InTransitLocation.strLocationName + ' (' + ItemLocation.strDescription + ')') 
		,intSummaryLocationId  		= t.intInTransitSourceLocationId
		,strSummaryLocationName = CASE WHEN t.intInTransitSourceLocationId IS NOT NULL THEN 
													[location].strLocationName + ' (In-Transit)'
												ELSE 
													[location].strLocationName
											END
		,t.intSubLocationId
		,subLoc.strSubLocationName
		,t.intStorageLocationId
		,strStorageLocationName		= strgLoc.strName
		,dtmDate					= t.dtmDate 
		,strSourceType				= t.strSourceType 										
		,strSourceNumber			= t.strSourceNumber 
		,strTransactionType			= (CASE WHEN ty.strName IN ('Invoice', 'Credit Memo') THEN isnull(invoice.strTransactionType, ty.strName) ELSE ty.strName END)
		,t.strTransactionForm		
		,t.strTransactionId
		,dblBeginningQtyBalance		= CAST(0 AS NUMERIC(38, 20)) 
		,dblQuantity				= ISNULL(t.dblQty, 0)
		,dblRunningQtyBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblCost					= ISNULL(t.dblCost, 0)
		,dblBeginningBalance		= CAST(0 AS NUMERIC(38, 20))
		,dblValue					= ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2)
		,dblValueRounded			= ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2)
		,dblRunningBalance			= CAST(0 AS NUMERIC(38, 20))
		,t.strBatchId
		,CostingMethod.strCostingMethod
		,strUOM						= valuationUnitMeasure.strUnitMeasure
		,strStockUOM				= stockUnitMeasure.strUnitMeasure
		,dblQuantityInStockUOM		= CAST(ISNULL(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, stockUOM.intItemUOMId, t.dblQty), 0) AS NUMERIC(18, 6)) 
		,dblCostInStockUOM			= ISNULL(dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, stockUOM.intItemUOMId, t.dblCost), 0)
		,dblPrice					= ISNULL(ItemPricing.dblSalePrice ,0)
		,strBOLNumber				= t.strBOLNumber 
		,strEntity					= e.strName		
		,e.intEntityId
		,strParentLotNumber			= ParentLot.strParentLotNumber
		,strLotNumber				= l.strLotNumber
		,strAdjustedTransaction		= t.strRelatedTransactionId
		,ysnInTransit				= CAST(CASE WHEN t.intInTransitSourceLocationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) 
		,t.dtmCreated
		,t.intTicketId				
		,strTransactionUOM			= transactionUnitMeasure.strUnitMeasure 
		,strDescription				= t.strDescription 
		,intItemStockUOM			= stockUOM.intItemUOMId 
		,intUnitMeasureStockUOM		= stockUnitMeasure.intUnitMeasureId
		,t.strAccountIdInventory
		,t.strAccountIdInTransit

		,i.intCertificationId
		,Certification.strCertificationName
		,strGrade					= Grade.strDescription
		,strOrigin 					= Origin.strDescription
		,strProductType				= ProductType.strDescription
		,strRegion 					= Region.strDescription
		,strSeason 					= Season.strDescription
		,strClass 					= Class.strDescription
		,strProductLine 			= ProductLine.strDescription
FROM 	tblICInventoryTransaction t 
		INNER JOIN tblICItem i 
			ON t.intItemId = i.intItemId
		
		INNER JOIN tblICItemUOM stockUOM 		
			ON stockUOM.intItemId = i.intItemId
			AND stockUOM.ysnStockUnit = 1 
		INNER JOIN tblICUnitMeasure stockUnitMeasure
			ON stockUnitMeasure.intUnitMeasureId = stockUOM.intUnitMeasureId 
		
		LEFT JOIN tblICItemUOM valuationUOM 
			ON valuationUOM.intItemUOMId = t.intItemUOMId
		LEFT JOIN tblICUnitMeasure valuationUnitMeasure
			ON valuationUnitMeasure.intUnitMeasureId = valuationUOM.intUnitMeasureId 
			
		LEFT JOIN tblICItemUOM transactionUOM 
			ON transactionUOM.intItemUOMId = t.intTransactionItemUOMId
		LEFT JOIN tblICUnitMeasure transactionUnitMeasure
			ON transactionUnitMeasure.intUnitMeasureId = transactionUOM.intUnitMeasureId 
			
		LEFT JOIN tblICCategory c 
			ON c.intCategoryId = i.intCategoryId
		LEFT JOIN tblICCommodity commodity
			ON commodity.intCommodityId = i.intCommodityId		
		LEFT JOIN tblICInventoryTransactionType ty 
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		LEFT JOIN tblICStorageLocation strgLoc 
			ON strgLoc.intStorageLocationId = t.intStorageLocationId
		LEFT JOIN tblSMCompanyLocation [location]
			ON [location].intCompanyLocationId = t.intCompanyLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation subLoc
			ON subLoc.intCompanyLocationSubLocationId = t.intSubLocationId
		LEFT JOIN tblICCostingMethod CostingMethod
			ON CostingMethod.intCostingMethodId = t.intCostingMethod

		LEFT JOIN tblICItemPricing ItemPricing
			ON ItemPricing.intItemId = i.intItemId
			AND ItemPricing.intItemLocationId = t.intItemLocationId
		LEFT JOIN tblICLot l
			ON l.intLotId = t.intLotId
		LEFT JOIN tblICParentLot ParentLot
			ON ParentLot.intItemId = l.intItemId
			AND ParentLot.intParentLotId = l.intParentLotId


		LEFT JOIN tblARInvoice invoice
			ON invoice.intInvoiceId = t.intTransactionId
			AND invoice.strInvoiceNumber = t.strTransactionId
			AND ty.intTransactionTypeId in (33, 45)	

		LEFT JOIN tblEMEntity e 
			ON e.intEntityId = t.intSourceEntityId 

		LEFT JOIN tblICCertification Certification
			ON Certification.intCertificationId = i.intCertificationId
		LEFT JOIN tblICCommodityAttribute Grade 
			ON Grade.intCommodityAttributeId = i.intGradeId
		LEFT JOIN tblICCommodityAttribute Origin 
			ON Origin.intCommodityAttributeId = i.intOriginId
		LEFT JOIN tblICCommodityAttribute ProductType
			ON ProductType.intCommodityAttributeId = i.intProductTypeId
		LEFT JOIN tblICCommodityAttribute Region
			ON Region.intCommodityAttributeId = i.intRegionId
		LEFT JOIN tblICCommodityAttribute Season
			ON Season.intCommodityAttributeId = i.intSeasonId
		LEFT JOIN tblICCommodityAttribute Class
			ON Class.intCommodityAttributeId = i.intClassVarietyId
		LEFT JOIN tblICCommodityProductLine ProductLine
			ON ProductLine.intCommodityProductLineId = i.intProductLineId
WHERE	i.strType NOT IN (
			'Other Charge'
			,'Non-Inventory'
			,'Service'
			,'Software'
			,'Comment'
			,'Bundle'
		)



