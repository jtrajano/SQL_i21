CREATE VIEW [dbo].[vyuSTSearchRevertHolderDetail]
AS
SELECT DISTINCT
	RHD.intRevertHolderDetailId
	, RHD.intRevertHolderId
	, RHD.strTableName
	, RHD.strTableColumnName
	, RHD.strTableColumnDataType
	, RHD.intPrimaryKeyId
	, RHD.intItemId
	, RHD.intItemUOMId
	, RHD.intItemLocationId
	, RHD.intCompanyLocationId
	, RHD.dtmDateModified
	, RHD.strChangeDescription
	, RHD.strOldData
	, RHD.strNewData
	, Item.strItemNo
	, Item.strDescription AS strItemDescription
	, Uom.strLongUPCCode
	, CompanyLoc.strLocationName
	, RHD.intConcurrencyId
	, strPreviewNewData = CASE
							WHEN RHD.strTableColumnName IN ('intCategoryId')
								THEN Category.strCategoryCode
							WHEN RHD.strTableColumnName IN ('strCountCode')
								THEN Item.strCountCode

							--WHEN RHD.strTableColumnName IN ('intDepositPLUId')
							--	THEN
							WHEN RHD.strTableColumnName = 'strCounted'
								THEN ItemLoc.strCounted
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
								THEN StorageLoc_New.strName

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
							WHEN RHD.strTableColumnName = 'ysnCountBySINo'
								THEN CASE WHEN ItemLoc.ysnCountBySINo = 1 THEN 'Yes' ELSE 'No' END

							ELSE RHD.strNewData
						END
	, strPreviewOldData = CASE
							WHEN RHD.strTableColumnName IN ('intCategoryId')
								THEN Category_Old.strCategoryCode
							WHEN RHD.strTableColumnName IN ('strCountCode')
								THEN OldItemValue.strCountCode

							--WHEN RHD.strTableColumnName IN ('intDepositPLUId')
							--	THEN
							WHEN RHD.strTableColumnName = 'strCounted'
								THEN ItemLoc_Old.strCounted
							WHEN RHD.strTableColumnName = 'intFamilyId'
								THEN ISNULL(SubCatFamily_Old.strSubcategoryId, '')
							WHEN RHD.strTableColumnName = 'intClassId'
								THEN ISNULL(SubCatClass_Old.strSubcategoryId, '')
							WHEN RHD.strTableColumnName = 'intProductCodeId'
								THEN ISNULL(ProductCode_Old.strRegProdCode, '')
							WHEN RHD.strTableColumnName = 'intVendorId'
								--THEN ISNULL(Entity_Old.strName, '')
								THEN CASE WHEN Vendor_Old.intEntityId IS NULL THEN '' ELSE ISNULL(Entity_Old.strName, '') END
							WHEN RHD.strTableColumnName = 'intMinimumAge'
								--THEN CAST(ItemLoc_Old.intMinimumAge AS NVARCHAR(50))
								THEN RHD.strOldData
							WHEN RHD.strTableColumnName = 'dblMinOrder'
								--THEN CAST(ItemLoc_Old.dblMinOrder AS NVARCHAR(50))
								THEN RHD.strOldData
							WHEN RHD.strTableColumnName = 'dblSuggestedQty'
								--THEN CAST(ItemLoc_Old.dblSuggestedQty AS NVARCHAR(50))
								THEN RHD.strOldData
							WHEN RHD.strTableColumnName = 'intStorageLocationId'
								THEN StorageLoc_Old.strName

							WHEN RHD.strOldData = 'true' THEN 'Yes'
							WHEN RHD.strOldData = 'false' THEN 'No'

							ELSE RHD.strOldData
						END
FROM tblSTRevertHolderDetail RHD

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


-- OLD DATA
LEFT JOIN
(
	SELECT * FROM
	(
		SELECT DISTINCT
		          d.intRevertHolderDetailId
				  , d.intItemLocationId
				  , d.intItemId
				  , d.strTableColumnName
				  , d.strOldData
		FROM tblSTRevertHolderDetail d
		WHERE d.strTableColumnName IN(N'intCategoryId', N'strCountCode')
	) src
	PIVOT (
			MAX(strOldData) FOR strTableColumnName IN (intCategoryId, strCountCode)
	) piv
) OldItemValue
	ON OldItemValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
LEFT JOIN tblICCategory Category_Old
	ON OldItemValue.intCategoryId = Category_Old.intCategoryId
LEFT JOIN
(
	SELECT * FROM
	(
		SELECT DISTINCT
		          d.intRevertHolderDetailId
				  , d.intItemLocationId
				  , d.intItemId
				  , d.strTableColumnName
				  , d.strOldData
		FROM tblSTRevertHolderDetail d
		WHERE d.strTableColumnName IN ('intDepositPLUId', 'strCounted', 'intFamilyId', 'intClassId', 'intProductCodeId', 'intMinimumAge', 'dblMinOrder', 'dblSuggestedQty', 'intStorageLocationId')
	) src
	PIVOT (
			MAX(strOldData) FOR strTableColumnName IN (intDepositPLUId, strCounted, intFamilyId, intClassId, intProductCodeId, intMinimumAge, dblMinOrder, dblSuggestedQty, intStorageLocationId)
	) piv
) OldItemLocValue
	ON OldItemLocValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
LEFT JOIN
(
	SELECT * FROM
	(
		SELECT DISTINCT
		          d.intRevertHolderDetailId
				  , d.intItemLocationId
				  , d.intItemId
				  , d.strTableColumnName
				  , d.strOldData
		FROM tblSTRevertHolderDetail d
		WHERE d.strTableColumnName IN ('intVendorId')
	) src
	PIVOT (
			MAX(strOldData) FOR strTableColumnName IN (intVendorId)
	) piv
) OldItemLocVendorValue
	ON OldItemLocVendorValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
LEFT JOIN tblAPVendor Vendor_Old
	ON OldItemLocVendorValue.intVendorId = Vendor_Old.intEntityId
LEFT JOIN tblEMEntity Entity_Old
	ON OldItemLocVendorValue.intVendorId = Entity_Old.intEntityId
LEFT JOIN tblICItemLocation ItemLoc_Old
	ON OldItemLocValue.intItemLocationId = ItemLoc_Old.intItemLocationId
LEFT JOIN tblSTSubcategory SubCatFamily_Old
	ON ItemLoc_Old.intFamilyId = SubCatFamily_Old.intSubcategoryId
LEFT JOIN tblSTSubcategory SubCatClass_Old
	ON ItemLoc_Old.intClassId = SubCatClass_Old.intSubcategoryId
LEFT JOIN tblSTSubcategoryRegProd ProductCode_Old
	ON ItemLoc_Old.intProductCodeId = ProductCode_Old.intRegProdId

LEFT JOIN tblICStorageLocation StorageLoc_Old
	ON ItemLoc_Old.intStorageLocationId = StorageLoc_Old.intStorageLocationId


--WHERE RHD.strTableColumnName = 'intVendorId'