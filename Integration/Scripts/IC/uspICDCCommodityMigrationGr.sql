IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCommodityMigrationGr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCommodityMigrationGr]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCommodityMigrationGr]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


---++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Use this script to import commodity and UOM
--It creates a category and item for each commodity as required by i21
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



----========================================STEP 1 ====================================
--insert all commodities 
 insert into tblICCommodity 
(strCommodityCode,strDescription,ysnExchangeTraded,intFutureMarketId,intDecimalDPR,dblConsolidateFactor,ysnFXExposure,dblPriceCheckMin,dblPriceCheckMax,
dtmCropEndDateCurrent,dtmCropEndDateNew,strEDICode,intScheduleStoreId,intScheduleDiscountId,intScaleAutoDistId,ysnAllowLoadContracts,
dblMaxUnder,dblMaxOver,intConcurrencyId)
select rtrim(gacom_com_cd),rtrim(gacom_desc),1 ExchangeTraded,
(select intFutureMarketId from tblRKFutureMarket where strFutSymbol COLLATE SQL_Latin1_General_CP1_CS_AS = gacom_dflt_bot COLLATE SQL_Latin1_General_CP1_CS_AS) gacom_dflt_bot,
gacom_dpr_no_dec,gacom_cnsld_factor,case rtrim(gacom_fx_exposure_yn) when 'Y' then 1 else 0 end gacom_fx_exposure_yn,gacom_un_min_prc,gacom_un_max_prc,
CASE WHEN ISDATE(gacom_crop_curr_rev_dt) = 1 THEN CONVERT(DATE, CAST(gacom_crop_curr_rev_dt AS CHAR(12)), 112) END gacom_crop_curr_rev_dt,
CASE WHEN ISDATE(gacom_crop_new_rev_dt) = 1 THEN CONVERT(DATE, CAST(gacom_crop_new_rev_dt AS CHAR(12)), 112) END gacom_crop_new_rev_dt,
gacom_edi_cd,null,null,null,case gacom_allow_load_cnt_yn when 'Y' then 1 else 0 end gacom_allow_load_cnt_yn,
gacom_load_cnt_under_un,gacom_load_cnt_over_un,1 ConcurrencyId
 from gacommst 
 WHERE NOT EXISTS (SELECT * FROM tblICCommodity WHERE strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS)


 ----=====================================STEP 2=========================================
--insert uoms into Commodity UOM 
--find the uoms in i21 which matches the commodity code in origin and i21
--Bushels or Ton has to be set as stock unit and unit qty has to be set to 1

insert into tblICCommodityUnitMeasure 
(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
select ic.intCommodityId, iu.intUnitMeasureId, 1 dblUnitQty, 
case iu.strUnitMeasure when 'BU' then 1 When 'TON' then 1 else 0 end 'ysnStockUnit', 
case iu.strUnitMeasure when 'BU' then 1 When 'TON' then 1 else 0 end 'ysnDefault', 
1 'intConcurrencyId' 
from gacommst oc 
join tblICCommodity ic on rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS = ic.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICUnitMeasure iu on upper(iu.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = upper(rtrim(oc.gacom_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
where NOT EXISTS (select * from tblICCommodityUnitMeasure where intCommodityId = ic.intCommodityId and intUnitMeasureId = iu.intUnitMeasureId)
----=====================================STEP 3===========================
--origin stores the wgt factor to lb. There is no lb uom in origin setup for this. In i21 lb needs to be setup as a uom to receive commodity in lb
--insert an record in commodity uom for lb for each commodity
--convert the unit qty to match converstion to stock unit bu or ton

insert into tblICCommodityUnitMeasure 
(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
select ic.intCommodityId, (select top 1 intUnitMeasureId from tblICUnitMeasure where strUnitMeasure = 'lb') lbunit , 
Case iu.strUnitMeasure When 'BU' then 1/gacom_un_wgt When 'TON' then 1/gacom_un_wgt else gacom_un_wgt end unitqty, 
0 'ysnStockUnit', 0 'ysnDefault', 1 'intConcurrencyId' 
from gacommst oc 
join tblICCommodity ic on rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS = ic.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICUnitMeasure iu on upper(iu.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = upper(rtrim(oc.gacom_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
where upper(rtrim(oc.gacom_un_desc)) <> 'LB'
 AND NOT EXISTS (select * from tblICCommodityUnitMeasure where intCommodityId = ic.intCommodityId and intUnitMeasureId = iu.intUnitMeasureId)


----====================================STEP 4======================================
--For grain only business, Setup a category for each commodity. Category is required for i21
--for grain & ag business, setup a category for commodites which does not have an associated ag item
insert into tblICCategory (strCategoryCode, strDescription, strInventoryType, intCostingMethod, strInventoryTracking, intConcurrencyId)
select rtrim(gacom_com_cd), rtrim(gacom_desc), 'Inventory' strInventoryType, 1 CostingMethod, 'Item Level' InventoryTracking, 1 intConcurrencyId
from gacommst oc
left join tblICCategory C on C.strCategoryCode = rtrim(gacom_com_cd)  COLLATE SQL_Latin1_General_CP1_CS_AS
where C.intCategoryId is null AND  NOT EXISTS (select agitm_no from agitmmst where agitm_ga_com_cd = oc.gacom_com_cd)



----===============================STEP 5===================================
----Import GL accounts for the category from origin commodity setup
--moved to another sp

----=========================STEP 6=================================
--for grain only business, insert an item for each commodity. i21 needs an item for the commodities.
--for grain & ag business, insert an item for commodites which does not have an associated ag item
insert into tblICItem 
(strItemNo, strDescription, strType, strInventoryTracking, strLotTracking, intCommodityId, intCategoryId, strStatus,
intLifeTime)
(select rtrim(gacom_com_cd), rtrim(gacom_desc), 'Inventory' strInventoryType, 'Item Level' InventoryTracking, 'No' LotTracking,
ic.intCommodityId, icat.intCategoryId, 'Active' Status, 1
from gacommst oc 
join tblICCommodity ic on ic.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICCategory icat on icat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
left join tblICItem I on I.strItemNo = rtrim(gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
where I.intItemId is null and  NOT EXISTS (select agitm_no from agitmmst where agitm_ga_com_cd = oc.gacom_com_cd))


----=======================STEP 7===========================================
----insert uom for items from the commodity table
INSERT INTO tblICItemUOM 
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
(
select I.intItemId, CM.intUnitMeasureId, CM.dblUnitQty, CM.ysnStockUnit,1 AllowPurchase, 1 AllowSale, 1 ConcurrencyId 
from tblICCommodityUnitMeasure CM
join tblICCommodity C on C.intCommodityId = CM.intCommodityId
join tblICItem I on C.strCommodityCode = I.strItemNo
where NOT EXISTS (select intItemId from tblICItemUOM where intItemId = I.intItemId and intUnitMeasureId = CM.intUnitMeasureId))

----==========================STEP 8=======================================
----insert locations for items created from commodity. Origin does not have locations mapped to commodity. So all locations has to be added by default
--**************************************************************************************
----locations which are not required for commodity business has to be removed manually
--**************************************************************************************
insert into tblICItemLocation 
(intItemId, intLocationId, intCostingMethod, intIssueUOMId, intReceiveUOMId, intAllowNegativeInventory, intConcurrencyId)
(
select I.intItemId, L.intCompanyLocationId, 1 CostingMethod, U.intItemUOMId DefaultIssueUOM, 
U.intItemUOMId DefaultReceiveUOM, 0 AllowNegative, 1 ConcurrencyId
from tblICItem I 
join tblICCommodity C on I.intCommodityId = C.intCommodityId
join gacommst oc on C.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICItemUOM U on I.intItemId = U.intItemId
left join tblSMCompanyLocation L on 1 = 1
where U.ysnStockUnit = 1 and NOT EXISTS (select * from tblICItemLocation where intItemId = I.intItemId and intLocationId = L.intCompanyLocationId))


----====================================STEP 9======================================
--Setup a grain discount category for each commodity if grain discounts are setup
insert into tblICCategory (strCategoryCode, strDescription, strInventoryType, intCostingMethod, strInventoryTracking, intConcurrencyId)
select distinct rtrim(gacom_com_cd)+'Discount', rtrim(gacom_desc)+' Discount', 'Other Charge' strInventoryType, 1 CostingMethod, 'Item Level' InventoryTracking, 1 intConcurrencyId
from gacommst oc
join gacdcmst od on rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(od.gacdc_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
left join tblICCategory C on C.strCategoryCode = rtrim(gacom_com_cd)+'Discount'  COLLATE SQL_Latin1_General_CP1_CS_AS
where C.intCategoryId is null


----====================================STEP 10======================================
--convert discount codes as other charge items from discount code table. 

insert into tblICItem 
(strItemNo, strDescription, strShortName,strType, strInventoryTracking, strLotTracking, intCommodityId, intCategoryId, strStatus,
intLifeTime, strCostType, strCostMethod,ysnAccrue)
select rtrim(gacdc_com_cd)+rtrim(oc.gacdc_cd), rtrim(gacdc_com_cd)+' '+rtrim(gacdc_desc), rtrim(oc.gacdc_cd) strShortName,'Other Charge' strInventoryType, 'Item Level' InventoryTracking, 'No' LotTracking,
ic.intCommodityId, icat.intCategoryId, 'Active' Status, 1 intLifeTime, 'Discount' strCostType
,'Per Unit' strCostMethod, 1 ysnAccrue
from gacdcmst oc 
join tblICCommodity ic on ic.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacdc_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICCategory icat on icat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacdc_com_cd)+'Discount' COLLATE SQL_Latin1_General_CP1_CS_AS
left join tblICItem  I on I.strItemNo = rtrim(gacdc_com_cd)+rtrim(oc.gacdc_cd)  COLLATE SQL_Latin1_General_CP1_CS_AS
where I.intItemId is null

----=======================STEP 11===========================================
----insert uom for discount items from the commodity table
INSERT INTO tblICItemUOM 
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
select I.intItemId, CM.intUnitMeasureId, 1 dblUnitQty, 0 ysnStockUnit,1 AllowPurchase, 1 AllowSale, 1 ConcurrencyId 
from tblICCommodityUnitMeasure CM
join tblICCommodity C on C.intCommodityId = CM.intCommodityId
join tblICItem I on C.intCommodityId = I.intCommodityId
where I.strCostType = 'Discount'
and  NOT EXISTS (select intItemId from tblICItemUOM where intItemId = I.intItemId and intUnitMeasureId = CM.intUnitMeasureId)


---================================STEP 12=============================================
--Add locations for discount items

insert into tblICItemLocation 
(intItemId, intLocationId, intCostingMethod, intAllowNegativeInventory, intConcurrencyId)
select I.intItemId, CL.intLocationId, 1 CostingMethod, 0 AllowNegative, 1 ConcurrencyId
--,I.strItemNo, I.intCommodityId
from  
(select I.intItemId, I.strItemNo, I.intCommodityId from tblICItem I
where I.strCostType = 'Discount') I
join 
(select distinct IL.intLocationId, I.intCommodityId
from tblICItemLocation IL
join tblICItem I on IL.intItemId = I.intItemId
where I.intCommodityId is not null) CL
on CL.intCommodityId = I.intCommodityId
WHERE NOT EXISTS (select * from tblICItemLocation where intItemId = I.intItemId and intLocationId = CL.intLocationId)
----====================================STEP 13======================================
--Setup a grain Freight category for each commodity 
insert into tblICCategory (strCategoryCode, strDescription, strInventoryType, intCostingMethod, strInventoryTracking, intConcurrencyId)
select rtrim(gacom_com_cd)+'Freight', rtrim(gacom_desc)+' Freight', 'Other Charge' strInventoryType, 1 CostingMethod, 'Item Level' InventoryTracking, 1 intConcurrencyId
from gacommst oc
left join tblICCategory icat on icat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd)+'Freight' COLLATE SQL_Latin1_General_CP1_CS_AS
where icat.intCategoryId IS NULL 

----====================================STEP 14======================================
--convert Freight as other charge items from each Commodity. 

insert into tblICItem 
(strItemNo, strDescription, strShortName,strType, strInventoryTracking, strLotTracking, intCommodityId, intCategoryId, strStatus,
intLifeTime, strCostType, strCostMethod,ysnAccrue)
select LTRIM(RTRIM(gacom_com_cd))+' Freight', LTRIM(RTRIM(ISNULL(oc.gacom_desc,gacom_com_cd)))+' Freight', 'Freight' strShortName,'Other Charge' strInventoryType, 'Item Level' InventoryTracking, 'No' LotTracking,
ic.intCommodityId, icat.intCategoryId, 'Active' Status, 1 intLifeTime, 'Freight' strCostType
,'Per Unit' strCostMethod, 1 ysnAccrue
from gacommst oc 
join tblICCommodity ic on ic.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd) COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICCategory icat on icat.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = rtrim(oc.gacom_com_cd)+'Freight' COLLATE SQL_Latin1_General_CP1_CS_AS
LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(gacom_com_cd))+' Freight' COLLATE  SQL_Latin1_General_CP1_CS_AS 
		WHERE Item.strItemNo IS NULL
		
----====================================STEP 15===========================================
----insert uom for Freight items from the commodity table
INSERT INTO tblICItemUOM 
(intItemId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnAllowPurchase, ysnAllowSale, intConcurrencyId)
select I.intItemId, CM.intUnitMeasureId, 1 dblUnitQty, 0 ysnStockUnit,1 AllowPurchase, 1 AllowSale, 1 ConcurrencyId 
from tblICCommodityUnitMeasure CM
join tblICCommodity C on C.intCommodityId = CM.intCommodityId
join tblICItem I on C.intCommodityId = I.intCommodityId
where I.strCostType = 'Freight'	and  NOT EXISTS (select intItemId from tblICItemUOM where intItemId = I.intItemId and intUnitMeasureId = CM.intUnitMeasureId)


---=====================================STEP 16=============================================
--Add locations for discount items

insert into tblICItemLocation 
(intItemId, intLocationId, intCostingMethod, intAllowNegativeInventory, intConcurrencyId)
select I.intItemId, CL.intLocationId, 1 CostingMethod, 0 AllowNegative, 1 ConcurrencyId
--,I.strItemNo, I.intCommodityId
from  
(select I.intItemId, I.strItemNo, I.intCommodityId from tblICItem I
where I.strCostType = 'Freight') I
join 
(select distinct IL.intLocationId, I.intCommodityId
from tblICItemLocation IL
join tblICItem I on IL.intItemId = I.intItemId
where I.intCommodityId is not null) CL
on CL.intCommodityId = I.intCommodityId	
WHERE NOT EXISTS (select * from tblICItemLocation where intItemId = I.intItemId and intLocationId = CL.intLocationId)

----============================STEP xx==============================================
----find the look up values from i21 setup tables and update i21 commodity table
--has to be done after discount & storage schedules are imported
----Default Storage schedule
--update tblICCommodity set intScheduleStoreId = [intStorageScheduleTypeId]
--from 
--(select [intStorageScheduleTypeId] , gacom_com_cd
--from [tblGRStorageType] SSR 
--join gacommst cmst on strStorageTypeCode COLLATE SQL_Latin1_General_CP1_CS_AS = CAST(gacom_def_stor_schd_no AS VARCHAR(15)) COLLATE SQL_Latin1_General_CP1_CS_AS
--) as St
--where St.gacom_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = tblICCommodity.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS

----Default Discount Schedule
--update tblICCommodity set intScheduleDiscountId = intDiscountId
--from 
--(select intDiscountId , gacom_com_cd
--from [tblGRDiscountId] SSR 
--join gacommst cmst on strDiscountId COLLATE SQL_Latin1_General_CP1_CS_AS = CAST(gacom_def_disc_schd_no AS VARCHAR(15)) COLLATE SQL_Latin1_General_CP1_CS_AS
--) as St
--where St.gacom_com_cd COLLATE SQL_Latin1_General_CP1_CS_AS = tblICCommodity.strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS


GO

