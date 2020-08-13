CREATE VIEW [dbo].[vyuSTSearchRevertHolderDetail]
AS
SELECT --DISTINCT
	RHD.intRevertHolderDetailId
	, RHD.intRevertHolderId
	, RHD.strTableName COLLATE Latin1_General_CI_AS AS strTableName
	, RHD.strTableColumnName COLLATE Latin1_General_CI_AS AS strTableColumnName
	, RHD.strTableColumnDataType COLLATE Latin1_General_CI_AS AS strTableColumnDataType
	, RHD.intPrimaryKeyId
	, RHD.intItemId
	, RHD.intItemUOMId
	, RHD.intItemLocationId
	, RHD.intItemPricingId
	, RHD.intItemSpecialPricingId
	, RHD.intCompanyLocationId
	, RHD.dtmDateModified
	, RHD.strChangeDescription COLLATE Latin1_General_CI_AS AS strChangeDescription
	, RHD.strOldData COLLATE Latin1_General_CI_AS AS strOldData
	, RHD.strNewData COLLATE Latin1_General_CI_AS AS strNewData
	, Item.strItemNo
	, Item.strDescription AS strItemDescription
	, Uom.strLongUPCCode
	, CompanyLoc.strLocationName
	, RHD.intConcurrencyId
	, strPreviewNewData = CASE
							 WHEN revertHolder.intRevertType = 1
								THEN CASE
										-- tblICItem
										WHEN RHD.strTableColumnName = 'intCategoryId'
											THEN ISNULL(Category.strCategoryCode, '')
										WHEN RHD.strTableColumnName = 'strCountCode'
											THEN ISNULL(Item.strCountCode, '')

										-- tblICItemLocation
										WHEN RHD.strTableColumnName = 'intDepositPLUId'
											THEN ISNULL(Uom_New.strUpcCode, '')
										WHEN RHD.strTableColumnName = 'strCounted'
											THEN ISNULL(ItemLoc.strCounted, '')
										WHEN RHD.strTableColumnName = 'intFamilyId'
											THEN ISNULL(SubCatFamily_New.strSubcategoryId, '')
										WHEN RHD.strTableColumnName = 'intClassId'
											THEN ISNULL(SubCatClass_New.strSubcategoryId, '')
										WHEN RHD.strTableColumnName = 'intProductCodeId'
											THEN ISNULL(ProductCode_New.strRegProdCode, '')
										WHEN RHD.strTableColumnName = 'intVendorId'
											THEN ISNULL(Entity_New.strName, '')
										WHEN RHD.strTableColumnName = 'intMinimumAge'
											THEN CAST(ItemLoc.intMinimumAge AS NVARCHAR(50))
										WHEN RHD.strTableColumnName = 'dblMinOrder'
											THEN CAST(ItemLoc.dblMinOrder AS NVARCHAR(50))
										WHEN RHD.strTableColumnName = 'dblSuggestedQty'
											THEN CAST(ItemLoc.dblSuggestedQty AS NVARCHAR(50))
										WHEN RHD.strTableColumnName = 'intStorageLocationId'
											THEN ISNULL(StorageLoc_New.strName, '')
										WHEN RHD.strTableColumnName = 'intCountGroupId'
											THEN ISNULL(CountGroup_New.strCountGroup, '')

										WHEN RHD.strTableColumnName = 'ysnTaxFlag1'
											THEN CASE WHEN ItemLoc.ysnTaxFlag1 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnTaxFlag2'
											THEN CASE WHEN ItemLoc.ysnTaxFlag2 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnTaxFlag3'
											THEN CASE WHEN ItemLoc.ysnTaxFlag3 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnTaxFlag4'
											THEN CASE WHEN ItemLoc.ysnTaxFlag4 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnDepositRequired'
											THEN CASE WHEN ItemLoc.ysnDepositRequired = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnQuantityRequired' 
											THEN CASE WHEN ItemLoc.ysnQuantityRequired = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnScaleItem' 
											THEN CASE WHEN ItemLoc.ysnScaleItem = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnFoodStampable' 
											THEN CASE WHEN ItemLoc.ysnFoodStampable = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnReturnable' 
											THEN CASE WHEN ItemLoc.ysnReturnable = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnSaleable'
											THEN CASE WHEN ItemLoc.ysnSaleable = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnIdRequiredLiquor' 
											THEN CASE WHEN ItemLoc.ysnIdRequiredLiquor = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnIdRequiredCigarette' 
											THEN CASE WHEN ItemLoc.ysnIdRequiredCigarette = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnPromotionalItem'
											THEN CASE WHEN ItemLoc.ysnPromotionalItem = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnPrePriced'
											THEN CASE WHEN ItemLoc.ysnPrePriced = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnApplyBlueLaw1'
											THEN CASE WHEN ItemLoc.ysnApplyBlueLaw1 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnApplyBlueLaw2'
											THEN CASE WHEN ItemLoc.ysnApplyBlueLaw2 = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnCountedDaily'		
											THEN CASE WHEN ItemLoc.ysnCountedDaily = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'strCounted'
											THEN CASE WHEN ItemLoc.strCounted = 1 THEN 'Yes' ELSE 'No' END
										WHEN RHD.strTableColumnName = 'ysnCountBySINo'
											THEN CASE WHEN ItemLoc.ysnCountBySINo = 1 THEN 'Yes' ELSE 'No' END

										ELSE 
											ISNULL(RHD.strNewData, '')
									END			
									

							 WHEN revertHolder.intRevertType = 2
								THEN CASE
									WHEN RHD.strTableColumnName = 'dblSalePrice'
										THEN CAST(ItemPricing_New.dblSalePrice AS NVARCHAR(50))
									WHEN RHD.strTableColumnName = 'dblStandardCost'
										THEN CAST(ItemPricing_New.dblStandardCost AS NVARCHAR(50))
									WHEN RHD.strTableColumnName = 'dblLastCost'
										THEN CAST(ItemPricing_New.dblLastCost AS NVARCHAR(50))

									WHEN RHD.strTableColumnName = 'dblUnitAfterDiscount'
										THEN CAST(ItemSpecialPricing_New.dblUnitAfterDiscount AS NVARCHAR(50))
									WHEN RHD.strTableColumnName = 'dtmBeginDate'
										THEN CONVERT(VARCHAR(10), CAST(ItemSpecialPricing_New.dtmBeginDate AS DATE), 101) -- CAST(ItemSpecialPricing_Old.dtmBeginDate AS NVARCHAR(20))
									WHEN RHD.strTableColumnName = 'dtmEndDate'
										THEN CONVERT(VARCHAR(10), CAST(ItemSpecialPricing_New.dtmEndDate AS DATE), 101) -- CAST(ItemSpecialPricing_Old.dtmEndDate AS NVARCHAR(20))

									ELSE 
										ISNULL(RHD.strNewData, '')
								END

							ELSE  
								ISNULL(RHD.strNewData, '')
					END COLLATE Latin1_General_CI_AS
	, strPreviewOldData	= CASE
								WHEN RHD.strTableColumnDataType = 'DATETIME'
									THEN CONVERT(VARCHAR(10), CAST(RHD.strOldData AS DATE), 101)
								WHEN RHD.strOldData = 'true' THEN 'Yes'
								WHEN RHD.strOldData = 'false' THEN 'No'
								ELSE
									ISNULL(RHD.strPreviewOldData, RHD.strOldData)
						END COLLATE Latin1_General_CI_AS
--, strPreviewOldData = CASE
--							WHEN RHD.strTableColumnName = 'intCategoryId'
--								THEN Category_Old.strCategoryCode
--							WHEN RHD.strTableColumnName = 'strCountCode'
--								THEN OldItemValue.strCountCode

--							--WHEN RHD.strTableColumnName = 'dblSalePrice'
--							--	THEN CAST(ItemPricing_Old.dblSalePrice AS NVARCHAR(50))
--							--WHEN RHD.strTableColumnName = 'dblStandardCost'
--							--	THEN CAST(ItemPricing_Old.dblStandardCost AS NVARCHAR(50))
--							--WHEN RHD.strTableColumnName = 'dblLastCost'
--							--	THEN CAST(ItemPricing_Old.dblLastCost AS NVARCHAR(50))

--							--WHEN RHD.strTableColumnName = 'dblUnitAfterDiscount'
--							--	THEN CAST(ItemSpecialPricing_Old.dblUnitAfterDiscount AS NVARCHAR(50))
--							--WHEN RHD.strTableColumnName = 'dtmBeginDate'
--							--	THEN CONVERT(VARCHAR(10), CAST(ItemSpecialPricing_Old.dtmBeginDate AS DATE), 101) -- CAST(ItemSpecialPricing_Old.dtmBeginDate AS NVARCHAR(20))
--							--WHEN RHD.strTableColumnName = 'dtmEndDate'
--							--	THEN CONVERT(VARCHAR(10), CAST(ItemSpecialPricing_Old.dtmEndDate AS DATE), 101) -- CAST(ItemSpecialPricing_Old.dtmEndDate AS NVARCHAR(20))

--							WHEN RHD.strTableColumnName = 'intDepositPLUId'
--								THEN Uom_Old.strUpcCode
--							WHEN RHD.strTableColumnName = 'strCounted'
--								THEN OldItemLocValue.strCounted
--							WHEN RHD.strTableColumnName = 'intFamilyId'
--								THEN ISNULL(SubCatFamily_Old.strSubcategoryId, '')
--							WHEN RHD.strTableColumnName = 'intClassId'
--								THEN ISNULL(SubCatClass_Old.strSubcategoryId, '')
--							WHEN RHD.strTableColumnName = 'intProductCodeId'
--								THEN ISNULL(ProductCode_Old.strRegProdCode, '')
--							WHEN RHD.strTableColumnName = 'intVendorId'
--								THEN CASE WHEN Entity_Old.intEntityId IS NULL THEN '' ELSE ISNULL(Entity_Old.strName, '') END
--							WHEN RHD.strTableColumnName = 'intMinimumAge'
--								THEN RHD.strOldData
--							WHEN RHD.strTableColumnName = 'dblMinOrder'
--								THEN RHD.strOldData
--							WHEN RHD.strTableColumnName = 'dblSuggestedQty'
--								THEN RHD.strOldData
--							WHEN RHD.strTableColumnName = 'intStorageLocationId'
--								THEN StorageLoc_Old.strName

--							WHEN RHD.strOldData = 'true' THEN 'Yes'
--							WHEN RHD.strOldData = 'false' THEN 'No'

--							-- Else will handle these columns: 'dblUnitAfterDiscount', 'dtmBeginDate', 'dtmEndDate'
--							ELSE RHD.strOldData
--						END
FROM tblSTRevertHolderDetail RHD
INNER JOIN tblSTRevertHolder revertHolder
	ON RHD.intRevertHolderId = revertHolder.intRevertHolderId

-- NEW DATA
INNER JOIN tblICItem Item
	ON RHD.intItemId = Item.intItemId
INNER JOIN tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
LEFT JOIN tblICItemLocation ItemLoc
	ON RHD.intItemLocationId = ItemLoc.intItemLocationId
LEFT JOIN tblICItemUOM Uom
	ON Item.intItemId = Uom.intItemId
LEFT JOIN tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
LEFT JOIN tblSTSubcategory SubCatFamily_New
	ON ItemLoc.intFamilyId = SubCatFamily_New.intSubcategoryId
LEFT JOIN tblSTSubcategory SubCatClass_New
	ON ItemLoc.intClassId = SubCatClass_New.intSubcategoryId
LEFT JOIN tblSTSubcategoryRegProd ProductCode_New
	ON ItemLoc.intProductCodeId = ProductCode_New.intRegProdId
LEFT JOIN tblAPVendor Vendor_New
	ON ItemLoc.intVendorId = Vendor_New.intEntityId
LEFT JOIN tblEMEntity Entity_New
	ON Vendor_New.intEntityId = Entity_New.intEntityId
LEFT JOIN tblICStorageLocation StorageLoc_New
	ON ItemLoc.intStorageLocationId = StorageLoc_New.intStorageLocationId
LEFT JOIN tblICCountGroup CountGroup_New
	ON ItemLoc.intCountGroupId = CountGroup_New.intCountGroupId
LEFT JOIN tblICItemUOM Uom_New
	ON ItemLoc.intDepositPLUId = Uom_New.intItemUOMId
LEFT JOIN tblICItemPricing ItemPricing_New
	ON RHD.intItemPricingId = ItemPricing_New.intItemPricingId
LEFT JOIN tblICItemSpecialPricing ItemSpecialPricing_New
	ON RHD.intItemSpecialPricingId = ItemSpecialPricing_New.intItemSpecialPricingId

---- OLD DATA tblICItem
--LEFT JOIN
--(
--	SELECT * FROM
--	(
--		SELECT DISTINCT
--		          d.intRevertHolderDetailId
--				  , d.intItemLocationId
--				  , d.intItemId
--				  , d.strTableColumnName
--				  , d.strOldData
--		FROM tblSTRevertHolderDetail d
--		WHERE d.strTableColumnName IN(N'intCategoryId', N'strCountCode')
--	) src
--	PIVOT (
--			MAX(strOldData) FOR strTableColumnName IN (intCategoryId, strCountCode)
--	) piv
--) OldItemValue
--	ON OldItemValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
--LEFT JOIN tblICCategory Category_Old
--	ON OldItemValue.intCategoryId = Category_Old.intCategoryId

---- OLD DATA tblICItemLocation
--LEFT JOIN
--(
--	SELECT * FROM
--	(
--		SELECT DISTINCT
--		          d.intRevertHolderDetailId
--				  , d.intItemLocationId
--				  , d.intItemId
--				  , d.strTableColumnName
--				  , d.strOldData
--		FROM tblSTRevertHolderDetail d
--		WHERE d.strTableColumnName IN ('intDepositPLUId', 'strCounted', 'intFamilyId', 'intClassId', 'intProductCodeId', 'intMinimumAge', 'dblMinOrder', 'dblSuggestedQty', 'intStorageLocationId', 'intCountGroupId', 'intVendorId')
--	) src
--	PIVOT (
--			MAX(strOldData) FOR strTableColumnName IN (intDepositPLUId, strCounted, intFamilyId, intClassId, intProductCodeId, intMinimumAge, dblMinOrder, dblSuggestedQty, intStorageLocationId, intCountGroupId, intVendorId)
--	) piv
--) OldItemLocValue
--	ON OldItemLocValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
----	ON OldItemLocValue.intVendorId = Vendor_Old.intEntityId
--LEFT JOIN tblEMEntity Entity_Old
--	ON OldItemLocValue.intVendorId = Entity_Old.intEntityId
--LEFT JOIN tblICItemLocation ItemLoc_Old
--	ON OldItemLocValue.intItemLocationId = ItemLoc_Old.intItemLocationId
--LEFT JOIN tblSTSubcategory SubCatFamily_Old
--	ON OldItemLocValue.intFamilyId = SubCatFamily_Old.intSubcategoryId
--LEFT JOIN tblSTSubcategory SubCatClass_Old
--	ON OldItemLocValue.intClassId = SubCatClass_Old.intSubcategoryId
--LEFT JOIN tblSTSubcategoryRegProd ProductCode_Old
--	ON OldItemLocValue.intProductCodeId = ProductCode_Old.intRegProdId
--LEFT JOIN tblICStorageLocation StorageLoc_Old
--	ON OldItemLocValue.intStorageLocationId = StorageLoc_Old.intStorageLocationId
--LEFT JOIN tblICCountGroup CountGroup_Old
--	ON OldItemLocValue.intCountGroupId = CountGroup_Old.intCountGroupId
--LEFT JOIN tblICItemUOM Uom_Old
--	ON OldItemLocValue.intDepositPLUId = Uom_Old.intItemUOMId



---- OLD DATA tblICItemPricing
--LEFT JOIN
--(
--	SELECT * FROM
--	(
--		SELECT DISTINCT
--		          d.intRevertHolderDetailId
--				  , d.intItemPricingId
--				  , d.intItemId
--				  , d.strTableColumnName
--				  , d.strOldData
--		FROM tblSTRevertHolderDetail d
--		WHERE d.strTableColumnName IN ('dblSalePrice', 'dblStandardCost', 'dblLastCost')
--	) src
--	PIVOT (
--			MAX(strOldData) FOR strTableColumnName IN (dblSalePrice, dblStandardCost, dblLastCost)
--	) piv
--) OldItemPricing
--	ON OldItemPricing.intRevertHolderDetailId = RHD.intRevertHolderDetailId
--LEFT JOIN tblICItemPricing ItemPricing_Old
--	ON OldItemPricing.intItemPricingId = ItemPricing_Old.intItemPricingId

---- OLD DATA tblICItemSpecialPricing
--LEFT JOIN
--(
--	SELECT * FROM
--	(
--		SELECT DISTINCT
--		          d.intRevertHolderDetailId
--				  , d.intItemSpecialPricingId
--				  , d.intItemId
--				  , d.strTableColumnName
--				  , d.strOldData
--		FROM tblSTRevertHolderDetail d
--		WHERE d.strTableColumnName IN ('dblUnitAfterDiscount', 'dtmBeginDate', 'dtmEndDate')
--	) src
--	PIVOT (
--			MAX(strOldData) FOR strTableColumnName IN (dblSalePrice, dblStandardCost, dblLastCost)
--	) piv
--) OldItemSpecialPricing
--	ON OldItemSpecialPricing.intRevertHolderDetailId = RHD.intRevertHolderDetailId
--LEFT JOIN tblICItemSpecialPricing ItemSpecialPricing_Old
--	ON OldItemSpecialPricing.intItemSpecialPricingId = ItemSpecialPricing_Old.intItemSpecialPricingId
