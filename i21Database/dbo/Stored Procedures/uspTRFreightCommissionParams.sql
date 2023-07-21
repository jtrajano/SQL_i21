create procedure uspTRFreightCommissionParams  
@dtmDateFrom nvarchar(50),  
@dtmDateTo nvarchar(50),  
@dtmRealDateFrom DATE,  
@dtmRealDateTo DATE,  
@intDriverId INT,
@intShipViaId INT,
@strDeliveryType nvarchar(100),  
@intFreightItemId INT,  
@intSurchargeItemId INT,  
@intFreightCategoryId INT,  
@dblFreightUnitCommissionPct INT,
@dblOtherUnitCommissionPct INT
    
as  
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    
  
select dtmFrom = @dtmDateFrom  
,dtmTo = @dtmDateTo  
,dtmRealDateFrom = @dtmRealDateFrom  
,dtmRealDateTo = @dtmRealDateTo  
,strDeliveryType = @strDeliveryType
,intDriverId  
,intFreightItemId = @intFreightItemId  
,intSurchargeItemId = @intSurchargeItemId  
,intFreightCategoryId = @intFreightCategoryId  
,dblFreightUnitCommissionPct = @dblFreightUnitCommissionPct  
,dblOtherUnitCommissionPct = @dblOtherUnitCommissionPct  
,intShipViaId = @intShipViaId

,strDriverName  
,dtmLoadDateTime  
,strMovement  
,strVendor = ISNULL(strVendor, '')  
,strSupplyPoint = ISNULL(strSupplyPoint, '')  
,strCustomerNumber = ISNULL(strCustomerNumber, '')  
,strCustomerName = ISNULL(strCustomerName, '')  
,intItemId  
,strItemNo  
,intItemCategoryId  
,strItemCategory  
,strItemDescription  
,dblUnits  
,dblPrice  
,intInvoiceId = ISNULL(intInvoiceId, 0)
,strCompanyAddress   
,strCompanyName  
,intLoadHeaderId  
,intLoadDistributionHeaderId  
,intLoadDistributionDetailId  
  
from vyuTRGetFreightCommissionLine cl  
  
where ((cl.intDriverId =  @intDriverId OR @intDriverId = 0))  
and (cl.strDeliveryType = @strDeliveryType   
  OR @strDeliveryType = 'All'   
  OR cl.strDeliveryType = 'Other Charge'
  OR (RTRIM(LTRIM(ISNULL(cl.strReceiptLink, ''))) = '' AND cl.intItemCategoryId = @intFreightCategoryId))  
AND (cl.dtmLoadDateTime >= @dtmRealDateFrom AND cl.dtmLoadDateTime <= @dtmRealDateTo) 
AND (cl.intShipViaId = @intShipViaId OR @intShipViaId = 0)
order by cl.dtmLoadDateTime, cl.strMovement desc  