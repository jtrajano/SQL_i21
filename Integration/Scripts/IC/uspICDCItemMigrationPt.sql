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
INSERT INTO tblICItem (
	strItemNo
	,strType
	,strDescription
	,strStatus
	,strInventoryTracking
	,strLotTracking
	,intCategoryId
	,intPatronageCategoryId
	,intLifeTime
	,ysnLandedCost
	,ysnDropShip
	,ysnSpecialCommission
	,ysnStockedItem
	,ysnDyedFuel
	,strBarcodePrint
	,ysnMSDSRequired
	,ysnAvailableTM
	,ysnExtendPickTicket
	,ysnExportEDI
	,ysnHazardMaterial
	,ysnMaterialFee
	,strCountCode
	,ysnTaxable
	,strKeywords
	,intConcurrencyId
	,ysnCommisionable
	) (
	SELECT RTRIM(ptitm_itm_no)
--** Items with physical count set to 'No' is classified as 'Inventory Type' = Service and 
--   Items with physical count set to 'Yes' or 'Obsolete' is classified as 'Inventory Type' = Inventory. **

	,(
		CASE 
			WHEN (min(ptitm_phys_inv_yno) = 'N')
				THEN 'Other Charge' 
			ELSE 'Inventory'
			END
		)
	,RTRIM(min(ptitm_desc))
--** Items with physical count set to 'Obsolete' is classified as 'Status' = Discontinued and 
--   Items with physical count set to 'Yes' or 'No' is classified as 'Status' = Active. **
	,(
		CASE 
			WHEN (min(ptitm_phys_inv_yno) = 'O')
				THEN 'Discontinued'
			ELSE 'Active'
			END
		)
	,'Item Level'
	,'No'
	,(
		SELECT TOP 1 min(intCategoryId)
		FROM tblICCategory AS cls
		WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = min(inv.ptitm_class) COLLATE SQL_Latin1_General_CP1_CS_AS
		)
	,(
		SELECT TOP 1 min(intPatronageCategoryId)
		FROM tblPATPatronageCategory
		INNER JOIN ptitmmst ON (strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = (ptitm_class) COLLATE SQL_Latin1_General_CP1_CS_AS
		)
	,'1'
	,'0'
	,'0'
	,'0'
	,(
		CASE 
			WHEN (min(ptitm_stock_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_dyed_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_bar_code_ind) = 'I')
				THEN 'Item'
			WHEN (min(ptitm_bar_code_ind) = 'U')
				THEN 'UPC'
			ELSE 'None'
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_msds_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_avail_tm) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_ext_pic_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_edi_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_hazmat_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,(
		CASE 
			WHEN (min(ptitm_amf_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,RTRIM(min(ptitm_phys_inv_yno))
	,(
		CASE 
			WHEN (min(ptitm_sst_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		)
	,RTRIM(min(ptitm_search))
	,1
	,(
		CASE 
			WHEN (min(ptitm_comm_ind_uag) = 'Y')
				THEN 1
			ELSE 0
			END
		) FROM ptitmmst AS inv GROUP BY ptitm_itm_no
	)
--** Group By ptitim_itm_no is done inorder to support single item in multiple locations. **

--update items Inventory type from Category table
update tblICItem set strType = C.strInventoryType
from tblICCategory C
where C.intCategoryId = tblICItem.intCategoryId


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
SELECT DISTINCT ptitm_itm_no
	,ptitm_unit
	,ptitm_pak_desc
	,ptitm_pak_qty
FROM ptitmmst

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
	INSERT INTO [dbo].[tblICItemUOM] (
		intItemId
		,intUnitMeasureId
		,dblUnitQty
		,strUpcCode
		,ysnStockUnit
		,ysnAllowPurchase
		,ysnAllowSale
		,intConcurrencyId
		) (
--** If unit of an Item (@unitvalue) is = 1, then UnitMeasure is considered in terms of unit. So update of unit alone is enough and package is not required.
--   Hence to fetch unit, we join strSymbol column from tblICUnitMeasure table with ptitm_unit column from ptitmmst table. **

		SELECT inv.intItemId
		,unm.intUnitMeasureId
		,min(itm.ptitm_pak_qty)
		,RTRIM(min(itm.ptitm_upc_code))
		,1
		,1
		,1
		,1 FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
		INNER JOIN tblICUnitMeasure AS unm ON Upper(unm.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(itm.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE ptitm_unit = @unit AND ptitm_itm_no = @item 
		GROUP BY inv.intItemId, unm.intUnitMeasureId
		)

--** If unit of an Item (@unitvalue) is > 1, then UnitMeasure is considered in terms of package. So we need to update package record also.
--   Hence to fetch package, we join strSymbol column from tblICUnitMeasure table with ptitm_pak_desc column from ptitmmst table. **

	IF @unitvalue > 1
	BEGIN
		INSERT INTO [dbo].[tblICItemUOM] (
			intItemId
			,intUnitMeasureId
			,dblUnitQty
			,strUpcCode
			,ysnStockUnit
			,ysnAllowPurchase
			,ysnAllowSale
			,intConcurrencyId
			) (
			SELECT inv.intItemId
			,unm.intUnitMeasureId
			,min(itm.ptitm_pak_qty)
			,RTRIM(min(itm.ptitm_upc_code))
			,0
			,1
			,1
			,1 FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
			 INNER JOIN tblICUnitMeasure AS unm ON Upper(unm.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(itm.ptitm_pak_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
			 WHERE ptitm_pak_desc = @package AND ptitm_itm_no = @item
			 GROUP BY inv.intItemId, unm.intUnitMeasureId
			)
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
INSERT INTO [dbo].[tblICItemLocation] (
	intItemId
	,intLocationId
	,intVendorId
	,intCostingMethod
	,intIssueUOMId
	,intReceiveUOMId
	,intAllowNegativeInventory
	,intConcurrencyId
	) (
	SELECT inv.intItemId
	,loc.intCompanyLocationId
	,vnd.intEntityId
	,1
	,intItemUOMId
	,intItemUOMId
	,1
	,1 FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN vyuEMEntity AS vnd ON (itm.ptitm_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = vnd.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS	AND vnd.strType = 'Vendor')
	 LEFT JOIN tblICItemUOM AS uom ON (uom.intItemId) = (inv.intItemId) WHERE uom.ysnStockUnit = 1
	)

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemPricing data migration from ptitmmst origin table to tblICItemPricing i21 table 
-- Section 4
--------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO [dbo].[tblICItemPricing] (
	[intItemId]
	,[intItemLocationId]
	,[strPricingMethod]
	,[dblLastCost]
	,[dblStandardCost]
	,[dblAverageCost]
	,dblAmountPercent
	,dblSalePrice
	,[intConcurrencyId]
	) (
SELECT 
inv.intItemId
	,iloc.intItemLocationId
	,'None'
	,itm.ptitm_cost1
	,itm.ptitm_std_cost
	,itm.ptitm_avg_cost
	,0
	,itm.ptitm_prc1
	,1 FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
)

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
	,[intConcurrencyId]
	)
SELECT inv.intItemId
	,iloc.intItemLocationId
	,(select strPricingLevelName from tblSMCompanyLocationPricingLevel PL 
	where PL.intCompanyLocationId = iloc.intLocationId and PL.intSort = 1
	) strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc1
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 where ptitm_prc1 > 0
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
	,(select strPricingLevelName from tblSMCompanyLocationPricingLevel PL 
	where PL.intCompanyLocationId = iloc.intLocationId and PL.intSort = 2
	) strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc2
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 where ptitm_prc2 > 0 and ptitm_prc2 <> ptitm_prc1

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
	,(select strPricingLevelName from tblSMCompanyLocationPricingLevel PL 
	where PL.intCompanyLocationId = iloc.intLocationId and PL.intSort = 3
	) strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.ptitm_unit COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,'None' PricingMethod
	,0
	,ptitm_prc3
	,1 ConcurrencyId
	FROM ptitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.ptitm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 where ptitm_prc3 > 0 and ptitm_prc3 not in (ptitm_prc1,ptitm_prc2)


GO