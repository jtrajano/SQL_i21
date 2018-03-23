IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCatMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCatMigrationAg]; 
GO 

Create PROCEDURE [dbo].[uspICDCCatMigrationAg]
--** Below Stored Procedure is to migrate inventory and related tables like class and unit measure.
--   It loads data into item and related i21 tables like tblICCategory, tblICUnitMeasure **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- Category/Class data migration from agclsmst origin table to tblICCategory i21 table 
--** Note: In Origin Category is called as Class and it is referred from agclsmst table ** 
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
SELECT RTRIM(agcls_cd)
	,RTRIM(agcls_desc)
	,''
	,case 
	(select top 1 case when agitm_ga_com_cd is not null then 'Y' else agitm_phys_inv_ynbo end 
	from agitmmst where agitm_class = oc.agcls_cd order by agitm_phys_inv_ynbo desc) 
	when 'Y' then 'Inventory' 
	when 'O' then 'Inventory' 
	when 'S' then 'Non Inventory'
	when 'B' then 'Finished Goods'
	when 'A' then 'Finished Goods'
	else 'Other Charge' end	'InventoryType'
	,'1'
	,'Item Level'
	,1
	,0
FROM agclsmst oc
LEFT JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = oc.agcls_cd COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE CAT.intCategoryId IS NULL

--=========================================================================
--Tax groups in category maintenance will be setup manually by AR team
--====================================================================


