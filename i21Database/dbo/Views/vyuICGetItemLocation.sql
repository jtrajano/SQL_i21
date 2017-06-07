CREATE VIEW [dbo].[vyuICGetItemLocation]
	AS 

SELECT ItemLocation.intItemLocationId
	, ItemLocation.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, ItemLocation.intLocationId
	, Location.strLocationName
	, Location.strLocationType
	, ItemLocation.intVendorId
	, Vendor.strVendorId
	, strVendorName = Vendor.strName
	, ItemLocation.strDescription
	, ItemLocation.intCostingMethod
	, strCostingMethod = (CASE WHEN intCostingMethod = 1 THEN 'AVG'
								WHEN intCostingMethod = 2 THEN 'FIFO'
								WHEN intCostingMethod = 3 THEN 'LIFO' END)
	, ItemLocation.intAllowNegativeInventory
	, strAllowNegativeInventory = (CASE WHEN intAllowNegativeInventory = 1 THEN 'Yes'
								WHEN intAllowNegativeInventory = 2 THEN 'Yes with Auto Write-Off'
								WHEN intAllowNegativeInventory = 3 THEN 'No' END)
	, ItemLocation.intSubLocationId
	, SubLocation.strSubLocationName
	, ItemLocation.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, ItemLocation.intIssueUOMId
	, strIssueUOM = IssueUOM.strUnitMeasure
	, ItemLocation.intReceiveUOMId
	, strReceiveUOM = ReceiveUOM.strUnitMeasure
	, ItemLocation.intFamilyId
	, strFamily = Family.strSubcategoryId
	, ItemLocation.intClassId
	, strClass = Class.strSubcategoryId
	, ItemLocation.intProductCodeId
	, strProductCode = ProductCode.strRegProdCode
	, ItemLocation.strPassportFuelId1
	, ItemLocation.strPassportFuelId2
	, ItemLocation.strPassportFuelId3
	, ItemLocation.ysnTaxFlag1
	, ItemLocation.ysnTaxFlag2
	, ItemLocation.ysnTaxFlag3
	, ItemLocation.ysnTaxFlag4
	, ItemLocation.ysnPromotionalItem
	, ItemLocation.intMixMatchId
	, MixMatch.strPromoItemListId
	, ItemLocation.ysnDepositRequired
	, ItemLocation.intDepositPLUId
	, strDepositPLU = DepositPLU.strUpcCode
	, ItemLocation.intBottleDepositNo
	, ItemLocation.ysnSaleable
	, ItemLocation.ysnQuantityRequired
	, ItemLocation.ysnScaleItem
	, ItemLocation.ysnFoodStampable
	, ItemLocation.ysnReturnable
	, ItemLocation.ysnPrePriced
	, ItemLocation.ysnOpenPricePLU
	, ItemLocation.ysnLinkedItem
	, ItemLocation.strVendorCategory
	, ItemLocation.ysnCountBySINo
	, ItemLocation.strSerialNoBegin
	, ItemLocation.strSerialNoEnd
	, ItemLocation.ysnIdRequiredLiquor
	, ItemLocation.ysnIdRequiredCigarette
	, ItemLocation.intMinimumAge
	, ItemLocation.ysnApplyBlueLaw1
	, ItemLocation.ysnApplyBlueLaw2
	, ItemLocation.ysnCarWash
	, ItemLocation.intItemTypeCode
	, strItemTypeCode = CAST(ISNULL(ItemTypeCode.intRadiantItemTypeCode, '') AS NVARCHAR)
	, ItemLocation.intItemTypeSubCode
	, ItemLocation.ysnAutoCalculateFreight
	, ItemLocation.intFreightMethodId
	, FreightTerm.strFreightTerm
	, ItemLocation.dblFreightRate
	, ItemLocation.intShipViaId
	, ShipVia.strShipVia
	, ItemLocation.dblReorderPoint
	, ItemLocation.dblMinOrder
	, ItemLocation.dblSuggestedQty
	, ItemLocation.dblLeadTime
	, ItemLocation.strCounted
	, ItemLocation.intCountGroupId
	, CountGroup.strCountGroup
	, ItemLocation.ysnCountedDaily
	, ItemLocation.ysnLockedInventory
	, ItemLocation.intSort
FROM tblICItemLocation ItemLocation
	INNER JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
	INNER JOIN tblICItem Item ON Item.intItemId = ItemLocation.intItemId
	
	LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = ItemLocation.intVendorId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = ItemLocation.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = ItemLocation.intStorageLocationId
	LEFT JOIN vyuICGetItemUOM ReceiveUOM ON ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId
	LEFT JOIN vyuICGetItemUOM IssueUOM ON IssueUOM.intItemUOMId = ItemLocation.intIssueUOMId
	LEFT JOIN tblSTSubcategory Family ON Family.intSubcategoryId = ItemLocation.intFamilyId
	LEFT JOIN tblSTSubcategory Class ON Class.intSubcategoryId = ItemLocation.intClassId
	LEFT JOIN tblSTSubcategoryRegProd ProductCode ON ProductCode.intRegProdId = ItemLocation.intProductCodeId
	LEFT JOIN tblSTPromotionItemList MixMatch ON MixMatch.intPromoItemListId = ItemLocation.intMixMatchId
	LEFT JOIN vyuICGetItemUOM DepositPLU ON DepositPLU.intItemUOMId = ItemLocation.intDepositPLUId
	LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = ItemLocation.intFreightMethodId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = ItemLocation.intShipViaId
	LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = ItemLocation.intCountGroupId
	LEFT JOIN tblSTRadiantItemTypeCode ItemTypeCode ON ItemTypeCode.intRadiantItemTypeCodeId = ItemLocation.intItemTypeCode
