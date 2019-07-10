-- ITEM count: 8322

CREATE VIEW dbo.vyuSTPricebookMaster
AS
SELECT DISTINCT
    Item.intItemId
	, Item.strItemNo
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.strDescription
	, Uom.strLongUPCCode
	, Uom.strUpcCode
	, Item.intConcurrencyId
	
	-- Item Location
	, ISNULL(ItemLoc_POSDescription.strDescription,'') AS strPOSDescription
	, ItemLoc_Family.intFamilyId
	, ItemLoc_Class.intClassId
	, ItemLoc_Vendor.intVendorId
	, Family.strSubcategoryId AS strFamily
	, Class.strSubcategoryId AS strClass
	, Vendor.strName AS strVendorName

	-- tblICItemVendorXref
	, VendorXref.strVendorProduct
FROM dbo.tblICItem AS Item 
INNER JOIN dbo.tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
LEFT JOIN dbo.tblICItemUOM Uom
	ON Item.intItemId = Uom.intItemId

LEFT JOIN 
(
	SELECT DISTINCT
		intItemId
		, strDescription
		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY strDescription DESC) AS rn
	FROM dbo.tblICItemLocation
) ItemLoc_POSDescription
	ON Item.intItemId = ItemLoc_POSDescription.intItemId
	AND ItemLoc_POSDescription.rn = 1

LEFT JOIN 
(
	SELECT DISTINCT
		intItemId
		, intFamilyId
		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intFamilyId DESC) AS rn
	FROM dbo.tblICItemLocation
) ItemLoc_Family
	ON Item.intItemId = ItemLoc_Family.intItemId
	AND ItemLoc_Family.rn = 1
LEFT JOIN dbo.tblSTSubcategory Family
	ON ItemLoc_Family.intFamilyId = Family.intSubcategoryId

LEFT JOIN 
(
	SELECT DISTINCT
		intItemId
		, intClassId
		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intClassId DESC) AS rn
	FROM dbo.tblICItemLocation
) ItemLoc_Class
	ON Item.intItemId = ItemLoc_Class.intItemId
	AND ItemLoc_Class.rn = 1
LEFT JOIN dbo.tblSTSubcategory Class
	ON ItemLoc_Class.intClassId = Class.intSubcategoryId

LEFT JOIN 
(
	SELECT DISTINCT
		intItemId
		, intVendorId
		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY intVendorId DESC) AS rn
	FROM dbo.tblICItemLocation
) ItemLoc_Vendor
	ON Item.intItemId = ItemLoc_Vendor.intItemId
	AND ItemLoc_Vendor.rn = 1
LEFT JOIN dbo.tblEMEntity Vendor
	ON ItemLoc_Vendor.intVendorId = Vendor.intEntityId


LEFT JOIN 
(
	SELECT DISTINCT
		intItemId
		, strVendorProduct
		, ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY strVendorProduct DESC) AS rn
	FROM dbo.tblICItemVendorXref
) VendorXref
	ON Item.intItemId = VendorXref.intItemId
	AND VendorXref.rn = 1
WHERE Uom.ysnStockUnit = 1