﻿
CREATE PROCEDURE uspTRFreightCommissionFreightParams    
@intItemId INT,    
@intInvoiceId INT,  
@intFreightItemId INT,  
@intSurchargeItemId INT,  
@intFreightCategoryId INT,  
@dblFreightUnitCommissionPct INT,
@dblOtherUnitCommissionPct INT,
@intLoadDistributionDetailId INT  
    
AS  
  
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS ON      
SET NOCOUNT ON      
SET XACT_ABORT ON      
SET ANSI_WARNINGS OFF      
 
 

 IF(@intInvoiceId > 0)
	 BEGIN
		 -- Distribution Detail with Invoice (Delivered to Customer)
		SELECT     
		  intItemId  = @intItemId  
		, intTrueItemId = intItemId  
		, strItemDescription  = CASE WHEN intItemId = @intFreightItemId THEN 'Unit Freight Charge' ELSE 'Surcharge' END  
		, intInvoiceId    
		, dblFreightRate    
		, dblFreight = dblTotal  
		, dblCommissionPct = CASE WHEN intItemId = @intFreightItemId THEN @dblFreightUnitCommissionPct ELSE @dblOtherUnitCommissionPct END  
		, dblTotalCommission = CASE WHEN intItemId = @intFreightItemId THEN ((@dblFreightUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) ELSE ((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * dblTotal) END  
		FROM vyuTRGetFreightCommissionFreight fcf  
		WHERE intInvoiceId = @intInvoiceId  
		 AND (  
		  (intItemId = @intFreightItemId AND intCategoryId = @intFreightCategoryId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)  
		  --OR (intItemId = @intSurchargeItemId AND intCategoryId = @intFreightCategoryId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)  
		  OR (intCategoryId = @intFreightCategoryId AND intItemId != @intItemId AND strBOLNumberDetail IS NULL AND intLoadDistributionDetailId = @intLoadDistributionDetailId)  
		  OR (intCategoryId = @intFreightCategoryId AND intItemId != @intItemId AND intLoadDistributionDetailId = @intLoadDistributionDetailId)  
		 )
		 AND @intInvoiceId IS NOT NULL

	 END
 ELSE
	BEGIN
	 ---- Distribution Detail without Invoice (Delivered to Location but has freight rate and surcharge)
		-- FOR LDD Freight
		SELECT     
		  intItemId  = @intItemId  
		, intTrueItemId = @intItemId  
		, strItemDescription  = 'Unit Freight Charge'
		, intInvoiceId = 0
		, dblFreightRate    
		, dblFreight = (dblFreightUnit * dblFreightRate)
		, dblCommissionPct = @dblFreightUnitCommissionPct
		, dblTotalCommission = ((@dblFreightUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * (dblFreightUnit * dblFreightRate))  
		FROM tblTRLoadDistributionDetail ldd
			left join tblICItem ii ON ii.intItemId = ldd.intItemId
		WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
			--AND @intInvoiceId IS NULL

		UNION ALL

		-- FOR LDD Surcharge
		SELECT     
		  intItemId  = @intItemId  
		, intTrueItemId = @intItemId  
		, strItemDescription  = 'Surcharge'
		, intInvoiceId = 0
		, dblFreightRate    
		, dblFreight = (dblFreightUnit * dblFreightRate) * dblDistSurcharge
		, dblCommissionPct = @dblOtherUnitCommissionPct  
		, dblTotalCommission =  ((@dblOtherUnitCommissionPct/CONVERT(DECIMAL(18,6),100)) * ((dblFreightUnit * dblFreightRate) * dblDistSurcharge))  
		FROM tblTRLoadDistributionDetail ldd
			left join tblICItem ii ON ii.intItemId = ldd.intItemId
		WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
			--AND @intInvoiceId IS NULL
	
	END


