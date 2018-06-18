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
MERGE tblICItem AS [Target]
USING
(
	SELECT
		  strItemNo					= RTRIM(ptitm_itm_no) COLLATE Latin1_General_CI_AS
		, strType					= CASE WHEN (min(ptitm_phys_inv_yno) = 'N') THEN 'Other Charge' ELSE 'Inventory' END COLLATE Latin1_General_CI_AS
		, strDescription			= RTRIM(min(ptitm_desc)) COLLATE Latin1_General_CI_AS
		, strStatus					= CASE WHEN (min(ptitm_phys_inv_yno) = 'O') THEN 'Discontinued' ELSE 'Active' END COLLATE Latin1_General_CI_AS
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
	GROUP BY ptitm_itm_no
) AS [Source] (strItemNo, strType, strDescription, strStatus, strInventoryTracking, strLotTracking, intCategoryId, intPatronageCategoryId, intLifeTime, ysnLandedCost, ysnDropShip
	,ysnSpecialCommission, ysnStockedItem, ysnDyedFuel, strBarcodePrint, ysnMSDSRequired, ysnAvailableTM, dblDefaultFull, ysnExtendPickTicket, ysnExportEDI, ysnHazardMaterial
	,ysnMaterialFee, strCountCode, ysnTaxable, strKeywords, intConcurrencyId, ysnCommisionable)
ON [Target].strItemNo = [Source].strItemNo
WHEN NOT MATCHED THEN
INSERT (strItemNo, strType, strDescription, strStatus, strInventoryTracking, strLotTracking, intCategoryId, intPatronageCategoryId, intLifeTime, ysnLandedCost, ysnDropShip
	,ysnSpecialCommission, ysnStockedItem, ysnDyedFuel, strBarcodePrint, ysnMSDSRequired, ysnAvailableTM, dblDefaultFull, ysnExtendPickTicket, ysnExportEDI, ysnHazardMaterial
	,ysnMaterialFee, strCountCode, ysnTaxable, strKeywords, intConcurrencyId, ysnCommisionable)
VALUES ([Source].strItemNo, [Source].strType, [Source].strDescription, [Source].strStatus, [Source].strInventoryTracking, [Source].strLotTracking, [Source].intCategoryId,
	[Source].intPatronageCategoryId, [Source].intLifeTime, [Source].ysnLandedCost, [Source].ysnDropShip, [Source].ysnSpecialCommission, [Source].ysnStockedItem, [Source].ysnDyedFuel,
	[Source].strBarcodePrint, [Source].ysnMSDSRequired, [Source].ysnAvailableTM, [Source].dblDefaultFull, [Source].ysnExtendPickTicket, [Source].ysnExportEDI, [Source].ysnHazardMaterial,
	[Source].ysnMaterialFee, [Source].strCountCode, [Source].ysnTaxable, [Source].strKeywords, [Source].intConcurrencyId, [Source].ysnCommisionable);


--update items Inventory type from Category table
update	tblICItem 
set		strType = C.strInventoryType
from	tblICCategory C
where	C.intCategoryId = tblICItem.intCategoryId
		AND RTRIM(LTRIM(ISNULL(C.strInventoryType, ''))) <> '' 


--UPDATE tblICItem
--SET strType = 'Other Charge'
--WHERE strDescription LIKE '%CHARGE%'

--** Items allocated for some charges are considered as non item and we classify it as 'Other Charge' Type.
 --  We validate this thru strDescription. If it contains any charges in it then that item is marked as type 'Other Charge'. **  

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemUOM data migration from ptitmmst origin table to tblICItemUOM i21 table 
-- Section 2
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @item NVARCHAR(MAX)
DECLARE @unit NVARCHAR(MAX)
DECLARE @package NVARCHAR(MAX)
DECLARE @unitvalue INT

DECLARE itm_cursor CURSOR
FOR
SELECT ptitm_itm_no
	  ,ptitm_unit
	  ,ptitm_pak_desc
	  ,min(ptitm_pak_qty)
FROM   ptitmmst
group by ptitm_itm_no,ptitm_unit,ptitm_pak_desc

OPEN itm_cursor

SET @unit = NULL
--** Cursor variable equivalent for ptitm_unit column **.
SET @item = NULL
--** Cursor variable equivalent for ptitm_itm_no column **.
SET @package = NULL
--** Cursor variable equivalent for ptitm_pak_desc column **.
SET @unitvalue = 0
--** Cursor variable equivalent for ptitm_pak_qty column **.

FETCH NEXT
FROM itm_cursor
INTO @item
	,@unit
	,@package
	,@unitvalue

--** Using Cursor method we associate the Unit from UnitMeasure table with item from tblICItem table for each item record by record. **

WHILE @@FETCH_STATUS = 0
BEGIN
	MERGE tblICItemUOM AS [Target]
	USING
	(
		SELECT
			  intItemId			= inv.intItemId
			, intUnitMeasureId	= unm.intUnitMeasureId
			, dblUnitQty		= min(itm.ptitm_pak_qty)
			, strUpcCode		= CASE WHEN RTRIM(min(itm.ptitm_upc_code)) COLLATE Latin1_General_CI_AS = '' 
									   THEN NULL 
									   ELSE RTRIM(min(itm.ptitm_upc_code)) COLLATE Latin1_General_CI_AS END 
			, ysnStockUnit		= CAST(1 AS BIT)
			, ysnAllowPurchase	= CAST(1 AS BIT)
			, ysnAllowSale		= CAST(1 AS BIT)
			, intConcurrencyId	= 1
		FROM ptitmmst AS itm
			INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
			INNER JOIN tblICUnitMeasure AS unm ON Upper(unm.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(itm.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE ptitm_unit = @unit AND ptitm_itm_no = @item 
		GROUP BY inv.intItemId, unm.intUnitMeasureId
	) AS [Source] (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
	ON [Target].intItemId = [Source].intItemId
		AND [Target].intUnitMeasureId = [Source].intUnitMeasureId
	WHEN NOT MATCHED THEN
	INSERT (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
	VALUES ([Source].intItemId, [Source].intUnitMeasureId, [Source].dblUnitQty, [Source].strUpcCode, [Source].ysnStockUnit, 
		[Source].ysnAllowPurchase, [Source].ysnAllowSale, [Source].intConcurrencyId);

--** If unit of an Item (@unitvalue) is > 1, then UnitMeasure is considered in terms of package. So we need to update package record also.
--   Hence to fetch package, we join strSymbol column from tblICUnitMeasure table with ptitm_pak_desc column from ptitmmst table. **

	IF @unitvalue > 1
	BEGIN
		MERGE tblICItemUOM AS [Target]
		USING
		(
			SELECT
				  intItemId			= inv.intItemId
				, intUnitMeasureId	= unm.intUnitMeasureId
				, dblUnitQty		= min(itm.ptitm_pak_qty)
				, strUpcCode		= RTRIM(min(itm.ptitm_upc_code)) COLLATE Latin1_General_CI_AS
				, ysnStockUnit		= CAST(0 AS BIT)
				, ysnAllowPurchase	= CAST(1 AS BIT)
				, ysnAllowSale		= CAST(1 AS BIT)
				, intConcurrencyId	= 1
			FROM ptitmmst AS itm 
				INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
				INNER JOIN tblICUnitMeasure AS unm ON Upper(unm.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(itm.ptitm_pak_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE ptitm_pak_desc = @package AND ptitm_itm_no = @item
			GROUP BY inv.intItemId, unm.intUnitMeasureId
		) AS [Source] (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
		ON [Target].intItemId = [Source].intItemId
			AND [Target].intUnitMeasureId = [Source].intUnitMeasureId
		WHEN NOT MATCHED THEN
		INSERT (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
		VALUES ([Source].intItemId, [Source].intUnitMeasureId, [Source].dblUnitQty, [Source].strUpcCode, [Source].ysnStockUnit, 
			[Source].ysnAllowPurchase, [Source].ysnAllowSale, [Source].intConcurrencyId);
	END

	FETCH NEXT
	FROM itm_cursor
	INTO @item
		,@unit
		,@package
		,@unitvalue
END

CLOSE itm_cursor

DEALLOCATE itm_cursor

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemLocation data migration from ptlocmst/ptitmmst origin tables to tblICItemLocation i21 table 
-- Section 3
--------------------------------------------------------------------------------------------------------------------------------------------
MERGE tblICItemLocation AS [Target]
USING
(
	SELECT
		  intItemId						= inv.intItemId
		, intLocationId					= loc.intCompanyLocationId
		, intVendorId					= vnd.intEntityId
		, intCostingMethod				= 1
		, intIssueUOMId					= intItemUOMId
		, intReceiveUOMId				= intItemUOMId
		, intAllowNegativeInventory		= 3
		, intConcurrencyId				= 1
	FROM ptitmmst AS itm
		INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
		LEFT JOIN vyuEMEntity AS vnd ON (itm.ptitm_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = vnd.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS	AND vnd.strType = 'Vendor')
		LEFT JOIN tblICItemUOM AS uom ON (uom.intItemId) = (inv.intItemId) WHERE uom.ysnStockUnit = 1	
) AS [Source] (intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
ON [Target].intItemId = [Source].intItemId
	AND [Target].intLocationId = [Source].intLocationId
WHEN NOT MATCHED THEN
INSERT (intItemId, intLocationId, intVendorId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
VALUES ([Source].intItemId, [Source].intLocationId, [Source].intVendorId, [Source].intCostingMethod, [Source].intIssueUOMId,
	[Source].intReceiveUOMId, [Source].intAllowNegativeInventory, [Source].intConcurrencyId);

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemPricing data migration from ptitmmst origin table to tblICItemPricing i21 table 
-- Section 4
--------------------------------------------------------------------------------------------------------------------------------------------
MERGE tblICItemPricing AS [Target]
USING
(
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
--This is the retail price and is imported as standard pricing
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
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 2 and ptitm_prc2 > 0 and ptitm_prc2 <> ptitm_prc1

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
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 3 and ptitm_prc3 > 0 and ptitm_prc3 not in (ptitm_prc1,ptitm_prc2)

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
		JOIN tblICItemUOM U ON I.intItemId = U.intItemId AND U.ysnStockUOM = 1
	WHERE ptitm_alt_itm <>'' AND ptitm_alt_itm <> ptitm_itm_no

GO