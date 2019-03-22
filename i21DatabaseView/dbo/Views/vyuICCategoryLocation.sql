CREATE VIEW [dbo].[vyuICCategoryLocation]
AS 

SELECT	
	categoryLocation.* 
	,companyLocation.strLocationName
	,companyLocation.intCompanyLocationId
	,strProductCodeId = defaultProductCode.strRegProdCode
	,strFamilyId = defaultFamily.strSubcategoryId
	,strClassId = defaultClass.strSubcategoryId
	,strGeneralItemNo = Item.strItemNo
FROM	
	tblICCategoryLocation categoryLocation
	LEFT JOIN tblSMCompanyLocation companyLocation
		ON categoryLocation.intLocationId = companyLocation.intCompanyLocationId
	LEFT JOIN tblSTSubcategoryRegProd defaultProductCode
		ON categoryLocation.intProductCodeId = defaultProductCode.intRegProdId
	LEFT JOIN tblSTSubcategory defaultFamily
		ON categoryLocation.intFamilyId = defaultFamily.intSubcategoryId
	LEFT JOIN tblSTSubcategory defaultClass
		ON categoryLocation.intClassId = defaultClass.intSubcategoryId
	LEFT JOIN tblICItem Item ON Item.intItemId = categoryLocation.intGeneralItemId