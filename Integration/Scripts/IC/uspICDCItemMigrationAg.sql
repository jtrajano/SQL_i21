IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCItemMigrationAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCItemMigrationAg]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCItemMigrationAg]
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
-- Inventory/Item data migration from agitmmst origin table to tblICItem i21 table 
-- Section 1
--------------------------------------------------------------------------------------------------------------------------------------------
	INSERT INTO tblICItem (
	strItemNo
	,strType
	,strShortName
	,strDescription
	,strStatus
	,strInventoryTracking
	,strLotTracking
	,intCategoryId
	,intCommodityId
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
	,ysnCommisionable
	,intConcurrencyId
	) (
	SELECT RTRIM(agitm_no) ItemNo
--** inventory type should match with the inventory type of Category.
--so read from the converted data of tblICCategory table
--import all items as 'Inventory' and change it with the next update stmt

	--,(
	--	CASE 
	--		WHEN (min(agitm_phys_inv_ynbo) = 'N')
	--			THEN 'Service' 
	--		WHEN (min(agitm_phys_inv_ynbo) = 'N' and min(agitm_ga_com_cd) <> '')
	--			THEN 'Inventory'
	--		ELSE 'Inventory'
	--		END
	--	) ItemType
	,'Inventory' ItemType
	,RTRIM(min(agitm_search)) ShortName
	,RTRIM(min(agitm_desc)) ItemName
--** Items with physical count set to 'Obsolete' is classified as 'Status' = Discontinued and 
--   Items with physical count set to 'Yes' or 'No' is classified as 'Status' = Active. **
	,(
		CASE 
			WHEN (min(agitm_phys_inv_ynbo) = 'O')
				THEN 'Discontinued'
			ELSE 'Active'
			END
		) ItemStatus
	,'Item Level' InvValuation
	,case rtrim(min(agitm_lot_yns)) when 'Y' then 'Yes - Manual' else 'No' end LotTracking
	,(
		SELECT TOP 1 min(intCategoryId)
		FROM tblICCategory AS cls
		WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = min(inv.agitm_class) COLLATE SQL_Latin1_General_CP1_CS_AS
		) CategoryId
	,(
		SELECT TOP 1 min(intCommodityId)
		FROM tblICCommodity AS cm
		WHERE (cm.strCommodityCode) COLLATE SQL_Latin1_General_CP1_CS_AS = min(inv.agitm_ga_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
		) CommodityId
	,'1' LifeTime
	,0 LandedCost
	,0 DropDhip
	,0 SpecialCommission
	,(
		CASE 
			WHEN (min(agitm_stk_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		) ysnStockedItem
	,(
		CASE 
			WHEN (min(agitm_dyed_fuel_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		) DyedFuel
	,(
		CASE 
			WHEN (min(agitm_bar_code_ind) = 'I')
				THEN 'Item'
			WHEN (min(agitm_bar_code_ind) = 'U')
				THEN 'UPC'
			ELSE 'None'
			END
		) BarcodePrinted
	,(
		CASE 
			WHEN (min(agitm_msds_yn) = 'Y')
				THEN 1
			ELSE 0
			END
		) MSDSRequired
	,(
		CASE 
			WHEN (min(agitm_avail_tm) = 'Y')
				THEN 1
			ELSE 0
			END
		) AvailableTM
	,0 PickTicket
	,0 ExportEDI
	,(
		CASE 
			WHEN (isnull(min(agitm_med_tag),'N') = 'N')
				THEN 0
			ELSE 1
			END
		) HazardMaterial
	,0 MaterialFee
	,RTRIM(min(agitm_phys_inv_ynbo)) CountCode
	,(
		CASE 
			WHEN (min(agitm_slstax_rpt_ynha) = 'Y')
				THEN 1
			ELSE 0
			END
		) Taxable
	,RTRIM(min(agitm_search)) KeyWords
	,(
		CASE 
			WHEN (min(agitm_comm_ind_uag) = 'Y')
				THEN 1
			ELSE 0
			END
		) Commisionable
	,1 ConcurrencyId
		FROM agitmmst AS inv GROUP BY agitm_no
)

--all items are imported with type 'Inventory'
--update items Inventory type from Category table
update tblICItem set strType = C.strInventoryType
from tblICCategory C
where C.intCategoryId = tblICItem.intCategoryId


--** Items allocated for some charges are considered as non item and we classify it as 'Other Charge' Type.
 --  We validate this thru strDescription. If it contains any charges in it then that item is marked as type 'Other Charge'. **  

--UPDATE tblICItem
--SET strType = 'Other Charge'
--WHERE strDescription LIKE '%CHARGES%'


--------------------------------------------------------------------------------------------------------------------------------------------
-- Item UOM data migration from agitmmst origin table to tblICItemUOM i21 table 
-- Section 2
--------------------------------------------------------------------------------------------------------------------------------------------
--import stock unit first. Stock unit is agitm_un_desc
--items are repeated for location in origin. So pick only one item from the location to avoid duplicate entries 
Insert into tblICItemUOM
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
select intItemId, U.intUnitMeasureId, 1 dblUnitQty, 1 ysnStockUnit,1 ysnAllowPurchase, 1 ysnAllowSale, 1 intConcurrencyId 
from tblICItem I 
join 
(select rtrim(agitm_no) agitm_no, min(upper(rtrim(agitm_un_desc))) agitm_un_desc from agitmmst 
group by rtrim(agitm_no)) as oi 
on I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
join tblICUnitMeasure U on U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = oi.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS

---------------------------------------------------
--add lb as additional uom for items which has agitm_lbs_per_un set
Insert into tblICItemUOM
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
select intItemId, 
(select intUnitMeasureId from tblICUnitMeasure where strUnitMeasure = 'LB') intUnitMeasureId, 
oi.agitm_lbs_per_un dblUnitQty, 0 ysnStockUnit,1 ysnAllowPurchase, 1 ysnAllowSale, 1 intConcurrencyId 
from tblICItem I 
join 
(select rtrim(agitm_no) agitm_no, min(upper(rtrim(agitm_un_desc))) agitm_un_desc, min(agitm_lbs_per_un) agitm_lbs_per_un from agitmmst 
where agitm_lbs_per_un > 1
group by rtrim(agitm_no)) as oi 
on I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
join tblICUnitMeasure U on U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = oi.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS

-----------------------------------------------------------
--add packing units for uoms which has agitm_un_per_pak set
Insert into tblICItemUOM
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
select intItemId, 
(select intUnitMeasureId from tblICUnitMeasure where strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = 
upper(rtrim(agitm_un_desc))+' '+SUBSTRING(cast(agitm_un_per_pak as varchar(15)), 0, CHARINDEX('.', agitm_un_per_pak))
COLLATE SQL_Latin1_General_CP1_CS_AS) intUnitMeasureId, 
oi.agitm_un_per_pak dblUnitQty, 0 ysnStockUnit,1 ysnAllowPurchase, 1 ysnAllowSale, 1 intConcurrencyId 
from tblICItem I 
join 
(select rtrim(agitm_no) agitm_no, min(upper(rtrim(agitm_un_desc))) agitm_un_desc, min(agitm_un_per_pak) agitm_un_per_pak from agitmmst 
where agitm_un_per_pak > 1
group by rtrim(agitm_no)) as oi 
on I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
join tblICUnitMeasure U on U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = oi.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS


--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemLocation data migration from ptlocmst/agitmmst origin tables to tblICItemLocation i21 table 
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
	,1 intCostingMethod
	,intItemUOMId intIssueUOMId
	,intItemUOMId intReceiveUOMId
	,0 intAllowNegativeInventory
	,1 intConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN vyuEMEntity AS vnd ON (itm.agitm_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = vnd.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS	AND vnd.strType = 'Vendor')
	 LEFT JOIN tblICItemUOM AS uom ON (uom.intItemId) = (inv.intItemId) WHERE uom.ysnStockUnit = 1
)

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemPricing data migration from agitmmst origin table to tblICItemPricing i21 table 
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
SELECT inv.intItemId
	,iloc.intItemLocationId
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,itm.agitm_last_un_cost
	,itm.agitm_std_un_cost
	,itm.agitm_avg_un_cost
	,agitm_prc_calc1
	,agitm_un_prc1
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
)
----------------------------------------------------------------------------------------------------------------
--Import pricing level maintenance. There are 5 pricing levels in origin.
-- Section 5
----------------------------------------------------------------------------------------------------------------
insert into tblSMCompanyLocationPricingLevel
(intCompanyLocationId, strPricingLevelName, intSort, intConcurrencyId)
select CL.intCompanyLocationId, prclvl, srt, 1 from 
(
select agloc_loc_no,agloc_prc1_desc prclvl, 1 srt from aglocmst where agloc_prc1_desc is not null
union
select agloc_loc_no,agloc_prc2_desc prclvl, 2 srt from aglocmst where agloc_prc2_desc is not null
union
select agloc_loc_no,agloc_prc3_desc prclvl, 3 srt from aglocmst where agloc_prc3_desc is not null
union
select agloc_loc_no,agloc_prc4_desc prclvl, 4 srt from aglocmst where agloc_prc4_desc is not null
union
select agloc_loc_no,agloc_prc5_desc prclvl, 5 srt from aglocmst where agloc_prc5_desc is not null
) as prc join tblSMCompanyLocation CL on CL.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = prc.agloc_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS
where CL.[intCompanyLocationId] not in (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
where [strPricingLevelName] COLLATE Latin1_General_CI_AS = prclvl COLLATE Latin1_General_CI_AS)
order by CL.intCompanyLocationId, srt

--------------------------------------------------------------------------------------------------------------
--Set default pricing level for the customer
---------------------------------------------------------------------------------------------------------------


----**** check if this is done in AR import ******


------------------------------------------------------------------------------------------------------------------
--import pricing levels for the items
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
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc1
	,agitm_un_prc1
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 1 and agitm_un_prc1 > 0
)

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
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc2
	,agitm_un_prc2
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 2 and agitm_un_prc2 > 0 and agitm_un_prc2 <> agitm_un_prc1 
)
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
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc3
	,agitm_un_prc3
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 3 and agitm_un_prc3 > 0 and agitm_un_prc3 not in (agitm_un_prc1,agitm_un_prc2)
)
--price level 4
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
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc4
	,agitm_un_prc4
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 4 and agitm_un_prc4 > 0 and agitm_un_prc4 not in (agitm_un_prc1,agitm_un_prc2,agitm_un_prc3)
)

--price 5
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
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and U.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = itm.agitm_un_desc COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc5
	,agitm_un_prc5
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
	 join tblSMCompanyLocationPricingLevel PL on PL.intCompanyLocationId = iloc.intLocationId 
	 where PL.intSort = 5 and agitm_un_prc5 > 0 and agitm_un_prc5 not in (agitm_un_prc1,agitm_un_prc2,agitm_un_prc3,agitm_un_prc4)
)

--------------------------------------------------------------------------------------------------------------
--Set special pricing level for the customer
---------------------------------------------------------------------------------------------------------------


----**** check if this is done in AR import ******
--------------------------------------------------------------------------------------------------------------------------------------------

