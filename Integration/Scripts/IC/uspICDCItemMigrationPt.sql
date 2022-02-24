IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCItemMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCItemMigrationPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCItemMigrationPt]
--** Below Stored Procedure is to migrate inventory and related tables like class, location, unit measure, item pricing, etc.
--   It loads data into item and related i21 tables like tblICCategory, tblICUnitMeasure, tblICItem,
--   tblICItemUOM, tblICItemLocation, tblICItemPricing. **

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

--------------------------------------------------------------------------------------------------------------------------------------------
-- Inventory/Item data migration from ptitmmst origin table to tblICItem i21 table 
-- Section 1
--------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO tblICItem(
	strItemNo
	, strType
	, strDescription
	, strStatus
	, strInventoryTracking
	, strLotTracking
	, intCategoryId
	, intPatronageCategoryId
	, intLifeTime
	, ysnLandedCost
	, ysnDropShip
	, ysnSpecialCommission
	, ysnStockedItem
	, ysnDyedFuel
	, strBarcodePrint
	, ysnMSDSRequired
	, ysnAvailableTM
	, dblDefaultFull
	, ysnExtendPickTicket
	, ysnExportEDI
	, ysnHazardMaterial
	, ysnMaterialFee
	, strCountCode
	, ysnTaxable
	, strKeywords
	, intConcurrencyId
	, ysnCommisionable
	, dtmDateCreated
)
SELECT
	strItemNo				
	, strType				
	, strDescription		
	, strStatus				
	, strInventoryTracking	
	, strLotTracking		
	, intCategoryId			
	, intPatronageCategoryId
	, intLifeTime			
	, ysnLandedCost			
	, ysnDropShip			
	, ysnSpecialCommission	
	, ysnStockedItem		
	, ysnDyedFuel			
	, strBarcodePrint		
	, ysnMSDSRequired		
	, ysnAvailableTM		
	, dblDefaultFull		
	, ysnExtendPickTicket	
	, ysnExportEDI			
	, ysnHazardMaterial		
	, ysnMaterialFee		
	, strCountCode			
	, ysnTaxable			
	, strKeywords			
	, intConcurrencyId		
	, ysnCommisionable
	, GETUTCDATE()
FROM (
	SELECT
			  strItemNo					= RTRIM(ptitm_itm_no) COLLATE Latin1_General_CI_AS
			, strType					= CASE WHEN (min(ptitm_phys_inv_yno) = 'N') THEN 'Other Charge' ELSE 'Inventory' END COLLATE Latin1_General_CI_AS
			, strDescription			= RTRIM(min(ptitm_desc)) COLLATE Latin1_General_CI_AS
			, strStatus					= 'Active'
			, strInventoryTracking		= 'Item Level' COLLATE Latin1_General_CI_AS
			, strLotTracking			= 'No' COLLATE Latin1_General_CI_AS
			, intCategoryId				= (SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = min(inv.ptitm_class) COLLATE SQL_Latin1_General_CP1_CS_AS)
			, intPatronageCategoryId	= (SELECT TOP 1 min(intPatronageCategoryId) FROM tblPATPatronageCategory INNER JOIN ptitmmst ON (strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = (ptitm_class) COLLATE SQL_Latin1_General_CP1_CS_AS)
			, intLifeTime				= 1
			, ysnLandedCost				= CAST(0 AS BIT)
			, ysnDropShip				= CAST(0 AS BIT)
			, ysnSpecialCommission		= CAST(0 AS BIT)
			, ysnStockedItem			= CAST(CASE WHEN (min(ptitm_stock_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, ysnDyedFuel				= CAST(CASE WHEN (min(ptitm_dyed_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, strBarcodePrint			= CASE WHEN (min(ptitm_bar_code_ind) = 'I') THEN 'Item' WHEN (min(ptitm_bar_code_ind) = 'U') THEN 'UPC' ELSE 'None' END COLLATE Latin1_General_CI_AS
			, ysnMSDSRequired			= CAST(CASE WHEN (min(ptitm_msds_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, ysnAvailableTM			= CAST(CASE WHEN (max(ptitm_avail_tm) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, dblDefaultFull			= max(ptitm_deflt_percnt)
			, ysnExtendPickTicket		= CAST(CASE WHEN (min(ptitm_ext_pic_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, ysnExportEDI				= CAST(CASE WHEN (min(ptitm_edi_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, ysnHazardMaterial			= CAST(CASE WHEN (min(ptitm_hazmat_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, ysnMaterialFee			= CAST(CASE WHEN (min(ptitm_amf_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, strCountCode				= RTRIM(min(ptitm_phys_inv_yno)) COLLATE Latin1_General_CI_AS
			, ysnTaxable				= CAST(CASE WHEN (min(ptitm_sst_yn) = 'Y') THEN 1 ELSE 0 END AS BIT)
			, strKeywords				= RTRIM(min(ptitm_search)) COLLATE Latin1_General_CI_AS
			, intConcurrencyId			= 1
			, ysnCommisionable			= CAST(CASE WHEN (min(ptitm_comm_ind_uag) = 'Y') THEN 1 ELSE 0 END AS BIT)
	FROM ptitmmst AS inv 
	where ptitm_phys_inv_yno <> 'O'
	GROUP BY ptitm_itm_no
) AS i
WHERE NOT EXISTS(SELECT TOP 1 * FROM tblICItem where strItemNo = i.strItemNo)

--update items Inventory type from Category table
-- In latest versions, changing type is not allowed.
-- update	tblICItem 
-- set		strType = C.strInventoryType
-- from	tblICCategory C
-- where	C.intCategoryId = tblICItem.intCategoryId
-- 		AND RTRIM(LTRIM(ISNULL(C.strInventoryType, ''))) <> '' 

--====Delete obsolete items. It is not required in i21 as history is not imported===
--Delete from tblICItem where strStatus = 'Discontinued'
--UPDATE tblICItem
--SET strType = 'Other Charge'
--WHERE strDescription LIKE '%CHARGE%'

--** Items allocated for some charges are considered as non item and we classify it as 'Other Charge' Type.
 --  We validate this thru strDescription. If it contains any charges in it then that item is marked as type 'Other Charge'. **  

UPDATE tblICItem 
SET strInventoryTracking = 'Lot Level'
WHERE ISNULL(strLotTracking, '') <> 'No'

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemUOM data migration from ptitmmst origin table to tblICItemUOM i21 table 
-- Section 2
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @ItemUoms TABLE (
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strPack NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strUpcCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblPackQty NUMERIC(38, 20),
	ysnStockUnit BIT,
	ysnAllowSale BIT,
	ysnAllowPurchase BIT
)

INSERT INTO @ItemUoms (
	strItemNo
	, strUnit
	, strPack
	, strUpcCode
	, dblPackQty
	, ysnAllowPurchase
	, ysnAllowSale
	, ysnStockUnit
)
SELECT DISTINCT 
	ptitm_itm_no = LTRIM(RTRIM(ptitm_itm_no))
	,ptitm_unit = LTRIM(RTRIM(ptitm_unit))
	,ptitm_pak_desc = LTRIM(RTRIM(ptitm_pak_desc))
	,strUpcCode = 
		CASE 
			WHEN LTRIM(RTRIM(min(ptitm_upc_code))) = '' THEN NULL 
			ELSE LTRIM(RTRIM(min(ptitm_upc_code))) 
		END 
	,ptitm_pak_qty = MIN(ptitm_pak_qty)
	,ysnAllowPurchase = 1
	,ysnAllowSale = 1
	,ysnStockUnit = 0
FROM   
	ptitmmst p 
WHERE 
	RTRIM(LTRIM(ptitm_phys_inv_yno)) <> 'O'	
GROUP BY 
	ptitm_itm_no
	,ptitm_unit
	,ptitm_pak_desc

DELETE u
FROM @ItemUoms u
WHERE 
	EXISTS (
		SELECT * 
		FROM 
			tblICItemUOM x INNER JOIN tblICItem z 
				on z.intItemId = x.intItemId
		WHERE 
			z.strItemNo = u.strItemNo 
			AND LTRIM(RTRIM(LOWER(u.strUpcCode))) = LTRIM(RTRIM(LOWER(x.strUpcCode)))
	)

DECLARE @PackUnits TABLE (
	intItemId INT,
	intUnitMeasureId INT,
	dblUnitQty NUMERIC(38, 20),
	strUpcCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnStockUnit BIT,
	ysnAllowSale BIT,
	ysnAllowPurchase BIT
)

DECLARE @BaseUnits TABLE (
	intItemId INT,
	intUnitMeasureId INT,
	dblUnitQty NUMERIC(38, 20),
	strUpcCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnStockUnit BIT,
	ysnAllowSale BIT,
	ysnAllowPurchase BIT
)

INSERT INTO @BaseUnits(
	intItemId
	, intUnitMeasureId
	, dblUnitQty
	, strUpcCode
	, ysnStockUnit
	, ysnAllowPurchase
	, ysnAllowSale
)
SELECT 
	inv.intItemId
	, u.intUnitMeasureId
	, 1
	--, uom.strUpcCode
	--upccode should not be set for stock unit when there are packing units.
	,strUpcCode = 
		CASE 
			WHEN strUnit <> strPack THEN strUpcCode
			ELSE null
		END
	, 1 ysnStockUnit
	, 1 ysnAllowPurchase
	, 1 ysnAllowSale
FROM 
	@ItemUoms uom
	INNER JOIN tblICItem inv ON inv.strItemNo = uom.strItemNo
	INNER JOIN tblICUnitMeasure u ON UPPER(u.strUnitMeasure) = UPPER(uom.strUnit)
WHERE 
	NULLIF(uom.strUnit, '') IS NOT NULL
	AND NOT EXISTS(
		SELECT * FROM tblICItemUOM WHERE intItemId = inv.intItemId AND intUnitMeasureId = u.intUnitMeasureId
	)

;WITH CTE AS 
(
    SELECT intItemId, intUnitMeasureId, ROW_NUMBER() OVER 
    (
        PARTITION BY intItemId, intUnitMeasureId ORDER BY intItemId, intUnitMeasureId
    ) RowNumber
    FROM  @BaseUnits
)
DELETE
FROM CTE 
WHERE RowNumber > 1

;WITH CTE AS 
(
    SELECT intItemId, strUpcCode, ROW_NUMBER() OVER 
    (
        PARTITION BY strUpcCode ORDER BY strUpcCode
    ) RowNumber
    FROM  @BaseUnits
	WHERE strUpcCode IS NOT NULL
)
UPDATE CTE 
SET strUpcCode = NULL
WHERE RowNumber > 1

MERGE INTO tblICItemUOM AS Target
USING (
	SELECT 
		pu.intItemId
		, pu.intUnitMeasureId
		, pu.dblUnitQty
		, pu.strUpcCode
		, 1 ysnStockUnit
		, 1 ysnAllowPurchase
		, 1 ysnAllowSale
		, 1 intConcurrencyId
	FROM 
		@BaseUnits pu
) AS Source ON (
	(Source.strUpcCode = Target.strUpcCode AND Source.strUpcCode IS NOT NULL) 
	OR (Source.strUpcCode IS NULL AND Source.intItemId = Target.intItemId AND Source.intUnitMeasureId = Target.intUnitMeasureId)
)
WHEN NOT MATCHED THEN
INSERT (
	intItemId
	, intUnitMeasureId
	, dblUnitQty
	, strUpcCode
	, ysnStockUnit
	, ysnAllowPurchase
	, ysnAllowSale
	, intConcurrencyId
)
VALUES (
	Source.intItemId
	, Source.intUnitMeasureId
	, Source.dblUnitQty
	, Source.strUpcCode
	, Source.ysnStockUnit
	, Source.ysnAllowPurchase
	, Source.ysnAllowSale
	, Source.intConcurrencyId
)
;

--upccode should not be set for stock unit when there are packing units.
--This is alternate solution
--update iu
--set strUpcCode = null 
--from tblICItemUOM iu
--join tblICItem i on iu.intItemId = i.intItemId
--join ptitmmst p on p.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = i.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS
--where strUpcCode is not null
--and ysnStockUnit = 1
--and p.ptitm_unit <> p.ptitm_pak_de

---- =============================== PACK UNITS ================================================================================
 INSERT INTO @PackUnits(
	intItemId
	, intUnitMeasureId
	, dblUnitQty
	, strUpcCode
	, ysnStockUnit
	, ysnAllowPurchase
	, ysnAllowSale
)
SELECT 
	inv.intItemId
	, u.intUnitMeasureId
	, uom.dblPackQty
	, uom.strUpcCode
	, 0 ysnStockUnit
	, 1 ysnAllowPurchase
	, 1 ysnAllowSale
FROM 
	@ItemUoms uom
	INNER JOIN tblICItem inv ON inv.strItemNo = uom.strItemNo
	INNER JOIN tblICUnitMeasure u ON UPPER(u.strUnitMeasure) = UPPER(uom.strPack)
WHERE 
	NULLIF(uom.strPack, '') IS NOT NULL
	AND NOT EXISTS(
			SELECT * 
			FROM tblICItemUOM
			WHERE intItemId = inv.intItemId AND (intUnitMeasureId = u.intUnitMeasureId OR LTRIM(RTRIM(LOWER(strUpcCode))) = LTRIM(RTRIM(LOWER(uom.strUpcCode))))
	)

;WITH CTE AS 
(
	SELECT intItemId, intUnitMeasureId, ROW_NUMBER() OVER 
	(
		PARTITION BY intItemId, intUnitMeasureId ORDER BY intItemId, intUnitMeasureId
	) RowNumber
	FROM  @PackUnits
)
DELETE
FROM CTE 
WHERE RowNumber > 1

MERGE INTO tblICItemUOM AS Target
USING (
	SELECT pu.intItemId, pu.intUnitMeasureId, pu.dblUnitQty, pu.strUpcCode, 0 ysnStockUnit, 1 ysnAllowPurchase, 1 ysnAllowSale, 1 intConcurrencyId
	FROM @PackUnits pu
) AS Source ON 
--no need to check upccode match
--((Source.strUpcCode = Target.strUpcCode AND Source.strUpcCode IS NOT NULL) OR 
--(Source.strUpcCode IS NULL AND Source.intItemId = Target.intItemId AND Source.intUnitMeasureId = Target.intUnitMeasureId))
(Source.intItemId = Target.intItemId AND Source.intUnitMeasureId = Target.intUnitMeasureId)
WHEN NOT MATCHED THEN
INSERT (
	intItemId
	, intUnitMeasureId
	, dblUnitQty
	, strUpcCode
	, ysnStockUnit
	, ysnAllowPurchase
	, ysnAllowSale
	, intConcurrencyId
)
VALUES(
	Source.intItemId
	, Source.intUnitMeasureId
	, Source.dblUnitQty
	, Source.strUpcCode
	, Source.ysnStockUnit
	, Source.ysnAllowPurchase
	, Source.ysnAllowSale
	, Source.intConcurrencyId
)
;

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemLocation data migration from ptlocmst/ptitmmst origin tables to tblICItemLocation i21 table 
-- Section 3
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Loc TABLE (
	intItemId INT
	, intLocationId INT
	, intVendorId INT
	, intCostingMethod INT
	, intIssueUOMId INT
	, intReceiveUOMId INT
	, intAllowNegativeInventory INT
	, intConcurrencyId INT
)
INSERT INTO @Loc(
	intItemId
	, intLocationId
	, intVendorId
	, intCostingMethod
	, intIssueUOMId
	, intReceiveUOMId
	, intAllowNegativeInventory
	, intConcurrencyId
)
SELECT
	intItemId						= inv.intItemId
	, intLocationId					= loc.intCompanyLocationId
	, intVendorId					= vnd.intEntityId
	, intCostingMethod				= 1
	, intIssueUOMId					= intItemUOMId
	, intReceiveUOMId				= intItemUOMId
	, intAllowNegativeInventory		= 1
	, intConcurrencyId				= 1
FROM 
	ptitmmst AS itm
	INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
	LEFT JOIN vyuEMEntity AS vnd ON (itm.ptitm_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = vnd.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS	AND vnd.strType = 'Vendor')
	LEFT JOIN tblICItemUOM AS uom ON (uom.intItemId) = (inv.intItemId) WHERE uom.ysnStockUnit = 1	
	AND ptitm_phys_inv_yno <> 'O'

;WITH CTE AS 
(
    SELECT intItemId, intLocationId, ROW_NUMBER() OVER 
    (
        PARTITION BY intItemId, intLocationId ORDER BY intItemId, intLocationId
    ) RowNumber
    FROM  @Loc
)
DELETE
FROM CTE 
WHERE RowNumber > 1

MERGE tblICItemLocation AS [Target]
USING
(
	SELECT 
		intItemId
		, intLocationId
		, intVendorId
		, intCostingMethod
		, intIssueUOMId
		, intReceiveUOMId
		, intAllowNegativeInventory
		, intConcurrencyId
	FROM 
		@Loc
) AS [Source] (
	intItemId
	, intLocationId
	, intVendorId
	, intCostingMethod
	, intIssueUOMId
	, intReceiveUOMId
	, intAllowNegativeInventory
	, intConcurrencyId
)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intLocationId = [Source].intLocationId
WHEN NOT MATCHED THEN
INSERT (
	intItemId
	, intLocationId
	, intVendorId
	, intCostingMethod
	, intIssueUOMId
	, intReceiveUOMId
	, intAllowNegativeInventory
	, intConcurrencyId
)
VALUES (
	[Source].intItemId
	, [Source].intLocationId
	, [Source].intVendorId
	, [Source].intCostingMethod
	, [Source].intIssueUOMId
	, [Source].intReceiveUOMId
	, [Source].intAllowNegativeInventory
	, [Source].intConcurrencyId
);

UPDATE l
SET 
	l.dblReorderPoint = itm.ptitm_re_order
	,l.dblMinOrder = itm.ptitm_min_ord_qty
	,l.strStorageUnitNo = itm.ptitm_binloc
	,l.intStorageLocationId = (
		SELECT TOP 1 
			s.intStorageLocationId 
		FROM 
			tblICStorageLocation s JOIN tblSMCompanyLocationSubLocation sl 
				ON sl.intCompanyLocationSubLocationId = s.intSubLocationId
			JOIN tblSMCompanyLocation l 
				on sl.intCompanyLocationId = l.intCompanyLocationId
		WHERE 
			s.strName COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_binloc COLLATE SQL_Latin1_General_CP1_CS_AS
			and l.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS 
	) 
	,l.intSubLocationId = (
		SELECT TOP 1 
			s.intSubLocationId 
		FROM 
			tblICStorageLocation s JOIN tblSMCompanyLocationSubLocation sl 
				ON sl.intCompanyLocationSubLocationId = s.intSubLocationId
			JOIN tblSMCompanyLocation l 
				ON sl.intCompanyLocationId = l.intCompanyLocationId
		WHERE 
			s.strName COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_binloc COLLATE SQL_Latin1_General_CP1_CS_AS
			AND l.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS 
	)
FROM 
	ptitmmst AS itm INNER JOIN tblICItem AS inv 
		ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
    INNER JOIN tblSMCompanyLocation AS loc 
		ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
    JOIN tblICItemLocation l 
		ON l.intLocationId = loc.intCompanyLocationId 
		AND l.intItemId = inv.intItemId
	    AND ptitm_phys_inv_yno <> 'O'

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemPricing data migration from ptitmmst origin table to tblICItemPricing i21 table 
-- Section 4
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Pricing TABLE(
	intItemId INT
	, intItemLocationId INT
	, strPricingMethod NVARCHAR(100)
	, dblLastCost NUMERIC(38, 20)
	, dblStandardCost NUMERIC(38, 20)
	, dblAverageCost NUMERIC(38, 20)
	, dblAmountPercent NUMERIC(38, 20)
	, dblSalePrice NUMERIC(38, 20), intConcurrencyId INT
)

INSERT INTO @Pricing
SELECT
	[intItemId]			= inv.intItemId
	, [intItemLocationId]	= iloc.intItemLocationId
	, [strPricingMethod]	= 'None' COLLATE Latin1_General_CI_AS
	, [dblLastCost]			= itm.ptitm_cost1
	, [dblStandardCost]		= itm.ptitm_std_cost
	, [dblAverageCost]		= itm.ptitm_avg_cost
	, dblAmountPercent		= 0.00
	, dblSalePrice			= itm.ptitm_prc1
	, [intConcurrencyId]	= 1
FROM 
	ptitmmst AS itm INNER JOIN tblICItem AS inv 
		ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	INNER JOIN tblSMCompanyLocation AS loc 
		ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	INNER JOIN tblICItemLocation AS iloc 
		ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)

;WITH CTE AS 
(
    SELECT intItemId, intItemLocationId, ROW_NUMBER() OVER 
    (
        PARTITION BY intItemId, intItemLocationId ORDER BY intItemId, intItemLocationId
    ) RowNumber
    FROM  @Pricing
)
DELETE
FROM CTE 
WHERE RowNumber > 1

MERGE tblICItemPricing AS [Target]
USING
(
	SELECT * FROM @Pricing
) AS [Source] (intItemId, intItemLocationId, strPricingMethod, dblLastCost, dblStandardCost, dblAverageCost, dblAmountPercent, dblSalePrice, intConcurrencyId)
ON 
	[Target].intItemId = [Source].intItemId
	AND [Target].intItemLocationId = [Source].intItemLocationId
WHEN NOT MATCHED THEN
INSERT (
	intItemId
	, intItemLocationId
	, strPricingMethod
	, dblLastCost
	, dblStandardCost
	, dblAverageCost
	, dblAmountPercent
	, dblSalePrice
	, intConcurrencyId
)
VALUES (
	[Source].intItemId
	, [Source].intItemLocationId
	, [Source].strPricingMethod
	, [Source].dblLastCost
	, [Source].dblStandardCost
	, [Source].dblAverageCost
	, [Source].dblAmountPercent
	, [Source].dblSalePrice
	, [Source].intConcurrencyId
);

----------------------------------------------------------------------------------------------------------------
--Import pricing level maintenance. There are 3 pricing levels in origin for petro.
--create pricing levels for all locations in i21.
----------------------------------------------------------------------------------------------------------------
INSERT INTO tblSMCompanyLocationPricingLevel(
	intCompanyLocationId
	, strPricingLevelName
	, intSort
	, intConcurrencyId
)
SELECT 
	CL.intCompanyLocationId
	, prclvl
	, srt
	, 1 
FROM (
	SELECT pt3cf_prc1 prclvl, 1 srt FROM ptctlmst WHERE pt3cf_prc1 is not null
	UNION 
	SELECT pt3cf_prc2 prclvl, 2 srt FROM ptctlmst WHERE pt3cf_prc2 is not null
	UNION
	SELECT pt3cf_prc3 prclvl, 3 srt FROM ptctlmst WHERE pt3cf_prc3 is not null
) AS prc JOIN tblSMCompanyLocation CL 
	ON 1 = 1
WHERE 
	NOT EXISTS (
		SELECT TOP 1 1 
		FROM 
			tblSMCompanyLocationPricingLevel
		WHERE 
			[strPricingLevelName] COLLATE Latin1_General_CI_AS = prclvl COLLATE Latin1_General_CI_AS 
			AND CL.[intCompanyLocationId] = intCompanyLocationId
	)
			--on CL.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = prc.agloc_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS
ORDER BY 
	CL.intCompanyLocationId
	, srt


------------------------------------------------------------------------------------------------------------------
--import pricing levels for the items
--Petro has 3 levels
-- Section 5
------------------------------------------------------------------------------------------------------------------
--price level 1
BEGIN 
	IF OBJECT_ID('tempdb..#tmpImportPricingLevel1') IS NOT NULL  
		DROP TABLE #tmpImportPricingLevel1

	CREATE TABLE #tmpImportPricingLevel1 (
		intItemId INT 
		,intItemLocationId INT NULL 
		,strPriceLevel NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,intItemUnitMeasureId INT NULL
		,dblUnit NUMERIC(18, 6) NULL
		,strPricingMethod NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,dblAmountRate NUMERIC(18, 6) NULL 
		,dblUnitPrice NUMERIC(18, 6) NULL
		,intCompanyLocationPricingLevelId INT NULL 
	)

	INSERT INTO #tmpImportPricingLevel1 (
		intItemId 
		,intItemLocationId 
		,strPriceLevel 
		,intItemUnitMeasureId 
		,dblUnit 
		,strPricingMethod 
		,dblAmountRate 
		,dblUnitPrice 
		,intCompanyLocationPricingLevelId 
	)
	SELECT 
		inv.intItemId
		,iloc.intItemLocationId
		,PL.strPricingLevelName strPricingLevel
		,intItemUnitMeasureId = (
			SELECT TOP 1 
				IU.intItemUOMId 
			FROM 
				tblICItemUOM IU JOIN tblICUnitMeasure U 
					ON U.intUnitMeasureId = IU.intUnitMeasureId
			WHERE 
				IU.intItemId = inv.intItemId
				AND U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS
			)
		,1 dblUnit
		,'None' PricingMethod
		,0
		,ptitm_prc1
		,PL.intCompanyLocationPricingLevelId
	FROM 
		ptitmmst AS itm INNER JOIN tblICItem AS inv 
			ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblSMCompanyLocation AS loc 
			ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblICItemLocation AS iloc 
			ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
		JOIN tblSMCompanyLocationPricingLevel PL 
			ON PL.intCompanyLocationId = iloc.intLocationId 
	WHERE 
		PL.intSort = 1 
		AND ptitm_prc1 > 0

	INSERT INTO [dbo].[tblICItemPricingLevel] (
		intItemId
		,intItemLocationId
		,strPriceLevel
		,intItemUnitMeasureId
		,dblUnit
		,strPricingMethod
		,dblAmountRate
		,dblUnitPrice
		,intCompanyLocationPricingLevelId
		,intConcurrencyId
	)
	SELECT 
		t.intItemId 
		,t.intItemLocationId 
		,t.strPriceLevel 
		,t.intItemUnitMeasureId 
		,t.dblUnit 
		,t.strPricingMethod 
		,t.dblAmountRate 
		,t.dblUnitPrice 
		,t.intCompanyLocationPricingLevelId 	
		,intConcurrencyId = 1
	FROM 
		#tmpImportPricingLevel1 t LEFT JOIN tblICItemPricingLevel p
			ON t.intItemId = p.intItemId 
			AND (t.intItemLocationId = p.intItemLocationId OR (t.intItemLocationId IS NULL AND p.intItemLocationId IS NULL))
			AND (t.strPriceLevel = p.strPriceLevel COLLATE SQL_Latin1_General_CP1_CS_AS OR (t.strPriceLevel IS NULL AND p.strPriceLevel IS NULL))
			AND (t.intItemUnitMeasureId = p.intItemUnitMeasureId OR (t.intItemUnitMeasureId IS NULL AND p.intItemUnitMeasureId IS NULL))
			AND p.dtmEffectiveDate IS NULL 
	WHERE
		p.intItemPricingLevelId IS NULL
END 

---------------------------------------------------------------------------------------------------------------------
--price level 2
BEGIN 
	IF OBJECT_ID('tempdb..#tmpImportPricingLevel2') IS NOT NULL  
		DROP TABLE #tmpImportPricingLevel2

	CREATE TABLE #tmpImportPricingLevel2 (
		intItemId INT 
		,intItemLocationId INT NULL 
		,strPriceLevel NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,intItemUnitMeasureId INT NULL
		,dblUnit NUMERIC(18, 6) NULL
		,strPricingMethod NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,dblAmountRate NUMERIC(18, 6) NULL 
		,dblUnitPrice NUMERIC(18, 6) NULL
		,intCompanyLocationPricingLevelId INT NULL 
	)

	INSERT INTO #tmpImportPricingLevel2 (
		intItemId 
		,intItemLocationId 
		,strPriceLevel 
		,intItemUnitMeasureId 
		,dblUnit 
		,strPricingMethod 
		,dblAmountRate 
		,dblUnitPrice 
		,intCompanyLocationPricingLevelId 
	)
	SELECT 
		inv.intItemId
		,iloc.intItemLocationId
		,PL.strPricingLevelName strPricingLevel
		,intItemUnitMeasureId = (
			SELECT TOP 1 
				IU.intItemUOMId 
			FROM 
				tblICItemUOM IU JOIN tblICUnitMeasure U 
					ON U.intUnitMeasureId = IU.intUnitMeasureId
			WHERE 
				IU.intItemId = inv.intItemId
				AND U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS
		) 
		,1 dblUnit
		,'None' PricingMethod
		,0
		,ptitm_prc2
		,PL.intCompanyLocationPricingLevelId
	FROM 
		ptitmmst AS itm INNER JOIN tblICItem AS inv 
			ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblSMCompanyLocation AS loc 
			ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblICItemLocation AS iloc 
			ON (loc.intCompanyLocationId = iloc.intLocationId AND iloc.intItemId = inv.intItemId)
		JOIN tblSMCompanyLocationPricingLevel PL 
			ON PL.intCompanyLocationId = iloc.intLocationId 
	WHERE 
		PL.intSort = 2 
		AND ptitm_prc2 > 0
		--should not check this. Price levels can have same price
		--and ptitm_prc2 <> ptitm_prc1

	INSERT INTO [dbo].[tblICItemPricingLevel] (
		[intItemId]
		,[intItemLocationId]
		,strPriceLevel
		,intItemUnitMeasureId
		,dblUnit
		,strPricingMethod
		,dblAmountRate
		,dblUnitPrice
		,intCompanyLocationPricingLevelId
		,[intConcurrencyId]
	) 
	SELECT 
		t.intItemId 
		,t.intItemLocationId 
		,t.strPriceLevel 
		,t.intItemUnitMeasureId 
		,t.dblUnit 
		,t.strPricingMethod 
		,t.dblAmountRate 
		,t.dblUnitPrice 
		,t.intCompanyLocationPricingLevelId 	
		,intConcurrencyId = 1
	FROM 
		#tmpImportPricingLevel2 t LEFT JOIN tblICItemPricingLevel p
			ON t.intItemId = p.intItemId 
			AND (t.intItemLocationId = p.intItemLocationId OR (t.intItemLocationId IS NULL AND p.intItemLocationId IS NULL))
			AND (t.strPriceLevel = p.strPriceLevel COLLATE SQL_Latin1_General_CP1_CS_AS OR (t.strPriceLevel IS NULL AND p.strPriceLevel IS NULL))
			AND (t.intItemUnitMeasureId = p.intItemUnitMeasureId OR (t.intItemUnitMeasureId IS NULL AND p.intItemUnitMeasureId IS NULL))
			AND p.dtmEffectiveDate IS NULL 
	WHERE
		p.intItemPricingLevelId IS NULL 

END 

--------------------------------------------------------------------------------------------------------------------
--price level 3
BEGIN 
	IF OBJECT_ID('tempdb..#tmpImportPricingLevel3') IS NOT NULL  
		DROP TABLE #tmpImportPricingLevel3

	CREATE TABLE #tmpImportPricingLevel3 (
		intItemId INT 
		,intItemLocationId INT NULL 
		,strPriceLevel NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,intItemUnitMeasureId INT NULL
		,dblUnit NUMERIC(18, 6) NULL
		,strPricingMethod NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NULL 
		,dblAmountRate NUMERIC(18, 6) NULL 
		,dblUnitPrice NUMERIC(18, 6) NULL
		,intCompanyLocationPricingLevelId INT NULL 
	)

	INSERT INTO #tmpImportPricingLevel3 (
		intItemId 
		,intItemLocationId 
		,strPriceLevel 
		,intItemUnitMeasureId 
		,dblUnit 
		,strPricingMethod 
		,dblAmountRate 
		,dblUnitPrice 
		,intCompanyLocationPricingLevelId 
	)
	SELECT 
		inv.intItemId
		,iloc.intItemLocationId
		,PL.strPricingLevelName strPricingLevel
		,intItemUnitMeasureId = (
			SELECT TOP 1 
				IU.intItemUOMId 
			FROM 
				tblICItemUOM IU JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			WHERE 
				IU.intItemId = inv.intItemId
				AND U.strSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS
		)
		,1 dblUnit
		,'None' PricingMethod
		,0
		,ptitm_prc3
		,PL.intCompanyLocationPricingLevelId
	FROM 
		ptitmmst AS itm INNER JOIN tblICItem AS inv 
			ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblSMCompanyLocation AS loc 
			ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblICItemLocation AS iloc 
			ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
		JOIN tblSMCompanyLocationPricingLevel PL 
			ON PL.intCompanyLocationId = iloc.intLocationId 
	WHERE 
		PL.intSort = 3 
		AND ptitm_prc3 > 0
		--should not check this. Price levels can have same price
		--and ptitm_prc3 not in (ptitm_prc1,ptitm_prc2)

	INSERT INTO [dbo].[tblICItemPricingLevel] (
		[intItemId]
		,[intItemLocationId]
		,strPriceLevel
		,intItemUnitMeasureId
		,dblUnit
		,strPricingMethod
		,dblAmountRate
		,dblUnitPrice
		,intCompanyLocationPricingLevelId
		,[intConcurrencyId]
	) 
	SELECT 
		t.intItemId 
		,t.intItemLocationId 
		,t.strPriceLevel 
		,t.intItemUnitMeasureId 
		,t.dblUnit 
		,t.strPricingMethod 
		,t.dblAmountRate 
		,t.dblUnitPrice 
		,t.intCompanyLocationPricingLevelId 	
		,intConcurrencyId = 1
	FROM 
		#tmpImportPricingLevel3 t LEFT JOIN tblICItemPricingLevel p
			ON t.intItemId = p.intItemId 
			AND (t.intItemLocationId = p.intItemLocationId OR (t.intItemLocationId IS NULL AND p.intItemLocationId IS NULL))
			AND (t.strPriceLevel = p.strPriceLevel COLLATE SQL_Latin1_General_CP1_CS_AS OR (t.strPriceLevel IS NULL AND p.strPriceLevel IS NULL))
			AND (t.intItemUnitMeasureId = p.intItemUnitMeasureId OR (t.intItemUnitMeasureId IS NULL AND p.intItemUnitMeasureId IS NULL))
			AND p.dtmEffectiveDate IS NULL 
	WHERE
		p.intItemPricingLevelId IS NULL 
END 

--===Convert Physical items to bundles in i21
UPDATE I 
SET strBundleType = 'Kit',
	ysnListBundleSeparately = 0
FROM 
	tblICItem I 
WHERE EXISTS (
		SELECT TOP 1 1 
		FROM 
			ptitmmst 
		WHERE 
			ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = strItemNo 
			AND ptitm_alt_itm <>'' 
			AND ptitm_alt_itm <> ptitm_itm_no
	) 

INSERT INTO tblICItemBundle (
	intItemId,
	intBundleItemId,
	strDescription,
	dblQuantity,
	intItemUnitMeasureId,
	ysnAddOn,
	dblMarkUpOrDown,
	intConcurrencyId
)
SELECT DISTINCT 
	I.intItemId, 
	IA.intItemId,
	I.strDescription, 
	1 Quantity, 
	U.intItemUOMId,
	0 addon, 
	0 markup,
	1 Concurrency 
FROM 
	tblICItem I JOIN ptitmmst p 
		ON I.strItemNo = p.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
	JOIN tblICItem IA 
		ON IA.strItemNo = p.ptitm_alt_itm COLLATE SQL_Latin1_General_CP1_CS_AS
	JOIN tblICItemUOM U 
		ON I.intItemId = U.intItemId AND U.ysnStockUnit = 1
WHERE 
	ptitm_alt_itm <>'' AND ptitm_alt_itm <> ptitm_itm_no
	AND NOT EXISTS(SELECT * FROM tblICItemBundle where intItemId = I.intItemId AND intItemUOMId = U.intItemUOMId)

UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1
UPDATE tblICItemLocation SET intCostingMethod = 1 WHERE intCostingMethod IS NULL

-- Fix Items with multiple stock Units
DECLARE @ItemsWithMultipleStockUnits TABLE (
	intItemId INT
	, intItemUOMId INT NULL
)
INSERT INTO @ItemsWithMultipleStockUnits(
	intItemId
)
SELECT u.intItemId--, i.strItemNo
FROM 
	tblICItemUOM u INNER JOIN tblICItem i ON i.intItemId = u.intItemId
WHERE 
	u.ysnStockUnit = 1
GROUP BY 
	u.intItemId--, i.strItemNo
HAVING COUNT(*) > 1

UPDATE u
SET 
	u.intItemUOMId = i.intItemUOMId
FROM 
	@ItemsWithMultipleStockUnits u INNER JOIN tblICItemUOM i 
		ON i.intItemId = u.intItemId

UPDATE u
SET u.ysnStockUnit = 0
FROM 
	tblICItemUOM u INNER JOIN @ItemsWithMultipleStockUnits m 
		ON m.intItemId = u.intItemId
		AND m.intItemUOMId <> u.intItemUOMId

-- import Storage unit #
UPDATE tblICItemLocation
SET 
	strStorageUnitNo = D.ptitm_binloc
FROM 
	tblICItemLocation A
	INNER JOIN tblICItem B on A.intItemId = B.intItemId
	INNER JOIN tblSMCompanyLocation C on A.intLocationId = C.intCompanyLocationId
	INNER JOIN ptitmmst D on B.strItemNo = D.ptitm_itm_no collate SQL_Latin1_General_CP1_CS_AS
	AND C.strLocationNumber = D.ptitm_loc_no collate SQL_Latin1_General_CP1_CS_AS

-- Fix the duplicate UPC Codes (strUpcCode)
UPDATE iu
SET 
	iu.strUpcCode = NULL 
FROM 
	tblICItemUOM iu INNER JOIN (
		SELECT 
			iu.strUpcCode
		FROM 
			tblICItemUOM iu
		WHERE
			strUpcCode IS NOT NULL 
		GROUP BY 
			iu.strUpcCode
		HAVING 
			COUNT(1) > 1	
	) iuFix 
		ON iu.strUpcCode = iuFix.strUpcCode

-- Fix the duplicate UPC Codes (strLongUPCCode)
UPDATE iu
SET 
	iu.strLongUPCCode = NULL 
FROM 
	tblICItemUOM iu INNER JOIN (
		SELECT 
			iu.strLongUPCCode
		FROM 
			tblICItemUOM iu
		WHERE
			strLongUPCCode IS NOT NULL 
		GROUP BY 
			iu.strLongUPCCode
		HAVING 
			COUNT(1) > 1	
	) iuFix 
		ON iu.strLongUPCCode = iuFix.strLongUPCCode

GO