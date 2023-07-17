create procedure uspTRFreightCommissionFreightParams  
@intItemId INT,  
@intInvoiceId INT,
@intFreightItemId INT,
@intSurchargeItemId INT,
@intFreightCategoryId INT,
@dblFreightUnitCommissionPct INT,--@dblFreightUnitCommissionPct DECIMAL(18,6),
@dblOtherUnitCommissionPct INT,--@dblOtherUnitCommissionPct DECIMAL(18,6),
@intLoadDistributionDetailId INT
--@dtmFrom NVARCHAR(50),
--@dtmTo NVARCHAR(50)
  
as

SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    


--DECLARE @dto DATETIME = CONVERT(NVARCHAR(255),CONVERT(SMALLDATETIME, @dtmTo,105))
--DECLARE @dfrom DATETIME = CONVERT(NVARCHAR(255),CONVERT(SMALLDATETIME, @dtmFrom,105))

select   
  intItemId  = @intItemId
, intTrueItemId = intItemId
, strItemDescription  = CASE 
							WHEN intItemId = @intFreightItemId THEN 'Unit Freight Charge'
							--WHEN intItemId = @intSurchargeItemId THEN 'Surcharge'
							ELSE strItemDescription END
, intInvoiceId  
, dblFreightRate  
, dblFreight = dblTotal
, dblCommissionPct = CASE WHEN intItemId = @intFreightItemId THEN @dblFreightUnitCommissionPct ELSE @dblOtherUnitCommissionPct END
, dblTotalCommission = CASE WHEN intItemId = @intFreightItemId THEN ((@dblFreightUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) ELSE ((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) END

  
from vyuTRGetFreightCommissionFreight fcf
where intInvoiceId = @intInvoiceId
	AND (
		(intItemId = @intFreightItemId AND intCategoryId = @intFreightCategoryId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)
		--OR (intItemId = @intSurchargeItemId AND intCategoryId = @intFreightCategoryId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)
		OR (intCategoryId = @intFreightCategoryId AND intItemId != @intItemId AND strBOLNumberDetail IS NULL AND intLoadDistributionDetailId = @intLoadDistributionDetailId)
		OR (intCategoryId = @intFreightCategoryId AND intItemId != @intItemId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)
	)