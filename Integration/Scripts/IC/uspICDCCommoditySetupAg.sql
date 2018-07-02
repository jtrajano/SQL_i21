
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCCommoditySetupAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCCommoditySetupAg]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCCommoditySetupAg]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--==============================Step 1 =============================================
--Origin Ag does not have commodity
--Contracts need commodity. So create commodity .
INSERT INTO tblICCommodity(strCommodityCode,strDescription)
values
('Ag', 'Ag Contract')

----=====================================STEP 2=========================================
--find Gallons uoms from i21 
--Gallons has to be set as stock unit and unit qty has to be set to 1
--NOT ALL INSTALLS HAVE 'GALLON' AS THE TERM FOR GALLONS. SO CHANGE THE SCRIPT IN STEP 3 ACCORDINGLY

--select * from tblICUnitMeasure

----=====================================STEP 3=========================================
--update all items in origin contract with commodity code

update I set intCommodityId = (select intCommodityId from tblICCommodity where strCommodityCode = 'Ag')
from tblICItem I 
join agcntmst cnt on I.strItemNo collate Latin1_General_CI_AS = rtrim(cnt.agcnt_itm_or_cls) 

----=====================================STEP 4=========================================
--insert uoms into Commodity UOM for all items in the contract.

insert into tblICCommodityUnitMeasure 
(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
select distinct c.intCommodityId 'intCommodityId', u.intUnitMeasureId, 1 'dblUnitQty', 1 'ysnStockUnit', 1 'ysnDefault', 1 'intConcurrencyId' 
from tblICItem i
join tblICItemUOM iu on i.intItemId = iu.intItemId
join tblICUnitMeasure u on iu.intUnitMeasureId = u.intUnitMeasureId
join agcntmst cnt on i.strItemNo collate Latin1_General_CI_AS = rtrim(cnt.agcnt_itm_or_cls) 
join tblICCommodity c on i.intCommodityId = c.intCommodityId
where iu.ysnStockUnit = 1




GO
