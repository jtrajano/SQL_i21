CREATE VIEW vyuSTItemCategoryLocation
AS
SELECT C.intCategoryId
      , C.strCategoryCode
	  , C.strDescription AS strCategoryDescription
	  , I.intItemId
	  , I.strItemNo
	  , I.strDescription AS strItemDescription
	  , CL.intCompanyLocationId
	  , CL.strLocationName
	  , ST.intStoreId
	  , ST.intStoreNo
FROM tblICCategory C
JOIN tblICCategoryLocation CLOC
	ON C.intCategoryId = CLOC.intCategoryId
JOIN tblICItem I
	ON CLOC.intGeneralItemId = I.intItemId
JOIN tblSMCompanyLocation CL
	ON CLOC.intLocationId = CL.intCompanyLocationId
JOIN tblSTStore ST
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
JOIN tblICCategoryPricing CategoryPricing
	ON C.intCategoryId = CategoryPricing.intCategoryId