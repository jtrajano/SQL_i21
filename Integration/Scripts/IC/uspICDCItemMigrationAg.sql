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
SET ANSI_WARNINGS ON
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
	,dblDefaultFull
	,ysnExtendPickTicket
	,ysnExportEDI
	,ysnHazardMaterial
	,ysnMaterialFee
	,strCountCode
	,ysnTaxable
	,strKeywords
	,ysnCommisionable
	,ysnTonnageTax
	,intTonnageTaxUOMId
	,intConcurrencyId
	,dtmDateCreated
	) 
SELECT ei.ItemNo, ei.ItemType, ei.ShortName, ei.ItemName, ei.ItemStatus, ei.InvValuation, ei.LotTracking,
	ei.CategoryId, ei.CommodityId, ei.[LifeTime], ei.LandedCost, ei.DropDhip, ei.SpecialCommission
	, ei.ysnStockedItem, ei.DyedFuel, ei.BarcodePrinted, ei.MSDSRequired, ei.AvailableTM
	, ei.DefaultFull, ei.PickTicket, ei.ExportEDI, ei.HazardMaterial, ei.MaterialFee, ei.CountCode
	, ei.Taxable, ei.KeyWords, ei.Commisionable,ei.TonnageTax,ei.TonnageTaxUOM, ei.ConcurrencyId, GETUTCDATE()
FROM
	 (
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
	,'Active' ItemStatus
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
			WHEN (MAX(agitm_avail_tm) = 'Y')
				THEN 1
			ELSE 0
			END
		) AvailableTM
	,MAX(agitm_deflt_percnt) DefaultFull	
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
	,(
		CASE 
		WHEN (min(agitm_tontax_rpt_yn) = 'Y')
			THEN 1
		ELSE 0
		END
		) TonnageTax
		,(
		CASE 
		WHEN (min(agitm_tontax_rpt_yn) = 'Y')
			THEN (SELECT TOP 1 IUOM.intUnitMeasureId FROM tblICUnitMeasure IUOM WHERE UPPER(IUOM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(MIN(agitm_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS)
		ELSE NULL
		END
		) TonnageTaxUOM
	,1 ConcurrencyId
		FROM agitmmst AS inv 
		WHERE agitm_phys_inv_ynbo <> 'O'
		GROUP BY agitm_no
) ei
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = ei.ItemNo COLLATE SQL_Latin1_General_CP1_CS_AS) --MSA todo : remove/change this after confirmation, will cause this not to import other item not yet imported.
	--AND ei.ItemStatus <> 'Discontinued'

--all items are imported with type 'Inventory'
--update items Inventory type from Category table
-- In latest versions, changing type is not allowed.
-- update	tblICItem 
-- set		strType = C.strInventoryType
-- from	tblICCategory C
-- where	C.intCategoryId = tblICItem.intCategoryId
-- 		AND RTRIM(LTRIM(ISNULL(C.strInventoryType, ''))) <> '' 

--====Delete obsolete items. It is not required in i21 as history is not imported===
--Delete from tblICItem where strStatus = 'Discontinued'

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
DECLARE @InsertedItemUOM table( intItemUOMId int);  

INSERT INTO tblICItemUOM
      (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
OUTPUT INSERTED.intItemUOMId INTO @InsertedItemUOM  
SELECT distinct intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId 
FROM (
		SELECT intItemId , 
		intUnitMeasureId = U.intUnitMeasureId , 
		dblUnitQty = 1 ,
		strUpcCode = 
		CASE WHEN AgUPC.UpcDupCount > 1 THEN
			AGItemUPC + '_Dup_' + CAST(I.intItemId as NVARCHAR(50)) 
		ELSE
			CASE WHEN ISNUMERIC(oi.agitm_upc_code) = 1 AND LEN(LTRIM(RTRIM(oi.agitm_upc_code))) >= 11 THEN  LTRIM(RTRIM(oi.agitm_upc_code)) ELSE NULL END    
		END ,
		ysnStockUnit = 1 ,
		ysnAllowPurchase = 1 , 
		ysnAllowSale = 1 , 
		intConcurrencyId = 1
		FROM tblICItem I 
		JOIN agitmmst oi
			
			ON I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
			AND agitm_phys_inv_ynbo <> 'O'
		JOIN tblICUnitMeasure U 
			ON UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(oi.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
        LEFT JOIN (
					 SELECT  rtrim(agitmUPC.agitm_upc_code) AGItemUPC , COUNT(agitmUPC.agitm_upc_code) UpcDupCount
					 FROM agitmmst agitmUPC
					 WHERE agitmUPC.agitm_phys_inv_ynbo <> 'O' AND RTRIM(agitmUPC.agitm_upc_code) <> ''
					 GROUP BY rtrim(agitmUPC.agitm_upc_code) 
                  ) AgUPC
		ON oi.agitm_upc_code COLLATE SQL_Latin1_General_CP1_CS_AS = RTRIM(AgUPC.AGItemUPC)  COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE intItemId not in (select intItemId from tblICItemUOM)
	) a
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemId = a.intItemId AND intUnitMeasureId = a.intUnitMeasureId)

---------------------------------------------------
--add lb as additional uom for items which has agitm_lbs_per_un set
INSERT INTO tblICItemUOM
      (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
OUTPUT INSERTED.intItemUOMId INTO @InsertedItemUOM  
SELECT distinct intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId 
FROM (
		select intItemId, 
			(select intUnitMeasureId from tblICUnitMeasure where strUnitMeasure = 'LB') intUnitMeasureId, 
			Case UPPER(oi.agitm_un_desc) When 'BU' then 1/oi.agitm_lbs_per_un When 'TON' then 1/oi.agitm_lbs_per_un When 'CWT' then 1/oi.agitm_lbs_per_un else oi.agitm_lbs_per_un end dblUnitQty, 
			strUpcCode = NULL, -- causes duplicates upc might already inserted -->>>> NULLIF(oi.strUpcCode,'') , 
			0 ysnStockUnit,
			1 ysnAllowPurchase, 
			1 ysnAllowSale, 
			1 intConcurrencyId 
		FROM tblICItem I 
		JOIN 
			(SELECT rtrim(agitm_no) agitm_no, min(upper(rtrim(agitm_un_desc))) agitm_un_desc, min(agitm_lbs_per_un) agitm_lbs_per_un, MIN(RTRIM(agitm_upc_code)) strUpcCode from agitmmst 
			 WHERE agitm_lbs_per_un not in (1,0) and UPPER(agitm_un_desc) <> 'LB'
			 GROUP BY rtrim(agitm_no)) as oi 
		ON I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
		JOIN tblICUnitMeasure U on upper(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(oi.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
	) a
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemId = a.intItemId AND intUnitMeasureId = a.intUnitMeasureId)

-----------------------------------------------------------
--add packing units for uoms which has agitm_un_per_pak set
INSERT INTO tblICItemUOM
      (intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
OUTPUT INSERTED.intItemUOMId INTO @InsertedItemUOM  
SELECT distinct intItemId, intUnitMeasureId, dblUnitQty, strUpcCode, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId 
FROM (
		select I.intItemId, 
			(select intUnitMeasureId from tblICUnitMeasure where strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = 	upper(rtrim(agitm_pak_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS) intUnitMeasureId, 
			oi.agitm_un_per_pak dblUnitQty, 
			strUpcCode = NULL, --set to null, UPC already inserted for the stock unit (UOM), 
			0 ysnStockUnit,
			1 ysnAllowPurchase
			, 1 ysnAllowSale
			, 1 intConcurrencyId 
		from tblICItem I 
		JOIN 
			(SELECT rtrim(agitm_no) agitm_no, min(upper(rtrim(agitm_pak_desc))) agitm_pak_desc, min(agitm_un_per_pak) agitm_un_per_pak , MIN(RTRIM(agitm_upc_code)) strUpcCode from agitmmst 
			WHERE agitm_un_per_pak not in (1,0) and UPPER(agitm_un_desc) <> UPPER(agitm_pak_desc)
			GROUP BY RTRIM(agitm_no)) as oi 
		ON I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oi.agitm_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
		JOIN tblICUnitMeasure U on upper(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = oi.agitm_pak_desc COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblICItemUOM iu on iu.intItemId = I.intItemId and iu.intUnitMeasureId = U.intUnitMeasureId
		where iu.intItemId is null and iu.intUnitMeasureId is null
) a
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemId = a.intItemId AND intUnitMeasureId = a.intUnitMeasureId)

DECLARE @upc TABLE (intItemUOMId INT,
strUpcCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL ,
strLongUpcCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL)

INSERT INTO @upc(intItemUOMId,
strUpcCode,
strLongUpcCode)
SELECT DISTINCT A.intItemUOMId
, NULL
, CASE WHEN AgUPC.UpcDupCount > 1 THEN
	AGItemUPC + '_Dup_' + CAST(I.intItemId as NVARCHAR(50)) 
  ELSE
	CASE WHEN ISNUMERIC(AgUPC.AGItemUPC) = 1 AND LEN(LTRIM(RTRIM(AgUPC.AGItemUPC))) >= 11 THEN  LTRIM(RTRIM(AgUPC.AGItemUPC)) ELSE NULL END    
  END agupc_upc_cd
FROM @InsertedItemUOM A
INNER JOIN tblICItemUOM UOM
	ON A.intItemUOMId = UOM.intItemUOMId
	 AND UOM.ysnStockUnit = 1
INNER JOIN tblICItem I
	ON UOM.intItemId = I.intItemId
INNER JOIN agupcmst agUPCmst 
	ON I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(agUPCmst.agupc_item_no) COLLATE SQL_Latin1_General_CP1_CS_AS 
INNER JOIN (
			SELECT  rtrim(agUPCmst.agupc_upc_cd) AGItemUPC , COUNT(agUPCmst.agupc_upc_cd) UpcDupCount
			FROM agupcmst agUPCmst
			WHERE RTRIM(agUPCmst.agupc_upc_cd) <> ''
			GROUP BY rtrim(agUPCmst.agupc_upc_cd) 
			) AgUPC
ON agUPCmst.agupc_upc_cd COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(AgUPC.AGItemUPC) COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE ISNUMERIC(agUPCmst.agupc_upc_cd) = 1 AND LEN(LTRIM(RTRIM(agUPCmst.agupc_upc_cd))) >= 11

INSERT INTO tblICItemUomUpc(intItemUOMId, strUpcCode, strLongUpcCode)
SELECT intItemUOMId, strUpcCode, strLongUpcCode FROM @upc
WHERE NOT EXISTS(SELECT * FROM tblICItemUomUpc u WHERE u.strLongUpcCode = strLongUpcCode AND u.intItemUOMId = intItemUOMId)

--set stock unit to No for Non Inventory Items
update iu set ysnStockUnit = 0
from tblICItemUOM iu 
join tblICItem i on i.intItemId = iu.intItemId
where i.strType <> 'Inventory'

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemLocation data migration from ptlocmst/agitmmst origin tables to tblICItemLocation i21 table 
-- Section 3
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Loc TABLE (intItemId INT
	,intLocationId INT
	,intVendorId INT NULL
	,intCostingMethod INT NULL
	,intIssueUOMId INT NULL
	,intReceiveUOMId INT NULL
	,intAllowNegativeInventory INT NULL
	,intConcurrencyId INT NULL
	,dblReorderPoint NUMERIC(38, 20))

INSERT INTO @Loc (
	intItemId
	,intLocationId
	,intVendorId
	,intCostingMethod
	,intIssueUOMId
	,intReceiveUOMId
	,intAllowNegativeInventory
	,intConcurrencyId
	,dblReorderPoint
	) 
SELECT DISTINCT intItemId
	,intCompanyLocationId
	,intEntityId
	,intCostingMethod
	,intIssueUOMId
	,intReceiveUOMId
	,intAllowNegativeInventory
	,intConcurrencyId
	, dblReorderPoint
FROM (
SELECT 
	inv.intItemId
	,loc.intCompanyLocationId
	,vnd.intEntityId
	,1 intCostingMethod
	,intItemUOMId intIssueUOMId
	,intItemUOMId intReceiveUOMId
	,1 intAllowNegativeInventory
	,1 intConcurrencyId
	,itm.agitm_un_min_bal dblReorderPoint
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS)
	 LEFT JOIN vyuEMEntity AS vnd ON (itm.agitm_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = vnd.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS	AND vnd.strType = 'Vendor')
	 LEFT JOIN tblICItemUOM AS uom ON (uom.intItemId) = (inv.intItemId) and uom.ysnStockUnit = 1
	 WHERE itm.agitm_phys_inv_ynbo <> 'O'
) a
--WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemId = a.intItemId AND intLocationId = a.intCompanyLocationId)

INSERT INTO tblICItemLocation(intItemId
	,intLocationId, intConcurrencyId)
SELECT DISTINCT intItemId
	,intLocationId
	,1
FROM @Loc a
WHERE NOT EXISTS(SELECT * FROM tblICItemLocation WHERE intItemId = a.intItemId AND intLocationId = a.intLocationId)

UPDATE a
SET  intVendorId = l.intVendorId
	,intCostingMethod = l.intCostingMethod
	,intIssueUOMId = l.intIssueUOMId
	,intReceiveUOMId = l.intReceiveUOMId
	,intAllowNegativeInventory = l.intAllowNegativeInventory
	,dblReorderPoint = l.dblReorderPoint
FROM @Loc l
	INNER JOIN tblICItemLocation a ON l.intItemId = a.intItemId AND l.intLocationId = a.intItemLocationId

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
	) 
SELECT
	intItemId, intItemLocationId, PricingMethod, LastCost, StandardCost, AverageCost, AmountPercent, SalePrice, ConcurrencyId
FROM	(
SELECT inv.intItemId
	,iloc.intItemLocationId
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,itm.agitm_last_un_cost LastCost
	,itm.agitm_std_un_cost StandardCost
	,itm.agitm_avg_un_cost AverageCost
	,agitm_prc_calc1 AmountPercent
	,agitm_un_prc1 SalePrice
	,1 ConcurrencyId
	FROM agitmmst AS itm INNER JOIN tblICItem AS inv ON (itm.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS)
	 INNER JOIN tblSMCompanyLocation AS loc ON (itm.agitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS) 
	 INNER JOIN tblICItemLocation AS iloc ON (loc.intCompanyLocationId = iloc.intLocationId	AND iloc.intItemId = inv.intItemId)
) a
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICItemPricing WHERE intItemId = a.intItemId AND intItemLocationId = a.intItemLocationId)

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
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(itm.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc1
	,agitm_un_prc1
	,PL.intCompanyLocationPricingLevelId
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
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(itm.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc2
	,agitm_un_prc2
	,PL.intCompanyLocationPricingLevelId
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
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(itm.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc3
	,agitm_un_prc3
	,PL.intCompanyLocationPricingLevelId
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
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(itm.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc4
	,agitm_un_prc4
	,PL.intCompanyLocationPricingLevelId
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
	, intCompanyLocationPricingLevelId
	,[intConcurrencyId]
	) (
SELECT inv.intItemId
	,iloc.intItemLocationId
	,PL.strPricingLevelName strPricingLevel
	,(select IU.intItemUOMId from tblICItemUOM IU join tblICUnitMeasure U on U.intUnitMeasureId = IU.intUnitMeasureId
	where IU.intItemId = inv.intItemId
	and UPPER(U.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(itm.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS) uom
	,1 dblUnit
	,Case 
	when agitm_prc_calc_ind = 'A' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind ='F' and agitm_un_prc1 = 0 then 'None'
	when agitm_prc_calc_ind = 'F' then 'Fixed Dollar Amount'
	when agitm_prc_calc_ind = 'P' then 'Percent of Margin'
	else 'None' End PricingMethod
	,agitm_prc_calc5
	,agitm_un_prc5
	,PL.intCompanyLocationPricingLevelId
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

--------------------------------------------------------------------------------------------------------------
--Update Restricted Chemical & EPA Numbers
---------------------------------------------------------------------------------------------------------------

UPDATE item
SET item.ysnRestrictedChemical = 1
FROM tblICItem item
	INNER JOIN agitmmst a ON item.strItemNo = a.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE a.agitm_rest_chem_rpt_yn = 'Y'

UPDATE item
SET item.strEPANumber = a.agitm_epa_no
FROM tblICItem item
	INNER JOIN agitmmst a ON item.strItemNo = a.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE a.agitm_rest_chem_rpt_yn = 'Y'

-- Update Medication & Ingredient tags
-- Get tags
DECLARE @Tags TABLE (intId INT IDENTITY(1, 1), strTagNo NVARCHAR(10), strDescription NVARCHAR(30), strComment NVARCHAR(70), intSequenceNo SMALLINT PRIMARY KEY(intId))
INSERT INTO @Tags
SELECT agtag_tag_no = LTRIM(RTRIM(agtag_tag_no)), LTRIM(RTRIM(agtag_desc)) agtag_desc, agtag_comment, agtag_seq_no
FROM agtagmst
WHERE agtag_hazmat_yn = 'N'
GROUP BY agtag_tag_no, agtag_comment, agtag_desc, agtag_seq_no

DECLARE @NormalizedTags TABLE (intId INT IDENTITY(1, 1), strTagNo NVARCHAR(10), strDescription NVARCHAR(30), strComment NVARCHAR(MAX) PRIMARY KEY(intId))
INSERT INTO @NormalizedTags
SELECT t.strTagNo, t.strDescription, strComment =
	STUFF((SELECT '' + x.strComment + CHAR(13) + CHAR(10)
		FROM @Tags x
		WHERE x.strTagNo = t.strTagNo
			AND x.strComment IS NOT NULL
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1,0,'')
FROM @Tags t
WHERE t.strComment IS NOT NULL
GROUP BY t.strTagNo, t.strDescription

-- Insert known medication tags
INSERT INTO tblICTag(strTagNumber, strType, strDescription, strMessage, dtmDateCreated, intCreatedByUserId, intConcurrencyId)
SELECT DISTINCT LTRIM(RTRIM(o.agitm_med_tag)) COLLATE Latin1_General_CI_AS, 'Medication Tag', nt.strDescription, nt.strComment, GETUTCDATE(), 1, 1
FROM agitmmst o
	LEFT OUTER JOIN @NormalizedTags nt ON nt.strTagNo COLLATE Latin1_General_CI_AS =  LTRIM(RTRIM(o.agitm_med_tag))
WHERE NULLIF(LTRIM(RTRIM(o.agitm_med_tag)) COLLATE Latin1_General_CI_AS, '') IS NOT NULL
AND NOT EXISTS(
    SELECT * FROM tblICTag WHERE strTagNumber = LTRIM(RTRIM(o.agitm_med_tag)) COLLATE Latin1_General_CI_AS
)

-- Insert known ingredient tags
INSERT INTO tblICTag(strTagNumber, strType, strDescription, strMessage, dtmDateCreated, intCreatedByUserId, intConcurrencyId)
SELECT DISTINCT LTRIM(RTRIM(o.agitm_invc_tag)) COLLATE Latin1_General_CI_AS, 'Ingredient Tag', nt.strDescription, nt.strComment, GETUTCDATE(), 1, 1
FROM agitmmst o
	LEFT OUTER JOIN @NormalizedTags nt ON nt.strTagNo COLLATE Latin1_General_CI_AS =  LTRIM(RTRIM(o.agitm_invc_tag))
WHERE NULLIF(LTRIM(RTRIM(o.agitm_invc_tag)) COLLATE Latin1_General_CI_AS, '') IS NOT NULL
AND NOT EXISTS(
    SELECT * FROM tblICTag WHERE strTagNumber = LTRIM(RTRIM(o.agitm_invc_tag)) COLLATE Latin1_General_CI_AS
)

-- Insert unknown tags
INSERT INTO tblICTag(strTagNumber, strType, strDescription, strMessage, dtmDateCreated, intCreatedByUserId, intConcurrencyId)
SELECT DISTINCT LTRIM(RTRIM(o.strTagNo)) COLLATE Latin1_General_CI_AS, NULL, o.strDescription, o.strComment, GETUTCDATE(), 1, 1
FROM @NormalizedTags o
WHERE NOT EXISTS(
    SELECT * FROM tblICTag WHERE strTagNumber = LTRIM(RTRIM(o.strTagNo)) COLLATE Latin1_General_CI_AS
)

-- Update existing tags
UPDATE t
SET t.strDescription = o.strDescription,
	t.strMessage = o.strComment,
	t.dtmDateCreated = GETUTCDATE(),
	t.intCreatedByUserId = 1,
	t.intConcurrencyId = 1
FROM tblICTag t
	INNER JOIN @NormalizedTags o ON o.strTagNo COLLATE Latin1_General_CI_AS  = t.strTagNumber COLLATE Latin1_General_CI_AS

UPDATE i
SET i.intMedicationTag = med.intTagId
FROM agitmmst o
    INNER JOIN tblICItem i ON i.strItemNo COLLATE Latin1_General_CI_AS  = LTRIM(RTRIM(o.agitm_no)) COLLATE Latin1_General_CI_AS
    LEFT OUTER JOIN tblICTag med ON med.strTagNumber COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(o.agitm_med_tag)) COLLATE Latin1_General_CI_AS
        AND med.strType = 'Medication Tag'
WHERE i.intMedicationTag IS NULL
    AND o.agitm_med_tag IS NOT NULL

UPDATE i
SET i.intIngredientTag = inv.intTagId
FROM agitmmst o
    INNER JOIN tblICItem i ON i.strItemNo COLLATE Latin1_General_CI_AS  = LTRIM(RTRIM(o.agitm_no)) COLLATE Latin1_General_CI_AS
    LEFT OUTER JOIN tblICTag inv ON inv.strTagNumber COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(o.agitm_invc_tag)) COLLATE Latin1_General_CI_AS
        AND inv.strType = 'Ingredient Tag'
WHERE i.intIngredientTag IS NULL
    AND o.agitm_invc_tag IS NOT NULL

-- Fix stock units and costing methods
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