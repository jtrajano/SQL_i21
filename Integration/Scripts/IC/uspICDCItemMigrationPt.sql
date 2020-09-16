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
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- Inventory/Item data migration from ptitmmst origin table to tblICItem i21 table 
-- Section 1
--------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO tblICItem(strItemNo, strType, strDescription, strStatus, strInventoryTracking, strLotTracking, intCategoryId, intPatronageCategoryId, intLifeTime, ysnLandedCost, ysnDropShip
	,ysnSpecialCommission, ysnStockedItem, ysnDyedFuel, strBarcodePrint, ysnMSDSRequired, ysnAvailableTM, dblDefaultFull, ysnExtendPickTicket, ysnExportEDI, ysnHazardMaterial
	,ysnMaterialFee, strCountCode, ysnTaxable, strKeywords, intConcurrencyId, ysnCommisionable, dtmDateCreated)
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
WHERE NOT EXISTS(SELECT * FROM tblICItem where strItemNo = i.strItemNo)
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
	ysnAllowPurchase BIT)

INSERT INTO @ItemUoms(strItemNo, strUnit, strPack, strUpcCode, dblPackQty, ysnAllowPurchase, ysnAllowSale, ysnStockUnit)
SELECT DISTINCT LTRIM(RTRIM(ptitm_itm_no))
	  ,LTRIM(RTRIM(ptitm_unit))
	  ,LTRIM(RTRIM(ptitm_pak_desc))
	  ,CASE WHEN LTRIM(RTRIM(min(ptitm_upc_code))) = '' THEN NULL ELSE LTRIM(RTRIM(min(ptitm_upc_code))) END 
	  ,MIN(ptitm_pak_qty)
	  ,1,1,0
FROM   ptitmmst
where RTRIM(LTRIM(ptitm_phys_inv_yno)) <> 'O'
---and ptitm_itm_no = '10093P'
group by ptitm_itm_no,ptitm_unit,ptitm_pak_desc
DELETE u
FROM @ItemUoms u
WHERE EXISTS(SELECT * FROM tblICItemUOM x inner join tblICItem z on z.intItemId = x.intItemId
	WHERE z.strItemNo = u.strItemNo AND LTRIM(RTRIM(LOWER(u.strUpcCode))) = LTRIM(RTRIM(LOWER(x.strUpcCode))))

DECLARE @PackUnits TABLE (
	intItemId INT,
	intUnitMeasureId INT,
	dblUnitQty NUMERIC(38, 20),
	strUpcCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnStockUnit BIT,
	ysnAllowSale BIT,
	ysnAllowPurchase BIT)

DECLARE @BaseUnits TABLE (
	intItemId INT,
	intUnitMeasureId INT,
	dblUnitQty NUMERIC(38, 20),
	strUpcCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	ysnStockUnit BIT,
	ysnAllowSale BIT,
	ysnAllowPurchase BIT)

INSERT INTO @BaseUnits(intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale)
SELECT inv.intItemId, u.intUnitMeasureId, 1,
--, uom.strUpcCode
--upccode should not be set for stock unit when there are packing units.
case when strUnit <> strPack then 
strUpcCode
else
null
end
, 1 ysnStockUnit, 1 ysnAllowPurchase, 1 ysnAllowSale
FROM @ItemUoms uom
	INNER JOIN tblICItem inv ON inv.strItemNo = uom.strItemNo
	INNER JOIN tblICUnitMeasure u ON UPPER(u.strSymbol) = UPPER(uom.strUnit)
WHERE NULLIF(uom.strUnit, '') IS NOT NULL
	AND NOT EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = inv.intItemId AND intUnitMeasureId = u.intUnitMeasureId)

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
	SELECT pu.intItemId, pu.intUnitMeasureId, pu.dblUnitQty, pu.strUpcCode, 1 ysnStockUnit, 1 ysnAllowPurchase, 1 ysnAllowSale, 1 intConcurrencyId
	FROM @BaseUnits pu
) AS Source ON ((Source.strUpcCode = Target.strUpcCode AND Source.strUpcCode IS NOT NULL) OR (Source.strUpcCode IS NULL AND Source.intItemId = Target.intItemId AND Source.intUnitMeasureId = Target.intUnitMeasureId))
WHEN NOT MATCHED THEN
INSERT (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
VALUES(Source.intItemId, Source.intUnitMeasureId, Source.dblUnitQty, Source.strUpcCode, Source.ysnStockUnit, Source.ysnAllowPurchase, Source.ysnAllowSale, Source.intConcurrencyId)
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
 INSERT INTO @PackUnits(intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale)
	SELECT inv.intItemId, u.intUnitMeasureId, uom.dblPackQty, uom.strUpcCode, 0 ysnStockUnit, 1 ysnAllowPurchase, 1 ysnAllowSale
	FROM @ItemUoms uom
		INNER JOIN tblICItem inv ON inv.strItemNo = uom.strItemNo
		INNER JOIN tblICUnitMeasure u ON UPPER(u.strSymbol) = UPPER(uom.strPack)
	WHERE NULLIF(uom.strPack, '') IS NOT NULL
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
INSERT (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
VALUES(Source.intItemId, Source.intUnitMeasureId, Source.dblUnitQty, Source.strUpcCode, Source.ysnStockUnit, Source.ysnAllowPurchase, Source.ysnAllowSale, Source.intConcurrencyId)
;

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemLocation data migration from ptlocmst/ptitmmst origin tables to tblICItemLocation i21 table 
-- Section 3
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Loc TABLE (intItemId INT, intLocationId INT, intVendorId INT, intCostingMethod INT, intIssueUOMId INT, intReceiveUOMId INT, intAllowNegativeInventory INT, intConcurrencyId INT)
INSERT INTO @Loc(intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
SELECT
		intItemId						= inv.intItemId
	, intLocationId					= loc.intCompanyLocationId
	, intVendorId					= vnd.intEntityId
	, intCostingMethod				= 1
	, intIssueUOMId					= intItemUOMId
	, intReceiveUOMId				= intItemUOMId
	, intAllowNegativeInventory		= 1
	, intConcurrencyId				= 1
FROM ptitmmst AS itm
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
	SELECT intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId
	FROM @Loc
) AS [Source] (intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intLocationId = [Source].intLocationId
WHEN NOT MATCHED THEN
INSERT (intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intLocationId, [Source].intVendorId, [Source].intCostingMethod, [Source].intIssueUOMId,
	[Source].intReceiveUOMId, [Source].intAllowNegativeInventory, [Source].intConcurrencyId);


update l
set l.dblReorderPoint = itm.ptitm_re_order
,l.dblMinOrder = itm.ptitm_min_ord_qty
,l.strStorageUnitNo = itm.ptitm_binloc
,l.intStorageLocationId = 
(select TOP 1 s.intStorageLocationId from tblICStorageLocation s 
join tblSMCompanyLocationSubLocation sl on sl.intCompanyLocationSubLocationId = s.intSubLocationId
join tblSMCompanyLocation l on sl.intCompanyLocationId = l.intCompanyLocationId
where s.strName COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_binloc COLLATE SQL_Latin1_General_CP1_CS_AS
and l.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS 
) 
,l.intSubLocationId =
(select TOP 1 s.intSubLocationId from tblICStorageLocation s 
join tblSMCompanyLocationSubLocation sl on sl.intCompanyLocationSubLocationId = s.intSubLocationId
join tblSMCompanyLocation l on sl.intCompanyLocationId = l.intCompanyLocationId
where s.strName COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_binloc COLLATE SQL_Latin1_General_CP1_CS_AS
and l.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS 
)
FROM ptitmmst AS itm
    INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
    INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
    join tblICItemLocation l on l.intLocationId = loc.intCompanyLocationId and l.intItemId = inv.intItemId
    AND ptitm_phys_inv_yno <> 'O'
--and itm.ptitm_itm_no = '213304P'

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemPricing data migration from ptitmmst origin table to tblICItemPricing i21 table 
-- Section 4
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Pricing TABLE(intItemId INT, intItemLocationId INT, strPricingMethod NVARCHAR(100), dblLastCost NUMERIC(38, 20),
	dblStandardCost NUMERIC(38, 20), dblAverageCost NUMERIC(38, 20),  dblAmountPercent NUMERIC(38, 20), dblSalePrice NUMERIC(38, 20), intConcurrencyId INT)
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
	FROM ptitmmst AS itm
		INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
		INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)

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
	SELECT *
	FROM @Pricing
) AS [Source] (intItemId, intItemLocationId, strPricingMethod, dblLastCost, dblStandardCost, dblAverageCost, dblAmountPercent, dblSalePrice, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intItemLocationId = [Source].intItemLocationId
WHEN NOT MATCHED THEN
INSERT (intItemId, intItemLocationId, strPricingMethod, dblLastCost, dblStandardCost, dblAverageCost, dblAmountPercent, dblSalePrice, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intItemLocationId, [Source].strPricingMethod, [Source].dblLastCost, [Source].dblStandardCost,
	[Source].dblAverageCost, [Source].dblAmountPercent, [Source].dblSalePrice, [Source].intConcurrencyId);

----------------------------------------------------------------------------------------------------------------
--Import pricing level maintenance. There are 3 pricing levels in origin for petro.
--create pricing levels for all locations in i21.
----------------------------------------------------------------------------------------------------------------
insert into tblSMCompanyLocationPricingLevel
(intCompanyLocationId, strPricingLevelName, intSort, intConcurrencyId)
select CL.intCompanyLocationId, prclvl, srt, 1 from 
(
select pt3cf_prc1 prclvl, 1 srt from ptctlmst where pt3cf_prc1 is not null
union
select pt3cf_prc2 prclvl, 2 srt from ptctlmst where pt3cf_prc2 is not null
union
select pt3cf_prc3 prclvl, 3 srt from ptctlmst where pt3cf_prc3 is not null
) as prc 
join tblSMCompanyLocation CL on 1 = 1
where CL.[intCompanyLocationId] not in (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
where [strPricingLevelName] COLLATE Latin1_General_CI_AS = prclvl COLLATE Latin1_General_CI_AS)
--on CL.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = prc.agloc_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS
order by CL.intCompanyLocationId, srt


------------------------------------------------------------------------------------------------------------------
--import pricing levels for the items
--Petro has 3 levels
-- Section 5
------------------------------------------------------------------------------------------------------------------
--price level 1

INSERT INTO [dbo].[tblICItemPricingLevel] (
	[intItemId]
	,[intItemLocationId]
	,strPriceLevel
	,intItemUnitMeasureId
	,dblUnit
	,strPricingMethod
	,dblAmountRate
	,dblUnitPrice
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	)
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId 
	from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc1
	,PL.intCompanyLocationPricingLevelId
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 1 and ptitm_prc1 > 0
---------------------------------------------------------------------------------------------------------------------
--price level 2
INSERT INTO [dbo].[tblICItemPricingLevel] (
	[intItemId]
	,[intItemLocationId]
	,strPriceLevel
	,intItemUnitMeasureId
	,dblUnit
	,strPricingMethod
	,dblAmountRate
	,dblUnitPrice
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	)
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc2
	,PL.intCompanyLocationPricingLevelId
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 2 and ptitm_prc2 > 0
	--should not check this. Price levels can have same price
	--and ptitm_prc2 <> ptitm_prc1
	and not exists (select 1 from tblICItemPricingLevel l where l.intItemId = inv.intItemId
	and iloc.intItemLocationId = l.intItemLocationId and l.strPriceLevel = PL.strPricingLevelName)
--------------------------------------------------------------------------------------------------------------------
--price level 3
INSERT INTO [dbo].[tblICItemPricingLevel] (
	[intItemId]
	,[intItemLocationId]
	,strPriceLevel
	,intItemUnitMeasureId
	,dblUnit
	,strPricingMethod
	,dblAmountRate
	,dblUnitPrice
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	)
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc3
	,PL.intCompanyLocationPricingLevelId
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 3 and ptitm_prc3 > 0
	--should not check this. Price levels can have same price
     --and ptitm_prc3 not in (ptitm_prc1,ptitm_prc2)
     and not exists (select 1 from tblICItemPricingLevel l where l.intItemId = inv.intItemId 
     and  iloc.intItemLocationId = l.intItemLocationId and l.strPriceLevel = PL.strPricingLevelName)

	--===Convert Physical items to bundles in i21
	UPDATE I 
	SET strType = 'Bundle',
		strBundleType = 'Kit',
		ysnListBundleSeparately = 0
	FROM tblICItem I WHERE strItemNo in	(SELECT ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS FROM ptitmmst WHERE ptitm_alt_itm <>'' and ptitm_alt_itm <> ptitm_itm_no) 

	INSERT INTO tblICItemBundle (intItemId,
								intBundleItemId,
								strDescription,
								dblQuantity,
								intItemUnitMeasureId,
								ysnAddOn,
								dblMarkUpOrDown,
								intConcurrencyId)
	SELECT DISTINCT I.intItemId, 
				IA.intItemId,
				I.strDescription, 
				1 Quantity, 
				U.intItemUOMId,
				0 addon, 
				0 markup,
				1 Concurrency 
	FROM tblICItem I 
		JOIN ptitmmst p ON I.strItemNo = p.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		JOIN tblICItem IA ON IA.strItemNo = p.ptitm_alt_itm COLLATE SQL_Latin1_General_CP1_CS_AS
		JOIN tblICItemUOM U ON I.intItemId = U.intItemId AND U.ysnStockUnit = 1
	WHERE ptitm_alt_itm <>'' AND ptitm_alt_itm <> ptitm_itm_no
		AND NOT EXISTS(SELECT * FROM tblICItemBundle where intItemId = I.intItemId AND intItemUOMId = U.intItemUOMId)

UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1
UPDATE tblICItemLocation SET intCostingMethod = 1 WHERE intCostingMethod IS NULL

-- Fix Items with multiple stock Units
DECLARE @ItemsWithMultipleStockUnits TABLE (intItemId INT, intItemUOMId INT NULL)
INSERT INTO @ItemsWithMultipleStockUnits(intItemId)
SELECT u.intItemId--, i.strItemNo
FROM tblICItemUOM u
	INNER JOIN tblICItem i ON i.intItemId = u.intItemId
WHERE u.ysnStockUnit = 1
GROUP BY u.intItemId--, i.strItemNo
HAVING COUNT(*) > 1

update u
SET u.intItemUOMId = i.intItemUOMId
FROM @ItemsWithMultipleStockUnits u
INNER JOIN tblICItemUOM i ON i.intItemId = u.intItemId

UPDATE u
SET u.ysnStockUnit = 0
FROM tblICItemUOM u
INNER JOIN @ItemsWithMultipleStockUnits m ON m.intItemId = u.intItemId
	AND m.intItemUOMId <> u.intItemUOMId

-- import Storage unit #
update tblICItemLocation
set strStorageUnitNo = D.ptitm_binloc
from tblICItemLocation A
inner join tblICItem B on A.intItemId = B.intItemId
inner join tblSMCompanyLocation C on A.intLocationId = C.intCompanyLocationId
inner join ptitmmst D on B.strItemNo = D.ptitm_itm_no collate SQL_Latin1_General_CP1_CS_AS
 and C.strLocationNumber = D.ptitm_loc_no collate SQL_Latin1_General_CP1_CS_AS

GO