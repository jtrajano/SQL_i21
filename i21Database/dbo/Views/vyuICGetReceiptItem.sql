CREATE VIEW [dbo].[vyuICGetReceiptItem]
AS 

SELECT 
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId) AS INT)
	,Item.intItemId
	,Item.strItemNo
	,Item.strDescription
	,Item.strType
	,Item.strStatus
	,Item.intCommodityId
	,Item.intLifeTime
	,Item.strLifeTimeType
	,Item.strLotTracking
	,Item.ysnLotWeightsRequired
	,ItemPricing.strPricingMethod
	,dblLastCost = COALESCE(
		dbo.fnICGetPromotionalCostByEffectiveDate(
			Item.intItemId
			, ItemLocation.intItemLocationId
			, COALESCE(ReceiveUOM.intItemUOMId, ItemUOM.intItemUOMId, GrossUOM.intItemUOMId)
			, GETDATE()
		)
		, EffectiveCost.dblCost
		, ItemPricing.dblLastCost
		, 0
	)
	,dblStandardCost = COALESCE(ItemPricing.dblStandardCost, 0)
	,dblSalePrice = COALESCE(EffectivePrice.dblRetailPrice, ItemPricing.dblSalePrice, 0)
	,dblReceiveUOMConvFactor = COALESCE(ReceiveUOM.dblUnitQty, ItemUOM.dblUnitQty, 0)
	,strReceiveUOM = COALESCE(ReceiveUOM.strUnitMeasure, ItemUOM.strUnitMeasure)
	,strReceiveUOMType = COALESCE(ReceiveUOM.strUnitType, ItemUOM.strUnitType)
	,intReceiveUOMId = COALESCE(ReceiveUOM.intItemUOMId, ItemUOM.intItemUOMId)
	,ysnReceiveUOMAllowPurchase = COALESCE(ReceiveUOM.ysnAllowPurchase, ItemUOM.ysnAllowPurchase) 
	,strReceiveUPC = COALESCE(ReceiveUOM.strLongUPCCode, ItemUOM.strLongUPCCode, COALESCE(ReceiveUOM.strUpcCode, ItemUOM.strUpcCode, ''))
	,strLongUPCCode = COALESCE(ReceiveUOM.strLongUPCCode, ItemUOM.strLongUPCCode, COALESCE(ReceiveUOM.strUpcCode, ItemUOM.strUpcCode, '')) 
	,strShortUpc = ISNULL(ReceiveUOM.strUpcCode, ItemUOM.strUpcCode) 
	,strUPCDescription = ISNULL(ReceiveUOM.strUPCDescription, ItemUOM.strUPCDescription) 
	,intCheckDigit = ISNULL(ReceiveUOM.intCheckDigit, ItemUOM.intCheckDigit) 
	,intModifier = ISNULL(ReceiveUOM.intModifier, ItemUOM.intModifier) 
	,intReceiveUnitMeasureId = COALESCE(ReceiveUOM.intUnitMeasureId, ItemUOM.intUnitMeasureId)
	,intGrossUOMId = GrossUOM.intItemUOMId
	,strGrossUOM = GrossUOM.strUnitMeasure
	,intGrossUnitMeasureId = GrossUOM.intUnitMeasureId
	,dblGrossUOMConvFactor = GrossUOM.dblUnitQty
	,ItemLocation.intLocationId
	,ItemLocation.intSubLocationId
	,ItemLocation.intStorageLocationId
	,ItemLocation.ysnStorageUnitRequired
	,StorageLocation.strName AS strStorageLocationName
	,SubLocation.strSubLocationName AS strSubLocationName
	,intCostingMethod = 
			CASE 
				WHEN ISNULL(Item.strLotTracking, 'No') <> 'No' THEN 
					4 -- 4 is for Lot Costing
				ELSE
					ItemLocation.intCostingMethod
			END
	,ysnHasAddOn = CAST(ISNULL(ItemAddOn.ysnHasAddOn, 0) AS BIT)
	,ysnHasAddOnOtherCharge = CAST(ISNULL(AddOnOtherCharge.ysnHasAddOnOtherCharge, 0) AS BIT)
	,Item.intComputeItemTotalOption
	,strVendorProduct = COALESCE(vendorXRefByLocation.strVendorProduct, vendorXRefWithNoLocation.strVendorProduct) 
	,strProductDescription = COALESCE(vendorXRefByLocation.strProductDescription, vendorXRefWithNoLocation.strProductDescription) 
	,intXrefVendorId =  COALESCE(vendorXRefByLocation.intVendorId, vendorXRefWithNoLocation.intVendorId) 
	,intVendorXRefItemUOMId = COALESCE(vendorXRefByLocation.intItemUnitMeasureId, vendorXRefWithNoLocation.intItemUnitMeasureId) 
	,intItemVendorXrefId  = COALESCE(vendorXRefByLocation.intItemVendorXrefId, vendorXRefWithNoLocation.intItemVendorXrefId) 
FROM 
	tblICItem Item

	LEFT JOIN (
		tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
			ON l.intCompanyLocationId = ItemLocation.intLocationId
	)
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId IS NOT NULL 

	OUTER APPLY (
		SELECT TOP 1 
			ReceiveUOM.intItemUOMId
			,ReceiveUOM.dblUnitQty
			,rUOM.strUnitMeasure
			,rUOM.strUnitType
			,ReceiveUOM.ysnAllowPurchase
			,ReceiveUOM.strLongUPCCode
			,ReceiveUOM.strUpcCode
			,ReceiveUOM.intUpcCode
			,ReceiveUOM.strUPCDescription
			,ReceiveUOM.intCheckDigit
			,ReceiveUOM.intModifier
			,ReceiveUOM.intUnitMeasureId
		FROM
			tblICItemUOM ReceiveUOM INNER JOIN tblICUnitMeasure rUOM 
				ON rUOM.intUnitMeasureId = ReceiveUOM.intUnitMeasureId
		WHERE		
			ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId
			AND ReceiveUOM.ysnAllowPurchase = 1	
	) ReceiveUOM		

	OUTER APPLY (
		SELECT TOP 1 
			GrossUOM.intItemUOMId
			,GrossUOM.dblUnitQty
			,gUOM.strUnitMeasure
			,gUOM.strUnitType
			,GrossUOM.intUnitMeasureId
		FROM 
			tblICItemUOM GrossUOM INNER JOIN tblICUnitMeasure gUOM 
				ON gUOM.intUnitMeasureId = GrossUOM.intUnitMeasureId
				AND gUOM.strUnitType IN ('Volume', 'Weight')
		WHERE
			GrossUOM.intItemUOMId = ItemLocation.intGrossUOMId
	) GrossUOM		

	OUTER APPLY (
		SELECT 
			ItemUOM.intItemUOMId
			,ItemUOM.dblUnitQty
			,iUOM.strUnitMeasure
			,iUOM.strUnitType
			,ItemUOM.ysnAllowPurchase
			,ItemUOM.strLongUPCCode
			,ItemUOM.strUpcCode
			,ItemUOM.intUpcCode
			,ItemUOM.strUPCDescription
			,ItemUOM.intCheckDigit
			,ItemUOM.intModifier
			,ItemUOM.intUnitMeasureId
		FROM 
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
				ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
		WHERE
			ItemUOM.intItemId = Item.intItemId			
			AND ItemUOM.ysnAllowPurchase = 1
			AND ReceiveUOM.intItemUOMId IS NULL
	) ItemUOM		

	OUTER APPLY dbo.fnICGetItemCostByEffectiveDate(
		GETDATE()
		, Item.intItemId
		, ItemLocation.intItemLocationId
		, DEFAULT
	) EffectiveCost

	OUTER APPLY dbo.fnICGetItemPriceByEffectiveDate(
		GETDATE()
		, Item.intItemId
		, ItemLocation.intItemLocationId
		, COALESCE(ReceiveUOM.intItemUOMId, ItemUOM.intItemUOMId, GrossUOM.intItemUOMId)
		, DEFAULT
	) EffectivePrice

	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemLocation.intItemId = ItemPricing.intItemId 
		AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId

	LEFT JOIN tblICStorageLocation StorageLocation 
		ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId

	OUTER APPLY (
		SELECT TOP 1 1 as ysnHasAddOn 
		FROM 
			tblICItemAddOn ItemAddOn 
		WHERE 
			ItemAddOn.intItemId = Item.intItemId
	) ItemAddOn

	OUTER APPLY(
		SELECT TOP 1 1 as ysnHasAddOnOtherCharge 
		FROM 
			tblICItemAddOn ItemAddOn INNER JOIN tblICItem ChargeItem 
				ON ChargeItem.intItemId = ItemAddOn.intItemId
		WHERE 
			ItemAddOn.intItemId = Item.intItemId
			AND ChargeItem.strType = 'Other Charge'
	) AddOnOtherCharge

	OUTER APPLY (
		SELECT 
			xref.intItemVendorXrefId
			,xref.intVendorId
			,xref.strProductDescription
			,xref.strVendorProduct
			,xref.intItemUnitMeasureId
		FROM 
			tblICItemVendorXref xref
		WHERE 
			xref.intItemId = Item.intItemId
			AND xref.intItemLocationId = ItemLocation.intItemLocationId
			AND (
				xref.intItemUnitMeasureId = ISNULL(ReceiveUOM.intUnitMeasureId, ItemUOM.intUnitMeasureId)
				OR xref.intItemUnitMeasureId IS NULL 
			)
	) vendorXRefByLocation

	OUTER APPLY (
		SELECT 
			xref.intItemVendorXrefId
			,xref.intVendorId
			,xref.strProductDescription
			,xref.strVendorProduct
			,xref.intItemUnitMeasureId
		FROM 
			tblICItemVendorXref xref
		WHERE 
			xref.intItemId = Item.intItemId
			AND xref.intItemLocationId IS NULL
			AND (
				xref.intItemUnitMeasureId = ISNULL(ReceiveUOM.intItemUOMId, ItemUOM.intItemUOMId)
				OR xref.intItemUnitMeasureId IS NULL 
			)
	) vendorXRefWithNoLocation
