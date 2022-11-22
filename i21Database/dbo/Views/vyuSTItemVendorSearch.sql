CREATE VIEW vyuSTItemVendorSearch
AS

SELECT DISTINCT
	I.intItemId,
	IV.strVendorProduct AS strVendorItemNo,
	IV.strProductDescription AS strDescription,
	I.strItemNo,
	V.strName AS strVendorId,
	CV.strVendorDepartment,
	CAT.strCategoryCode,
	subcategories.strSubCategory AS strSubcategory,
	family.strSubcategoryId AS strFamily,
	class.strSubcategoryId AS strClass,
	CASE WHEN I.strStatus = 'Active'
		THEN CAST(1 AS BIT)
	  ELSE
		CAST(0 AS BIT)
	END AS ysnActive
FROM tblICItem I
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
JOIN tblICItemVendorXref IV
	ON I.intItemId = IV.intItemId
JOIN vyuAPVendor V
	ON IV.intVendorId = V.intEntityId
JOIN tblICCategory CAT
	ON I.intCategoryId = CAT.intCategoryId
LEFT JOIN tblICCategoryVendor CV
	ON CAT.intCategoryId = CV.intCategoryId
LEFT JOIN tblSTSubcategory family
	ON I.intStoreFamilyId = family.intSubcategoryId
LEFT JOIN tblSTSubcategory class
	ON I.intStoreClassId = class.intSubcategoryId
LEFT JOIN tblSTSubCategories subcategories
	ON I.intSubcategoriesId = subcategories.intSubcategoriesId