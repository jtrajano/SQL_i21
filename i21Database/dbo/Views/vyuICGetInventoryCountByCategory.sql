CREATE VIEW [dbo].[vyuICGetInventoryCountByCategory]
	AS
SELECT 
	Location.strLocationName,
	InventoryCountByCategory.*
FROM tblICInventoryCountByCategory InventoryCountByCategory
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = InventoryCountByCategory.intLocationId