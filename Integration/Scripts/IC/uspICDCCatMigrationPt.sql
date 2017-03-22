Create PROCEDURE [dbo].[uspICDCCatMigrationPt]
--** Below Stored Procedure is to migrate inventory and related tables like class, location, unit measure, item pricing, etc.
--   It loads data into item and related i21 tables like tblICCategory, tblICUnitMeasure, tblICItem,
--   tblICItemUOM, tblICItemLocation, tblICItemPricing. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- Category/Class data migration from ptclsmst origin table to tblICCategory i21 table 
--** Note: In Origin Category is called as Class and it is referred from ptclsmst table ** 
-- Section 1
--------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblICCategory (
	strCategoryCode
	,strDescription
	,strMaterialFee
	,strInventoryType
	,intCostingMethod
	,strInventoryTracking
	,intConcurrencyId
	,ysnAutoCalculateFreight
	)
SELECT RTRIM(ptcls_class)
	,RTRIM(ptcls_desc)
	,RTRIM(ptcls_amf_yn)
--** get the inventory type from item 
	,case	
		when
			(select COUNT(*) cnt from ptitmmst where ptitm_class = ptclsmst.ptcls_class and ptitm_phys_inv_yno = 'Y') > 1 then 'Inventory' 
		else 
			'Other Charge' 
		end	'InventoryType'			
	,'1'
	,'Item Level'
	,1
	,(
		CASE 
			WHEN (ptcls_auto_frt_yn = 'Y')
				THEN 1
			ELSE 0
			END
		)
FROM ptclsmst


GO