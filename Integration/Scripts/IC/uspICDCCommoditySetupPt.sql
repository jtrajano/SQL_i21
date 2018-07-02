
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCommoditySetupPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCommoditySetupPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCommoditySetupPt]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--==============================Step 1 =============================================
--Origin Petro does not have commodity
--Contracts need commodity. So create commodity for classes used in origin contract.
INSERT INTO tblICCommodity(strCommodityCode,strDescription)
values
('Pt', 'Pt Contract')


----=====================================STEP 2=========================================
--find Gallons uoms from i21 
--Gallons has to be set as stock unit and unit qty has to be set to 1
--NOT ALL INSTALLS HAVE 'GALLON' AS THE TERM FOR GALLONS. SO CHANGE THE SCRIPT IN STEP 3 ACCORDINGLY

--select * from tblICUnitMeasure

----=====================================STEP 3=========================================
--update all items in origin contract with commodity code

update I set intCommodityId = (select intCommodityId from tblICCommodity where strCommodityCode = 'Pt')
from tblICItem I 
join ptcntmst cnt on I.strItemNo collate Latin1_General_CI_AS = rtrim(cnt.ptcnt_itm_or_cls) 


----=====================================STEP 4=========================================
--insert uoms into Commodity UOM for all items in the contract.

insert into tblICCommodityUnitMeasure 
(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
select distinct c.intCommodityId 'intCommodityId', u.intUnitMeasureId, 1 'dblUnitQty', 1 'ysnStockUnit', 1 'ysnDefault', 1 'intConcurrencyId' 
from tblICItem i
join tblICItemUOM iu on i.intItemId = iu.intItemId
join tblICUnitMeasure u on iu.intUnitMeasureId = u.intUnitMeasureId
join ptcntmst cnt on i.strItemNo collate Latin1_General_CI_AS = rtrim(cnt.ptcnt_itm_or_cls) 
join tblICCommodity c on i.intCommodityId = c.intCommodityId
where iu.ysnStockUnit = 1



------=====================================STEP 3=========================================
----insert uoms into Commodity UOM 

--insert into tblICCommodityUnitMeasure 
--(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
--select c.intCommodityId 'intCommodityId', iu.intUnitMeasureId, 1 'dblUnitQty', 1 'ysnStockUnit', 1 'ysnDefault', 1 'intConcurrencyId' 
--from tblICUnitMeasure iu
--cross join tblICCommodity c
--where strUnitMeasure = 'GALLON'

------=====================================STEP 4=========================================
----update all fuel items with commodity code

--update I set intCommodityId = CM.intCommodityId
--from tblICItem I join tblICCategory C on I.intCategoryId = C.intCategoryId
--join tblICCommodity CM on C.strCategoryCode = CM.strCommodityCode

GO