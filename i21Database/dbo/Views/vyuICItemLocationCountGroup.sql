CREATE VIEW [dbo].[vyuICItemLocationCountGroup]
AS 
SELECT ItemLocation.intItemLocationId
	  ,ItemLocation.intLocationId
	  ,Item.intItemId
	  ,Item.intCategoryId	  
	  ,ItemLocation.intCountGroupId
	  ,Item.strItemNo
	  ,Item.strDescription AS strItemDescription
	  ,ItemCategory.strDescription AS strCategoryDescription
	  ,ItemCategory.strCategoryCode
	  ,CompanyLocation.strLocationName
	  ,CountGroup.strCountGroup
	  ,ItemLocation.dtmDateCreated
	  ,ItemLocation.dtmDateModified
	  ,ItemLocation.intModifiedByUserId
	  ,ItemLocation.intCreatedByUserId
	  ,ItemLocation.intConcurrencyId
FROM tblICItemLocation AS ItemLocation
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
LEFT JOIN tblICItem AS Item ON ItemLocation.intItemId = Item.intItemId
LEFT JOIN tblICCategory AS ItemCategory ON Item.intCategoryId = ItemCategory.intCategoryId
LEFT JOIN tblICCountGroup AS CountGroup ON ItemLocation.intCountGroupId = CountGroup.intCountGroupId;