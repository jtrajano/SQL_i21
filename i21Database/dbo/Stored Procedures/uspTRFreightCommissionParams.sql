create procedure uspTRFreightCommissionParams
@dtmDateFrom nvarchar(50),
@dtmDateTo nvarchar(50),
@dtmRealDateFrom DATE,
@dtmRealDateTo DATE,
@intDriverId INT,
@strDeliveryType nvarchar(100),
@intFreightItemId INT,
@intSurchargeItemId INT,
@intFreightCategoryId INT,
@dblFreightUnitCommissionPct INT,--@dblFreightUnitCommissionPct DECIMAL(18,6),
@dblOtherUnitCommissionPct INT--@dblOtherUnitCommissionPct DECIMAL(18,6)
  
as
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  


--DECLARE @dto DATETIME = CONVERT(NVARCHAR(255),CONVERT(SMALLDATETIME, @dtmDateTo,105))
--DECLARE @dfrom DATETIME = CONVERT(NVARCHAR(255),CONVERT(SMALLDATETIME, @dtmDateFrom,105))

--print @dto
--print @dfrom

select dtmFrom = @dtmDateFrom
,dtmTo = @dtmDateTo
,strDeliveryType
,intDriverId
,intFreightItemId = @intFreightItemId
,intSurchargeItemId = @intSurchargeItemId
,intFreightCategoryId = @intFreightCategoryId
,dblFreightUnitCommissionPct = @dblFreightUnitCommissionPct
,dblOtherUnitCommissionPct = @dblOtherUnitCommissionPct

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
,intInvoiceId
,strCompanyAddress 
,strCompanyName
,intLoadHeaderId
,intLoadDistributionHeaderId
,intLoadDistributionDetailId
,dblTotalBillUnit = NULL
,dblTotalCommision = NULL

from vyuTRGetFreightCommissionLine cl
where ((cl.intDriverId =  @intDriverId OR @intDriverId = 0) OR (RTRIM(LTRIM(ISNULL(cl.strReceiptLink, ''))) = '' AND cl.intItemCategoryId = @intFreightCategoryId))
and (cl.strDeliveryType = @strDeliveryType 
		OR @strDeliveryType = 'All' 
		OR cl.strDeliveryType = 'Other Charge')
AND (cl.dtmLoadDateTime >= @dtmRealDateFrom AND cl.dtmLoadDateTime <= @dtmRealDateTo)
order by cl.dtmLoadDateTime, cl.strMovement desc