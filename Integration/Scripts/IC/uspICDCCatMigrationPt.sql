IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCatMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCatMigrationPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCatMigrationPt]
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
MERGE tblICCategory AS [Target]
USING 
(
	SELECT
		  strCategoryCode			= RTRIM(ptcls_class) COLLATE Latin1_General_CI_AS
		, strDescription			= RTRIM(ptcls_desc) COLLATE Latin1_General_CI_AS
		, strMaterialFee			= RTRIM(ptcls_amf_yn) COLLATE Latin1_General_CI_AS
		, strInventoryType			= CASE WHEN (SELECT COUNT(*) cnt FROM ptitmmst WHERE ptitm_class = ptclsmst.ptcls_class AND ptitm_phys_inv_yno = 'Y') > 0 THEN 'Inventory' ELSE 'Other Charge' END COLLATE Latin1_General_CI_AS
		, intCostingMethod			= '1'
		, strInventoryTracking		= 'Item Level'
		, intConcurrencyId			= 1
		,ysnAutoCalculateFreight	= CAST(CASE WHEN (ptcls_auto_frt_yn = 'Y') THEN 1 ELSE 0 END AS BIT)
	FROM ptclsmst
	LEFT JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = RTRIM(ptcls_class) COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE CAT.intCategoryId IS NULL
) AS [Source] (strCategoryCode, strDescription, strMaterialFee, strInventoryType, intCostingMethod, strInventoryTracking, intConcurrencyId, ysnAutoCalculateFreight)
ON [Target].strCategoryCode = [Source].strCategoryCode
WHEN NOT MATCHED THEN
INSERT (strCategoryCode, strDescription, strMaterialFee, strInventoryType, intCostingMethod, strInventoryTracking, intConcurrencyId, ysnAutoCalculateFreight)
VALUES ([Source].strCategoryCode, [Source].strDescription, [Source].strMaterialFee, [Source].strInventoryType, [Source].intCostingMethod, [Source].strInventoryTracking, [Source].intConcurrencyId, [Source].ysnAutoCalculateFreight);

GO