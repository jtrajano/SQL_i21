--liquibase formatted sql

-- changeset Von:vyuICGetInventoryCountByCategoryDetail.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryCountByCategoryDetail]
	AS 

SELECT 
	InventoryCountByCategoryDetail.*,
	Category.strCategoryCode,
	Category.strDescription
FROM tblICInventoryCountByCategoryDetail InventoryCountByCategoryDetail
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = InventoryCountByCategoryDetail.intCategoryId



