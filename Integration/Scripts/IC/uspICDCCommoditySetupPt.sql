
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
select distinct cl.ptcls_class, cl.ptcls_desc from ptitmmst it join ptclsmst cl on cl.ptcls_class = it.ptitm_class
join ptcntmst ct on it.ptitm_itm_no = ct.ptcnt_itm_or_cls
LEFT JOIN tblICCommodity ON  strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = cl.ptcls_class COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE intCommodityId IS NULL


----=====================================STEP 2=========================================
--find Gallons uoms from i21 
--Gallons has to be set as stock unit and unit qty has to be set to 1
--NOT ALL INSTALLS HAVE 'GALLON' AS THE TERM FOR GALLONS. SO CHANGE THE SCRIPT IN STEP 3 ACCORDINGLY

--select * from tblICUnitMeasure

----=====================================STEP 3=========================================
--insert uoms into Commodity UOM 

insert into tblICCommodityUnitMeasure 
(intCommodityId, intUnitMeasureId, dblUnitQty, ysnStockUnit, ysnDefault, intConcurrencyId)
select c.intCommodityId 'intCommodityId', iu.intUnitMeasureId, 1 'dblUnitQty', 1 'ysnStockUnit', 1 'ysnDefault', 1 'intConcurrencyId' 
from tblICUnitMeasure iu
cross join tblICCommodity c
where strUnitMeasure = 'GALLON' 
AND NOT EXISTS (SELECT * FROM tblICCommodityUnitMeasure WHERE intCommodityId = c.intCommodityId AND intUnitMeasureId = iu.intUnitMeasureId)

----=====================================STEP 4=========================================
--update all fuel items with commodity code

update I set intCommodityId = CM.intCommodityId
from tblICItem I join tblICCategory C on I.intCategoryId = C.intCategoryId
join tblICCommodity CM on C.strCategoryCode = CM.strCommodityCode