CREATE VIEW [dbo].[vyuQMItemLocation]
AS 
SELECT Item.intItemId
	 , strItemNo
	 , strLocationName
	 , Item.strDescription
	 , strType
	 , intOriginId
	 , strOriginName
	 , CompanyLocation.intCompanyLocationId
FROM vyuICGetCompactItem AS Item
LEFT JOIN tblICItemLocation AS ItemLocation ON Item.intItemId = ItemLocation.intItemId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId

