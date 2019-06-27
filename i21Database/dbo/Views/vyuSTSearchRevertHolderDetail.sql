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
	, Item_New.strItemNo
	, Item_New.strDescription AS strItemDescription
	, Uom.strLongUPCCode
	, CompanyLoc.strLocationName
	, RHD.intConcurrencyId
	, strPreviewNewData = CASE
							WHEN RHD.strTableColumnName IN ('intCategoryId')
								THEN Category_New.strCategoryCode
							WHEN RHD.strTableColumnName IN ('strCountCode')
								THEN Item_New.strCountCode

							--WHEN RHD.strTableColumnName IN ('intDepositPLUId')
							--	THEN
							WHEN RHD.strTableColumnName = 'strCounted'
								THEN ItemLoc_New.strCounted
							WHEN RHD.strTableColumnName = 'intFamilyId'
								THEN ISNULL(SubCatFamily_New.strSubcategoryId, '')
							WHEN RHD.strTableColumnName = 'intClassId'
								THEN ISNULL(SubCatClass_New.strSubcategoryId, '')
							WHEN RHD.strTableColumnName = 'intProductCodeId'
								THEN ISNULL(ProductCode_New.strRegProdCode, '')
							WHEN RHD.strTableColumnName = 'intVendorId'
								THEN ISNULL(Entity_New.strName, '')
							WHEN RHD.strTableColumnName = 'intMinimumAge'
								THEN CAST(ItemLoc_New.intMinimumAge AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'dblMinOrder'
								THEN CAST(ItemLoc_New.dblMinOrder AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'dblSuggestedQty'
								THEN CAST(ItemLoc_New.dblSuggestedQty AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'intStorageLocationId'
								THEN StorageLoc_New.strName

							WHEN RHD.strNewData = 'true' THEN 'Yes'
							WHEN RHD.strNewData = 'false' THEN 'No'

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
								THEN ISNULL(Entity_Old.strName, '')
							WHEN RHD.strTableColumnName = 'intMinimumAge'
								THEN CAST(ItemLoc_Old.intMinimumAge AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'dblMinOrder'
								THEN CAST(ItemLoc_Old.dblMinOrder AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'dblSuggestedQty'
								THEN CAST(ItemLoc_Old.dblSuggestedQty AS NVARCHAR(50))
							WHEN RHD.strTableColumnName = 'intStorageLocationId'
								THEN StorageLoc_Old.strName

							WHEN RHD.strOldData = 'true' THEN 'Yes'
							WHEN RHD.strOldData = 'false' THEN 'No'

							ELSE RHD.strOldData
						END
FROM tblSTRevertHolderDetail RHD
INNER JOIN tblICItem Item_New
	ON RHD.intItemId = Item_New.intItemId
INNER JOIN tblICCategory Category_New
	ON Item_New.intCategoryId = Category_New.intCategoryId
INNER JOIN tblICItemUOM Uom
	ON RHD.intItemUOMId = Uom.intItemUOMId
INNER JOIN tblICItemLocation ItemLoc_New
	ON RHD.intItemLocationId = ItemLoc_New.intItemLocationId
INNER JOIN tblSMCompanyLocation CompanyLoc
	ON RHD.intCompanyLocationId = CompanyLoc.intCompanyLocationId

-- New Data
LEFT JOIN tblSTSubcategory SubCatFamily_New
	ON ItemLoc_New.intFamilyId = SubCatFamily_New.intSubcategoryId
LEFT JOIN tblSTSubcategory SubCatClass_New
	ON ItemLoc_New.intClassId = SubCatClass_New.intSubcategoryId
LEFT JOIN tblSTSubcategoryRegProd ProductCode_New
	ON ItemLoc_New.intProductCodeId = ProductCode_New.intRegProdId
LEFT JOIN tblAPVendor Vendor_New
	ON ItemLoc_New.intVendorId = Vendor_New.intEntityId
LEFT JOIN tblEMEntity Entity_New
	ON Vendor_New.intEntityId = Entity_New.intEntityId
LEFT JOIN tblICStorageLocation StorageLoc_New
	ON ItemLoc_New.intStorageLocationId = StorageLoc_New.intStorageLocationId

---- Old Data
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
		WHERE d.strTableColumnName IN ('ysnTaxFlag1','ysnTaxFlag2', 'ysnTaxFlag3', 'ysnTaxFlag4', 'ysnDepositRequired', 'intDepositPLUId', 'ysnQuantityRequired', 'ysnScaleItem', 'ysnFoodStampable',
														'ysnReturnable', 'ysnSaleable', 'ysnIdRequiredLiquor', 'ysnIdRequiredCigarette', 'ysnPromotionalItem', 'ysnPrePriced', 'ysnApplyBlueLaw1', 'ysnApplyBlueLaw2',
														'ysnCountedDaily', 'strCounted', 'ysnCountBySINo', 'intFamilyId', 'intClassId', 'intProductCodeId', 'intVendorId', 'intMinimumAge', 'dblMinOrder', 'dblSuggestedQty', 
														'intStorageLocationId')
	) src
	PIVOT (
			MAX(strOldData) FOR strTableColumnName IN (ysnTaxFlag1,ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnDepositRequired, intDepositPLUId, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable,
														ysnReturnable, ysnSaleable, ysnIdRequiredLiquor, ysnIdRequiredCigarette, ysnPromotionalItem, ysnPrePriced, ysnApplyBlueLaw1, ysnApplyBlueLaw2,
														ysnCountedDaily, strCounted, ysnCountBySINo, intFamilyId, intClassId, intProductCodeId, intVendorId, intMinimumAge, dblMinOrder, dblSuggestedQty, 
														intStorageLocationId)
	) piv
) OldItemLocValue
	ON OldItemLocValue.intRevertHolderDetailId = RHD.intRevertHolderDetailId
LEFT JOIN tblICItemLocation ItemLoc_Old
	ON OldItemLocValue.intItemLocationId = ItemLoc_Old.intItemLocationId
LEFT JOIN tblSTSubcategory SubCatFamily_Old
	ON ItemLoc_Old.intFamilyId = SubCatFamily_Old.intSubcategoryId
LEFT JOIN tblSTSubcategory SubCatClass_Old
	ON ItemLoc_Old.intClassId = SubCatClass_Old.intSubcategoryId
LEFT JOIN tblSTSubcategoryRegProd ProductCode_Old
	ON ItemLoc_Old.intProductCodeId = ProductCode_Old.intRegProdId
LEFT JOIN tblAPVendor Vendor_Old
	ON ItemLoc_Old.intVendorId = Vendor_Old.intEntityId
LEFT JOIN tblEMEntity Entity_Old
	ON Vendor_Old.intEntityId = Entity_Old.intEntityId
LEFT JOIN tblICStorageLocation StorageLoc_Old
	ON ItemLoc_Old.intStorageLocationId = StorageLoc_Old.intStorageLocationId

