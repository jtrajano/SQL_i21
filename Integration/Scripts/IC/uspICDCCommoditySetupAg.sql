
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
--Origin AG Items does not have commodity
--Contracts need commodity. So create commodity for classes used in origin contract.
INSERT INTO tblICCommodity(strCommodityCode,strDescription)
SELECT DISTINCT ITM.agitm_no, ITM.agitm_desc FROM agitmmst ITM
		JOIN agcntmst CT ON ITM.agitm_no = CT.agcnt_itm_or_cls
		LEFT JOIN tblICCommodity ON  strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS = ITM.agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS
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
from tblICCommodity c 
join agitmmst I on agitm_no COLLATE SQL_Latin1_General_CP1_CS_AS = strCommodityCode COLLATE SQL_Latin1_General_CP1_CS_AS
join tblICUnitMeasure iu on strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS = upper(rtrim(agitm_un_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE NOT EXISTS (SELECT * FROM tblICCommodityUnitMeasure WHERE intCommodityId = c.intCommodityId AND intUnitMeasureId = iu.intUnitMeasureId)

----=====================================STEP 4=========================================
--update all AG items with commodity code
update I set intCommodityId = CM.intCommodityId
from tblICItem I join tblICCommodity CM on I.strItemNo = CM.strCommodityCode
