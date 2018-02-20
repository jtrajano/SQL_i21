IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCTImportContractPlanPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspCTImportContractPlanPt]; 
GO 

CREATE PROCEDURE [dbo].[uspCTImportContractPlanPt]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
--=====================================STEP 1 ================================================
--insert Contract Plans/Templates
--Commodity must be manually selected after the import
--verify category and item data

insert into tblCTContractPlan
(strContractPlan, strDescription, intContractTypeId, intCommodityId, intPricingTypeId,
dtmStartDate, dtmEndDate, intCategoryId, intItemId, dblPrice,ysnActive, intConcurrencyId)
select LTRIM(RtRIM(ptcpl_plan_no)), LTRIM(RtRIM(ptcpl_desc)), 2 'intContractTypeId',
(select intCommodityId from tblICCommodity where strCommodityCode = rtrim(ptcpl_itm_class) collate Latin1_General_CI_AS) 'intCommodityId',
6 'intPricingTypeId',
CONVERT(DATETIME, LEFT(ptcpl_start_date,8)) 'dtmStartDate', CONVERT(DATETIME, LEFT(ptcpl_end_date,8)) 'dtmEndDate',
null 'intCategoryId',
(select intItemId from tblICItem where strItemNo = rtrim(ptcpl_itm_class) collate Latin1_General_CI_AS) 'intItemId', ptcpl_price, 1 'ysnActive', 1 'intConcurrencyId'
from ptcplmst

GO
