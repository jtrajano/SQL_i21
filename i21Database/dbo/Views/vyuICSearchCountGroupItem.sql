CREATE VIEW [dbo].[vyuICSearchCountGroupItem]
	AS 

SELECT Item.intItemId
	  ,Item.strItemNo
	  ,Item.strDescription AS strItemDescription
	  ,CountGroup.strCountGroup
	  ,CountGroup.intCountGroupId
	  ,CountGroup.intCountsPerYear
	  ,CountGroup.ysnIncludeOnHand
	  ,CountGroup.ysnScannedCountEntry
	  ,CountGroup.ysnCountByLots
	  ,CountGroup.ysnCountByPallets
	  ,CountGroup.ysnRecountMismatch
	  ,CountGroup.ysnExternal
	  ,ItemCategory.strDescription AS strCategoryDescription
	  ,CompanyLocation.strLocationName
FROM tblICItem AS Item 
LEFT JOIN tblICItemLocation AS ItemLocation ON Item.intItemId = ItemLocation.intItemId 
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICCategory AS ItemCategory ON Item.intCategoryId = ItemCategory.intCategoryId
LEFT JOIN tblICCountGroup AS CountGroup ON ItemLocation.intCountGroupId = CountGroup.intCountGroupId
WHERE ItemLocation.intCountGroupId IS NOT NULL;