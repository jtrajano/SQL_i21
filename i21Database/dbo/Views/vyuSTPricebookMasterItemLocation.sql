CREATE VIEW dbo.vyuSTPricebookMasterItemLocation
AS 
SELECT 
	ItemLoc.intItemLocationId
	, Item.intItemId
	, Store.intStoreId
	, Store.intStoreNo
	, ItemLoc.intLocationId
	, CompanyLoc.strLocationName
	
	, ItemLoc.intProductCodeId
	, ItemLoc.intCountGroupId
	, ItemLoc.intFamilyId
	, ItemLoc.intClassId
	, ItemLoc.strDescription
	, ItemLoc.ysnTaxFlag1
	, ItemLoc.ysnTaxFlag2
	, ItemLoc.ysnTaxFlag3
	, ItemLoc.ysnTaxFlag4
	, ItemLoc.ysnPromotionalItem
	, ItemLoc.ysnDepositRequired
	, ItemLoc.intDepositPLUId
	, ItemLoc.intBottleDepositNo
	, ItemLoc.ysnSaleable
	, ItemLoc.ysnQuantityRequired
	, ItemLoc.ysnScaleItem
	, ItemLoc.ysnFoodStampable
	, ItemLoc.ysnReturnable
	, ItemLoc.ysnPrePriced
	, ItemLoc.ysnOpenPricePLU
	, ItemLoc.ysnLinkedItem
	, ItemLoc.ysnIdRequiredLiquor
	, ItemLoc.ysnIdRequiredCigarette
	, ItemLoc.intMinimumAge
	--, ItemLoc.intTransactionLimit -- TO ADD PENDING 
	, ItemLoc.ysnApplyBlueLaw1
	, ItemLoc.ysnApplyBlueLaw2
	, ItemLoc.ysnCarWash
	, ItemLoc.intVendorId
	
	, Product.strRegProdCode AS strRegProdCode
	, CountGroup.strCountGroup AS strCountGroup
	, UPC.strUPCCode AS strUPCCode
	, Family.strSubcategoryId AS strFamily
	, Class.strSubcategoryId AS strClass
	, Entity.strName AS strVendorName

	, ItemLoc.intConcurrencyId
FROM dbo.tblICItemLocation ItemLoc
INNER JOIN dbo.tblICItem Item
	ON ItemLoc.intItemId = Item.intItemId
INNER JOIN dbo.tblSMCompanyLocation CompanyLoc
	ON ItemLoc.intLocationId = CompanyLoc.intCompanyLocationId
LEFT JOIN dbo.tblSTStore Store
	ON CompanyLoc.intCompanyLocationId = Store.intCompanyLocationId
LEFT OUTER JOIN dbo.tblSTSubcategory AS Family 
	ON ItemLoc.intFamilyId = Family.intSubcategoryId
LEFT OUTER JOIN dbo.tblSTSubcategory AS Class 
	ON ItemLoc.intClassId = Class.intSubcategoryId
LEFT OUTER JOIN dbo.tblSTSubcategoryRegProd AS Product 
	ON ItemLoc.intProductCodeId = Product.intRegProdId
LEFT OUTER JOIN dbo.tblICCountGroup AS CountGroup 
	ON ItemLoc.intCountGroupId = CountGroup.intCountGroupId
LEFT OUTER JOIN dbo.tblICItemUPC AS UPC 
	ON ItemLoc.intDepositPLUId = UPC.intItemUPCId
LEFT OUTER JOIN dbo.tblEMEntity AS Entity 
	ON Entity.intEntityId = ItemLoc.intVendorId 
