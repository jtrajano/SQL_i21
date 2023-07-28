--liquibase formatted sql

-- changeset Von:vyuICGetInventoryCountByCategory.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryCountByCategory]
	AS
SELECT 
	Location.strLocationName,
	InventoryCountByCategory.*
FROM tblICInventoryCountByCategory InventoryCountByCategory
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = InventoryCountByCategory.intLocationId



